<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
              xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
              xmlns:xhtml="http://www.w3.org/1999/xhtml"
              xmlns="http://www.w3.org/1999/xhtml"
              exclude-result-prefixes="xhtml"
              version="1.0">
  <xsl:output method="xml" version="1.0" encoding="UTF-8"
              doctype-public="-//W3C//DTD XHTML 1.1//EN"
              doctype-system="http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd"
              indent="no"
              media-type="application/xhtml+xml" />

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
    <xsl:copy>
      <link href="/css/ef.gy" rel="stylesheet" type="text/css" />
      <xsl:apply-templates select="@*|node()" />
      <xsl:choose>
        <xsl:when test="//xhtml:link[@href='http://ef.gy/atom/site']" />
        <xsl:otherwise>
          <link rel="alternate" type="application/atom+xml" href="/atom/site" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="xhtml:title">
    <title>ef.gy :: <xsl:apply-templates select="@*|node()" /></title>
  </xsl:template>

  <xsl:template match="xhtml:body">
    <xsl:copy>
      <xsl:apply-templates select="@*" />
      <h1><xsl:value-of select="/xhtml:html/xhtml:head/xhtml:title"/></h1>
      <ul>
        <li><a href="about">About</a></li>
        <li><a href="fortune">Fortune</a></li>
        <li><a href="site">Articles &amp; Projects</a></li>
        <li><a href="source-code">Source Code</a></li>
      </ul>
      <xsl:if test="//xhtml:meta[@name='unix:name']">
        <ul id="social">
          <li><a href="https://twitter.com/share?url=http://ef.gy/{//xhtml:meta[@name='unix:name']/@content}&amp;via=jyujinX" onclick="javascript:window.open(this.href,'', 'menubar=no,toolbar=no,resizable=yes,scrollbars=yes,height=600,width=600');return false;">tweet</a></li>
          <li><a href="http://www.facebook.com/sharer.php?u=http://ef.gy/{//xhtml:meta[@name='unix:name']/@content}" onclick="javascript:window.open(this.href,'', 'menubar=no,toolbar=no,resizable=yes,scrollbars=yes,height=600,width=600');return false;">share: facebook</a></li>
          <li><a href="https://www.xing.com/app/user?op=share&amp;url=http://ef.gy/{//xhtml:meta[@name='unix:name']/@content}" onclick="javascript:window.open(this.href,'','');return false;">share: xing</a></li>
          <li><a href="https://plus.google.com/share?url=http://ef.gy/{//xhtml:meta[@name='unix:name']/@content}" onclick="javascript:window.open(this.href,'', 'menubar=no,toolbar=no,resizable=yes,scrollbars=yes,height=600,width=600');return false;">share: google+</a></li>
        </ul>
      </xsl:if>
      <xsl:if test="(//xhtml:meta[@name='description']/@content) and not(xhtml:div[@class='figure']/xhtml:h1)">
        <div class="figure">
          <h2>Summary</h2>
          <p><xsl:value-of select="//xhtml:meta[@name='description']/@content"/></p>
        </div>
      </xsl:if>
      <xsl:apply-templates select="node()" />
      <xsl:if test="//xhtml:meta[@name='author'][@content='Magnus Achim Deininger']"><address>
        <a rel="author" href="about">
          <img src="/jpeg/mdeininger" alt="Magnus Achim Deininger" />
          <span>Written by <span>Magnus Achim Deininger</span>.</span> Magnus Achim Deininger is a <del>sellsword</del> freelance computer scientist specialising in peculiar problems, such as embedded development, formal language theory and experiments in minimalistic design. This website serves as his personal journal and testing ground for unusual and/or crazy ideas.</a>
      </address></xsl:if>
      <xsl:if test="//xhtml:meta[@name='author'][@content='Nadja Klein']"><address>
        <a rel="author" href="http://www.facebook.com/nadja.klein.967">
          <span>Written by <span>Nadja Klein</span>.</span> Guest blogging on this site, resident coffee junkie Nadja is one of that rare blend of computer scientists with an affinity for maths. She used to work as a developer for a software company until just recently and is currently concentrating on getting her degree in computer science.</a>
      </address></xsl:if>
      <xsl:if test="//xhtml:meta[@name='date']">
        <table>
          <tbody>
            <tr><th>Published on</th><td><xsl:value-of select="//xhtml:meta[@name='date']/@content" /></td></tr>
            <xsl:if test="//xhtml:meta[@name='mtime']">
              <tr><th>Last Modified</th><td><xsl:value-of select="//xhtml:meta[@name='mtime']/@content" /></td></tr>
            </xsl:if>
            <xsl:if test="//xhtml:meta[@name='category']">
              <tr><th>Category</th><td><xsl:value-of select="//xhtml:meta[@name='category']/@content" /></td></tr>
            </xsl:if>
          </tbody>
        </table>
      </xsl:if>
      <div id="ScribCode940130255"/>
    </xsl:copy>
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

