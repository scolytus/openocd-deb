#
# Template for a debian/control file
#

CONTROL_CONTENT=$(cat <<__HERE__
Source: ${PACKAGE}
Maintainer: ${FULLNAME} <${EMAIL}>
Section: misc
Priority: optional
Standards-Version: 3.9.2
Build-Depends: debhelper (>= 8), ${BUILD_DEPENDS}

Package: openocd
Architecture: any
Depends: ${DEPENDS}
Homepage: http://openocd.sourceforge.net
Description: OpenOCD Debugger
__HERE__
)

