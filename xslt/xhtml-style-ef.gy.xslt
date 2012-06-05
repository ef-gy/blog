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
        <li><a href="articles">Articles</a></li>
        <li><a href="irc://irc.freenode.org/kyuba">IRC</a></li>
        <li><a href="source-code">Source Code</a></li>
      </ul>
      <xsl:apply-templates select="node()" />
      <xsl:if test="//xhtml:meta[@name='author'][@content='Magnus Achim Deininger']"><address>
        <a rel="author" href="about">
          <img src="/jpeg/mdeininger" alt="Magnus Achim Deininger" />
          <span>Written by <span>Magnus Achim Deininger</span>.</span>
          Magnus Achim Deininger is a <del>sellsword</del> freelance programmer specialising in peculiar problems, such as embedded development, formal language theory and experiments in minimalistic design. This website serves as his personal journal and testing ground for unusual and/or crazy ideas.
        </a>
      </address></xsl:if>
    </xsl:copy>
  </xsl:template>

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

