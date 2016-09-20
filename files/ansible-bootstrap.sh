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
  ANSIBLE_MODE=${1:-"push"}

  [ $DEBUG ] && echo "Will prepare machine for ansible '${ANSIBLE_MODE}' mode"

}

 installpkg() {

  local _pkgs=$@

  [ $DEBUG ] && echo "will install '${_pkgs}' package..."

  for pkg in "${_pkgs}"; do
    if [ -x "$(which ${pkg})" ]; then

      [ $DEBUG ] && echo "  $pkg already installed...skipping"
      echo

    else
      [ $DEBUG ] && echo " $pkg not installed...installing"

      # install ansible from ubuntu ppa
      if [ ${pkg} == 'ansible' ] && [ $(hostnamectl  | grep -o "Ubuntu")  == "Ubuntu" ]
      then
        sudo apt-get install software-properties-common
        sudo apt-add-repository ppa:ansible/ansible
        sudo apt-get update
        sudo apt-get install ansible
      else
        # install with package manager
        sudo $PKG_MANAGER install -y ${pkg}
      fi
    fi

    [ $DEBUG ] && echo "...all done"
  done
}

# echo $(basename $0)
if [ $(basename $0) = "ansible-bootstrap.sh" ]; then

  # see how we're called
  parse_args $@

  # guess package manager

  [ $DEBUG ] && echo "guessing OS package manager..."
  echo

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
  echo

  if [ "${ANSIBLE_MODE}" = "pull" ]; then
    installpkg ansible git
  else
    installpkg python
  fi

fi
