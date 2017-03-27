FW_VER=2.0
FW_REL=1
FW_DEB=pve-firmware_${FW_VER}-${FW_REL}_all.deb

GITVERSION:=$(shell cat .git/refs/heads/master)

DEBS=${FW_DEB}

${FW_DEB} fw: control.firmware linux-firmware.git/WHENCE dvb-firmware.git/README changelog.firmware fwlist-2.6.18-2-pve fwlist-2.6.24-12-pve fwlist-2.6.32-3-pve fwlist-2.6.32-4-pve fwlist-2.6.32-6-pve fwlist-2.6.32-13-pve fwlist-2.6.32-14-pve fwlist-2.6.32-20-pve fwlist-2.6.32-21-pve fwlist-3.10.0-3-pve fwlist-3.10.0-7-pve fwlist-3.10.0-8-pve fwlist-3.19.8-1-pve fwlist-4.2.8-1-pve fwlist-4.4.13-2-pve fwlist-4.4.16-1-pve fwlist-4.4.21-1-pve fwlist-4.4.44-1-pve fwlist-${KVNAME}
	rm -rf fwdata
	mkdir -p fwdata/lib/firmware
	./assemble-firmware.pl fwlist-${KVNAME} fwdata/lib/firmware
	# include any files from older/newer kernels here
	./assemble-firmware.pl fwlist-2.6.18-2-pve fwdata/lib/firmware
	./assemble-firmware.pl fwlist-2.6.24-12-pve fwdata/lib/firmware
	./assemble-firmware.pl fwlist-2.6.32-3-pve fwdata/lib/firmware
	./assemble-firmware.pl fwlist-2.6.32-4-pve fwdata/lib/firmware
	./assemble-firmware.pl fwlist-2.6.32-6-pve fwdata/lib/firmware
	./assemble-firmware.pl fwlist-2.6.32-13-pve fwdata/lib/firmware
	./assemble-firmware.pl fwlist-2.6.32-14-pve fwdata/lib/firmware
	./assemble-firmware.pl fwlist-2.6.32-20-pve fwdata/lib/firmware
	./assemble-firmware.pl fwlist-2.6.32-21-pve fwdata/lib/firmware
	./assemble-firmware.pl fwlist-3.10.0-3-pve fwdata/lib/firmware
	./assemble-firmware.pl fwlist-3.10.0-7-pve fwdata/lib/firmware
	./assemble-firmware.pl fwlist-3.10.0-8-pve fwdata/lib/firmware
	./assemble-firmware.pl fwlist-3.19.8-1-pve fwdata/lib/firmware
	./assemble-firmware.pl fwlist-4.2.8-1-pve fwdata/lib/firmware
	./assemble-firmware.pl fwlist-4.4.13-2-pve fwdata/lib/firmware
	./assemble-firmware.pl fwlist-4.4.16-1-pve fwdata/lib/firmware
	./assemble-firmware.pl fwlist-4.4.21-1-pve fwdata/lib/firmware
	./assemble-firmware.pl fwlist-4.4.44-1-pve fwdata/lib/firmware
	install -d fwdata/usr/share/doc/pve-firmware
	cp linux-firmware.git/WHENCE fwdata/usr/share/doc/pve-firmware/README
	install -d fwdata/usr/share/doc/pve-firmware/licenses
	cp linux-firmware.git/LICEN[CS]E* fwdata/usr/share/doc/pve-firmware/licenses
	install -D -m 0644 changelog.firmware fwdata/usr/share/doc/pve-firmware/changelog.Debian
	gzip -n -9 fwdata/usr/share/doc/pve-firmware/changelog.Debian
	echo "git clone git://git.proxmox.com/git/pve-firmware.git\\ngit checkout ${GITVERSION}" >fwdata/usr/share/doc/pve-firmware/SOURCE
	install -d fwdata/DEBIAN
	sed -e 's/@VERSION@/${FW_VER}-${FW_REL}/' <control.firmware >fwdata/DEBIAN/control
	dpkg-deb --build fwdata ${FW_DEB}
