#!/bin/sh

set -ex

if [ `id -u` != 0 ]; then
	echo "needs root!"
	exit 1
fi

RDISK_MPOINT="/mnt/resource"

RDISK=$(mount | grep ${RDISK_MPOINT} | cut -d ' ' -f 1)

if [ -z "${RDISK}" ]; then
	echo "no resource disk!"
	exit 1
fi

umount ${RDISK_MPOINT}

pkg install -y poudriere-devel

zpool create tank ${RDISK}
zfs create tank/ports
zfs create tank/distfiles

echo "ALLOW_MAKE_JOBS=yes" >> /usr/local/etc/poudriere.conf
echo "ZPOOL=tank" >> /usr/local/etc/poudriere.conf
sed -i.bak -e 's,FREEBSD_HOST=_PROTO_://_CHANGE_THIS_,FREEBSD_HOST=https://download.FreeBSD.org,' /usr/local/etc/poudriere.conf
sed -i.bak -e 's,DISTFILES_CACHE=/usr/ports/distfiles,DISTFILES_CACHE=/tank/distfiles,' /usr/local/etc/poudriere.conf

poudriere jail -c -j 13_0_amd64 -a amd64 -v 13.0-RELEASE
poudriere jail -c -j 13_0_i386 -a i386 -v 13.0-RELEASE
poudriere jail -c -j 12_2_amd64 -a amd64 -v 12.2-RELEASE
poudriere jail -c -j 12_2_i386 -a i386 -v 12.2-RELEASE

poudriere ports -c -f none -m null -M /tank/ports
