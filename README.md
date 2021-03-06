nodejs-rpm
==========

RPM spec file for nodejs, and npm modules.

No compiling necessary, will create rpm files from the precompiled dist files.

* node.js rpm spec : https://github.com/weikinhuang/nodejs-rpm

## Building the nodejs RPM

Tested on:

* CentOS 6.3 x86_64

#### RHEL/CentOS/SL 6

```bash
    $ yum install rpm-build
    $ cd nodejs-rpm
    $ ./build-nodejs.sh [VERSION=0.10.3] [ARCH=$(uname -m)]
    $ # example: ./build-nodejs.sh 0.10.2
    $ # example: ./build-nodejs.sh 0.10.2 i386
```

Files will be placed into a RPMS directory

## Building npm module RPMS

Tested on:

* CentOS 6.3 x86_64

#### RHEL/CentOS/SL 6

```bash
    $ yum install rpm-build
    $ # (built from previous step or however you wish to install nodejs/npm)
    $ yum install nodejs nodejs-npm
    $ cd nodejs-rpm
    $ ./build-nodejs-npm-module.sh module [VERSION=1.2.18]
    $ # example: ./build-nodejs-npm-module.sh socket.io
    $ # example: ./build-nodejs-npm-module.sh socket.io 0.9.13
    $ # example: ./build-nodejs-npm-module.sh express
    $ # example: ./build-nodejs-npm-module.sh mysql 2.0.0-alpha7
```

Files will be placed into a RPMS directory
