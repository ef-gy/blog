root:=http://ef.gy/
name:=Magnus Achim Deininger
INDICES:=download/index.atom download/kyuba/index.atom

# directories
BUILD:=.build
PDFDEST:=pdf
MOBIDEST:=mobi
EPUBDEST:=epub
DOWNLOAD:=$(BUILD)/download
BUILDTMP:=$(shell pwd)/$(BUILD)/tmp

# programmes
XSLTPROC:=xsltproc
GNUPLOT:=gnuplot
R:=R
KINDLEGEN:=kindlegen
INKSCAPE:=inkscape
ZIP:=zip
XVFB:=xvfb-run -a
SQLITE3:=sqlite3
CURL:=curl -s

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
RS:=$(wildcard src/*.r)
DOCUMENTS:=$(filter-out about.xhtml public-keys.xhtml,$(wildcard *.xhtml) $(wildcard *.atom))

# escaped file names
XHTMLESC:=$(subst :,\:,$(XHTMLS))

# target files
BUILDRAW:=$(addprefix $(BUILD)/,$(basename $(DOCUMENTS)))
PPXHTMLS:=$(addprefix $(BUILD)/,$(XHTMLS))
DOCBOOKS:=$(addsuffix .docbook,$(BUILDRAW))
PDFS:=$(addsuffix .pdf,$(BUILDRAW))
OPFS:=$(addsuffix .opf,$(BUILDRAW))
MOBIS:=$(addsuffix .mobi,$(BUILDRAW))
EPUBS:=$(addsuffix .epub,$(BUILDRAW))
SVGS:=$(addsuffix .svg,$(basename $(notdir $(PLOTS))) $(basename $(notdir $(RS))))
PNGS:=$(addprefix png/rasterised/,$(addsuffix .png,$(basename $(SVGS) $(basename $(notdir $(wildcard *.svg))))))
OPFXHTMLS:=$(addprefix $(BUILD)/,$(addsuffix .opf.xhtml,$(basename $(notdir $(wildcard *.xhtml)))))

# escaped target file names
PPXHTMLESC:=$(subst :,\:,$(PPXHTMLS))
DOCBOOKESC:=$(subst :,\:,$(DOCBOOKS))
PDFESC:=$(subst :,\:,$(PDFS))
OPFESC:=$(subst :,\:,$(OPFS))
MOBIESC:=$(subst :,\:,$(MOBIS))
EPUBESC:=$(subst :,\:,$(EPUBS))
PNGESC:=$(subst :,\:,$(PNGS))
OPFXHTMLESC:=$(subst :,\:,$(OPFXHTMLS))

BUILDD:=$(BUILD)/.volatile
DATABASES:=life.sqlite3
XSLTPROCARGS:=--stringparam baseURI "http://ef.gy" --stringparam documentRoot "$$(pwd)" --param licence "document('$$(pwd)/$(BUILD)/licence.xml')" --stringparam builddir $(BUILD)

# files to be downloaded
CSSDOWNLOADS:=css/highlight.css
JSDOWNLOADS:=js/disqus-embed.js js/analytics.js js/facebook-sdk.js js/highlight.js js/twitter-widgets.js js/google-platform.js

# don't delete intermediary files
.SECONDARY:

# meta rules
update: index pdfs mobis epubs pngs install

all: fortune index svgs pdfs mobis epubs csss jss
run: run-fortune
clean:
	rm -f $(DATABASES) $(INDICES); true
	rm -rf $(BUILDTMP) $(BUILD)/*; true
	rm -f $(CSSDOWNLOADS) $(JSDOWNLOADS)

scrub: clean
	rm -rf $(BUILD)

databases: $(DATABASES)
index: $(INDICES) index.xml

svgs: $(SVGS)
docbooks: $(DOCBOOKESC)
pdfs: $(PDFESC)
opfs: $(OPFESC)
mobis: $(MOBIESC)
epubs: $(EPUBESC)
pngs: $(PNGESC)

csss: css/ef.gy.minified.css css/ef.gy+highlight.minified.css $(CSSDOWNLOADS)
jss: $(JSDOWNLOADS) js/highlight+social.js

install: install-pdf install-mobi install-epub
install-pdf: $(PDFDEST)/.volatile $(addprefix $(PDFDEST)/,$(notdir $(PDFESC)))
install-mobi: $(MOBIDEST)/.volatile $(addprefix $(MOBIDEST)/,$(notdir $(MOBIESC)))
install-epub: $(EPUBDEST)/.volatile $(addprefix $(EPUBDEST)/,$(notdir $(EPUBESC)))

uninstall: uninstall-pdf

validate: validate-docbook validate-xhtml

# downloaded remote JavaScript files
js/disqus-embed.js:
	$(CURL) https://go.disqus.com/embed.js -o $@

js/analytics.js:
	$(CURL) https://www.google-analytics.com/analytics.js -o $@

js/facebook-sdk.js:
	$(CURL) https://connect.facebook.net/en_GB/sdk.js -o $@

js/highlight.js: js/highlight-setup.js
	$(CURL) https://cdnjs.cloudflare.com/ajax/libs/highlight.js/8.1/highlight.min.js -o $@
	cat js/highlight-setup.js >> $@

js/twitter-widgets.js:
	$(CURL) https://platform.twitter.com/widgets.js -o $@

js/google-platform.js:
	$(CURL) https://apis.google.com/js/platform.js -o $@

js/highlight+social.js: js/highlight.js js/social.js
	cat $^ > $@

# download remote CSS files and process local ones
css/highlight.css:
	$(CURL) https://cdnjs.cloudflare.com/ajax/libs/highlight.js/8.1/styles/default.min.css -o $@

css/ef.gy+highlight.css: css/ef.gy.css css/highlight.css
	cat $^ > $@

css/%.minified.css: css/%.css
	cssmin < $< | sed -r -e 's/calc\(([0-9%em]+)\+([0-9%em]+)\)/calc(\1 + \2)/' > $@

css/%.inline.xml: css/%.minified.css
	echo "<style xmlns='http://www.w3.org/1999/xhtml'><![CDATA[$$(cat $<)]]></style>" > $@

# .volatile files
$(BUILDD):
	mkdir -p $(BUILD); true
	ln -s $$(pwd)/png $(BUILD)/png
	ln -s $$(pwd)/jpeg $(BUILD)/jpeg
	ln -s $$(pwd) $(BUILD)/svg
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

$(EPUBDEST)/.volatile:
	mkdir -p $(EPUBDEST); true
	touch $@

png/rasterised/.volatile:
	mkdir -p png/rasterised; true
	touch $@

# css files (for epub/kindle)
$(BUILD)/book.css: css/book.css $(BUILDD)
	cp $< $@

$(BUILD)/cover.css: css/cover.css $(BUILDD)
	cp $< $@

# SVG rasterisation rules
png/rasterised/%.png: %.svg png/rasterised/.volatile
	rsvg-convert --keep-aspect-ratio --width 1920 $< -o $@

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

$(EPUBDEST)/%.epub: $(BUILD)/%.epub
	install $< $@

uninstall-pdf:
	rm -f $(addprefix $(PDFDEST)/,$(notdir $(PDFS)))

uninstall-mobi:
	rm -f $(addprefix $(MOBIDEST)/,$(notdir $(MOBIS)))

uninstall-epub:
	rm -f $(addprefix $(EPUBDEST)/,$(notdir $(EPUBS)))

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

# pattern rule to generate merged/preprocessed ATOMs
$(BUILD)/%.atom: %.atom $(BUILDD) $(BUILD)/licence.xml xslt/atom-merge.xslt xslt/xhtml-pre-process.xslt *.atom
	$(XSLTPROC) $(XSLTPROCARGS) xslt/atom-merge.xslt $< | \
		$(XSLTPROC) $(XSLTPROCARGS) xslt/xhtml-pre-process.xslt - > $@

# pattern rules to generate DocBook files
$(BUILD)/%.docbook: %.xhtml $(BUILDD) $(BUILD)/licence.xml xslt/docbook-transcode-xhtml.xslt
	$(XSLTPROC) $(XSLTPROCARGS) --param dblatexWorkaround 1 xslt/docbook-transcode-xhtml.xslt $< > $@

$(BUILD)/%.docbook: %.atom $(BUILDD) $(BUILD)/licence.xml xslt/docbook-transcode-xhtml.xslt xslt/docbook-transcode-atom.xslt
	$(XSLTPROC) $(XSLTPROCARGS) xslt/atom-merge.xslt $< | \
	    $(XSLTPROC) $(XSLTPROCARGS) --param dblatexWorkaround 1 xslt/docbook-transcode-xhtml.xslt - |\
		$(XSLTPROC) $(XSLTPROCARGS) --param dblatexWorkaround 1 xslt/docbook-transcode-atom.xslt - > $@

# pattern rule to generate PDFs
$(BUILD)/%.pdf: $(BUILD)/%.docbook $(BUILDD)
	dblatex --pdf $< -o $@
#	xmlto -o $(BUILD) --skip-validation --with-dblatex pdf $<
#	xsltproc -xinclude -o $<.fo /usr/share/xml/docbook/stylesheet/docbook-xsl-ns/fo/docbook.xsl $<
#	fop $<.fo -pdf $@

# pattern rules to generate EPUB/MOBI content
$(BUILD)/%/mimetype: $(BUILDD)
	mkdir -p $(BUILD)/$*
	echo 'application/epub+zip'>$@
	ln -s $$(pwd)/png $(BUILD)/$*/png
	ln -s $$(pwd)/jpeg $(BUILD)/$*/jpeg

$(BUILD)/%/META-INF/container.xml: $(BUILD)/%/mimetype
	mkdir -p $(BUILD)/$*/META-INF
	echo '<?xml version="1.0"?>'\
		'<container version="1.0" xmlns="urn:oasis:names:tc:opendocument:xmlns:container"><rootfiles>'\
		'<rootfile full-path="publication.opf" media-type="application/oebps-package+xml"/>'\
		'</rootfiles></container>'>$@

$(BUILD)/%/book.css: css/book.css $(BUILD)/%/mimetype
	cp $< $@

$(BUILD)/%/cover.css: css/cover.css $(BUILD)/%/mimetype
	cp $< $@

$(BUILD)/%/publication.opf: $(BUILD)/%.xhtml $(BUILD)/%/META-INF/container.xml $(BUILD)/licence.xml xslt/opf-transcode-xhtml.xslt $(PMML2SVG)
	$(XSLTPROC) $(XSLTPROCARGS) xslt/opf-transcode-xhtml.xslt $< > $@~
	for i in $(BUILD)/$*/content.xhtml; do\
		echo converting MathML to SVG: $$i;\
		CLASSPATH=$(SAXONJAR) java net.sf.saxon.Transform -ext:off -s:$$i -xsl:$(PMML2SVG) -o:$$i initSize=14 minSize=4 svgMasterUnit='pt';\
		rm -rf $(BUILD)/$*/tmp; mkdir -p $(BUILD)/$*/tmp || true;\
		$(XSLTPROC) $(XSLTPROCARGS) --stringparam tmpdir $$(pwd)/$(BUILD)/$*/tmp -o $$i xslt/xhtml-split-svg-opf.xslt $$i;\
		for j in $(BUILD)/$*/tmp/*.svg; do [ ! -e $$j ] || ( echo " - converting SVG text to outlines: $$j" && $(XVFB) $(INKSCAPE) --with-gui --verb EditSelectAll --verb ObjectToPath --verb FileSave --verb FileQuit $$j ); done;\
		$(XSLTPROC) $(XSLTPROCARGS) -o $$i xslt/xhtml-post-process-opf.xslt $$i;\
		rm -rf $(BUILD)/$*/tmp;\
	done
	mv $@~ $@

$(BUILD)/%/publication.opf: $(BUILD)/%.atom $(BUILD)/%/META-INF/container.xml $(BUILD)/licence.xml xslt/opf-transcode-atom.xslt $(PMML2SVG)
	$(XSLTPROC) $(XSLTPROCARGS) xslt/opf-transcode-atom.xslt $< > $@~
	for i in $(BUILD)/$*/content-*.xhtml; do\
		echo converting MathML to SVG: $$i;\
		CLASSPATH=$(SAXONJAR) java net.sf.saxon.Transform -ext:off -s:$$i -xsl:$(PMML2SVG) -o:$$i initSize=14 minSize=4 svgMasterUnit='pt';\
		rm -rf $(BUILD)/$*/tmp; mkdir -p $(BUILD)/$*/tmp || true;\
		$(XSLTPROC) $(XSLTPROCARGS) --stringparam tmpdir $$(pwd)/$(BUILD)/$*/tmp -o $$i xslt/xhtml-split-svg-opf.xslt $$i;\
		for j in $(BUILD)/$*/tmp/*.svg; do [ ! -e $$j ] || ( echo " - converting SVG text to outlines: $$j" && $(XVFB) $(INKSCAPE) --with-gui --verb EditSelectAll --verb ObjectToPath --verb FileSave --verb FileQuit $$j ); done;\
		$(XSLTPROC) $(XSLTPROCARGS) -o $$i xslt/xhtml-post-process-opf.xslt $$i;\
		rm -rf $(BUILD)/$*/tmp;\
	done
	mv $@~ $@

# pattern rule to generate MOBIs
$(BUILD)/%.mobi: $(BUILD)/%/publication.opf $(BUILD)/%/book.css $(BUILD)/%/cover.css
	cd $(BUILD)/$* && $(KINDLEGEN) publication.opf -o $(notdir $@) || true
	mv $(BUILD)/$*/$(notdir $@) $(BUILD)

$(BUILD)/%.epub: $(BUILD)/%/publication.opf $(BUILD)/%/book.css $(BUILD)/%/cover.css
	rm -f $@
	cd $(BUILD)/$* && $(ZIP) -0 ../$(notdir $@) mimetype && $(ZIP) ../$(notdir $@) META-INF/container.xml publication.opf $(shell $(XSLTPROC) xslt/opf-print-manifest.xslt $<)

# pattern rule for gnuplot graphs
%.svg: src/%.plot src/flash-integrity.plot xslt/clean.xslt
	$(GNUPLOT)\
		-e 'set terminal svg size 1200,600 dynamic fname "sans-serif"'\
		$< > $@
	$(XSLTPROC) $(XSLTPROCARGS) -o $@ xslt/clean.xslt $@

# pattern rule for R graphs
%.svg: src/%.r
	$(R) --no-save < $<

# pattern rule to generate directory indices
$(INDICES): makefile $(filter-out %index.atom, $(wildcard download/*))
	echo '<?xml version="1.0" encoding="utf-8"?>'\
		'<feed xmlns="http://www.w3.org/2005/Atom">'\
		'<id>$(root)$@</id><title>/$(subst /index.atom,,$@)</title><link rel="self" href="$(root)atom/$(subst .atom,,$@)"/>'\
		"<updated>$$(stat -c %y "$(subst /index.atom,,$@)"|sed -e 's/\(.\+\) \(.\+\)\(\..*\) \+\(...\)\(..\)/\1T\2\4:\5/')</updated>">$@
	for i in $(subst /index.atom,,$@)/*; do\
		if [ $${i} != "$@" -a -f $${i} ]; then echo "<entry><id>md5:$$(md5sum -b $${i}|cut -d ' ' -f 1)</id><title>$$(basename $${i})</title><link href='/$${i}' type='$$(file --mime-type $${i}|cut -d ' ' -f 2)'/><updated>$$(stat -c %y $${i}|sed -e 's/\(.\+\) \(.\+\)\(\..*\) \+\(...\)\(..\)/\1T\2\4:\5/')</updated><author><name>$(name)</name></author><category term='$$(echo '$(subst /index.atom,,$@)')'/><summary>File Type: $$(file --mime-type $${i}|cut -d ' ' -f 2). File Checksum (MD5): $$(md5sum -b $${i}|cut -d ' ' -f 1)</summary></entry>"; fi;\
	done>>$@
	echo '</feed>'>>$@

# global navigation index
index.xml: $(BUILD)/everything.atom xslt/atom-style-ef.gy.xslt xslt/atom-sort.xslt xslt/index-transcode-atom.xslt
	$(XSLTPROC) $(XSLTPROCARGS) xslt/atom-style-ef.gy.xslt $< |\
		$(XSLTPROC) $(XSLTPROCARGS) xslt/atom-sort.xslt - |\
		$(XSLTPROC) $(XSLTPROCARGS) xslt/index-transcode-atom.xslt - > $@

# pattern rules for databases
%.sqlite3: src/%.sql
	rm -f $@ && $(SQLITE3) $@ < $<

# specific rule to build the fortune daemon
fortune: src/fortune.cpp include/ef.gy/http.h
	clang++ -Iinclude/ -O2 src/fortune.cpp -lboost_system -lboost_regex -lboost_filesystem -lboost_iostreams -o fortune && strip -x fortune

# specific rule to build the tesseract javascript renderer
js/tesseract.js: src/tesseract.cpp
	em++ -v --llvm-opts 2 --closure 1 -s EXPORTED_FUNCTIONS="['_main','_updateProjection','_getProjection','_getAxisGraph3','_getAxisGraph4','_addOrigin3','_setOrigin3','_addOrigin4','_setOrigin4','cwrap']" -Iinclude src/tesseract.cpp -o js/tesseract.js

# specific rule to run the fortune daemon
run-fortune: fortune
	killall fortune; rm -f /var/tmp/fortune.socket && (nohup ./fortune /var/tmp/fortune.socket &) && sleep 1 && chmod a+w /var/tmp/fortune.socket

# specific rules for silly gadgets
game-of-life.xslt.xml::
	$(XSLTPROC) $(XSLTPROCARGS) xslt/0p-game-of-life.xslt $@

game-of-life.xml: life.sqlite3
	echo '<?xml version="1.0"?><game-of-life xmlns="http://ef.gy/2013/0p">' > $@
	echo "select fragment from vxmlfragment;" | $(SQLITE3) $< >> $@
	echo '</game-of-life>' >> $@

game-of-life.svg: game-of-life.xml xslt/svg-0p-game-of-life.xslt
	$(XSLTPROC) $(XSLTPROCARGS) -o $@ xslt/svg-0p-game-of-life.xslt $<
