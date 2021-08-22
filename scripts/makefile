SHELL=/bin/bash
PREFIX?=$(HOME)
SPREFIX?=/usr/local
# PREFIX2?=/tftpboot/global/rnovak
.sh:
	@rm -f $@
	cp $< $@
INSTALL =       dictprep \
	gibbons \
	rgibbons

EXECDIR := $(PREFIX)/bin
SEXECDIR := $(SPREFIX)/sbin


.PHONY: clean uninstall all
all: $(INSTALL)
install: $(INSTALL)
	mkdir -p $(EXECDIR)
	install -o $(USER) -C $? $(EXECDIR)
	rm -f $?
sinstall: $(INSTALL)
	mkdir -p $(SEXECDIR)
	install -o root -C $? $(SEXECDIR)
clean:
	@for execfile in $(INSTALL); do \
		echo rm -f $$execfile; \
		rm -f $$execfile; \
	done
uninstall:
	@for execfile in $(INSTALL); do \
		echo rm -f $(EXECDIR)/$$execfile; \
		rm -f $(EXECDIR)/$$execfile; \
	done
suninstall:
	@for execfile in $(INSTALL); do \
		echo rm -f $(SEXECDIR)/$$execfile; \
		rm -f $(SEXECDIR)/$$execfile; \
	done
$(EXECDIR):
	mkdir -p $(EXECDIR)
$(SEXECDIR):
	mkdir -p $(SEXECDIR)
GIBBONS=../etc/890-0.txt
test1: install
	gibbons $(GIBBONS)
test2: install $(GIBBONS)
	gibbons $(GIBBONS) > /tmp/t1
	cat /tmp/t1
	rgibbons /tmp/t1 > /tmp/t2
	getb2sum $(GIBBONS) > /tmp/t3
	cmp /tmp/t2 /tmp/t3
