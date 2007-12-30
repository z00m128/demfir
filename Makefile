SOURCE=demfir.a80
BOOT=demfirboot
EMPTYS=em_color.scr em_mono.scr em_48k.z80 em_128k.z80
FWDIR=firmwares
FIRMWARES=$(FWDIR)/*.bin $(FWDIR)/*.dfw
INCLUDES=config.a80 $(BOOT).a80 basic.tpi logo.pck logof6.pck logof6_2.pck spectrum.font didaktik.font
VERSION_LONG=$(shell grep "^DVERS" $(SOURCE)|cut -d \" -f 2)
VERSION=$(shell echo $(VERSION_LONG)|tr -d .)
BASE=$(SOURCE:%.a80=%$(VERSION))
COMPILE=$(BASE).tap
IMAGE0=$(BASE)_E.bin
IMAGE1=$(BASE)_R.bin
FILES=$(COMPILE) $(IMAGE0) $(IMAGE1) $(EMPTYS)# devast_ide.tap
DOCS=AUTHORS BUGS* ChangeLog* INSTALL* LICENSE Makefile README* TODO*
DISTR_DIR=$(SOURCE:%.a80=%-$(VERSION_LONG))
DEST=../..

all: $(BASE).iso

$(BASE).hdf: $(BASE).iso
	raw2hdf $(BASE).iso $(BASE).hdf

eltorito: $(BOOT).img
	mkisofs -U -V "DEMFIR $(VERSION_LONG) INSTALL" -b $(BOOT).img -c boot.catalog -hide $(BOOT).img -hide boot.catalog -o $(BASE).iso $(BOOT).img $(FILES)

$(BASE).iso: $(FILES) $(FIRMWARES)
	mkisofs -U -V "DEMFIR $(VERSION_LONG) INSTALL" -G $(IMAGE1) -o $(BASE).iso -m CVS -m .cvsignore -graft-points $(FWDIR)/=$(FWDIR)/ $(FILES)

$(BOOT).img: $(FILES) $(BOOT).a80 Makefile
	ln -sf $(IMAGE1) demfir_R.bin
	asl $(BOOT).a80 -o $(BOOT).p -L -u
	@echo
	p2bin $(BOOT).p $(BOOT).img -r 0-1474559 -l 0
#	p2bin $(BOOT).p $(BOOT).img -r 0-511 -l 0

$(COMPILE): $(SOURCE) $(INCLUDES) Makefile
	asl $(SOURCE) -o $(BASE).p -L -u
	@echo
	p2bin $(BASE).p $(IMAGE0) -r 0-8191 -l 0
	@echo
	p2bin $(BASE).p $(IMAGE1) -r 8192-16383 -l 0
	@echo
	bin2tap -o $(BASE).pat -a 24576 $(IMAGE0)
	@echo
	cat basic.tpi $(BASE).pat > $(COMPILE)
	@echo
	echo '.cvsignore *.bin demfir*.tap *.p *.err *.lst *.pat *.iso part1 $(BOOT).img $(EMPTYS)' >.cvsignore
	@echo

em_mono.scr:
	dd if=/dev/zero of=em_mono.scr bs=6144 count=1

em_color.scr:
	dd if=/dev/zero of=em_color.scr bs=6912 count=1

em_48k.z80:
	dd if=/dev/zero of=em_48k.z80 bs=49216 count=1

em_128k.z80:
	dd if=/dev/zero of=em_128k.z80 bs=131151 count=1

clean:
	rm -f *.bin demfir*.tap *.p *.err *.lst *.pat *.iso *.hdf part1 .cvsignore $(BOOT).img $(EMPTYS)

distrib: $(BASE).iso $(BOOT).img
	rm -rf $(DEST)/$(DISTR_DIR)
	mkdir $(DEST)/$(DISTR_DIR)
	mkdir $(DEST)/$(DISTR_DIR)/$(FWDIR)
	cp $(DOCS) $(SOURCE) $(INCLUDES) $(BOOT).img $(FILES) $(BASE).iso $(DEST)/$(DISTR_DIR)
	cp $(FIRMWARES) $(DEST)/$(DISTR_DIR)/$(FWDIR)
	cd $(DEST); tar zcvf $(DISTR_DIR).tar.gz $(DISTR_DIR)

run_old: $(BASE).iso
	ln -sf $(BASE).iso part1
#	xspect -divide-image $(IMAGE0) ./ -quick-load devast_ide.tap
	xspect -divide-image $(IMAGE0) ./

run: $(BASE).hdf
	fuse -m 128 --divide-write-protect --divide --rom-divide $(IMAGE0) $(BASE).hdf
