FW_VER=2.0
FW_REL=2
FW_DEB=pve-firmware_${FW_VER}-${FW_REL}_all.deb

GITVERSION:=$(shell cat .git/refs/heads/master)

export SOURCE_DATE_EPOCH ?= $(shell dpkg-parsechangelog -STimestamp)

DEBS=${FW_DEB}

${FW_DEB}: fwdata
	cp -a debian fwdata
	echo "git clone git://git.proxmox.com/git/pve-firmware.git\\ngit checkout ${GITVERSION}" >fwdata/debian/SOURCE
	cd fwdata; dpkg-buildpackage -b -us -uc

fwdata: linux-firmware.git/WHENCE dvb-firmware.git/README fwlist-2.6.18-2-pve fwlist-2.6.24-12-pve fwlist-2.6.32-3-pve fwlist-2.6.32-4-pve fwlist-2.6.32-6-pve fwlist-2.6.32-13-pve fwlist-2.6.32-14-pve fwlist-2.6.32-20-pve fwlist-2.6.32-21-pve fwlist-3.10.0-3-pve fwlist-3.10.0-7-pve fwlist-3.10.0-8-pve fwlist-3.19.8-1-pve fwlist-4.2.8-1-pve fwlist-4.4.13-2-pve fwlist-4.4.16-1-pve fwlist-4.4.21-1-pve fwlist-4.4.44-1-pve fwlist-4.10.5-1-pve
	rm -rf fwdata
	mkdir -p fwdata/lib/firmware
	./assemble-firmware.pl fwlist-4.10.5-1-pve fwdata/lib/firmware
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

# upgrade to current master
.PHONY: update_modules
update_modules: submodules
	git submodule foreach 'git pull --ff-only origin master'

# make sure submodules were initialized
.PHONY: submodules
submodules dvb-firmware.git/README linux-firmware.git/WHENCE:
	test -f "linux-firmware.git/WHENCE" || git submodule update --init

.PHONY: upload
upload: ${DEBS}
	tar cf - ${DEBS} | ssh repoman@repo.proxmox.com -- upload --product pve --dist stretch

.PHONY: clean
clean:
	rm -rf fwdata *.deb *.buildinfo *.dsc *.changes
