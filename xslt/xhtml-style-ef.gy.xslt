<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
              xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
              xmlns:xhtml="http://www.w3.org/1999/xhtml"
              xmlns:social="http://ef.gy/2012/social"
              xmlns:atom="http://www.w3.org/2005/Atom"
              xmlns:data="http://ef.gy/2013/data"
              xmlns:math="http://www.w3.org/1998/Math/MathML"
              xmlns="http://www.w3.org/1999/xhtml"
              exclude-result-prefixes="xhtml"
              version="1.0">
  <xsl:output method="xml" version="1.0" encoding="UTF-8"
              doctype-public="-//W3C//DTD XHTML 1.1//EN"
              doctype-system="http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd"
              indent="no"
              media-type="application/xhtml+xml" />

  <xsl:param name="target"/>
  <xsl:param name="collection"/>

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
    <xsl:variable name="entries" select="xhtml:meta[@name='context']/atom:feed/atom:entry"/>
    <xsl:variable name="pre" select="$entries[atom:content/xhtml:html/xhtml:head/xhtml:meta[@name='unix:name'][@content=$myname]]/preceding-sibling::*[1]"/>
    <xsl:variable name="post" select="$entries[atom:content/xhtml:html/xhtml:head/xhtml:meta[@name='unix:name'][@content=$myname]]/following-sibling::*[1]"/>
    <xsl:copy>
      <link href="/css/ef.gy" rel="stylesheet" type="text/css" />
      <xsl:if test="not(($collection = 'fortune') or ($collection = 'about') or ($collection = 'source-code'))">
        <link rel="alternate" type="application/pdf" href="/pdf/{$collection}"/>
        <link rel="alternate" type="application/x-mobipocket-ebook" href="/mobi/{$collection}.mobi"/>
        <link rel="alternate" type="application/epub+zip" href="/epub/{$collection}.epub"/>
        <link rel="alternate" type="application/docbook+xml" href="/docbook/{$collection}"/>
      </xsl:if>
      <xsl:apply-templates select="@*|node()" />
      <xsl:choose>
        <xsl:when test="//xhtml:link[@href='http://ef.gy/atom/site']" />
        <xsl:otherwise>
          <link rel="alternate" type="application/atom+xml" href="/atom/site" />
        </xsl:otherwise>
      </xsl:choose>
      <xsl:choose>
        <xsl:when test="//xhtml:link[@href='http://ef.gy/rss/site']" />
        <xsl:otherwise>
          <link rel="alternate" type="application/rss+xml" href="/rss/site" />
        </xsl:otherwise>
      </xsl:choose>
      <xsl:if test="$pre/atom:content">
        <xsl:choose>
          <xsl:when test="$pre/atom:link">
            <link rel="prev" href="/{$pre/atom:content/xhtml:html/xhtml:head/xhtml:meta[@name='unix:name']/@content}" title="{$pre/atom:title}"/>
          </xsl:when>
          <xsl:when test="$pre/atom:category[@term='einit.org']">
            <link rel="prev" href="/{$pre/atom:content/xhtml:html/xhtml:head/xhtml:meta[@name='unix:name']/@content}@drupal-einit" title="{$pre/atom:title}"/>
          </xsl:when>
          <xsl:when test="$pre/atom:category[@term='kyuba.org']">
            <link rel="prev" href="/{$pre/atom:content/xhtml:html/xhtml:head/xhtml:meta[@name='unix:name']/@content}@drupal-kyuba" title="{$pre/atom:title}"/>
          </xsl:when>
        </xsl:choose>
      </xsl:if>
      <xsl:if test="$post/atom:content">
        <xsl:choose>
          <xsl:when test="$post/atom:link">
            <link rel="next" href="/{$post/atom:content/xhtml:html/xhtml:head/xhtml:meta[@name='unix:name']/@content}" title="{$post/atom:title}"/>
          </xsl:when>
          <xsl:when test="$post/atom:category[@term='einit.org']">
            <link rel="next" href="/{$post/atom:content/xhtml:html/xhtml:head/xhtml:meta[@name='unix:name']/@content}@drupal-einit" title="{$post/atom:title}"/>
          </xsl:when>
          <xsl:when test="$post/atom:category[@term='kyuba.org']">
            <link rel="next" href="/{$post/atom:content/xhtml:html/xhtml:head/xhtml:meta[@name='unix:name']/@content}@drupal-kyuba" title="{$post/atom:title}"/>
          </xsl:when>
        </xsl:choose>
      </xsl:if>
      <xsl:if test="xhtml:meta[@name='author']">
        <xsl:variable name="author" select="xhtml:meta[@name='author']/@content"/>
        <xsl:choose>
          <xsl:when test="$author='Magnus Achim Deininger'">
            <link rel="author" href="https://plus.google.com/112902745191014401433"/>
            <link rel="author" href="https://twitter.com/jyujinX"/>
          </xsl:when>
        </xsl:choose>
      </xsl:if>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="xhtml:a/@href">
    <xsl:choose>
      <xsl:when test="$decorateWithCollection"><xsl:attribute name="href"><xsl:value-of select="concat('/',.,'@',$collection)"/></xsl:attribute></xsl:when>
      <xsl:otherwise><xsl:attribute name="href"><xsl:value-of select="."/></xsl:attribute></xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="xhtml:title">
    <xsl:choose>
      <xsl:when test="substring-after(.,'ef.gy') != ''">
        <title><xsl:apply-templates select="@*|node()" /></title>
      </xsl:when>
      <xsl:otherwise>
        <title>ef.gy :: <xsl:apply-templates select="@*|node()" /></title>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="xhtml:body">
    <body>
      <xsl:apply-templates select="@*" />
      <h1><xsl:value-of select="/xhtml:html/xhtml:head/xhtml:title"/></h1>
      <ul>
        <li><a href="/about">About</a></li>
        <li><a href="/fortune">Fortune</a></li>
        <li><a href="/site">Blog</a></li>
        <li><a href="/source-code">Source Code</a></li>
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
      <xsl:if test="//xhtml:meta[@name='unix:name']">
        <xsl:choose>
          <xsl:when test="(string-length($target) > 0) and (string-length($collection) > 0)">
            <social:social url="http://ef.gy/{$target}@{$collection}" twitter="jyujinX"/>
          </xsl:when>
          <xsl:otherwise>
            <social:social url="http://ef.gy/{//xhtml:meta[@name='unix:name']/@content}" twitter="jyujinX"/>
          </xsl:otherwise>
        </xsl:choose>
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
      <xsl:if test="descendant::math:math">
        <p id="maths-note">Some of the content on this page is in MathML. If your browser has trouble displaying any mathematical notation below you might find the <a href="/pdf/{$collection}">PDF transcript of this page</a> more helpful. There is also a <a href="/pdf/mathematics">collection of mathematical articles on this site</a>, which should include this one. Additionally there is <a href="/mobi/{$collection}.mobi">an ebook version of this page</a> as well as <a href="/mobi/mathematics.mobi">an ebook version of the aforementioned collection of mathematical articles</a>.</p>
      </xsl:if>
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
      <xsl:if test="../@id='unicorn-noms'">
        <p class="credit"><em>Background photo credit: <a href="http://www.flickr.com/photos/dolske/7639692938/">Justin Dolske</a> / <a href="http://foter.com">Foter.com</a> / <a href="http://creativecommons.org/licenses/by-sa/2.0/">CC BY-SA</a></em></p>
      </xsl:if>
      <xsl:if test="not(($collection = 'fortune') or ($collection = 'about') or ($collection = 'source-code'))">
        <xsl:if test="not(xhtml:ul[@id='feed'])">
          <div id="disqus_thread"/>
          <script type="text/javascript">var disqus_shortname = 'efgy'; <xsl:if test="/xhtml:html/xhtml:head/xhtml:meta[@name='unix:name']">var disqus_identifier = '<xsl:value-of select="/xhtml:html/xhtml:head/xhtml:meta[@name='unix:name']/@content"/>';</xsl:if> (function() { var dsq = document.createElement('script'); dsq.type = 'text/javascript'; dsq.async = true; dsq.src = '//' + disqus_shortname + '.disqus.com/embed.js'; (document.getElementsByTagName('head')[0] || document.getElementsByTagName('body')[0]).appendChild(dsq); })();</script>
          <noscript>Please enable JavaScript to view the <a href="http://disqus.com/?ref_noscript">comments powered by Disqus.</a></noscript>
          <a href="http://disqus.com" class="dsq-brlink">comments powered by <span class="logo-disqus">Disqus</span></a>
        </xsl:if>
        <ul id="hardcopies">
          <li>transcripts:</li>
          <li><a rel="alternate" type="application/pdf" href="/pdf/{$collection}">PDF</a></li>
          <li><a rel="alternate" type="application/x-mobipocket-ebook" href="/mobi/{$collection}.mobi">Kindle/MobiPocket</a></li>
          <li><a rel="alternate" type="application/epub+zip" href="/epub/{$collection}.epub">EPUB</a></li>
          <li><a rel="alternate" type="application/docbook+xml" href="/docbook/{$collection}">DocBook 5</a></li>
        </ul>
      </xsl:if>
      <xsl:if test="/xhtml:html/xhtml:head/xhtml:meta[@name='author']">
        <xsl:variable name="author" select="/xhtml:html/xhtml:head/xhtml:meta[@name='author']/@content"/>
        <xsl:choose>
          <xsl:when test="$author='Magnus Achim Deininger'"><address>
            <a rel="author" href="about">
              <span>Written by <span>Magnus Achim Deininger</span>.</span> Magnus is a <del>sellsword</del> freelance computer scientist specialising in peculiar problems, such as embedded development, formal language theory and experiments in minimalistic design. This website serves as his personal journal and testing ground for unusual and/or crazy ideas.</a>
          </address></xsl:when>
          <xsl:when test="$author='Nadja Klein'"><address>
            <a rel="author" href="http://www.facebook.com/nadja.klein.967">
              <span>Written by <span>Nadja Deininiger</span>.</span> Guest blogging on this site, resident coffee junkie Nadja is one of that rare blend of computer scientists with an affinity for maths. She used to work as a developer for a software company until just recently and is currently concentrating on getting her degree in computer science.</a>
          </address></xsl:when>
          <xsl:when test="$author='Nadja Deininger'"><address>
            <a rel="author" href="http://www.facebook.com/nadja.klein.967">
              <span>Written by <span>Nadja Deininger</span>.</span> Guest blogging on this site, resident coffee junkie Nadja is one of that rare blend of computer scientists with an affinity for maths. She used to work as a developer for a software company until just recently and is currently concentrating on getting her degree in computer science.</a>
          </address></xsl:when>
          <xsl:otherwise><address>
            <span>Written by <span><xsl:value-of select="$author"/></span></span>
          </address></xsl:otherwise>
        </xsl:choose>
      </xsl:if>
    </body>
  </xsl:template>

  <xsl:template match="xhtml:meta[@name='unix:name']" />
  <xsl:template match="xhtml:meta[@name='context']" />

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

