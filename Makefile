SOURCE=demfir.a80
INCLUDES=config.a80 logo.pck logof6.pck basic.tpi
VERSION_LONG=$(shell grep "^DVERS" $(SOURCE)|cut -d \" -f 2)
VERSION=$(shell echo $(VERSION_LONG)|tr -d .)
BASE=$(SOURCE:%.a80=%$(VERSION))
FILES=$(BASE).tap
DOCS=AUTHORS BUGS BUGS_cz ChangeLog ChangeLog_cz INSTALL INSTALL_cz LICENSE Makefile README README_cz TODO TODO_cz
DISTR_DIR=$(SOURCE:%.a80=%-$(VERSION_LONG))
DEST=../..

all: $(BASE).iso

$(BASE).iso: $(FILES)
	mkisofs -U -V "DEMFIR $(VERSION_LONG) INSTALL" -o $(BASE).iso $(FILES)

$(FILES): $(SOURCE) $(INCLUDES)
	asl $(SOURCE) -o $(BASE).p -L -u
#-E $(BASE).err
	p2bin $(BASE).p -r 0-8191 -l 0
#-r \$$-\$$
	bin2tap -o $(BASE).pat -a 24576 $(BASE).bin
	cat basic.tpi $(BASE).pat > $(FILES)
	echo '.cvsignore *.bin *.p *.err *.lst *.tap *.pat *.iso' >.cvsignore

clean:
	rm -f *.bin *.p *.err *.lst *.tap *.pat *.iso .cvsignore

distrib: $(BASE).iso
	rm -rf $(DEST)/$(DISTR_DIR)
	mkdir $(DEST)/$(DISTR_DIR)
	cp $(DOCS) $(SOURCE) $(INCLUDES) $(BASE).bin $(BASE).iso $(FILES) $(DEST)/$(DISTR_DIR)
	cd $(DEST); tar zcvf $(DISTR_DIR).tar.gz $(DISTR_DIR)
