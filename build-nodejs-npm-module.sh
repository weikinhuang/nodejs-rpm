#!/bin/bash
set -e

if [[ "$1" == "--help" ]]; then
	echo "Usage: $0 module [version]"
	exit
fi

# do name & version testing
MODULE_NAME=${1}
VERSION=${2-}

if [[ -n $VERSION ]]; then
	VERSION="@${VERSION}"
fi

if [[ -z $MODULE_NAME ]]; then
	echo "missing module name"
fi

WORKDIR=$(mktemp -d)
LOCALDIR=$(pwd)
TEMP_DIR=$(mktemp -d)

function extract_json () {
	node -e 'try {process.stdout.write(JSON.parse(require("fs").readFileSync(process.argv[1], {encoding:"utf8"}))[process.argv[2]] || "");} catch (e) {}' "$1" "$2"
}

# clean build environment
rm -rf "$WORKDIR/*"

mkdir -p "$WORKDIR/BUILD" "$WORKDIR/BUILDROOT" "$WORKDIR/RPMS" "$WORKDIR/SOURCES" "$WORKDIR/SPECS" "$WORKDIR/SRPMS" "$WORKDIR/tmp" 2>/dev/null


# download files
mkdir "$TEMP_DIR/nodejs-$MODULE_NAME"
npm -g --production --prefix="$TEMP_DIR/nodejs-$MODULE_NAME" install "${MODULE_NAME}${VERSION}"
pushd "$TEMP_DIR"
tar -czvf "$WORKDIR/SOURCES/nodejs-$MODULE_NAME.tar.gz" .
popd
pushd "$TEMP_DIR/nodejs-$MODULE_NAME"
BIN_FILES="$(find ./bin/ | grep -v '^\./bin/$' | sed 's|^\./bin/|%attr(0755,root,root) %{_prefix}/bin/|' | tr '\n' ';')"
popd
cp "$TEMP_DIR/nodejs-$MODULE_NAME/lib/node_modules/$MODULE_NAME/package.json" "$WORKDIR/SOURCES/"
rm -rf "$TEMP_DIR"

cat "$LOCALDIR/SPECS/nodejs-module.spec" | \
	sed "s|%{x_bin_files}|$BIN_FILES|" | \
	tr ';' '\n' > "${WORKDIR}/SPECS/nodejs-${MODULE_NAME}.spec"
	
#vim "${WORKDIR}/SPECS/nodejs-${MODULE_NAME}.spec"


MODULE_HOMEPAGE="$(extract_json "$WORKDIR/SOURCES/package.json" homepage)"
if [[ -z $MODULE_HOMEPAGE ]]; then
	MODULE_HOMEPAGE="https://npmjs.org/package/${MODULE_NAME}"
fi

CMD_PREFIX=
if getent passwd makerpm >/dev/null; then
	chown -R makerpm:makerpm "$WORKDIR"
	CMD_PREFIX="sudo -u makerpm"
fi

# make rpm in a sandbox
$CMD_PREFIX \
	rpmbuild -ba \
	--define="_topdir ${WORKDIR}" \
	--define="_tmppath ${WORKDIR}/tmp" \
	--define="x_ver $(extract_json "$WORKDIR/SOURCES/package.json" version | sed 's/-//')" \
	--define="x_desc $(extract_json "$WORKDIR/SOURCES/package.json" description)" \
	--define="x_homepage ${MODULE_HOMEPAGE}" \
	--define="x_node_ver $(node --version | sed 's/^v//')" \
	--define="module_name ${MODULE_NAME}" \
	"${WORKDIR}/SPECS/nodejs-${MODULE_NAME}.spec"
	
find "${WORKDIR}" -iname '*.rpm' | grep "/RPMS/" | xargs -I {} mv -f {} "${LOCALDIR}/RPMS/"
find "${WORKDIR}" -iname '*.rpm' | grep "/SRPMS/" | xargs -I {} mv -f {} "${LOCALDIR}/SRPMS/"

rm -rf "${WORKDIR}"
