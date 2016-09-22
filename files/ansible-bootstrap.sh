#!/bin/sh

usage() {

  echo "USAGE:"
  echo "  $(basename $0) OPTIONS <ansible-mode>"
  echo
  echo "OPTIONS:"
  echo "      -v verbose"
  echo "      -h show this help menu"
  echo
  echo "Where ansible-mode is either (pull|push)"
  echo
  echo "  The "push mode" is ansible's default mode. If specified, this script"
  echo "  will ensure that python 2 is available on target host. As such, this"
  echo "  is the default behavior of this utility"
  echo
  echo " The pull mode is the other way around. If specified, this script will"
  echo " ensure ansible and git is installed on target host."
  echo " see https://github.com/ansible/ansible-examples/blob/master/language_features/ansible_pull.yml"
  echo " for a playbook example."
  echo

}

parse_args() {

  while getopts "vh" opt
  do
    case $opt in
        v ) DEBUG=0 ;;
        h ) usage ;;
        * ) usage ;;
    esac
  done

  # Move argument pointer to next.
  shift $(($OPTIND - 1))
  ANSIBLE_MODE=${1}

  if [ -z ${ANSIBLE_MODE} ]; then
    [ $DEBUG ] && echo "No <ansible-mode provided>"
    [ $DEBUG ] && echo
    usage
    exit 1
  fi

  [ $DEBUG ] && echo "Will prepare machine for ansible '${ANSIBLE_MODE}' mode"

}

 installpkg() {

  local _pkgs=$@

  [ $DEBUG ] && echo "will install '${_pkgs}' package..."

  for pkg in "${_pkgs}"; do
    if [ -x "$(which ${pkg})" ]; then

      rc=2

      [ $DEBUG ] && echo "  $pkg already installed...skipping"
      [ $DEBUG ] && echo

    else
      [ $DEBUG ] && echo " $pkg not installed...installing"

      # install ansible from ubuntu ppa
      if [ ${pkg} = 'ansible' ] && [ $(hostnamectl  | grep -o "Ubuntu")  = "Ubuntu" ]
      then
        apt-get install software-properties-common
        apt-add-repository ppa:ansible/ansible
        apt-get update
        apt-get install ansible
      else
        # install with package manager
        $PKG_MANAGER update
        $PKG_MANAGER install -y ${pkg}
      fi

      rc=$?
    fi

    [ $DEBUG ] && echo "...all done"
  done
    return $rc

}

# echo $(basename $0)
if [ $(basename $0) = "ansible-bootstrap.sh" ]; then

  # see how we're called
  parse_args $@

  # guess package manager

  [ $DEBUG ] && echo "guessing OS package manager..."
  [ $DEBUG ] && echo

  # catch any debian or derivative machine
  if [ -x $(which apt-get) ]; then
    PKG_MANAGER=$(which apt-get)
  # catch any fedora or derivative machine
  elif [ -x $(which dnf) ]; then
    PKG_MANAGER=$(which dnf)
    # if dnf wasn't detected so far..., look for yum
    if [ -z ${PKG_MANAGER} ] && [ -x $(which yum) ]; then
      PKG_MANAGER=$(which yum)
    fi
  fi

  [ $DEBUG ] && echo "found $(basename ${PKG_MANAGER})!"
  [ $DEBUG ] && echo

  if [ "${ANSIBLE_MODE}" = "pull" ]; then
    installpkg ansible git
    rc=$?
  else
    # adjust python pkg name depending on OS
    if [ $(hostnamectl  | grep -o "Ubuntu")  = "Ubuntu" ]
    then
      installpkg python
      rc=$?
    else
      installpkg python2
      rc=$?
    fi
  fi

  case $rc in
    0)
      echo -n "changed=True msg=OK"
      exit 0
      ;;
    1)
      echo -n "changed=False msg=ansible bootstrap failed"
      exit 1
      ;;
    2)
      echo -n "changed=False msg=OK"
      exit 0
      ;;
  esac

fi
