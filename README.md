# ansible-bootstrap

Shell module packaged in a role to bootsrap a machine for ansible.

## Requirements

### Ansible version

Minimum required ansible version is 1.2.


## Role Variables

### Variables conditionally loaded

None.

### Default vars

Defaults from `defaults/main.yml`.

```yaml
# By default, bootstrap a server to use ansible in 'push' mode.  Mode can
# either be (push|pull). See module in library/bootstrap for
# details.
ansible_mode: push

```


## Installation

### Install with Ansible Galaxy

```shell
ansible-galaxy install archf.bootstrap
```

Basic usage is:

```yaml
- hosts: all
  roles:
    - role: archf.bootstrap
```

### Install with git

If you do not want a global installation, clone it into your `roles_path`.

```shell
git clone git@github.com:archf/ansible-bootstrap.git /path/to/roles_path
```

But I often add it as a submdule in a given `playbook_dir` repository.

```shell
git submodule add git@github.com:archf/ansible-bootstrap.git <playbook_dir>/roles/bootstrap
```

As the role is not managed by Ansible Galaxy, you do not have to specify the
github user account.

Basic usage is:

```yaml
- hosts: all
  roles:
  - role: bootstrap
```

## Ansible role dependencies

None.

## Todo

  * test on other platforms
  * make it better

## License

BSD.

## Author Information

Felix Archambault.

## Role stack

This role was carefully selected to be part an ultimate deck of roles to manage
your infrastructure.

All roles' documentation is wrapped in this [convenient guide](http://127.0.0.1:8000/).


---
This README was generated using ansidoc. This tool is available on pypi!

```shell
pip3 install ansidoc

# validate by running a dry-run (will output result to stdout)
ansidoc --dry-run <rolepath>

# generate you role readme file
ansidoc <rolepath>
```

You can even use it programatically from sphinx. Check it out.