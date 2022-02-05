#!/bin/sh

set -ex

PORTS=/tank/ports
USER=lwhsu
GROUP=lwhsu

sudo chown ${USER}:${GROUP} ${PORTS}

git clone -o freebsd https://git.freebsd.org/ports.git ${PORTS}
cd ${PORTS}
git remote set-url --push freebsd git@gitrepo.freebsd.org:ports.git

sudo pkg install -y \
	portfmt \
	portlint \
	py38-python-bugzilla
