root:=https://ef.gy/
name:=Magnus Achim Deininger
INDICES:=download/index.atom download/kyuba/index.atom

# domain settings
DOMAIN:=ef.gy
HIDDENSERVICE:=vturtipc7vmz6xjy.onion
DISQUS:=efgy

# directories
BUILD:=.build
PDFDEST:=pdf
MOBIDEST:=mobi
EPUBDEST:=epub
DOWNLOAD:=$(BUILD)/download
BUILDTMP:=$(shell pwd)/$(BUILD)/tmp
THIRDPARTY:=.third-party
CACHE:=.cache
CACHEO:=$(CACHE)/$(DOMAIN)
CACHET:=$(CACHE)/$(HIDDENSERVICE)

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
XSLTPROCCACHEOARGS:=--novalid --stringparam baseURI "https://$(DOMAIN)" --stringparam documentRoot "$$(pwd)" --stringparam disqusShortname "$(DISQUS)"
XSLTPROCCACHETARGS:=--novalid --stringparam baseURI "http://$(HIDDENSERVICE)" --stringparam documentRoot "$$(pwd)" --stringparam disqusShortname "$(DISQUS)"
XSLTPROCARGS:=$(XSLTPROCCACHEOARGS) --param licence "document('$$(pwd)/$(BUILD)/licence.xml')" --stringparam builddir $(BUILD)

# files to be downloaded
JSDOWNLOADS:=js/disqus-embed.js js/highlight.js

# don't delete intermediary files
.SECONDARY:

# meta rules
update: index pdfs mobis epubs pngs install

