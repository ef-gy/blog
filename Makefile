root:=http://ef.gy/
name:=Magnus Achim Deininger
INDICES:=download/index.atom download/kyuba/index.atom

# directories
BUILD:=.build
PDFDEST:=pdf
MOBIDEST:=mobi
DOWNLOAD:=$(BUILD)/download
BUILDTMP:=$(shell pwd)/$(BUILD)/tmp

# programmes
XSLTPROC:=xsltproc
GNUPLOT:=gnuplot
KINDLEGEN:=kindlegen
INKSCAPE:=inkscape
XVFB:=xvfb-run -a

# download locations
PMML2SVGZIP:=http://heanet.dl.sourceforge.net/project/pmml2svg/pmml2svg/pMML2SVG-0.8.5.zip
DOCBOOK5ZIP:=http://www.docbook.org/xml/5.0/docbook-5.0.zip

# download base names
PMML2SVGZIPBASE:=$(basename $(notdir $(PMML2SVGZIP)))

# data files
SAXONJAR:=/usr/share/java/saxonb.jar
XHTMLSTRICT:=/usr/share/xml/xhtml-relaxng/xhtml-strict.rng
PMML2SVG:=$(BUILD)/$(PMML2SVGZIPBASE)/XSLT2/pmml2svg.xsl

