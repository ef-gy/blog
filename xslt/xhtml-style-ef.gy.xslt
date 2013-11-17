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
  <xsl:param name="userCountry"/>
  <xsl:param name="cookieDisqus"/>
  <xsl:param name="documentRoot"/>

  <xsl:variable name="authors" select="document(concat($documentRoot,'/authors.xml'))/data:data/data:author"/>
  <xsl:variable name="referers" select="document(concat($documentRoot,'/referers.xml'))/data:referers/data:referer"/>
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
      <xsl:if test="$pre">
        <link rel="prev" href="{$pre/@href}" title="{$pre/@title}"/>
      </xsl:if>
      <xsl:if test="$post">
        <link rel="next" href="{$post/@href}" title="{$post/@title}"/>
      </xsl:if>
      <xsl:if test="$authordata/@googleplus">
        <link rel="author" href="https://plus.google.com/{$authordata/@googleplus}"/>
      </xsl:if>
      <xsl:if test="$authordata/@twitter">
        <link rel="author" href="https://twitter.com/{$authordata/@twitter}"/>
      </xsl:if>
    </head>
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
      <xsl:variable name="author" select="/xhtml:html/xhtml:head/xhtml:meta[@name='author']/@content"/>
      <xsl:variable name="authordata" select="$authors[@name=$author][1]"/>
      <xsl:variable name="suri"><xsl:choose>
        <xsl:when test="(string-length($target) > 0) and (string-length($collection) > 0)">/<xsl:value-of select="$target"/>@<xsl:value-of select="$collection"/></xsl:when>
        <xsl:otherwise>/<xsl:value-of select="//xhtml:meta[@name='unix:name']/@content"/></xsl:otherwise>
      </xsl:choose></xsl:variable>
      <xsl:variable name="uri" select="concat('http://ef.gy', $suri)"/>
      <xsl:variable name="uname" select="//xhtml:meta[@name='unix:name']/@content"/>
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
      <xsl:if test="$uname">
        <social:social url="{$uri}">
          <xsl:copy-of select="$authordata/@twitter | $authordata/@flattr"/>
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
      <xsl:if test="$authordata/@twitter != ''">
        <p class="follow">Since you came this far, why not <social:follow twitter="{$authordata/@twitter}" flattr="{$authordata/@flattr}"/></p>
      </xsl:if>
      <xsl:if test="../@id='phone'">
        <p class="credit"><em>Background photo credit: <a href="http://www.flickr.com/photos/w3p706/2872460783/">w3p706</a> / <a href="http://foter.com">Foter.com</a> / <a href="http://creativecommons.org/licenses/by-nc-sa/2.0/">CC BY-NC-SA</a></em></p>
      </xsl:if>
      <xsl:if test="../@id='unicorn-noms'">
        <p class="credit"><em>Background photo credit: <a href="http://www.flickr.com/photos/dolske/7639692938/">Justin Dolske</a> / <a href="http://foter.com">Foter.com</a> / <a href="http://creativecommons.org/licenses/by-sa/2.0/">CC BY-SA</a></em></p>
      </xsl:if>
      <xsl:if test="$uname">
        <xsl:variable name="my-referers" select="$referers[@location=$suri]"/>
        <xsl:if test="$my-referers">
          <h2>Refbacks</h2>
          <p>This page was linked from the following sources:</p>
          <ul id="referers">
            <xsl:for-each select="$my-referers">
              <li><a href="{.}"><xsl:value-of select="."/></a></li>
            </xsl:for-each>
          </ul>
        </xsl:if>
      </xsl:if>
      <xsl:if test="not(($collection = 'fortune') or ($collection = 'about') or ($collection = 'source-code'))">
        <ul id="hardcopies">
          <li>transcripts:</li>
          <li><a rel="alternate" type="application/pdf" href="/pdf/{$collection}">PDF</a></li>
          <li><a rel="alternate" type="application/x-mobipocket-ebook" href="/mobi/{$collection}.mobi">Kindle/MobiPocket</a></li>
          <li><a rel="alternate" type="application/epub+zip" href="/epub/{$collection}.epub">EPUB</a></li>
          <li><a rel="alternate" type="application/docbook+xml" href="/docbook/{$collection}">DocBook 5</a></li>
        </ul>
        <xsl:if test="not(xhtml:ul[@id='feed'])">
          <div id="disqus_thread"/>
          <xsl:choose>
            <xsl:when test="($userCountry = 'DEU') and ($cookieDisqus != 'on')">
              <script type="text/javascript">var disqus_shortname = 'efgy'; <xsl:if test="/xhtml:html/xhtml:head/xhtml:meta[@name='unix:name']">var disqus_identifier = '<xsl:value-of select="/xhtml:html/xhtml:head/xhtml:meta[@name='unix:name']/@content"/>';</xsl:if></script>
              <a id="comments" class="dsq-brlink" href="http://disqus.com" onclick="var dsq = document.createElement('script'); dsq.type = 'text/javascript'; dsq.async = true; dsq.src = '//' + disqus_shortname + '.disqus.com/embed.js'; (document.getElementsByTagName('head')[0] || document.getElementsByTagName('body')[0]).appendChild(dsq); document.cookie='disqus=on'; return false;">comments powered by <span class="logo-disqus">Disqus</span>; Comments are not shown by default for privacy reasons, click here to enable them. This will make your browser request data from the third-party disqus.com servers and may additionally request data from the Google Analytics servers. Clicking this link will also set a cookie that will automatically load disqus comments on further page loads on this website. If you change your mind later, simply remove this cookie in your browser.</a>
              <noscript>Please enable JavaScript to view the <a href="http://disqus.com/?ref_noscript">comments powered by Disqus.</a></noscript>
            </xsl:when>
            <xsl:otherwise>
              <script type="text/javascript">var disqus_shortname = 'efgy'; <xsl:if test="/xhtml:html/xhtml:head/xhtml:meta[@name='unix:name']">var disqus_identifier = '<xsl:value-of select="/xhtml:html/xhtml:head/xhtml:meta[@name='unix:name']/@content"/>';</xsl:if> (function() { var dsq = document.createElement('script'); dsq.type = 'text/javascript'; dsq.async = true; dsq.src = '//' + disqus_shortname + '.disqus.com/embed.js'; (document.getElementsByTagName('head')[0] || document.getElementsByTagName('body')[0]).appendChild(dsq); })();</script>
              <noscript>Please enable JavaScript to view the <a href="http://disqus.com/?ref_noscript">comments powered by Disqus.</a></noscript>
              <a href="http://disqus.com" class="dsq-brlink">comments powered by <span class="logo-disqus">Disqus</span></a>
            </xsl:otherwise>
          </xsl:choose>
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

