#!/bin/bash

#
# initialize directory and files
#
# (C) 2014 Michael Gissing
#

set -e
set -x

LOG="init.log"

# ------------------------------------------------------------------------------
fail() {
  echo "[ERROR][$(timestamp)] ${1}" | tee -a "${LOG}"
  exit 255
}

info() {
  echo "[INFO ][$(timestamp)] ${1}" | tee -a "${LOG}"
}

timestamp() {
  echo $(date +%Y%m%d-%H%M%S)
}

# ------------------------------------------------------------------------------
SD="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
WD=$(pwd)

LOG="${WD}/${LOG}"
rm "${LOG}" || true

RECIPE_DEFAULT="${SD}/default.recipe"
[ -f "${RECIPE_DEFAULT}" ] || fail "can not load default settings"
. "${RECIPE_DEFAULT}"

# ------------------------------------------------------------------------------
BASE_DIR="${WD}/${NAME}"
[ -d "${BASE_DIR}" ] || mkdir "${BASE_DIR}" || fail "cannot use/create base directory"
pushd "${BASE_DIR}" &> /dev/null

SRC_DIR="${BASE_DIR}/${DIRNAME}"
SRC_FILE="${BASE_DIR}/${FILENAME}"

if [ ! -d "${SRC_DIR}" ]; then
    if [ ! -f "${SRC_FILE}" ]; then
        info "downloading source file ${FILENAME}"
        wget "${URL}" -O "${SRC_FILE}" &>> "${LOG}"
    fi

    info "extracting ${FILENAME}"
    tar xvzf "${SRC_FILE}" &>> "${LOG}"
fi
pushd "${SRC_DIR}" &> /dev/null

DEB_DIR="${SRC_DIR}/debian"
rm -rf "${DEB_DIR}"
mkdir "${DEB_DIR}"

info "create debian/changelog"
# which dch &> /dev/null || fail "can not find dch - is package 'devscripts' installed?"
export DEBFULLNAME="${FULLNAME}"
export DEBEMAIL="${EMAIL}"
dch --create -v $DEBVERSION --package ${PACKAGE} "release ${DEBVERSION}" &>> "${LOG}"

info "create debian/compat"
echo "8" > "${DEB_DIR}/compat"

info "create debian/copyright"
cp "${SRC_DIR}/COPYING" "${DEB_DIR}/copyright"

info "create debian/rules"
. "${SD}/rules_contents.sh"
echo "${RULES_CONTENT}" > "${DEB_DIR}/rules"

info "create debian/control"
. "${SD}/control_contents.sh"
echo "${CONTROL_CONTENT}" > "${DEB_DIR}/control"

echo "DONE"