# source files
XHTMLS:=$(wildcard *.xhtml)
PLOTS:=$(filter-out src/flash-integrity.plot,$(wildcard src/*.plot))
DOCUMENTS:=$(filter-out source-code.xhtml about.xhtml,$(wildcard *.xhtml) $(wildcard *.atom))

# escaped file names
XHTMLESC:=$(subst :,\:,$(XHTMLS))

# target files
BUILDRAW:=$(addprefix $(BUILD)/,$(basename $(DOCUMENTS)))
PPXHTMLS:=$(addprefix $(BUILD)/,$(XHTMLS))
DOCBOOKS:=$(addsuffix .docbook,$(BUILDRAW))
PDFS:=$(addsuffix .pdf,$(BUILDRAW))
OPFS:=$(addsuffix .opf,$(BUILDRAW))
MOBIS:=$(addsuffix .mobi,$(BUILDRAW))
SVGS:=$(addsuffix .svg,$(basename $(notdir $(PLOTS))))
OPFXHTMLS:=$(addprefix $(BUILD)/,$(addsuffix .opf.xhtml,$(basename $(notdir $(wildcard *.xhtml)))))

# escaped target file names
PPXHTMLESC:=$(subst :,\:,$(PPXHTMLS))
DOCBOOKESC:=$(subst :,\:,$(DOCBOOKS))
PDFESC:=$(subst :,\:,$(PDFS))
OPFESC:=$(subst :,\:,$(OPFS))
MOBIESC:=$(subst :,\:,$(MOBIS))
OPFXHTMLDESC:=$(subst :,\:,$(OPFXHTMLS))

BUILDD:=$(BUILD)/.volatile
DATABASES:=
XSLTPROCARGS:=--stringparam baseURI "http://ef.gy" --stringparam documentRoot "$$(pwd)" --param licence "document('$$(pwd)/$(BUILD)/licence.xml')"

# don't delete intermediary files
.SECONDARY:

# meta rules
all: fortune index
run: run-fortune
clean:
	rm -f $(DATABASES) $(INDICES) $(BUILD)/*; true
	rm -rf $(BUILDTMP); true
scrub: clean
	rm -rf $(BUILD)

databases: $(DATABASES)
index: $(INDICES)

svgs: $(SVGS)
docbooks: $(DOCBOOKESC)
pdfs: $(PDFESC)
opfs: $(OPFESC)
mobis: $(MOBIESC)

install: install-pdf install-mobi
install-pdf: $(PDFDEST)/.volatile $(addprefix $(PDFDEST)/,$(notdir $(PDFESC)))
install-mobi: $(MOBIDEST)/.volatile $(addprefix $(MOBIDEST)/,$(notdir $(MOBIESC)))

uninstall: uninstall-pdf

validate: validate-docbook validate-xhtml

# .volatile files
$(BUILDD):
	mkdir -p $(BUILD); true
	touch $(BUILDD)

$(DOWNLOAD)/.volatile:
	mkdir $(DOWNLOAD); true
	touch $(DOWNLOAD)/.volatile

$(PDFDEST)/.volatile:
	mkdir -p $(PDFDEST); true
	touch $@

$(MOBIDEST)/.volatile:
	mkdir -p $(MOBIDEST); true
	touch $@

# css files (for epub/kindle)
$(BUILD)/ef.gy.book.css: css/ef.gy.book.css $(BUILDD)
	cp $< $@

# build data file downloads
$(DOWNLOAD)/docbook-5.0.zip: $(DOWNLOAD)/.volatile
	wget '$(DOCBOOK5ZIP)' -cO $@
	touch $@

$(DOWNLOAD)/$(PMML2SVGZIPBASE).zip: $(DOWNLOAD)/.volatile
	wget '$(PMML2SVGZIP)' -cO $@
	touch $@

# extract downloaded data files
$(BUILD)/docbook-5.0/VERSION: $(DOWNLOAD)/docbook-5.0.zip
	unzip $< -d $(BUILD)
	touch $@

$(BUILD)/$(PMML2SVGZIPBASE)/RELEASE: $(DOWNLOAD)/$(PMML2SVGZIPBASE).zip
	unzip $< -d $(BUILD)
	touch $@

$(PMML2SVG): $(BUILD)/$(PMML2SVGZIPBASE)/RELEASE
	touch $@

# install pattern rules
$(PDFDEST)/%.pdf: $(BUILD)/%.pdf
	install $< $@

$(MOBIDEST)/%.mobi: $(BUILD)/%.mobi
	install $< $@

uninstall-mobi:
	rm -f $(addprefix $(MOBIDEST)/,$(notdir $(MOBIS)))

uninstall-pdf:
	rm -f $(addprefix $(PDFDEST)/,$(notdir $(PDFS)))

# XML validation rules
validate-docbook: $(DOCBOOKESC) $(BUILD)/docbook-5.0/VERSION
	for i in $^; do ([ "$$(basename $$i)" != "VERSION" ] && (jing -C $(BUILD)/docbook-5.0/catalog.xml $(BUILD)/docbook-5.0/rng/docbook.rng "$$i" || echo "validation failed for '$$i'")) || true; done; true

validate-xhtml: $(XHTMLESC)
	for i in $^; do cp "$$i" "$(BUILD)/xhtml-tmp.xml"; jing $(XHTMLSTRICT) "$(BUILD)/xhtml-tmp.xml" || echo "validation failed for '$$i'"; done; true

# special build data files
$(BUILD)/licence.xml: COPYING
	echo "<?xml version='1.0' encoding='utf-8'?><legalnotice xmlns='http://docbook.org/ns/docbook' version='5.0'><para><![CDATA[" > $@
	sed -e "s:^$$:]]></para><para><!\[CDATA\[:" < $< >> $@
	echo "]]></para></legalnotice>" >> $@

# pattern rule to generate preprocessed XHTMLs
$(BUILD)/%.xhtml: %.xhtml $(BUILDD) $(BUILD)/licence.xml xslt/xhtml-pre-process.xslt
	$(XSLTPROC) $(XSLTPROCARGS) xslt/xhtml-pre-process.xslt $< > $@

# pattern rule to generate merged ATOMs
$(BUILD)/%.atom: %.atom $(BUILDD) $(BUILD)/licence.xml xslt/atom-merge.xslt
	$(XSLTPROC) $(XSLTPROCARGS) xslt/atom-merge.xslt $< > $@

# pattern rules to generate DocBook files
$(BUILD)/%.docbook: %.xhtml $(BUILDD) $(BUILD)/licence.xml xslt/docbook-transcode-xhtml.xslt
	$(XSLTPROC) $(XSLTPROCARGS) --param dblatexWorkaround 1 xslt/docbook-transcode-xhtml.xslt $< > $@

$(BUILD)/%.docbook: $(BUILD)/%.atom $(BUILDD) $(BUILD)/licence.xml xslt/docbook-transcode-xhtml.xslt xslt/docbook-transcode-atom.xslt
	$(XSLTPROC) $(XSLTPROCARGS) --param dblatexWorkaround 1 xslt/docbook-transcode-xhtml.xslt $< |\
		$(XSLTPROC) $(XSLTPROCARGS) --param dblatexWorkaround 1 xslt/docbook-transcode-atom.xslt - > $@

# pattern rule to generate PDFs
$(BUILD)/%.pdf: $(BUILD)/%.docbook $(BUILDD)
	dblatex --pdf $< -o $@
#	xmlto -o $(BUILD) --skip-validation --with-dblatex pdf $<
#	xsltproc -xinclude -o $<.fo /usr/share/xml/docbook/stylesheet/docbook-xsl-ns/fo/docbook.xsl $<
#	fop $<.fo -pdf $@

# pattern rules to generate OPF files
$(BUILD)/%.nomathml-xhtml: $(BUILD)/%.xhtml $(PMML2SVG)
	CLASSPATH=$(SAXONJAR) java net.sf.saxon.Transform -ext:off -s:$< -xsl:$(PMML2SVG) -o:$@ initSize=14 minSize=4 svgMasterUnit='pt'

$(BUILD)/%.opf.xhtml: $(BUILD)/%.nomathml-xhtml $(BUILD)/licence.xml xslt/xhtml-post-process-opf.xslt
	rm -rf "$(BUILDTMP)/$(notdir $*)"; mkdir -p "$(BUILDTMP)/$(notdir $*)"
	$(XSLTPROC) $(XSLTPROCARGS) --stringparam tmpdir "$(BUILDTMP)/$(notdir $*)" -o $@ xslt/xhtml-split-svg-opf.xslt $<
#	for i in $(BUILDTMP)/$(notdir $*)/*.svg; do echo "cleaning: $$i"; [ ! -e "$$i" ] || $(INKSCAPE) -f "$$i" --export-text-to-path --export-plain-svg="$$i.clean"; done
	for i in $(BUILDTMP)/$(notdir $*)/*.svg; do echo "cleaning: $$i"; [ ! -e "$$i" ] || ($(XVFB) $(INKSCAPE) --with-gui --verb EditSelectAll --verb ObjectToPath --verb FileSave --verb FileQuit "$$i"); done
	$(XSLTPROC) $(XSLTPROCARGS) -o $@ xslt/xhtml-post-process-opf.xslt $@
	#rm -rf "$(BUILDTMP)/$(notdir $*)"

$(BUILD)/%.opf: $(BUILD)/%.opf.xhtml $(BUILDD) $(BUILD)/licence.xml xslt/opf-transcode-xhtml.xslt
	$(XSLTPROC) $(XSLTPROCARGS) xslt/opf-transcode-xhtml.xslt $< > $@

$(BUILD)/%.opf: $(BUILD)/%.atom $(BUILDD) $(BUILD)/licence.xml xslt/opf-transcode-atom.xslt
	$(XSLTPROC) $(XSLTPROCARGS) xslt/opf-transcode-atom.xslt $< > $@

# pattern rule to generate MOBIs
$(BUILD)/%.mobi: $(BUILD)/%.opf $(BUILD)/ef.gy.book.css $(OPFXHTMLDESC)
	cd $(BUILD) && $(KINDLEGEN) $(notdir $<) -o $(notdir $@) || true

# pattern rule to generate directory indices
$(INDICES): Makefile $(filter-out %index.atom, $(wildcard download/*))
	echo '<?xml version="1.0" encoding="utf-8"?>'\
		'<feed xmlns="http://www.w3.org/2005/Atom">'\
		'<id>$(root)$@</id><title>/$(subst /index.atom,,$@)</title><link rel="self" href="$(root)atom/$(subst .atom,,$@)"/>'\
		"<updated>$$(stat -c %y "$(subst /index.atom,,$@)"|sed -e 's/\(.\+\) \(.\+\)\.0\+ \(...\)\(..\)/\1T\2\3:\4/')</updated>">$@
	for i in $(subst /index.atom,,$@)/*; do\
		if [ $${i} != "$@" -a -f $${i} ]; then echo "<entry><id>md5:$$(md5sum -b $${i}|cut -d ' ' -f 1)</id><title>$$(basename $${i})</title><link href='/$${i}' type='$$(file --mime-type $${i}|cut -d ' ' -f 2)'/><updated>$$(stat -c %y $${i}|sed -e 's/\(.\+\) \(.\+\)\.0\+ \(...\)\(..\)/\1T\2\3:\4/')</updated><author><name>$(name)</name></author><category term='$$(echo '$(subst /index.atom,,$@)')'/><summary>File Type: $$(file --mime-type $${i}|cut -d ' ' -f 2). File Checksum (MD5): $$(md5sum -b $${i}|cut -d ' ' -f 1)</summary></entry>"; fi;\
	done>>$@
	echo '</feed>'>>$@

# specific rule to build the fortune daemon
fortune: src/fortune.cpp include/ef.gy/http.h
	clang++ -Iinclude/ -O2 src/fortune.cpp -lboost_system -lboost_regex -lboost_filesystem -lboost_iostreams -o fortune && strip -x fortune

# specific rule to build the tesseract javascript renderer
js/tesseract.js: src/tesseract.cpp
	em++ -v --llvm-opts 2 --closure 1 -s EXPORTED_FUNCTIONS="['_main','_updateProjection','_getProjection','_getAxisGraph3','_getAxisGraph4','_addOrigin3','_setOrigin3','_addOrigin4','_setOrigin4','cwrap']" -Iinclude src/tesseract.cpp -o js/tesseract.js

# pattern rules for gnuplot graphs
%.svg: src/%.plot src/flash-integrity.plot
	$(GNUPLOT)\
		-e 'set terminal svg size 1200,600 dynamic fname "sans-serif"'\
		$< > $@

# specific rule to run the fortune daemon
run-fortune: fortune
	killall fortune; rm -f /var/tmp/fortune.socket && (nohup ./fortune /var/tmp/fortune.socket &) && sleep 1 && chmod a+w /var/tmp/fortune.socket
