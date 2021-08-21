SHELL=/bin/bash
PREFIX?=$(HOME)
SPREFIX?=/usr/local
# PREFIX2?=/tftpboot/global/rnovak
.sh:
	@rm -f $@
	cp $< $@
INSTALL =       dictprep \
								gibbons

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
test1: install
	gibbons ~/890-0.txt
