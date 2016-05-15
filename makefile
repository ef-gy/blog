# domain settings
DOMAIN:=ef.gy
HIDDENSERVICE:=vturtipc7vmz6xjy.onion

# directories
THIRDPARTY:=.third-party
CACHE:=.cache
CACHEO:=$(CACHE)/$(DOMAIN)
CACHET:=$(CACHE)/$(HIDDENSERVICE)

# programmes
XSLTPROC:=xsltproc
R:=R
SQLITE3:=sqlite3
CURL:=curl -s

# source files
RS:=$(wildcard src/*.r)
DOCUMENTS:=$(filter-out about.xhtml public-keys.xhtml,$(wildcard *.xhtml) $(wildcard *.atom))

# target files
SVGS:=$(addsuffix .svg,$(basename $(notdir $(RS))))
PNGS:=$(addprefix png/rasterised/,$(addsuffix .png,$(basename $(SVGS) $(basename $(notdir $(wildcard *.svg))))))

# escaped target file names
PNGESC:=$(subst :,\:,$(PNGS))

DATABASES:=life.sqlite3
XSLTPROCCACHEOARGS:=--novalid --stringparam baseURI "https://$(DOMAIN)" --stringparam documentRoot "$$(pwd)"
XSLTPROCCACHETARGS:=--novalid --stringparam baseURI "http://$(HIDDENSERVICE)" --stringparam documentRoot "$$(pwd)"
XSLTPROCARGS:=$(XSLTPROCCACHEOARGS)

# files to be downloaded
JSDOWNLOADS:=js/highlight.js

# don't delete intermediary files
.SECONDARY:

# meta rules
update: index pngs

all: index components cache zip
clean:
	rm -f $(DATABASES) $(INDICES); true
	rm -f css/*+*.css $(JSDOWNLOADS)

components: svgs csss jss pngs inlinecss

scrub: clean

databases: $(DATABASES)
index: $(CACHE)/index.xml

svgs: $(SVGS)
pngs: $(PNGESC)

csss: css/blog+highlight.css
jss: $(JSDOWNLOADS) js/highlight.js js/jquery.js

# create a local cache of post-processed files
$(CACHE)/.volatile $(CACHEO)/.volatile $(CACHET)/.volatile $(CACHE)/jpeg/.volatile $(CACHE)/png/.volatile $(CACHE)/css/.volatile $(CACHE)/js/.volatile $(CACHE)/svg/.volatile:
	mkdir -p $(dir $@) || true
	touch $@

MDXHTMLS:=$(addsuffix .xhtml,$(basename $(wildcard *.md)))
XHTMLS:=$(notdir $(wildcard *.xhtml) $(wildcard *.md))
XHTMLESCS:=$(subst :,\:,$(filter-out $(MDXHTMLS),$(XHTMLS)))
ATOMS:=$(filter-out everything.atom site.atom,$(notdir $(wildcard *.atom))) everything.atom site.atom
CEXHTMLS:=$(subst :,\:,$(XHTMLS)) $(addsuffix .xhtml,$(basename $(ATOMS)))
DXHTMLS:=$(addsuffix .dnt.xhtml,$(basename $(CEXHTMLS))) $(addsuffix .nodnt.xhtml,$(basename $(CEXHTMLS)))
DHTMLS:=$(addsuffix .html,$(basename $(DXHTMLS)))
JPEGS:=$(notdir $(addsuffix .jpeg,$(basename $(wildcard */*.jpg) $(wildcard */*.jpeg))))
DPNGS:=$(notdir $(addsuffix .png,$(basename $(wildcard */*.png))))
CSSS:=$(notdir $(addsuffix .css,$(basename $(wildcard css/*.css))))
DJSS:=$(notdir $(addsuffix .js,$(basename $(wildcard js/*.js))))

ATOMCACHE:=$(addprefix $(CACHEO)/,$(ATOMS)) $(addprefix $(CACHET)/,$(ATOMS))
DUMBATOMCACHE:=$(addsuffix .dumb.atom,$(basename $(ATOMCACHE)))
XHTMLCACHE:=$(addprefix $(CACHEO)/,$(DXHTMLS)) $(addprefix $(CACHET)/,$(DXHTMLS))
HTMLCACHE:=$(addprefix $(CACHEO)/,$(DHTMLS)) $(addprefix $(CACHET)/,$(DHTMLS))
JPEGCACHE:=$(addprefix $(CACHE)/jpeg/,$(JPEGS))
PNGCACHE:=$(addprefix $(CACHE)/png/,$(DPNGS))
CSSCACHE:=$(addprefix $(CACHE)/css/,$(CSSS))
JSCACHE:=$(addprefix $(CACHE)/js/,$(DJSS))
SVGCACHE:=$(addprefix $(CACHE)/svg/,$(SVGS) $(wildcard *.svg))
METACACHE:=$(addprefix $(CACHE)/,index.xml .gitignore) $(CACHEO)/sitemap.xml $(CACHET)/sitemap.xml

INLINECSS:=$(addsuffix .xml,$(CSSCACHE))

CACHEFILES:=$(ATOMCACHE) $(DUMBATOMCACHE) $(XHTMLCACHE) $(HTMLCACHE) $(JPEGCACHE) $(PNGCACHE) $(CSSCACHE) $(JSCACHE) $(SVGCACHE) $(METACACHE)

GZIPCACHE:=$(addsuffix .gz,$(CACHEFILES))

inlinecss: $(INLINECSS)

$(CACHEO)/%.xhtml: %.xhtml src/atom-merge.xslt $(CACHEO)/.volatile src/xhtml-pre-process.xslt makefile components $(CACHE)/index.xml
	$(XSLTPROC) $(XSLTPROCCACHEOARGS) src/xhtml-pre-process.xslt $< > $@

$(CACHET)/%.xhtml: %.xhtml src/atom-merge.xslt $(CACHET)/.volatile src/xhtml-pre-process.xslt makefile components $(CACHE)/index.xml
	$(XSLTPROC) $(XSLTPROCCACHETARGS) src/xhtml-pre-process.xslt $< > $@

%.xhtml: %.md makefile src/xhtml-fix-markdown.xslt components
	echo "<?xml version=\"1.0\" encoding=\"utf-8\" ?><html xmlns=\"http://www.w3.org/1999/xhtml\" xml:lang=\"en\"><head><meta name=\"unix:name\" content=\"$*\"/><meta name=\"date\" content=\"$$(git log --date=iso "$*.md"|grep 'Date:'|sed -E 's/Date:\s*(.+) (.+) (...)(..)/\1T\2\3:\4/'|sort|head -n1)\"/><meta name=\"mtime\" content=\"$$(git log --date=iso "$*.md"|grep 'Date:'|sed -E 's/Date:\s*(.+) (.+) (...)(..)/\1T\2\3:\4/'|sort|tail -n1)\"/><meta name=\"author\" content=\"$$(git log "$*.md" |grep Author:|sed -E 's/Author: (.+) <.+>/\1/'|tail -n1)\"/></head><body>" > $@
	markdown $< >> $@
	echo '</body></html>' >> $@
	xsltproc -o $@ src/xhtml-fix-markdown.xslt $@
	grep -q -F $@ .gitignore || echo $@ >> .gitignore

$(CACHE)/%.dumb.atom: $(CACHE)/%.atom src/atom-filter-dumb.xslt
	$(XSLTPROC) src/atom-filter-dumb.xslt $< > $@

$(CACHEO)/%.atom: %.atom $(ATOMS) src/atom-merge.xslt $(CACHEO)/.volatile src/xhtml-pre-process.xslt src/atom-style-ef.gy.xslt src/atom-sort.xslt makefile mdxhtmls components
	$(XSLTPROC) $(XSLTPROCCACHEOARGS) src/atom-merge.xslt $< |\
		$(XSLTPROC) $(XSLTPROCCACHEOARGS) src/xhtml-pre-process.xslt -|\
		$(XSLTPROC) $(XSLTPROCCACHEOARGS) src/atom-style-ef.gy.xslt -|\
		$(XSLTPROC) $(XSLTPROCCACHEOARGS) src/atom-sort.xslt - > $@

$(CACHEO)/%.xhtml: $(CACHEO)/%.atom src/xhtml-transcode-atom.xslt makefile
	$(XSLTPROC) $(XSLTPROCCACHEOARGS) src/xhtml-transcode-atom.xslt $< > $@

$(CACHEO)/%.dnt.xhtml: $(CACHEO)/%.xhtml src/xhtml-style-ef.gy.xslt src/xhtml-navigation.xslt src/xhtml-post-process.xslt src/xhtml-merge.xslt makefile social-metadata.xml authors.xml components
	$(XSLTPROC) $(XSLTPROCCACHEOARGS) --stringparam collection "$*" --stringparam DNT 1 src/xhtml-style-ef.gy.xslt $< |\
		$(XSLTPROC) $(XSLTPROCCACHEOARGS) --stringparam DNT 1 src/xhtml-navigation.xslt - |\
		$(XSLTPROC) $(XSLTPROCCACHEOARGS) src/xhtml-post-process.xslt - |\
		$(XSLTPROC) $(XSLTPROCCACHEOARGS) src/xhtml-merge.xslt - > $@

$(CACHEO)/%.nodnt.xhtml: $(CACHEO)/%.xhtml src/xhtml-style-ef.gy.xslt src/xhtml-navigation.xslt src/xhtml-post-process.xslt src/xhtml-merge.xslt makefile social-metadata.xml authors.xml components
	$(XSLTPROC) $(XSLTPROCCACHEOARGS) --stringparam collection "$*" --stringparam DNT 0 src/xhtml-style-ef.gy.xslt $< |\
		$(XSLTPROC) $(XSLTPROCCACHEOARGS) --stringparam DNT 0 src/xhtml-navigation.xslt - |\
		$(XSLTPROC) $(XSLTPROCCACHEOARGS) src/xhtml-post-process.xslt - |\
		$(XSLTPROC) $(XSLTPROCCACHEOARGS) src/xhtml-merge.xslt - > $@

$(CACHEO)/%.html: $(CACHEO)/%.xhtml src/html-post-process.xslt makefile
	$(XSLTPROC) $(XSLTPROCCACHEOARGS) src/html-post-process.xslt $< > $@

$(CACHET)/%.atom: %.atom $(ATOMS) src/atom-merge.xslt $(CACHET)/.volatile src/xhtml-pre-process.xslt src/atom-style-ef.gy.xslt src/atom-sort.xslt makefile mdxhtmls components
	$(XSLTPROC) $(XSLTPROCCACHETARGS) src/atom-merge.xslt $< |\
		$(XSLTPROC) $(XSLTPROCCACHETARGS) src/xhtml-pre-process.xslt -|\
		$(XSLTPROC) $(XSLTPROCCACHETARGS) src/atom-style-ef.gy.xslt -|\
		$(XSLTPROC) $(XSLTPROCCACHETARGS) src/atom-sort.xslt - > $@

$(CACHET)/%.xhtml: $(CACHET)/%.atom src/xhtml-transcode-atom.xslt makefile
	$(XSLTPROC) $(XSLTPROCCACHETARGS) src/xhtml-transcode-atom.xslt $< > $@

$(CACHET)/%.dnt.xhtml: $(CACHET)/%.xhtml src/xhtml-style-ef.gy.xslt src/xhtml-navigation.xslt src/xhtml-post-process.xslt src/xhtml-merge.xslt makefile social-metadata.xml authors.xml components
	$(XSLTPROC) $(XSLTPROCCACHETARGS) --stringparam collection "$*" --stringparam DNT 1 src/xhtml-style-ef.gy.xslt $< |\
		$(XSLTPROC) $(XSLTPROCCACHETARGS) --stringparam DNT 1 src/xhtml-navigation.xslt - |\
		$(XSLTPROC) $(XSLTPROCCACHETARGS) src/xhtml-post-process.xslt - |\
		$(XSLTPROC) $(XSLTPROCCACHETARGS) src/xhtml-merge.xslt - > $@

$(CACHET)/%.nodnt.xhtml: $(CACHET)/%.xhtml src/xhtml-style-ef.gy.xslt src/xhtml-navigation.xslt src/xhtml-post-process.xslt src/xhtml-merge.xslt makefile social-metadata.xml authors.xml components
	$(XSLTPROC) $(XSLTPROCCACHETARGS) --stringparam collection "$*" --stringparam DNT 0 src/xhtml-style-ef.gy.xslt $< |\
		$(XSLTPROC) $(XSLTPROCCACHETARGS) --stringparam DNT 0 src/xhtml-navigation.xslt - |\
		$(XSLTPROC) $(XSLTPROCCACHETARGS) src/xhtml-post-process.xslt - |\
		$(XSLTPROC) $(XSLTPROCCACHETARGS) src/xhtml-merge.xslt - > $@

$(CACHET)/%.html: $(CACHET)/%.xhtml src/html-post-process.xslt makefile
	$(XSLTPROC) $(XSLTPROCCACHETARGS) src/html-post-process.xslt $< > $@

$(CACHE)/svg/%.svg: %.svg $(CACHE)/svg/.volatile src/svg-style-ef.gy.xslt makefile
	$(XSLTPROC) $(XSLTPROCCACHEOARGS) src/svg-style-ef.gy.xslt $< > $@

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

$(CACHE)/js/%.js: js/%.js $(CACHE)/js/.volatile makefile
	cat $< > $@

$(CACHEO)/sitemap.xml: $(CACHEO)/everything.atom src/sitemap-transcode-atom.xslt
	$(XSLTPROC) $(XSLTPROCCACHEOARGS) src/sitemap-transcode-atom.xslt $< > $@

$(CACHET)/sitemap.xml: $(CACHET)/everything.atom src/sitemap-transcode-atom.xslt
	$(XSLTPROC) $(XSLTPROCCACHETARGS) src/sitemap-transcode-atom.xslt $< > $@

# global navigation index
$(CACHE)/index.xml: $(CACHEO)/everything.atom src/index-transcode-atom.xslt makefile $(CACHE)/.volatile
	$(XSLTPROC) $(XSLTPROCARGS) src/index-transcode-atom.xslt $< > $@

mdxhtmls: $(MDXHTMLS)
xhtmlcache: $(XHTMLCACHE)
htmlcache: $(HTMLCACHE)
atomcache: $(ATOMCACHE) $(DUMBATOMCACHE)
jpegcache: $(JPEGCACHE)
pngcache: $(PNGCACHE)
csscache: $(CSSCACHE)
jscache: $(JSCACHE)
svgcache: $(SVGCACHE)

$(CACHE)/.git/config:
	mkdir -p $(CACHE); cd $(CACHE) && git init

$(CACHE)/.gitignore:
	echo ".volatile" > $@
	echo "*.gz" >> $@
	echo "*.xhtml" >> $@
	echo "!*dnt.xhtml" >> $@
	echo "*.css.xml" >> $@

metacache: $(METACACHE)

cache: $(CACHE)/.git/config metacache xhtmlcache atomcache htmlcache jpegcache pngcache csscache jscache svgcache
	cd $(CACHE) && git add $(CACHEFILES:$(CACHE)/%=%) && git commit -m "cache update"

$(CACHE)/%.gz: $(CACHE)/%
	gzip -knf9 $<

zip: cache $(GZIPCACHE)

# third-party module downloads
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
js/highlight.js: $(THIRDPARTY)/highlight.js/build/highlight.pack.js js/highlight-setup.js
	cat $^ >> $@

# download remote CSS files and process local ones
css/highlight.css: $(THIRDPARTY)/highlight.js/src/styles/default.css
	cat $^ > $@

css/blog+highlight.css: css/blog.css css/highlight.css
	cat $^ > $@

# .volatile files
png/rasterised/.volatile:
	mkdir -p png/rasterised; true
	touch $@

# SVG rasterisation rules
png/rasterised/%.png: %.svg png/rasterised/.volatile
	rsvg-convert --keep-aspect-ratio --width 1920 $< -o $@

# pattern rule for R graphs
%.svg: src/%.r
	$(R) --no-save < $<

# pattern rules for databases
%.sqlite3: src/%.sql
	rm -f $@ && $(SQLITE3) $@ < $<

# specific rules for silly gadgets
game-of-life.xslt.xml::
	$(XSLTPROC) $(XSLTPROCARGS) src/0p-game-of-life.xslt $@

game-of-life.xml: life.sqlite3
	echo '<?xml version="1.0"?><game-of-life xmlns="http://ef.gy/2013/0p">' > $@
	echo "select fragment from vxmlfragment;" | $(SQLITE3) $< >> $@
	echo '</game-of-life>' >> $@

game-of-life.svg: game-of-life.xml src/svg-0p-game-of-life.xslt
	$(XSLTPROC) $(XSLTPROCARGS) -o $@ src/svg-0p-game-of-life.xslt $<

everything.atom: $(XHTMLESCS) makefile
	echo "<?xml version=\"1.0\" encoding=\"utf-8\"?><feed xmlns=\"http://www.w3.org/2005/Atom\" xml:id=\"$(basename $@)\" xmlns:xlink=\"http://www.w3.org/1999/xlink\"><title>$(DOMAIN)</title>" > $@
	for file in $(basename $(sort $(XHTMLESCS))); do \
	  echo "<entry xlink:href=\"$${file}.xhtml\"/>"; \
	done >> $@
	echo "</feed>" >> $@

social-metadata.xml::
	wst-sitemap-xml https://$(DOMAIN)/sitemap.xml > $@
	$(XSLTPROC) --stringparam base https://$(DOMAIN)/ -o $@ src/social-sort.xslt $@

popular.atom: social-metadata.xml src/atom-transcode-social.xslt
	$(XSLTPROC) --stringparam domain $(DOMAIN) -o $@ src/atom-transcode-social.xslt $<

latest.atom: everything.atom src/atom-filter-latest.xslt
	$(XSLTPROC) --stringparam documentRoot "$$(pwd)" src/atom-merge.xslt $< | \
		$(XSLTPROC) --stringparam domain $(DOMAIN) -o $@ src/atom-filter-latest.xslt -

site.atom: popular.atom latest.atom
	echo "<?xml version=\"1.0\" encoding=\"utf-8\"?><feed xmlns=\"http://www.w3.org/2005/Atom\" xml:id=\"$(basename $@)\" xmlns:xlink=\"http://www.w3.org/1999/xlink\"><title>$(DOMAIN)</title><subtitle>the latest and greatest</subtitle>" > $@
	for file in $^; do echo "<feed xlink:href=\"$${file}\"/>"; done >> $@
	echo "</feed>" >> $@
	$(XSLTPROC) --stringparam documentRoot $$(pwd) -o "$@" src/atom-merge-plain.xslt "$@"
	$(XSLTPROC) -o "$@" src/atom-dedupe.xslt "$@"
