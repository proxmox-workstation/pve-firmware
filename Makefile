include /usr/share/dpkg/pkg-info.mk

FW_DEB=pve-firmware_${DEB_VERSION}_all.deb

GITVERSION:=$(shell git rev-parse HEAD)

export SOURCE_DATE_EPOCH ?= $(shell dpkg-parsechangelog -STimestamp)

DEBS=${FW_DEB}

.PHONY: deb
deb: ${DEBS}

${FW_DEB}: fwdata
	cp -a debian fwdata
	echo "git clone git://git.proxmox.com/git/pve-firmware.git\\ngit checkout ${GITVERSION}" >fwdata/debian/SOURCE
	cd fwdata; dpkg-buildpackage -b -us -uc

# NOTE: when collapsing FW lists keep major.minor still separated, so we can sunset the older ones
# without user impact safely. The last oldstable list needs to be kept avoid breakage on upgrade
.PHONY: fw.list
fw.list: fwlist-5.4.86-1-pve
fw.list: fwlist-5.11.x-y-pve
fw.list: fwlist-5.13.x-y-pve
fw.list: fwlist-5.15.5-1-pve
fw.list: fwlist-5.15.19-1-pve
fw.list: fwlist-5.15.27-1-pve
fw.list: fwlist-5.15.35-1-pve
fw.list: fwlist-5.15.53-1-pve
fw.list: fwlist-5.19.0-1-pve
fw.list: fwlist-5.19-iwlwifi-extra
	rm -f $@.tmp $@
	sort -u $^ > $@.tmp
	mv $@.tmp $@

# kernel can read compressed files since 5.3, use xz to reduces installed-size to 27 %
# maybe switch to zstd with next major release (kernel support since 5.19) for less resource usage?
# Use https://lore.kernel.org/all/20210123102625.589472-1-pbrobinson@gmail.com/ once v3/upstreamed
fwdata: linux-firmware.git/WHENCE dvb-firmware.git/README fw.list
	rm -rf fwdata fwdata.tmp
	mkdir -p fwdata.tmp/lib/firmware
	cd linux-firmware.git; ./copy-firmware.sh -v ../fwdata.tmp/lib/firmware/
	./assemble-firmware.pl fw.list fwdata.tmp/lib/firmware
	find fwdata.tmp/lib/firmware -empty -type d -delete
	install -d fwdata.tmp/usr/share/doc/pve-firmware
	cp linux-firmware.git/WHENCE fwdata.tmp/usr/share/doc/pve-firmware/README
	install -d fwdata.tmp/usr/share/doc/pve-firmware/licenses
	cp linux-firmware.git/LICEN[CS]E* fwdata.tmp/usr/share/doc/pve-firmware/licenses
	cd fwdata.tmp/lib/firmware; find . -type f -print0 | xargs -0 -n1 -P0 -- xz -C crc32
	cd fwdata.tmp/lib/firmware; find . -type l -print0 | xargs -0 -n1 -P0 -- sh -c 'ln -sf "$$(readlink "$$0").xz" "$$0"; mv "$$0" "$$0.xz"'
	mv fwdata.tmp fwdata

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
	tar cf - ${DEBS} | ssh repoman@repo.proxmox.com -- upload --product pve,pmg,pbs --dist bullseye

.PHONY: clean
clean:
	rm -rf fwdata fw.list *.deb *.buildinfo *.dsc *.changes
