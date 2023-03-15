include /usr/share/dpkg/pkg-info.mk

FW_DEB=pve-firmware_$(DEB_VERSION)_all.deb

GITVERSION:=$(shell git rev-parse HEAD)

export SOURCE_DATE_EPOCH ?= $(shell dpkg-parsechangelog -STimestamp)

DEBS=$(FW_DEB)
BUILDDIR=fwdata

.PHONY: deb
deb: $(DEBS)

$(FW_DEB): $(BUILDDIR)
	cp -a debian $(BUILDDIR)
	echo "git clone git://git.proxmox.com/git/pve-firmware.git\\ngit checkout $(GITVERSION)" >$(BUILDDIR)/debian/SOURCE
	cd $(BUILDDIR); dpkg-buildpackage -b -us -uc

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
fw.list: fwlist-6.1.0-1-pve
fw.list: fwlist-6.1.10-1-pve
fw.list: fwlist-6.2.2-1-pve
fw.list: fwlist-6.2.6-1-pve
	rm -f $@.tmp $@
	sort -u $^ > $@.tmp
	mv $@.tmp $@

$(BUILDDIR): linux-firmware.git/WHENCE dvb-firmware.git/README fw.list
	rm -rf $(BUILDDIR) $(BUILDDIR).tmp
	mkdir -p $(BUILDDIR).tmp/lib/firmware
	cd linux-firmware.git; ./copy-firmware.sh -v ../$(BUILDDIR).tmp/lib/firmware/
	./assemble-firmware.pl fw.list $(BUILDDIR).tmp/lib/firmware
	find $(BUILDDIR).tmp/lib/firmware -empty -type d -delete
	install -d $(BUILDDIR).tmp/usr/share/doc/pve-firmware
	cp linux-firmware.git/WHENCE $(BUILDDIR).tmp/usr/share/doc/pve-firmware/README
	install -d $(BUILDDIR).tmp/usr/share/doc/pve-firmware/licenses
	cp linux-firmware.git/LICEN[CS]E* $(BUILDDIR).tmp/usr/share/doc/pve-firmware/licenses
	# we only compress big ones that almost definitively ain't required in the initrd
	# or are so big and unbuyable (netronome...)
	cd $(BUILDDIR).tmp/lib/firmware; find . -type f \( -name 'i[wb][lt]*' -o -path '*/netronome/*' \) -print0 | xargs -0 -n1 -P0 -- xz -C crc32
	cd $(BUILDDIR).tmp/lib/firmware; find . -xtype l -print0 | xargs -0 -n1 -P0 -- sh -c 'ln -sf "$$(readlink "$$0").xz" "$$0"; mv "$$0" "$$0.xz"'
	mv $(BUILDDIR).tmp $(BUILDDIR)

# upgrade to current master
.PHONY: update_modules
update_modules: submodule
	git submodule foreach 'git pull --ff-only origin master'

# make sure submodules were initialized
.PHONY: submodule
submodule dvb-firmware.git/README linux-firmware.git/WHENCE:
	test -f "linux-firmware.git/WHENCE" || git submodule update --init

.PHONY: upload
upload: $(DEBS)
	tar cf - $(DEBS) | ssh repoman@repo.proxmox.com -- upload --product pve,pmg,pbs --dist bullseye

.PHONY: clean
clean:
	rm -rf $(BUILDDIR) $(BUILDDIR).tmp fw.list *.deb *.buildinfo *.dsc *.changes
