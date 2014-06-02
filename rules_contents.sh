#
# Template for a debian/rules file
#

RULES_CONTENT=$(cat <<__HERE__
#!/usr/bin/make -f
%:
	dh \$@
override_dh_auto_configure:
	./configure --prefix=${DEB_DIR}/openocd/usr --enable-jlink
override_dh_auto_build:
	make -j3
override_dh_auto_install:
	make install

__HERE__
)

