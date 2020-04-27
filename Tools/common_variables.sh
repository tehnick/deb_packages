#!/bin/bash
#
# Common variables

export DEBEMAIL="Boris Pek <tehnick@debian.org>"
export UPDATE_STRING="New upstream release."

[ -z "${PKG_DIR}" ] && export PKG_DIR="${MAIN_DIR}/Debian/${PACKAGE}"

export TEMP_DIR="${PKG_DIR}/TEMP"
export TEST_DIR="${TEMP_DIR}/TEST"

cd "${PKG_DIR}/${PACKAGE}-debian" || exit 1

mkdir -p "${TEMP_DIR}"
cd "${TEMP_DIR}" || exit 1

[ -z "${A_TYPE}" ] && export A_TYPE="bz2"

echo "" > /dev/null

