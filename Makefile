SOURCE=demfir.a80
VERSION=$(shell grep "defb.*DEMFIR" $(SOURCE)|awk '{print $$3}'|tr -d .)
BASE=$(SOURCE:%.a80=%$(VERSION))
DEST=$(BASE).tap

all: $(BASE).iso

$(BASE).iso: $(DEST)
	mkisofs -U -V "DEMFIR $(VERSION) INSTALL" -o $(BASE).iso $(DEST)

$(DEST): $(SOURCE)
	asl $(SOURCE) -o $(BASE).p -L
#-E $(BASE).err
	p2bin $(BASE).p -l 0 -r \$$-\$$
	bin2tap $(BASE).bin $(BASE).pat 24576
	cat basic.tpi $(BASE).pat > $(DEST)

clean:
	rm -f *.bin *.p *.err *.lst *.tap *.pat *.iso
