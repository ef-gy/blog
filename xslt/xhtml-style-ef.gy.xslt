<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
              xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
              xmlns:xhtml="http://www.w3.org/1999/xhtml"
              xmlns:social="http://ef.gy/2012/social"
              xmlns:atom="http://www.w3.org/2005/Atom"
              xmlns:data="http://ef.gy/2013/data"
              xmlns:math="http://www.w3.org/1998/Math/MathML"
              xmlns="http://www.w3.org/1999/xhtml"
              exclude-result-prefixes="xhtml data"
              version="1.0">
  <xsl:output method="xml" version="1.0" encoding="UTF-8"
              doctype-public="-//W3C//DTD XHTML 1.1//EN"
              doctype-system="http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd"
              indent="no"
              media-type="application/xhtml+xml" />

  <xsl:param name="target"/>
  <xsl:param name="collection"/>
  <xsl:param name="documentRoot"/>
  <xsl:param name="baseURI"/>
  <xsl:param name="disqusShortname"/>

  <xsl:variable name="authors" select="document(concat($documentRoot,'/authors.xml'))/data:data/data:author"/>
  <xsl:variable name="indices" select="document(concat($documentRoot,'/index.xml'))/data:data/data:index"/>

  <data:month-name number="01">January</data:month-name>
  <data:month-name number="02">February</data:month-name>
  <data:month-name number="03">March</data:month-name>
  <data:month-name number="04">April</data:month-name>
  <data:month-name number="05">May</data:month-name>
  <data:month-name number="06">June</data:month-name>
  <data:month-name number="07">July</data:month-name>
  <data:month-name number="08">August</data:month-name>
  <data:month-name number="09">September</data:month-name>
  <data:month-name number="10">October</data:month-name>
  <data:month-name number="11">November</data:month-name>
  <data:month-name number="12">December</data:month-name>

  <xsl:variable name="decorateWithCollection" select="(string-length($target) > 0) and (string-length($collection) > 0) and not (//xhtml:body[@id='feed'])"/>

  <xsl:strip-space elements="*" />
  <xsl:preserve-space elements="xhtml:pre" />

  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()" />
    </xsl:copy>
  </xsl:template>

  <xsl:template match="xhtml:html">
    <html>
      <xsl:apply-templates select="@*|node()" />
    </html>
  </xsl:template>

  <xsl:template match="xhtml:head">
    <xsl:variable name="myname" select="xhtml:meta[@name='unix:name']/@content"/>
    <xsl:variable name="suri"><xsl:choose>
      <xsl:when test="(string-length($target) > 0) and (string-length($collection) > 0)">/<xsl:value-of select="$target"/>@<xsl:value-of select="$collection"/></xsl:when>
      <xsl:otherwise>/<xsl:value-of select="xhtml:meta[@name='unix:name']/@content"/></xsl:otherwise>
    </xsl:choose></xsl:variable>
    <xsl:variable name="pre" select="$indices[@href=$suri][1]/data:previous"/>
    <xsl:variable name="post" select="$indices[@href=$suri][1]/data:next"/>
    <xsl:variable name="author" select="xhtml:meta[@name='author']/@content"/>
    <xsl:variable name="authordata" select="$authors[@name=$author][1]"/>
    <head>
      <link href="/css/ef.gy" rel="stylesheet" type="text/css" />
      <xsl:if test="not(xhtml:meta[@name='category'][@content='auxiliary'])">
        <link rel="alternate" type="application/pdf" href="/pdf/{$collection}"/>
        <link rel="alternate" type="application/x-mobipocket-ebook" href="/mobi/{$collection}.mobi"/>
        <link rel="alternate" type="application/epub+zip" href="/epub/{$collection}.epub"/>
        <link rel="alternate" type="application/docbook+xml" href="/docbook/{$collection}"/>
      </xsl:if>
      <xsl:apply-templates select="@*|node()" />
      <xsl:choose>
        <xsl:when test="//xhtml:link[@href=concat($baseURI,'/atom/site')]" />
        <xsl:otherwise>
          <link rel="alternate" type="application/atom+xml" href="/atom/site" />
        </xsl:otherwise>
      </xsl:choose>
      <xsl:choose>
        <xsl:when test="//xhtml:link[@href=concat($baseURI,'/rss/site')]" />
        <xsl:otherwise>
          <link rel="alternate" type="application/rss+xml" href="/rss/site" />
        </xsl:otherwise>
      </xsl:choose>
      <xsl:if test="$pre">
        <link rel="prev" href="{$pre/@href}" title="{$pre/@title}"/>
      </xsl:if>
      <xsl:if test="$post">
        <link rel="next" href="{$post/@href}" title="{$post/@title}"/>
      </xsl:if>
      <xsl:if test="$authordata/@googleplus">
        <link rel="author" href="https://plus.google.com/{$authordata/@googleplus}"/>
      </xsl:if>
      <xsl:choose>
        <xsl:when test="(xhtml:meta[@name='category']/@content='Pictures') and //xhtml:a[@class='inline-img-src']"><meta name="photo" content="summary_large_image"/><meta name="twitter:image:src" content="{$baseURI}/rasterised{//xhtml:a[@class='inline-img-src'][1]/@href}"/><meta property="og:image" content="{$baseURI}/rasterised{//xhtml:a[@class='inline-img-src'][1]/@href}"/></xsl:when>
        <xsl:when test="(xhtml:meta[@name='category']/@content='Pictures') and //xhtml:img"><meta name="twitter:card" content="photo"/><meta name="twitter:image:src" content="{$baseURI}/{//xhtml:img[1]/@src}"/><meta property="og:image" content="{$baseURI}/{//xhtml:img[1]/@src}"/></xsl:when>
        <xsl:when test="xhtml:meta[@property='og:image']"><meta name="twitter:card" content="summary_large_image"/><meta name="twitter:image:src" content="{xhtml:meta[@property='og:image']/@content}"/></xsl:when>
        <xsl:when test="//xhtml:a[@class='inline-img-src']"><meta name="twitter:card" content="summary_large_image"/><meta name="twitter:image:src" content="{$baseURI}/rasterised{//xhtml:a[@class='inline-img-src'][1]/@href}"/><meta property="og:image" content="{$baseURI}/rasterised{//xhtml:a[@class='inline-img-src'][1]/@href}"/></xsl:when>
        <xsl:when test="//xhtml:img"><meta name="twitter:card" content="summary_large_image"/><meta name="twitter:image:src" content="{$baseURI}/{//xhtml:img[1]/@src}"/><meta property="og:image" content="{$baseURI}/{//xhtml:img[1]/@src}"/></xsl:when>
        <xsl:when test="../@id='unicorn-noms'"><meta name="twitter:card" content="summary_large_image"/><meta name="twitter:image:src" content="{$baseURI}/jpeg/unicorn-noms"/><meta property="og:image" content="{$baseURI}/jpeg/unicorn-noms"/></xsl:when>
        <xsl:when test="../@id='phone'"><meta name="twitter:card" content="summary_large_image"/><meta name="twitter:image:src" content="{$baseURI}/jpeg/corded-phone"/><meta property="og:image" content="{$baseURI}/jpeg/corded-phone"/></xsl:when>
        <xsl:when test="../@id='server-grill'"><meta name="twitter:card" content="summary_large_image"/><meta name="twitter:image:src" content="{$baseURI}/jpeg/7389234452_a0d7b0fd34_o"/><meta property="og:image" content="{$baseURI}/jpeg/7389234452_a0d7b0fd34_o"/></xsl:when>
        <xsl:when test="../@id='hypercube'"><meta name="twitter:card" content="summary_large_image"/><meta name="twitter:image:src" content="{$baseURI}/png/rasterised/4-cube-black-white"/><meta property="og:image" content="{$baseURI}/png/rasterised/4-cube-black-white"/></xsl:when>
        <xsl:otherwise><meta name="twitter:card" content="summary"/></xsl:otherwise>
      </xsl:choose>
      <xsl:if test="$authordata/@twitter">
        <meta name="twitter:site" content="@{$authordata/@twitter}"/> 
        <meta name="twitter:creator" content="@{$authordata/@twitter}"/> 
      </xsl:if>
      <xsl:if test="../descendant::math:math">
        <script type="text/javascript" src="https://c328740.ssl.cf1.rackcdn.com/mathjax/latest/MathJax.js?config=TeX-AMS-MML_HTMLorMML"></script>
      </xsl:if>
      <meta name="twitter:domain" content="ef.gy"/> 
      <meta name="twitter:title" content="{xhtml:title[1]}"/>
      <meta name="twitter:description" content="{xhtml:meta[@name='description']/@content}"/>
      <meta property="og:title" content="{xhtml:title[1]}"/>
      <meta property="og:type" content="article" />
      <meta property="og:url" content="{$baseURI}{$suri}"/>
      <meta property="og:description" content="{xhtml:meta[@name='description']/@content}"/>
      <meta property="og:site_name" content="ef.gy :: le bloeg d'enfer"/>
      <xsl:if test="xhtml:meta[@name='date']">
        <meta property="article:published_time" content="{xhtml:meta[@name='date']/@content}"/>
      </xsl:if>
      <xsl:if test="xhtml:meta[@name='mtime']">
        <meta property="article:modified_time" content="{xhtml:meta[@name='mtime']/@content}"/>
      </xsl:if>
      <meta name="viewport" content="width=device-width, initial-scale=1"/>
      <link href="https://plus.google.com/106167538536350810461" rel="publisher"/>
    </head>
  </xsl:template>

  <xsl:template match="xhtml:a/@href">
    <xsl:choose>
      <xsl:when test="$decorateWithCollection"><xsl:attribute name="href"><xsl:value-of select="concat('/',.,'@',$collection)"/></xsl:attribute></xsl:when>
      <xsl:otherwise><xsl:attribute name="href"><xsl:value-of select="."/></xsl:attribute></xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="xhtml:body">
    <body>
      <xsl:variable name="author" select="/xhtml:html/xhtml:head/xhtml:meta[@name='author']/@content"/>
      <xsl:variable name="authordata" select="$authors[@name=$author][1]"/>
      <xsl:variable name="suri"><xsl:choose>
        <xsl:when test="(string-length($target) > 0) and (string-length($collection) > 0)">/<xsl:value-of select="$target"/>@<xsl:value-of select="$collection"/></xsl:when>
        <xsl:otherwise>/<xsl:value-of select="//xhtml:meta[@name='unix:name']/@content"/></xsl:otherwise>
      </xsl:choose></xsl:variable>
      <xsl:variable name="uri" select="concat($baseURI, $suri)"/>
      <xsl:variable name="uname" select="//xhtml:meta[@name='unix:name']/@content"/>
      <xsl:apply-templates select="@*" />
      <h1><xsl:value-of select="/xhtml:html/xhtml:head/xhtml:title"/></h1>
      <ul>
        <li><a href="/about">About</a></li>
        <li><a href="/site">Blog</a></li>
      </ul>
      <xsl:choose>
        <xsl:when test="$collection='site'">
          <ul id="subfeeds">
            <li>abridged</li>
            <li><a href="/everything">unabridged</a></li>
          </ul>
        </xsl:when>
        <xsl:when test="$collection='everything'">
          <ul id="subfeeds">
            <li><a href="/site">abridged</a></li>
            <li>unabridged</li>
          </ul>
        </xsl:when>
      </xsl:choose>
      <xsl:if test="$uname">
        <social:social url="{$uri}">
          <xsl:copy-of select="$authordata/@twitter"/>
        </social:social>
      </xsl:if>
      <ul id="meta">
        <xsl:if test="../xhtml:head/xhtml:meta[@name='date']/@content">
          <xsl:variable name="published" select="../xhtml:head/xhtml:meta[@name='date']/@content"/>
          <li id="published">
            <span class="year"><xsl:value-of select="substring-before($published, '-')"/></span>
            <xsl:text>-</xsl:text>
            <span class="month"><xsl:value-of select="document('')//data:month-name[@number=substring-before(substring-after($published, '-'),'-')]"/></span>
            <xsl:text>-</xsl:text>
            <span class="day"><xsl:value-of select="substring-before(substring-after(substring-after($published, '-'),'-'),'T')"/></span>
          </li>
        </xsl:if>
        <xsl:if test="(string-length($collection)>0) and (string-length($target)>0)">
          <li id="collection"><a href="{$collection}"><xsl:value-of select="$collection"/></a></li>
        </xsl:if>
      </ul>
      <xsl:if test="(../xhtml:head/xhtml:meta[@name='description']/@content) and not(xhtml:div[@class='figure']/xhtml:h1)">
        <div class="figure auto-abstract">
          <h2>Summary</h2>
          <p><xsl:value-of select="../xhtml:head/xhtml:meta[@name='description']/@content"/></p>
        </div>
      </xsl:if>
      <xsl:apply-templates select="node()" />
      <xsl:if test="../xhtml:head/xhtml:meta[@name='mtime'] and (../xhtml:head/xhtml:meta[@name='mtime']/@content != ../xhtml:head/xhtml:meta[@name='date']/@content)">
        <p class="last-modified"><em>Last Modified: <xsl:value-of select="../xhtml:head/xhtml:meta[@name='mtime']/@content" /></em></p>
      </xsl:if>
      <xsl:if test="../@id='phone'">
        <p class="credit"><em>Background photo credit: <a href="http://www.flickr.com/photos/w3p706/2872460783/">w3p706</a> / <a href="http://foter.com">Foter.com</a> / <a href="http://creativecommons.org/licenses/by-nc-sa/2.0/">CC BY-NC-SA</a></em></p>
      </xsl:if>
      <xsl:if test="../@id='server-grill'">
        <p class="credit"><em>Background photo credit: <a href="https://www.flickr.com/photos/bigpresh/7389234452/">bigpresh</a> / <a href="http://foter.com/">Foter</a> / <a href="http://creativecommons.org/licenses/by/2.0/">Creative Commons Attribution 2.0 Generic (CC BY 2.0)</a></em></p>
      </xsl:if>
      <xsl:if test="../@id='unicorn-noms'">
        <p class="credit"><em>Background photo credit: <a href="http://www.flickr.com/photos/dolske/7639692938/">Justin Dolske</a> / <a href="http://foter.com">Foter.com</a> / <a href="http://creativecommons.org/licenses/by-sa/2.0/">CC BY-SA</a></em></p>
      </xsl:if>
      <xsl:if test="not(../xhtml:head/xhtml:meta[@name='category'][@content='auxiliary'])">
        <ul id="hardcopies">
          <li>transcripts:</li>
          <li><a rel="alternate" type="application/pdf" href="/pdf/{$collection}">PDF</a></li>
          <li><a rel="alternate" type="application/x-mobipocket-ebook" href="/mobi/{$collection}.mobi">Kindle/MobiPocket</a></li>
          <li><a rel="alternate" type="application/epub+zip" href="/epub/{$collection}.epub">EPUB</a></li>
          <li><a rel="alternate" type="application/docbook+xml" href="/docbook/{$collection}">DocBook 5</a></li>
        </ul>
        <xsl:if test="not(xhtml:ul[@id='feed']) and ($disqusShortname != '')">
          <div id="disqus_thread"/>
          <script type="text/javascript">var disqus_shortname = '<xsl:value-of select="$disqusShortname"/>'; <xsl:if test="/xhtml:html/xhtml:head/xhtml:meta[@name='unix:name']">var disqus_identifier = '<xsl:value-of select="/xhtml:html/xhtml:head/xhtml:meta[@name='unix:name']/@content"/>';</xsl:if> (function() { var dsq = document.createElement('script'); dsq.type = 'text/javascript'; dsq.async = true; dsq.src = '//' + disqus_shortname + '.disqus.com/embed.js'; (document.getElementsByTagName('head')[0] || document.getElementsByTagName('body')[0]).appendChild(dsq); })();</script>
          <noscript>Please enable JavaScript to view the <a href="http://disqus.com/?ref_noscript">comments powered by Disqus.</a></noscript>
          <a href="http://disqus.com" class="dsq-brlink">comments powered by <span class="logo-disqus">Disqus</span></a>
        </xsl:if>
      </xsl:if>
      <xsl:if test="$author != ''">
        <social:grid author-box="yes" name="{$author}"/>
      </xsl:if>
    </body>
  </xsl:template>

  <xsl:template match="xhtml:meta[@name='unix:name']" />

  <xsl:template match="xhtml:h1">
    <h2>
      <xsl:apply-templates select="@*|node()" />
    </h2>
  </xsl:template>
  <xsl:template match="xhtml:h2">
    <h3>
      <xsl:apply-templates select="@*|node()" />
    </h3>
  </xsl:template>
  <xsl:template match="xhtml:h3">
    <h4>
      <xsl:apply-templates select="@*|node()" />
    </h4>
  </xsl:template>
  <xsl:template match="xhtml:h4">
    <h5>
      <xsl:apply-templates select="@*|node()" />
    </h5>
  </xsl:template>
  <xsl:template match="xhtml:h5">
    <h6>
      <xsl:apply-templates select="@*|node()" />
    </h6>
  </xsl:template>
</xsl:stylesheet>

