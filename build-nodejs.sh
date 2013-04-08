#!/bin/bash -e

if [[ "$1" == "--help" ]]; then
	echo "Usage: $0 version arch"
	exit
fi

# do version testing
VERSION=${1-0.10.3}
BUILD_ARCH=${2-$(uname -m)}

case "$BUILD_ARCH" in
	x86_64)
		NODE_ARCH=x64
		;;
	*)
		NODE_ARCH=x86
		;;
esac

WORKDIR=$(mktemp -d)
LOCALDIR=$(pwd)

# download files
TAR_FILE="${LOCALDIR}/SOURCES/node-v${VERSION}-linux-${NODE_ARCH}.tar.gz"
if [[ ! -e "$TAR_FILE" ]]; then
	wget \
		-O "$TAR_FILE" \
		"http://nodejs.org/dist/v${VERSION}/node-v${VERSION}-linux-${NODE_ARCH}.tar.gz"
fi

cp -rp "${LOCALDIR}/SOURCES" $WORKDIR/
cp -rp "${LOCALDIR}/SPECS" $WORKDIR/

if [[ ! -d "${LOCALDIR}/RPMS/" ]]; then
	mkdir "${LOCALDIR}/RPMS/"
fi
if [[ ! -d "${LOCALDIR}/SRPMS/" ]]; then
	mkdir "${LOCALDIR}/SRPMS/"
fi

# clean build environment
rm -rf "$WORKDIR/BUILD"
rm -rf "$WORKDIR/BUILDROOT"
rm -rf "$WORKDIR/RPMS"
rm -rf "$WORKDIR/SRPMS"
rm -rf "$WORKDIR/tmp"

mkdir -p "$WORKDIR/BUILD" "$WORKDIR/BUILDROOT" "$WORKDIR/RPMS" "$WORKDIR/SRPMS" "$WORKDIR/tmp" 2>/dev/null

CMD_PREFIX=
if getent passwd makerpm >/dev/null; then
	chown -R makerpm:makerpm "$WORKDIR"
	CMD_PREFIX="sudo -u makerpm"
fi

# make rpm in a sandbox
$CMD_PREFIX \
	setarch $BUILD_ARCH \
	rpmbuild -ba \
	--define="_topdir ${WORKDIR}" \
	--define="_tmppath ${WORKDIR}/tmp" \
	--define="ver ${VERSION}" \
	--define="arch ${BUILD_ARCH}" \
	--define="node_arch ${NODE_ARCH}" \
	"${WORKDIR}/SPECS/nodejs.spec"

find "${WORKDIR}" -iname '*.rpm' | grep "/RPMS/" | xargs -I {} mv -f {} "${LOCALDIR}/RPMS/"
find "${WORKDIR}" -iname '*.rpm' | grep "/SRPMS/" | xargs -I {} mv -f {} "${LOCALDIR}/SRPMS/"

rm -rf "${WORKDIR}"