SOURCE=demfir.a80
VERSION_LONG=$(shell grep "defb.*DEMFIR" $(SOURCE)|awk '{print $$3}')
VERSION=$(shell echo $(VERSION_LONG)|tr -d .)
BASE=$(SOURCE:%.a80=%$(VERSION))
DEST=$(BASE).tap
DOCS=AUTHORS BUGS BUGS_cz ChangeLog ChangeLog_cz INSTALL INSTALL_cz LICENSE Makefile README README_cz TODO TODO_cz
DISTR_DIR=$(SOURCE:%.a80=%-$(VERSION_LONG))

all: $(BASE).iso

$(BASE).iso: $(DEST)
	mkisofs -U -V "DEMFIR $(VERSION_LONG) INSTALL" -o $(BASE).iso $(DEST)

$(DEST): $(SOURCE)
	asl $(SOURCE) -o $(BASE).p -L
#-E $(BASE).err
	p2bin $(BASE).p -r 0-8191
#-l 0 -r \$$-\$$
	bin2tap $(BASE).bin $(BASE).pat 24576
	cat basic.tpi $(BASE).pat > $(DEST)

clean:
	rm -f *.bin *.p *.err *.lst *.tap *.pat *.iso

distrib: $(BASE).iso
	rm -rf ../../$(DISTR_DIR)
	mkdir ../../$(DISTR_DIR)
	cp $(DOCS) $(SOURCE) basic.tpi logo.pck $(BASE).bin $(BASE).iso $(DEST) ../../$(DISTR_DIR)
	cd ../..; tar zcvf $(DISTR_DIR).tar.gz $(DISTR_DIR)
