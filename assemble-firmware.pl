#!/usr/bin/perl

use strict;
use warnings;

use File::Basename;
use File::Path;

my $fwsrc0 = "linux-2.6-3.10.0/firmware";
my $fwsrc1 = "linux-firmware.git";
my $fwsrc2 = "dvb-firmware.git";
my $fwsrc3 = "firmware-misc";

my $fwlist = shift;
die "no firmware list specified" if !$fwlist || ! -f $fwlist;

my $target = shift;
die "no target directory" if !$target || ! -d $target;

my $force_skip = {

    # not needed, the HBA has burned-in firmware
    'ql2600_fw.bin' => 1,
    'ql2700_fw.bin' => 1,
    'ql8100_fw.bin' => 1,
    'ql8300_fw.bin' => 1,
};

my $skip = {};
# debian squeeze also misses those files
foreach my $fw (qw(
3826.arm
BT3CPCC.bin
FW10
FW13
RTL8192U/boot.img
RTL8192U/data.img
RTL8192U/main.img
amdgpu/arcturus_asd.bin
amdgpu/arcturus_gpu_info.bin
amdgpu/arcturus_mec.bin
amdgpu/arcturus_mec2.bin
amdgpu/arcturus_rlc.bin
amdgpu/arcturus_sdma.bin
amdgpu/arcturus_smc.bin
amdgpu/arcturus_sos.bin
amdgpu/arcturus_vcn.bin
amdgpu/navi10_mes.bin
amdgpu/navi12_asd.bin
amdgpu/navi12_ce.bin
amdgpu/navi12_gpu_info.bin
amdgpu/navi12_me.bin
amdgpu/navi12_mec.bin
amdgpu/navi12_mec2.bin
amdgpu/navi12_pfp.bin
amdgpu/navi12_rlc.bin
amdgpu/navi12_sdma.bin
amdgpu/navi12_sdma1.bin
amdgpu/navi12_smc.bin
amdgpu/navi12_sos.bin
amdgpu/navi12_vcn.bin
amdgpu/vega20_ta.bin
ar9170.fw
ast_dp501_fw.bin
ath10k/QCA6174/hw2.1/firmware-4.bin
ath10k/QCA6174/hw3.0/firmware-5.bin
ath10k/QCA9887/hw1.0/board-2.bin
ath10k/QCA988X/hw2.0/board-2.bin
ath10k/QCA988X/hw2.0/firmware-2.bin
ath10k/QCA988X/hw2.0/firmware-3.bin
ath10k/QCA988X/hw2.0/firmware.bin
ath6k/AR6003/hw2.0/bdata.bin
ath6k/AR6003/hw2.1.1/bdata.bin
ath6k/AR6004/hw1.0/bdata.DB132.bin
ath6k/AR6004/hw1.0/bdata.bin
ath6k/AR6004/hw1.0/fw.ram.bin
ath6k/AR6004/hw1.1/bdata.DB132.bin
ath6k/AR6004/hw1.1/bdata.bin
ath6k/AR6004/hw1.1/fw.ram.bin
ath6k/AR6004/hw1.2/fw.ram.bin
ath6k/AR6004/hw1.3/fw.ram.bin
b43/ucode11.fw
b43/ucode13.fw
b43/ucode14.fw
b43/ucode15.fw
b43/ucode16_lp.fw
b43/ucode16_mimo.fw
b43/ucode24_lcn.fw
b43/ucode25_lcn.fw
b43/ucode25_mimo.fw
b43/ucode26_mimo.fw
b43/ucode29_mimo.fw
b43/ucode30_mimo.fw
b43/ucode33_lcn40.fw
b43/ucode40.fw
b43/ucode42.fw
b43/ucode5.fw
b43/ucode9.fw
b43legacy/ucode2.fw
b43legacy/ucode4.fw
bfubase.frm
brcm/brcmfmac-sdio.bin
brcm/brcmfmac-sdio.txt
brcm/brcmfmac43012-sdio.bin
brcm/brcmfmac43143-sdio.txt
brcm/brcmfmac43241b0-sdio.txt
brcm/brcmfmac43241b4-sdio.txt
brcm/brcmfmac43241b5-sdio.txt
brcm/brcmfmac4329-sdio.txt
brcm/brcmfmac4330-sdio.txt
brcm/brcmfmac4334-sdio.txt
brcm/brcmfmac43340-sdio.txt
brcm/brcmfmac4335-sdio.txt
brcm/brcmfmac43362-sdio.txt
brcm/brcmfmac4339-sdio.txt
brcm/brcmfmac43430-sdio.txt
brcm/brcmfmac43455-sdio.txt
brcm/brcmfmac43456-sdio.bin
brcm/brcmfmac4350-pcie.txt
brcm/brcmfmac4354-pcie.bin
brcm/brcmfmac4354-pcie.txt
brcm/brcmfmac4354-sdio.txt
brcm/brcmfmac4356-pcie.txt
brcm/brcmfmac43570-pcie.txt
brcm/brcmfmac4358-pcie.txt
brcm/brcmfmac4359-pcie.bin
brcm/brcmfmac43602-pcie.txt
brcm/brcmfmac4365b-pcie.bin
brcm/brcmfmac4365b-pcie.txt
brcm/brcmfmac4365c-pcie.bin
brcm/brcmfmac4366b-pcie.txt
brcm/brcmfmac4371-pcie.txt
c218tunx.cod
c320tunx.cod
cbfw-3.0.3.1.bin
cbfw.bin
comedi/jr3pci.idm
cp204unx.cod
ct2fw-3.0.3.1.bin
ct2fw.bin
ctfw-3.0.3.1.bin
ctfw.bin
cxgb4/t4fw-1.3.10.0.bin
cxgb4/t4fw.bin
cxgb4/t5fw.bin
cxgb4/t6fw.bin
cyzfirm.bin
daqboard2000_firmware.bin
fw.ram.bin
i1480-phy-0.0.bin
i1480-pre-phy-0.0.bin
i1480-usb-0.0.bin
i2400m-fw-sdio-1.3.sbcf
intel/ice/ddp/ice.pkg
isi4608.bin
isi4616.bin
isi608.bin
isi608em.bin
isi616em.bin
isight.fw
isl3886pci
isl3886usb
isl3887usb
iwlwifi-100-6.ucode
iwlwifi-1000-6.ucode
iwlwifi-130-5.ucode
iwlwifi-3165-10.ucode
iwlwifi-3168-26.ucode
iwlwifi-6000-6.ucode
iwlwifi-6000g2b-IWL6000G2B_UCODE_API_MAX.ucode
iwlwifi-7265D-26.ucode
iwlwifi-8000-10.ucode
iwlwifi-8000-12.ucode
iwlwifi-8000-13.ucode
iwlwifi-8000-8.ucode
iwlwifi-8000C-26.ucode
iwlwifi-8000C-33.ucode
iwlwifi-8265-26.ucode
iwlwifi-8265-33.ucode
iwlwifi-9000-pu-a0-jf-a0--26.ucode
iwlwifi-9000-pu-a0-jf-a0--33.ucode
iwlwifi-9000-pu-a0-jf-a0-34.ucode
iwlwifi-9000-pu-a0-jf-a0-43.ucode
iwlwifi-9000-pu-a0-jf-b0--33.ucode
iwlwifi-9000-pu-a0-jf-b0-34.ucode
iwlwifi-9000-pu-a0-jf-b0-43.ucode
iwlwifi-9000-pu-a0-lc-a0--26.ucode
iwlwifi-9260-th-a0-jf-a0--26.ucode
iwlwifi-9260-th-a0-jf-a0--33.ucode
iwlwifi-9260-th-a0-jf-a0-34.ucode
iwlwifi-9260-th-a0-jf-a0-43.ucode
iwlwifi-9260-th-b0-jf-b0--33.ucode
iwlwifi-Qu-a0-hr-a0--33.ucode
iwlwifi-Qu-a0-hr-a0-34.ucode
iwlwifi-Qu-a0-hr-a0-43.ucode
iwlwifi-Qu-a0-hr-a0-48.ucode
iwlwifi-Qu-a0-hr-a0-50.ucode
iwlwifi-Qu-a0-jf-b0--26.ucode
iwlwifi-Qu-a0-jf-b0--33.ucode
iwlwifi-Qu-a0-jf-b0-34.ucode
iwlwifi-Qu-a0-jf-b0-43.ucode
iwlwifi-Qu-a0-jf-b0-48.ucode
iwlwifi-Qu-a0-jf-b0-50.ucode
iwlwifi-Qu-b0-hr-b0-43.ucode
iwlwifi-Qu-b0-jf-b0-43.ucode
iwlwifi-Qu-b0-jf-b0-50.ucode
iwlwifi-Qu-c0-hr-b0-50.ucode
iwlwifi-QuQnj-a0-hr-a0-34.ucode
iwlwifi-QuQnj-a0-hr-a0-43.ucode
iwlwifi-QuQnj-a0-hr-a0-48.ucode
iwlwifi-QuQnj-a0-hr-a0-50.ucode
iwlwifi-QuQnj-a0-jf-b0-34.ucode
iwlwifi-QuQnj-a0-jf-b0-43.ucode
iwlwifi-QuQnj-b0-hr-b0-43.ucode
iwlwifi-QuQnj-b0-hr-b0-48.ucode
iwlwifi-QuQnj-b0-hr-b0-50.ucode
iwlwifi-QuQnj-b0-jf-b0-48.ucode
iwlwifi-QuQnj-b0-jf-b0-50.ucode
iwlwifi-QuQnj-f0-hr-a0-34.ucode
iwlwifi-QuQnj-f0-hr-a0-43.ucode
iwlwifi-QuQnj-f0-hr-a0-48.ucode
iwlwifi-QuQnj-f0-hr-a0-50.ucode
iwlwifi-QuZ-a0-hr-b0-50.ucode
iwlwifi-QuZ-a0-jf-b0-50.ucode
iwlwifi-cc-a0-50.ucode
iwlwifi-so-a0-gf-a0-48.ucode
iwlwifi-so-a0-gf-a0-50.ucode
iwlwifi-so-a0-hr-b0-48.ucode
iwlwifi-so-a0-hr-b0-50.ucode
iwlwifi-so-a0-jf-b0-48.ucode
iwlwifi-so-a0-jf-b0-50.ucode
iwlwifi-su-z0-43.ucode
iwlwifi-ty-a0-gf-a0-48.ucode
iwlwifi-ty-a0-gf-a0-50.ucode
iwmc3200wifi-calib-sdio.bin
iwmc3200wifi-lmac-sdio.bin
iwmc3200wifi-umac-sdio.bin
ks7010sd.rom
lantiq/xrx200_phy11g_a14.bin
lantiq/xrx200_phy11g_a22.bin
lantiq/xrx200_phy22f_a14.bin
lantiq/xrx200_phy22f_a22.bin
lantiq/xrx300_phy11g_a21.bin
lantiq/xrx300_phy22f_a21.bin
lattice-ecp3.bit
libertas/cf8305.bin
libertas/gspi8385.bin
libertas/gspi8385_helper.bin
libertas/gspi8385_hlp.bin
libertas/sd8688.bin
libertas/sd8688_helper.bin
libertas/usb8388.bin
libertas_cs.fw
libertas_cs_helper.fw
liquidio/lio_210nv.bin
liquidio/lio_210sv.bin
liquidio/lio_23xx.bin
liquidio/lio_410nv.bin
me2600_firmware.bin
me4000_firmware.bin
mediatek/mt7663pr2h.bin
mrvl/pcie8766_uapsta.bin
mrvl/pcie8997_uapsta.bin
mrvl/sd8786_uapsta.bin
mrvl/sd8977_uapsta.bin
mrvl/sd8987_uapsta.bin
mrvl/sd8997_uapsta.bin
mrvl/usb8997_uapsta.bin
mt7603_e1.bin
mt7603_e2.bin
mt7628_e1.bin
mt7628_e2.bin
mwl8k/fmimage_8363.fw
mwl8k/helper_8363.fw
netronome/nic_AMDA0058-0011_2x40.nffw
netronome/nic_AMDA0058-0012_2x40.nffw
netronome/nic_AMDA0081-0001_1x40.nffw
netronome/nic_AMDA0081-0001_4x10.nffw
netronome/nic_AMDA0096-0001_2x10.nffw
netronome/nic_AMDA0097-0001_2x40.nffw
netronome/nic_AMDA0097-0001_4x10_1x40.nffw
netronome/nic_AMDA0097-0001_8x10.nffw
netronome/nic_AMDA0099-0001_1x10_1x25.nffw
netronome/nic_AMDA0099-0001_2x10.nffw
netronome/nic_AMDA0099-0001_2x25.nffw
ni6534a.bin
niscrb01.bin
niscrb02.bin
nx3fwct.bin
nx3fwmn.bin
nxromimg.bin
orinoco_ezusb_fw
pca200e_ecd.bin2
phanfw-4.0.579.bin
prism2_ru.fw
prism_ap_fw.bin
prism_sta_fw.bin
rt3070.bin
rt3090.bin
rtl_bt/rtl8723b_config.bin
rtl_bt/rtl8723bs_config.bin
rtl_bt/rtl8723ds_config.bin
rtl_bt/rtl8723ds_fw.bin
rtl_bt/rtl8761a_config.bin
rtl_bt/rtl8821a_config.bin
rtlwifi/rtl8723bu_bt.bin
rtlwifi/rtl8723efw.bin
s5k4ecgx.bin
sd8686.bin
sd8686_helper.bin
softing-4.6/bcard.bin
softing-4.6/bcard2.bin
softing-4.6/cancard.bin
softing-4.6/cancrd2.bin
softing-4.6/cansja.bin
softing-4.6/ldcard.bin
softing-4.6/ldcard2.bin
solos-FPGA.bin
solos-Firmware.bin
solos-db-FPGA.bin
symbol_sp24t_prim_fw
symbol_sp24t_sec_fw
tehuti/firmware.bin
ti-connectivity/wl1271-nvs.bin
ti-connectivity/wl18xx-conf.bin
tms380tr.bin
usb8388.bin
wd719x-risc.bin
wd719x-wcs.bin
wil6210_sparrow_plus.fw
wil6436.brd
wil6436.fw
wlan/prima/WCNSS_qcom_wlan_nv.bin
zd1201-ap.fw
zd1201.fw
)) {
    $skip->{$fw} = 1;
}

