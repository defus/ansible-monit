# ansible-monit

[![Build Status](https://travis-ci.org/defus/ansible-monit.svg?branch=master)](https://travis-ci.org/defus/ansible-monit) [![Ansible Galaxy](https://img.shields.io/badge/galaxy-DavidWittman.redis-blue.svg?style=flat)](https://galaxy.ansible.com/detail#/role/730)

 - Ansible 2.1+
   - Ansible 1.9.x is currently supported, but it will be deprecated soon
 - Compatible with most versions of RHEL/CentOS 7.x
 
## Contents

 1. [Installation](#installation)
 2. [Getting Started](#getting-started)
  1. [Single Monit node](#single-monit-node)
 3. [Advanced Options](#advanced-options)
  1. [Verifying checksums](#verifying-checksums)
  2. [Install from local tarball](#install-from-local-tarball)
  3. [Building 32-bit binaries](#building-32-bit-binaries)
 4. [Role Variables](#role-variables)

## Installation

``` bash
$ ansible-galaxy install defus.ansible-monit
```

## Getting started

Below are a few example playbooks and configurations for deploying a variety of Monit scenarios.

This role expects to be run as root or as a user with sudo privileges.

### Deploy as a service

Deploying Monit as a service is prety trival; just add the role to your playbook and go. Here's an example which we'll make a little more exciting by setting the bind address to 127.0.0.1:

``` yml
---
- hosts: monit01.example.com
  vars:
    - monit_bind: 127.0.0.1
  roles:
    - defus.ansible-monit
```

``` bash
$ ansible-playbook -i monit01.example.com, monit.yml
```

**Note:** You may have noticed above that I just passed a hostname in as the Ansible inventory file. This is an easy way to run Ansible without first having to create an inventory file, you just need to suffix the hostname with a comma so Ansible knows what to do with it.

That's it! You'll now have a Monit server listening on 127.0.0.1 on monit01.example.com. By default, the Monit binaries are installed under /opt/monit, though this can be overridden by setting the `monit_install_dir` variable.

## Advanced Options

### Verifying checksums

Set the `monit_verify_checksum` variable to true to use the checksum verification option for `get_url`. Note that this will only verify checksums when Monit is downloaded from a URL, not when one is provided in a tarball with `monit_tarball`. Due to differences in the `get_url` module in Ansible 1.x and Ansible 2.x, this feature behaves differently depending on the version of Ansible which you are using.

#### Ansible 1.x

In Ansible 1.x, the `get_url` module only supports verifying sha256 checksums, which are not provided by default. If you wish to set `monit_verify_checksum`, you must also define a sha256 checksum with the `monit_checksum` variable.

``` yaml
- name: install monit on ansible 1.x and verify checksums
  hosts: all
  roles:
    - role: defus.ansible-monit
      monit_version: 5.25.2
      monit_verify_checksum: true
      monit_checksum: 7be59369a9dda7c9b36234be91fc2c7e4f5b1943
```

#### Ansible 2.x

When using Ansible 2.x, this role will verify the sha1 checksum of the download against checksums defined in the `monit_checksums` variable in `vars/main.yml`. If your version is not defined in here or you wish to override the checksum with one of your own, simply set the `monit_checksum` variable. As in the example below, you will need to prefix the checksum with the type of hash which you are using.

``` yaml
- name: install monit on ansible 1.x and verify checksums
  hosts: all
  roles:
    - role: defus.ansible-monit
      monit_version: 5.25.2
      monit_verify_checksum: true
      monit_checksum: "sha256:7be59369a9dda7c9b36234be91fc2c7e4f5b1943"
```

### Install from local tarball

If the environment your server resides in does not allow downloads (i.e. if the machine is sitting in a dmz) set the variable `monit_tarball` to the path of a locally downloaded Monit tarball to use instead of downloading over HTTP from mmonit.com.

Do not forget to set the version variable to the same version of the tarball to avoid confusion! For example:

```yml
vars:
  monit_version: 5.25.2
  monit_tarball: /path/to/monit-5.25.2.tar.gz
```

In this case the source archive is copied to the server over SSH rather than downloaded.

### Building 32 bit binaries

To build 32-bit binaries of Monit (which can be used for [memory optimization](https://redis.io/topics/memory-optimization)), set `monit_make_32bit: true`. This installs the necessary dependencies (x86 glibc) on RHEL/Debian/SuSE and sets the option '32bit' when running make.

## Role Variables

Here is a list of all the default variables for this role, which are also available in defaults/main.yml. One of these days I'll format these into a table or something.

``` yml
---


monit_interval: 60
monit_start_delay: 30 # 0 to disable

monit_alerts_on: true
monit_alert_skip_when: "action, instance, pid, ppid"

monit_mail_host: smtp.gmail.com
monit_mail_port: 587
monit_mail_username: you
monit_mail_password: securepassword
monit_mail_encryption: TLSV1 # SSLAUTO, SSLV2, SSLV3, TLSV1, TLSV11, TLSV12
monit_mail_alert_to: me@mydomain.com
monit_mail_default_from: monit@mydomain.com
monit_mail_default_subject: "[Monit] $SERVICE $EVENT"
monit_mail_default_message: "Monit $ACTION $SERVICE at $DATE on $HOST: $DESCRIPTION."

monit_process_list:
  - process: "foo"
    pid_path: "/full/path/to/pid/file/foo.pid"
    start: "systemctl start foo"
    stop: "systemctl stop foo"
    timeout: 60

monit_filesystem_list:
  - filesystem: "datafs"
    path: "/dev/sdb1"
    start: "/bin/mount /data"
    stop: "/bin/unmount /data"
    permission: "660"
    uid: "root"
    gid: "disk"
    space_usage_alert: 80
    space_usage_stop: 99

monit_remote_host_list:
  - host: "myserver"
    ip: "127.0.0.1"
    ports:
      - port: 3306
        protocol: mysql
        timeout: 15
      - port: 8080
        protocol: http
        request: "/"
        content: "Monit runtime status"
      - port: 443
        protocol: https
        timeout: 15
        request: "/some/path"
        content: "a string"

## Installation options
monit_version: 5.25.2
monit_install_dir: /opt/monit
monit_event_dir: "{{ monit_install_dir}}/events"
## Logging '""' par defaut
monit_logfile: '/var/log/monit/monit.log'
monit_download_url: "https://mmonit.com/monit/dist/monit-{{ monit_version }}.tar.gz"
# Set this to true to validate monit tarball checksum against vars/main.yml
monit_verify_checksum: true
# Set this value to a local path of a tarball to use for installation instead of downloading
monit_tarball: false
# Set this to true to build 32-bit binaries of Monit
monit_make_32bit: false
monit_user: monit
monit_group: "{{ monit_user }}"
## Networking/connection options
monit_bind: 0.0.0.0
monit_port: 8080 #par défaut 2812

## Role options
# Configure monit as a service
# This creates the init scripts for Monit and ensures the process is running
monit_as_service: true
# Add local facts to /etc/ansible/facts.d for Monit
monit_local_facts: true
# Service name
monit_service_name: "monit"

monit_checksums:
  5.25.2: 7be59369a9dda7c9b36234be91fc2c7e4f5b1943


## Facts

The following facts are accessible in your inventory or tasks outside of this role.

- `{{ ansible_local.monit.bind }}`
- `{{ ansible_local.monit.port }}`

To disable these facts, set `monit_local_facts` to a false value.
