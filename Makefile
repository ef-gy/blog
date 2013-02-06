root=http://ef.gy/
name=Magnus Achim Deininger
INDICES=download/index.atom download/kyuba/index.atom
BUILD:=.build
BUILDD:=$(BUILD)/.volatile
DOWNLOAD:=$(BUILD)/download
DATABASES:=rogue.sqlite3
XHTMLS:=$(wildcard *.xhtml)
XHTMLESC:=$(subst :,\:,$(XHTMLS))
DOCUMENTS:=$(filter-out source-code.xhtml about.xhtml,$(wildcard *.xhtml) $(wildcard *.atom))
BUILDRAW:=$(addprefix $(BUILD)/,$(basename $(DOCUMENTS)))
DOCBOOKS:=$(addsuffix .docbook,$(BUILDRAW))
DOCBOOKESC:=$(subst :,\:,$(DOCBOOKS))
PDFS:=$(addsuffix .pdf,$(BUILDRAW))
PDFESC:=$(subst :,\:,$(PDFS))
PDFDEST:=pdf
XSLTPROC:=xsltproc
XSLTPROCARGS:=--stringparam baseURI "http://ef.gy" --stringparam documentRoot "$$(pwd)" --param licence "document('$$(pwd)/$(BUILD)/licence.xml')"

XHTMLSTRICT:=/usr/share/xml/xhtml-relaxng/xhtml-strict.rng

#all: fortune js/tesseract.js
all: fortune index databases

install: install-pdf
uninstall: uninstall-pdf
validate: validate-docbook validate-xhtml

docbooks: $(DOCBOOKESC)
pdfs: $(PDFESC)

clean:
	rm -f $(DATABASES) $(INDICES) $(PDFS) $(DOCBOOKS)

scrub: clean
	rm -rf $(BUILD)

$(PDFDEST)/.volatile:
	mkdir -p $(PDFDEST); true

$(BUILDD):
	mkdir -p $(BUILD); true
	touch $(BUILDD)

$(DOWNLOAD)/.volatile:
	mkdir $(DOWNLOAD); true
	touch $(DOWNLOAD)/.volatile

$(DOWNLOAD)/docbook-5.0.zip: $(DOWNLOAD)/.volatile
	wget 'http://www.docbook.org/xml/5.0/docbook-5.0.zip' -cO $@
	touch $@

$(BUILD)/docbook-5.0/VERSION: $(DOWNLOAD)/docbook-5.0.zip
	unzip $< -d $(BUILD)
	touch $@

install-pdf: $(PDFDEST)/.volatile pdfs
	cp $(PDFS) $(PDFDEST)/

uninstall-pdf:
	rm -f $(addprefix $(PDFDEST)/,$(notdir $(PDFS)))

validate-docbook: $(DOCBOOKESC) $(BUILD)/docbook-5.0/VERSION
	for i in $^; do ([ "$$(basename $$i)" != "VERSION" ] && (jing -C $(BUILD)/docbook-5.0/catalog.xml $(BUILD)/docbook-5.0/rng/docbook.rng "$$i" || echo "validation failed for '$$i'")) || true; done; true

validate-xhtml: $(XHTMLESC)
	for i in $^; do cp "$$i" "$(BUILD)/xhtml-tmp.xml"; jing $(XHTMLSTRICT) "$(BUILD)/xhtml-tmp.xml" || echo "validation failed for '$$i'"; done; true

$(BUILD)/licence.xml: COPYING
	echo "<?xml version='1.0' encoding='utf-8'?><legalnotice xmlns='http://docbook.org/ns/docbook' version='5.0'><para><![CDATA[" > $@
	sed -e "s:^$$:]]></para><para><!\[CDATA\[:" < $< >> $@
	echo "]]></para></legalnotice>" >> $@

$(BUILD)/%.docbook: %.xhtml $(BUILDD) $(BUILD)/licence.xml
	$(XSLTPROC) $(XSLTPROCARGS) xslt/docbook-transcode-xhtml.xslt $< > $@

$(BUILD)/%.docbook: %.atom $(BUILDD) $(BUILD)/licence.xml
	$(XSLTPROC) $(XSLTPROCARGS) xslt/atom-merge.xslt $< |\
		$(XSLTPROC) $(XSLTPROCARGS) xslt/docbook-transcode-xhtml.xslt - |\
		$(XSLTPROC) $(XSLTPROCARGS) xslt/docbook-transcode-atom.xslt - > $@

$(BUILD)/%.pdf: $(BUILD)/%.docbook $(BUILDD)
	dblatex --pdf $< -o $@

databases: $(DATABASES)

rogue.sqlite3: src/rogue.sql src/rogue-data.sql
	rm -f rogue.sqlite3
	sqlite3 rogue.sqlite3 < src/rogue.sql
	sqlite3 rogue.sqlite3 < src/rogue-data.sql

index: $(INDICES)

$(INDICES): Makefile $(filter-out %index.atom, $(wildcard download/*))
	echo '<?xml version="1.0" encoding="utf-8"?>'\
		'<feed xmlns="http://www.w3.org/2005/Atom">'\
		'<id>$(root)$@</id><title>/$(subst /index.atom,,$@)</title><link rel="self" href="$(root)atom/$(subst .atom,,$@)"/>'\
		"<updated>$$(stat -c %y "$(subst /index.atom,,$@)"|sed -e 's/\(.\+\) \(.\+\)\.0\+ \(...\)\(..\)/\1T\2\3:\4/')</updated>">$@
	for i in $(subst /index.atom,,$@)/*; do\
		if [ $${i} != "$@" -a -f $${i} ]; then echo "<entry><id>md5:$$(md5sum -b $${i}|cut -d ' ' -f 1)</id><title>$$(basename $${i})</title><link href='/$${i}' type='$$(file --mime-type $${i}|cut -d ' ' -f 2)'/><updated>$$(stat -c %y $${i}|sed -e 's/\(.\+\) \(.\+\)\.0\+ \(...\)\(..\)/\1T\2\3:\4/')</updated><author><name>$(name)</name></author><category term='$$(echo '$(subst /index.atom,,$@)')'/><summary>File Type: $$(file --mime-type $${i}|cut -d ' ' -f 2). File Checksum (MD5): $$(md5sum -b $${i}|cut -d ' ' -f 1)</summary></entry>"; fi;\
	done>>$@
	echo '</feed>'>>$@

fortune: src/fortune.cpp include/ef.gy/http.h
	clang++ -Iinclude/ -O2 src/fortune.cpp -lboost_system -lboost_regex -lboost_filesystem -lboost_iostreams -o fortune && strip -x fortune

js/tesseract.js: src/tesseract.cpp
	em++ -v --llvm-opts 2 --closure 1 -s EXPORTED_FUNCTIONS="['_main','_updateProjection','_getProjection','_getAxisGraph3','_getAxisGraph4','_addOrigin3','_setOrigin3','_addOrigin4','_setOrigin4','cwrap']" -Iinclude src/tesseract.cpp -o js/tesseract.js

run: run-fortune

run-fortune: fortune
	killall fortune; rm -f /var/tmp/fortune.socket && (nohup ./fortune /var/tmp/fortune.socket &) && sleep 1 && chmod a+w /var/tmp/fortune.socket
