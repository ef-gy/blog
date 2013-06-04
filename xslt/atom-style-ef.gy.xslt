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

  <xsl:param name="target"/>
  <xsl:param name="collection"/>
  <xsl:param name="userAgent"/>

  <xsl:variable name="simpleFeed" select="contains($userAgent, 'MagpieRSS')"/>

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
          <id>http://ef.gy/atom/<xsl:value-of select="@xml:id"/></id>
        </xsl:when>
      </xsl:choose>

      <xsl:if test="@xml:id">
        <link href="http://ef.gy/atom/{@xml:id}" rel="self" />
        <xsl:if test="not($simpleFeed)">
          <link href="http://ef.gy/pdf/{@xml:id}" rel="alternate" type="application/pdf" />
          <link href="http://ef.gy/mobi/{@xml:id}.mobi" rel="alternate" type="application/x-mobipocket-ebook" />
          <link href="http://ef.gy/epub/{@xml:id}.epub" rel="alternate" type="application/epub+zip" />
          <link href="http://ef.gy/rss/{@xml:id}" rel="alternate" type="application/rss+xml" />
        </xsl:if>
        <link href="http://ef.gy/{@xml:id}" rel="alternate" type="application/xhtml+xml" />
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
    <title>http://ef.gy/ :: <xsl:value-of select="."/></title>
  </xsl:template>

  <xsl:template match="//atom:entry/atom:link/@href">
    <xsl:attribute name="href">http://ef.gy<xsl:value-of select="."/></xsl:attribute>
  </xsl:template>

  <xsl:template match="//atom:entry">
    <xsl:copy>
      <xsl:apply-templates/>
      <xsl:choose>
        <xsl:when test="atom:link/@href"/>
        <xsl:when test="atom:category[@term='einit.org']">
          <link href="{concat('http://ef.gy/',atom:content/xhtml:html/xhtml:head/xhtml:meta[@name='unix:name']/@content,'@drupal-einit')}"/>
        </xsl:when>
        <xsl:when test="atom:category[@term='kyuba.org']">
          <link href="{concat('http://ef.gy/',atom:content/xhtml:html/xhtml:head/xhtml:meta[@name='unix:name']/@content,'@drupal-kyuba')}"/>
        </xsl:when>
        <xsl:otherwise>
          <link href="{concat('http://ef.gy/',atom:content/xhtml:html/xhtml:head/xhtml:meta[@name='unix:name']/@content,'@',$collection)}"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="xhtml:html/@id"/>
</xsl:stylesheet>

