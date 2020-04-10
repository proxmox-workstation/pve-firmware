include /usr/share/dpkg/pkg-info.mk

FW_DEB=pve-firmware_${DEB_VERSION_UPSTREAM}_all.deb

GITVERSION:=$(shell git rev-parse HEAD)

export SOURCE_DATE_EPOCH ?= $(shell dpkg-parsechangelog -STimestamp)

DEBS=${FW_DEB}

.PHONY: deb
deb: ${DEBS}

${FW_DEB}: fwdata
	cp -a debian fwdata
	echo "git clone git://git.proxmox.com/git/pve-firmware.git\\ngit checkout ${GITVERSION}" >fwdata/debian/SOURCE
	cd fwdata; dpkg-buildpackage -b -us -uc

fwdata: linux-firmware.git/WHENCE dvb-firmware.git/README fwlist-*-pve
	rm -rf fwdata
	mkdir -p fwdata/lib/firmware
	./assemble-firmware.pl fwlist-5.4.30-1-pve fwdata/lib/firmware
	# include any files from older/newer kernels here
	./assemble-firmware.pl fwlist-5.4.27-1-pve fwdata/lib/firmware
	./assemble-firmware.pl fwlist-5.4.22-1-pve fwdata/lib/firmware
	./assemble-firmware.pl fwlist-5.3.18-1-pve fwdata/lib/firmware
	./assemble-firmware.pl fwlist-5.3.1-1-pve fwdata/lib/firmware
	./assemble-firmware.pl fwlist-5.0.21-4-pve fwdata/lib/firmware
	./assemble-firmware.pl fwlist-5.0.15-1-pve fwdata/lib/firmware
	./assemble-firmware.pl fwlist-5.0.8-1-pve fwdata/lib/firmware
	./assemble-firmware.pl fwlist-4.15-and-older fwdata/lib/firmware
	install -d fwdata/usr/share/doc/pve-firmware
	cp linux-firmware.git/WHENCE fwdata/usr/share/doc/pve-firmware/README
	install -d fwdata/usr/share/doc/pve-firmware/licenses
	cp linux-firmware.git/LICEN[CS]E* fwdata/usr/share/doc/pve-firmware/licenses

# upgrade to current master
.PHONY: update_modules
update_modules: submodule
	git submodule foreach 'git pull --ff-only origin master'

# make sure submodules were initialized
.PHONY: submodule
submodule dvb-firmware.git/README linux-firmware.git/WHENCE:
	test -f "linux-firmware.git/WHENCE" || git submodule update --init

.PHONY: upload
upload: ${DEBS}
	tar cf - ${DEBS} | ssh repoman@repo.proxmox.com -- upload --product pve,pmg --dist buster

.PHONY: clean
clean:
	rm -rf fwdata *.deb *.buildinfo *.dsc *.changes
