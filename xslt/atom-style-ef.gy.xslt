<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
              xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
              xmlns:xhtml="http://www.w3.org/1999/xhtml"
              xmlns:atom="http://www.w3.org/2005/Atom"
              xmlns="http://www.w3.org/2005/Atom"
              exclude-result-prefixes="xhtml atom"
              version="1.0">
  <xsl:output method="xml" version="1.0" encoding="UTF-8"
              indent="no"
              media-type="application/atom+xml"/>

  <xsl:param name="baseURI"/>

  <xsl:strip-space elements="*" />

  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()" />
    </xsl:copy>
  </xsl:template>

  <xsl:template match="/atom:feed">
    <feed>
      <xsl:apply-templates select="@*"/>
      <xsl:choose>
        <xsl:when test="atom:id"/>

        <xsl:when test="@xml:id">
          <id><xsl:value-of select="$baseURI"/>/atom/<xsl:value-of select="@xml:id"/></id>
        </xsl:when>
      </xsl:choose>

      <xsl:if test="@xml:id">
        <link href="{$baseURI}/atom/{@xml:id}" rel="self" />
        <link href="{$baseURI}/pdf/{@xml:id}" rel="alternate" type="application/pdf" />
        <link href="{$baseURI}/mobi/{@xml:id}.mobi" rel="alternate" type="application/x-mobipocket-ebook" />
        <link href="{$baseURI}/epub/{@xml:id}.epub" rel="alternate" type="application/epub+zip" />
        <link href="{$baseURI}/rss/{@xml:id}" rel="alternate" type="application/rss+xml" />
        <link href="{$baseURI}/{@xml:id}" rel="alternate" type="application/xhtml+xml" />
      </xsl:if>

      <xsl:choose>
        <xsl:when test="atom:updated" />

        <xsl:otherwise>
          <xsl:for-each select="//atom:entry">
            <xsl:sort select="atom:updated" order="descending" />
            <xsl:if test="position()=1">
              <updated><xsl:value-of select="atom:updated"/></updated>
            </xsl:if>
          </xsl:for-each>
        </xsl:otherwise>
      </xsl:choose>

      <xsl:apply-templates select="node()"/>
    </feed>
  </xsl:template>

  <xsl:template match="/atom:feed/atom:title">
    <title><xsl:value-of select="$baseURI"/>/ :: <xsl:value-of select="."/></title>
  </xsl:template>

  <xsl:template match="//atom:entry/atom:link[(@rel!='payment') or not(@rel)]/@href">
    <xsl:attribute name="href"><xsl:value-of select="$baseURI"/><xsl:value-of select="."/></xsl:attribute>
  </xsl:template>

  <xsl:template match="xhtml:html/@id"/>
</xsl:stylesheet>