all: fortune index pdfs mobis epubs components
run: run-fortune
clean:
	rm -f $(DATABASES) $(INDICES); true
	rm -rf $(BUILDTMP) $(BUILD)/*; true
	rm -f css/*+*.css $(JSDOWNLOADS)

components: svgs csss jss pngs inlinecss inlineimg

scrub: clean
	rm -rf $(BUILD)

databases: $(DATABASES)
index: $(INDICES) $(CACHE)/index.xml

svgs: $(SVGS)
docbooks: $(DOCBOOKESC)
pdfs: $(PDFESC)
opfs: $(OPFESC)
mobis: $(MOBIESC)
epubs: $(EPUBESC)
pngs: $(PNGESC)

csss: css/ef.gy+highlight.css
jss: $(JSDOWNLOADS) js/highlight.js js/highlight+disqus-embed.js js/jquery.js

install: install-pdf install-mobi install-epub
install-pdf: $(PDFDEST)/.volatile $(addprefix $(PDFDEST)/,$(notdir $(PDFESC)))
install-mobi: $(MOBIDEST)/.volatile $(addprefix $(MOBIDEST)/,$(notdir $(MOBIESC)))
install-epub: $(EPUBDEST)/.volatile $(addprefix $(EPUBDEST)/,$(notdir $(EPUBESC)))

uninstall: uninstall-pdf

validate: validate-docbook validate-xhtml

# create a local cache of post-processed files
$(CACHE)/.volatile:
	mkdir -p $(CACHE) || true
	touch $@

$(CACHEO)/.volatile: $(CACHE)/.volatile
	mkdir -p $(CACHEO) || true
	touch $@

$(CACHET)/.volatile: $(CACHE)/.volatile
	mkdir -p $(CACHET) || true
	touch $@

$(CACHE)/jpeg/.volatile: $(CACHE)/.volatile
	mkdir -p $(CACHE)/jpeg || true
	touch $@

$(CACHE)/png/.volatile: $(CACHE)/.volatile
	mkdir -p $(CACHE)/png || true
	touch $@

$(CACHE)/css/.volatile: $(CACHE)/.volatile
	mkdir -p $(CACHE)/css || true
	touch $@

CXHTMLS:=$(notdir $(wildcard *.xhtml))
ATOMS:=$(notdir $(wildcard *.atom))
RSSS:=$(addsuffix .rss,$(basename $(ATOMS)))
CEXHTMLS:=$(subst :,\:,$(CXHTMLS)) $(addsuffix .xhtml,$(basename $(ATOMS)))
CDOCBOOKS:=$(addsuffix .docbook,$(basename $(CEXHTMLS)))
DXHTMLS:=$(addsuffix .dnt.xhtml,$(basename $(CEXHTMLS))) $(addsuffix .nodnt.xhtml,$(basename $(CEXHTMLS)))
DHTMLS:=$(addsuffix .html,$(basename $(DXHTMLS)))
JPEGS:=$(notdir $(addsuffix .jpeg,$(basename $(wildcard */*.jpg) $(wildcard */*.jpeg))))
DPNGS:=$(notdir $(addsuffix .png,$(basename $(wildcard */*.png))))
CSSS:=$(notdir $(addsuffix .css,$(basename $(wildcard css/*.css))))

ATOMCACHE:=$(addprefix $(CACHEO)/,$(ATOMS)) $(addprefix $(CACHET)/,$(ATOMS))
RSSCACHE:=$(addprefix $(CACHEO)/,$(RSSS)) $(addprefix $(CACHET)/,$(RSSS))
DOCBOOKCACHE:=$(addprefix $(CACHEO)/,$(CDOCBOOKS)) $(addprefix $(CACHET)/,$(CDOCBOOKS))
XHTMLCACHE:=$(addprefix $(CACHEO)/,$(DXHTMLS)) $(addprefix $(CACHET)/,$(DXHTMLS))
HTMLCACHE:=$(addprefix $(CACHEO)/,$(DHTMLS)) $(addprefix $(CACHET)/,$(DHTMLS))
JPEGCACHE:=$(addprefix $(CACHE)/jpeg/,$(JPEGS))
PNGCACHE:=$(addprefix $(CACHE)/png/,$(DPNGS))
CSSCACHE:=$(addprefix $(CACHE)/css/,$(CSSS))

INLINEIMG:=$(addsuffix .base64.xml,$(JPEGCACHE) $(PNGCACHE))
INLINECSS:=$(addsuffix .xml,$(CSSCACHE))

GZIPCACHE:=$(addsuffix .gz,$(ATOMCACHE) $(RSSCACHE) $(DOCBOOKCACHE) $(XHTMLCACHE) $(HTMLCACHE) $(JPEGCACHE) $(PNGCACHE) $(CSSCACHE))

inlinecss: $(INLINECSS)
inlineimg: $(INLINEIMG)

$(CACHEO)/%.xhtml: %.xhtml xslt/atom-merge.xslt $(CACHEO)/.volatile xslt/xhtml-pre-process.xslt makefile
	$(XSLTPROC) $(XSLTPROCCACHEOARGS) xslt/xhtml-pre-process.xslt $< > $@

$(CACHEO)/%.atom: %.atom $(ATOMS) xslt/atom-merge.xslt $(CACHEO)/.volatile xslt/xhtml-pre-process.xslt xslt/atom-style-ef.gy.xslt xslt/atom-sort.xslt makefile
	$(XSLTPROC) $(XSLTPROCCACHEOARGS) xslt/atom-merge.xslt $< |\
		$(XSLTPROC) $(XSLTPROCCACHEOARGS) xslt/xhtml-pre-process.xslt -|\
		$(XSLTPROC) $(XSLTPROCCACHEOARGS) xslt/atom-style-ef.gy.xslt -|\
		$(XSLTPROC) $(XSLTPROCCACHEOARGS) xslt/atom-sort.xslt - > $@

$(CACHEO)/%.rss: $(CACHEO)/%.atom xslt/rss-transcode-atom.xslt makefile
	$(XSLTPROC) $(XSLTPROCCACHEOARGS) xslt/rss-transcode-atom.xslt $< > $@

$(CACHEO)/%.xhtml: $(CACHEO)/%.atom xslt/xhtml-transcode-atom.xslt makefile
	$(XSLTPROC) $(XSLTPROCCACHEOARGS) xslt/xhtml-transcode-atom.xslt $< > $@

$(CACHEO)/%.dnt.xhtml: $(CACHEO)/%.xhtml xslt/xhtml-style-ef.gy.xslt xslt/xhtml-navigation.xslt xslt/xhtml-post-process.xslt xslt/xhtml-merge.xslt makefile social-metadata.xml authors.xml components
	$(XSLTPROC) $(XSLTPROCCACHEOARGS) --stringparam collection "$*" --stringparam DNT 1 xslt/xhtml-style-ef.gy.xslt $< |\
		$(XSLTPROC) $(XSLTPROCCACHEOARGS) --stringparam DNT 1 xslt/xhtml-navigation.xslt - |\
		$(XSLTPROC) $(XSLTPROCCACHEOARGS) xslt/xhtml-post-process.xslt - |\
		$(XSLTPROC) $(XSLTPROCCACHEOARGS) xslt/xhtml-merge.xslt - > $@

$(CACHEO)/%.nodnt.xhtml: $(CACHEO)/%.xhtml xslt/xhtml-style-ef.gy.xslt xslt/xhtml-navigation.xslt xslt/xhtml-post-process.xslt xslt/xhtml-merge.xslt makefile social-metadata.xml authors.xml components
	$(XSLTPROC) $(XSLTPROCCACHEOARGS) --stringparam collection "$*" --stringparam DNT 0 xslt/xhtml-style-ef.gy.xslt $< |\
		$(XSLTPROC) $(XSLTPROCCACHEOARGS) --stringparam DNT 0 xslt/xhtml-navigation.xslt - |\
		$(XSLTPROC) $(XSLTPROCCACHEOARGS) xslt/xhtml-post-process.xslt - |\
		$(XSLTPROC) $(XSLTPROCCACHEOARGS) xslt/xhtml-merge.xslt - > $@

$(CACHEO)/%.html: $(CACHEO)/%.xhtml xslt/html-post-process.xslt makefile
	$(XSLTPROC) $(XSLTPROCCACHEOARGS) xslt/html-post-process.xslt $< > $@

$(CACHEO)/%.docbook: $(CACHEO)/%.atom xslt/docbook-transcode-xhtml.xslt xslt/docbook-transcode-atom.xslt makefile
	$(XSLTPROC) $(XSLTPROCCACHEOARGS) xslt/docbook-transcode-xhtml.xslt $< |\
		$(XSLTPROC) $(XSLTPROCCACHEOARGS) xslt/docbook-transcode-atom.xslt - > $@

$(CACHEO)/%.docbook: %.xhtml xslt/xhtml-pre-process.xslt xslt/docbook-transcode-xhtml.xslt makefile
	$(XSLTPROC) $(XSLTPROCCACHEOARGS) xslt/xhtml-pre-process.xslt $< |\
		$(XSLTPROC) $(XSLTPROCCACHEOARGS) xslt/docbook-transcode-xhtml.xslt - > $@

$(CACHET)/%.xhtml: %.xhtml xslt/atom-merge.xslt $(CACHET)/.volatile xslt/xhtml-pre-process.xslt makefile
	$(XSLTPROC) $(XSLTPROCCACHETARGS) xslt/xhtml-pre-process.xslt $< > $@

$(CACHET)/%.atom: %.atom $(ATOMS) xslt/atom-merge.xslt $(CACHET)/.volatile xslt/xhtml-pre-process.xslt xslt/atom-style-ef.gy.xslt xslt/atom-sort.xslt makefile
	$(XSLTPROC) $(XSLTPROCCACHETARGS) xslt/atom-merge.xslt $< |\
		$(XSLTPROC) $(XSLTPROCCACHETARGS) xslt/xhtml-pre-process.xslt -|\
		$(XSLTPROC) $(XSLTPROCCACHETARGS) xslt/atom-style-ef.gy.xslt -|\
		$(XSLTPROC) $(XSLTPROCCACHETARGS) xslt/atom-sort.xslt - > $@

$(CACHET)/%.rss: $(CACHET)/%.atom xslt/rss-transcode-atom.xslt makefile
	$(XSLTPROC) $(XSLTPROCCACHETARGS) xslt/rss-transcode-atom.xslt $< > $@

$(CACHET)/%.xhtml: $(CACHET)/%.atom xslt/xhtml-transcode-atom.xslt makefile
	$(XSLTPROC) $(XSLTPROCCACHETARGS) xslt/xhtml-transcode-atom.xslt $< > $@

$(CACHET)/%.dnt.xhtml: $(CACHET)/%.xhtml xslt/xhtml-style-ef.gy.xslt xslt/xhtml-navigation.xslt xslt/xhtml-post-process.xslt xslt/xhtml-merge.xslt makefile social-metadata.xml authors.xml components
	$(XSLTPROC) $(XSLTPROCCACHETARGS) --stringparam collection "$*" --stringparam DNT 1 xslt/xhtml-style-ef.gy.xslt $< |\
		$(XSLTPROC) $(XSLTPROCCACHETARGS) --stringparam DNT 1 xslt/xhtml-navigation.xslt - |\
		$(XSLTPROC) $(XSLTPROCCACHETARGS) xslt/xhtml-post-process.xslt - |\
		$(XSLTPROC) $(XSLTPROCCACHETARGS) xslt/xhtml-merge.xslt - > $@

$(CACHET)/%.nodnt.xhtml: $(CACHET)/%.xhtml xslt/xhtml-style-ef.gy.xslt xslt/xhtml-navigation.xslt xslt/xhtml-post-process.xslt xslt/xhtml-merge.xslt makefile social-metadata.xml authors.xml components
	$(XSLTPROC) $(XSLTPROCCACHETARGS) --stringparam collection "$*" --stringparam DNT 0 xslt/xhtml-style-ef.gy.xslt $< |\
		$(XSLTPROC) $(XSLTPROCCACHETARGS) --stringparam DNT 0 xslt/xhtml-navigation.xslt - |\
		$(XSLTPROC) $(XSLTPROCCACHETARGS) xslt/xhtml-post-process.xslt - |\
		$(XSLTPROC) $(XSLTPROCCACHETARGS) xslt/xhtml-merge.xslt - > $@

$(CACHET)/%.html: $(CACHET)/%.xhtml xslt/html-post-process.xslt makefile
	$(XSLTPROC) $(XSLTPROCCACHETARGS) xslt/html-post-process.xslt $< > $@

$(CACHET)/%.docbook: $(CACHET)/%.atom xslt/docbook-transcode-xhtml.xslt xslt/docbook-transcode-atom.xslt makefile
	$(XSLTPROC) $(XSLTPROCCACHETARGS) xslt/docbook-transcode-xhtml.xslt $< |\
		$(XSLTPROC) $(XSLTPROCCACHETARGS) xslt/docbook-transcode-atom.xslt - > $@

$(CACHET)/%.docbook: %.xhtml xslt/xhtml-pre-process.xslt xslt/docbook-transcode-xhtml.xslt makefile
	$(XSLTPROC) $(XSLTPROCCACHETARGS) xslt/xhtml-pre-process.xslt $< |\
		$(XSLTPROC) $(XSLTPROCCACHETARGS) xslt/docbook-transcode-xhtml.xslt - > $@

$(CACHE)/jpeg/%.jpeg: jpeg/%.jpeg $(CACHE)/jpeg/.volatile makefile
	convert "$<" -resize 921600@\> -strip -quality 86 "$@"

$(CACHE)/jpeg/%.jpeg: jpeg/%.jpg $(CACHE)/jpeg/.volatile makefile
	convert "$<" -resize 921600@\> -strip -quality 86 "$@"

$(CACHE)/png/%.png: png/%.png $(CACHE)/png/.volatile makefile
	convert "$<" -resize 921600@\> -strip "$@"

$(CACHE)/css/%.css: css/%.css $(CACHE)/css/.volatile makefile
	cssmin < $< | sed -r -e 's/calc\(([0-9%em]+)\+([0-9%em]+)\)/calc(\1 + \2)/' > $@

$(CACHE)/css/%.css.xml: $(CACHE)/css/%.css makefile
	echo "<?xml version='1.0' encoding='utf-8'?><style xmlns='http://www.w3.org/1999/xhtml' type='text/css'><![CDATA[" > $@
	cat $< >> $@
	echo "]]></style>" >> $@

# global navigation index
$(CACHE)/index.xml: $(CACHEO)/everything.atom xslt/index-transcode-atom.xslt makefile $(CACHE)/.volatile
	$(XSLTPROC) $(XSLTPROCARGS) xslt/index-transcode-atom.xslt $< > $@

xhtmlcache: $(XHTMLCACHE)
htmlcache: $(HTMLCACHE)
atomcache: $(ATOMCACHE)
rsscache: $(RSSCACHE)
docbookcache: $(DOCBOOKCACHE)
jpegcache: $(JPEGCACHE)
pngcache: $(PNGCACHE)
csscache: $(CSSCACHE)

cache: xhtmlcache atomcache rsscache docbookcache htmlcache jpegcache pngcache csscache

$(CACHE)/%.gz: $(CACHE)/%
	gzip -knf9 $<

$(CACHE)/%.base64: $(CACHE)/%
	openssl base64 -A -in $< -out $@

$(CACHE)/jpeg/%.base64.xml: $(CACHE)/jpeg/%.base64
	echo "<?xml version='1.0' encoding='utf-8'?><img xmlns='http://www.w3.org/1999/xhtml' src='data:image/jpeg;base64,$$(cat $<)'/>" > $@

$(CACHE)/png/%.base64.xml: $(CACHE)/png/%.base64
	echo "<?xml version='1.0' encoding='utf-8'?><img xmlns='http://www.w3.org/1999/xhtml' src='data:image/png;base64,$$(cat $<)'/>" > $@

zip: $(GZIPCACHE)

# $(THIRDPARTY) module downloads
$(THIRDPARTY)/.volatile:
	mkdir -p $(THIRDPARTY) || true
	touch $@

$(THIRDPARTY)/highlight.js/.git/HEAD: $(THIRDPARTY)/.volatile
	cd $(THIRDPARTY) && (git clone https://github.com/isagalaev/highlight.js || (cd highlight.js && git pull))

$(THIRDPARTY)/highlight.js/src/styles/default.css: $(THIRDPARTY)/highlight.js/.git/HEAD

$(THIRDPARTY)/jquery/.git/HEAD: $(THIRDPARTY)/.volatile
	cd $(THIRDPARTY) && (git clone https://github.com/jquery/jquery || (cd jquery && git pull))

# $(THIRDPARTY) module builds
$(THIRDPARTY)/highlight.js/build/highlight.pack.js: $(THIRDPARTY)/highlight.js/.git/HEAD
	cd $(THIRDPARTY)/highlight.js && python3 tools/build.py :common x86asm

$(THIRDPARTY)/jquery/dist/jquery.js $(THIRDPARTY)/jquery/dist/jquery.min.js: $(THIRDPARTY)/jquery/.git/HEAD
	cd $(THIRDPARTY)/jquery && npm run build

# $(THIRDPARTY) module installation
js/jquery.js: $(THIRDPARTY)/jquery/dist/jquery.min.js
	install $< $@

# download remote JavaScript files
js/disqus-embed.js:
	$(CURL) -L https://go.disqus.com/embed.js -o $@

js/highlight.js: $(THIRDPARTY)/highlight.js/build/highlight.pack.js js/highlight-setup.js
	cat $^ >> $@

js/highlight+disqus-embed.js: js/highlight.js js/disqus-embed.js
	cat $^ > $@

# download remote CSS files and process local ones
css/highlight.css: $(THIRDPARTY)/highlight.js/src/styles/default.css
	cat $^ > $@

css/ef.gy+highlight.css: css/ef.gy.css css/highlight.css
	cat $^ > $@

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
