<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
              xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
              xmlns:xhtml="http://www.w3.org/1999/xhtml"
              xmlns:source="http://ef.gy/2012/source"
              xmlns:atom="http://www.w3.org/2005/Atom"
              xmlns="http://www.w3.org/2005/Atom"
              exclude-result-prefixes="source xhtml atom"
              version="1.0">
  <xsl:output method="xml" version="1.0" encoding="UTF-8"
              indent="no"
              media-type="application/atom+xml"/>

  <xsl:strip-space elements="*" />

  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()" />
    </xsl:copy>
  </xsl:template>

  <xsl:template match="/atom:feed">
    <xsl:copy>
      <xsl:choose>
        <xsl:when test="atom:id" />

        <xsl:otherwise>
          <id><xsl:value-of select="atom:link[@rel='self']/@href" /></id>
        </xsl:otherwise>
      </xsl:choose>

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
    </xsl:copy>
  </xsl:template>

  <xsl:template match="/atom:feed/atom:title">
    <title>http://ef.gy/ :: <xsl:value-of select="."/></title>
  </xsl:template>

  <xsl:template match="//atom:entry/atom:link/@href">
    <xsl:attribute name="href">http://ef.gy<xsl:value-of select="."/></xsl:attribute>
  </xsl:template>
</xsl:stylesheet>

