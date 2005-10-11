SOURCE=demfir.a80
INCLUDES=config.a80 basic.tpi logo.pck logof6.pck spectrum.font didaktik.font
VERSION_LONG=$(shell grep "^DVERS" $(SOURCE)|cut -d \" -f 2)
VERSION=$(shell echo $(VERSION_LONG)|tr -d .)
BASE=$(SOURCE:%.a80=%$(VERSION))
COMPILE=$(BASE).tap
IMAGE0=$(BASE)_E.bin
IMAGE1=$(BASE)_R.bin
FILES=$(COMPILE) $(IMAGE0) $(IMAGE1) #devast_ide.tap
DOCS=AUTHORS BUGS* ChangeLog* INSTALL* LICENSE Makefile README* TODO*
DISTR_DIR=$(SOURCE:%.a80=%-$(VERSION_LONG))
DEST=../..

all: $(BASE).iso

$(BASE).iso: $(FILES)
	mkisofs -U -V "DEMFIR $(VERSION_LONG) INSTALL" -G $(IMAGE1) -o $(BASE).iso $(FILES)

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
	echo '.cvsignore *.bin demfir*.tap *.p *.err *.lst *.pat *.iso part1' >.cvsignore
	@echo

clean:
	rm -f *.bin demfir*.tap *.p *.err *.lst *.pat *.iso .cvsignore part1

distrib: $(BASE).iso
	rm -rf $(DEST)/$(DISTR_DIR)
	mkdir $(DEST)/$(DISTR_DIR)
	cp $(DOCS) $(SOURCE) $(INCLUDES) $(BASE).iso $(FILES) $(DEST)/$(DISTR_DIR)
	cd $(DEST); tar zcvf $(DISTR_DIR).tar.gz $(DISTR_DIR)

run: $(BASE).iso
	ln -sf $(BASE).iso part1
	xspect -divide-image $(IMAGE0) ./