sub copy_fw {
    my ($src, $dstfw) = @_;

    my $dest = "$target/$dstfw";

    return if -f $dest;

    mkpath dirname($dest);
    system ("cp '$src' '$dest'") == 0 || die "copy $src to $dest failed";
}

my $fwdone = {};

my $error = 0;

open(TMP, $fwlist);
while(defined(my $line = <TMP>)) {
    chomp $line;
    my ($fw, $mod) = split(/\s+/, $line, 2);

    next if $mod =~ m|^kernel/sound|;
    next if $mod =~ m|^kernel/drivers/isdn|;

    # skip ZyDas usb wireless, use package zd1211-firmware instead
    next if $fw =~ m|^zd1211/|; 

    # skip atmel at76c50x wireless networking chips.
    # use package atmel-firmware instead
    next if $fw =~ m|^atmel_at76c50|;

    # skip Bluetooth dongles based on the Broadcom BCM203x 
    # use package bluez-firmware instead
    next if $fw =~ m|^BCM2033|;

    next if $fw =~ m|^xc3028-v27\.fw|; # found twice!
    next if $fw =~ m|.inp|; # where are those files?
    next if $fw =~ m|^ueagle-atm/|; # where are those files?

    next if $force_skip->{$fw};

    next if $fwdone->{$fw};
    $fwdone->{$fw} = 1;

    my $fwdest = $fw;
    if ($fw eq 'libertas/gspi8686.bin') {
	$fw = 'libertas/gspi8686_v9.bin';
    }
    if ($fw eq 'libertas/gspi8686_hlp.bin') {
	$fw = 'libertas/gspi8686_v9_helper.bin';
    }

    if ($fw eq 'PE520.cis') {
	$fw = 'cis/PE520.cis';
    }
 
    # the rtl_nic/rtl8168d-1.fw file is buggy in current kernel tree
    if (-f "$fwsrc0/$fw" && 
	($fw ne 'rtl_nic/rtl8168d-1.fw')) { 
	copy_fw("$fwsrc0/$fw", $fwdest);
	next;
    }
    if (-f "$fwsrc1/$fw") {
	copy_fw("$fwsrc1/$fw", $fwdest);
	next;
    }
    if (-f "$fwsrc3/$fw") {
	copy_fw("$fwsrc3/$fw", $fwdest);
	next;
    }

    if ($fw =~ m|/|) {
	next if $skip->{$fw};

	warn "unable to find firmware: $fw $mod\n";
	$error++;
	next;
    }

    my $name = basename($fw);

    my $sr = `find '$fwsrc1' -type f -name '$name'`;
    chomp $sr;
    if ($sr) {
	print "found $fw in $sr\n";
	copy_fw($sr, $fwdest);
	next;
    }

    $sr = `find '$fwsrc2' -type f -name '$name'`;
    chomp $sr;
    if ($sr) {
	print "found $fw in $sr\n";
	copy_fw($sr, $fwdest);
	next;
    }

    $sr = `find '$fwsrc3' -type f -name '$name'`;
    chomp $sr;
    if ($sr) {
	print "found $fw in $sr\n";
	copy_fw($sr, $fwdest);
	next;
    }

    next if $skip->{$fw};
    next if $fw =~ m|^dvb-|;

    warn "unable to find firmware: $fw $mod\n";
    $error++;
    next;
}
close(TMP);

exit($error);
