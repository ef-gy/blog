<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
              xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
              xmlns:atom="http://www.w3.org/2005/Atom"
              xmlns:data="http://ef.gy/2013/data"
              xmlns="http://ef.gy/2013/data"
              exclude-result-prefixes="data atom"
              version="1.0">
  <xsl:output method="xml" version="1.0" encoding="UTF-8"
              indent="no"
              media-type="application/atom+xml"/>

  <xsl:param name="documentRoot"/>
  <xsl:param name="baseURI">http://ef.gy</xsl:param>

  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()" />
    </xsl:copy>
  </xsl:template>

  <xsl:template match="/atom:feed">
    <data>
      <xsl:apply-templates select="atom:entry"/>
    </data>
  </xsl:template>

  <xsl:template match="atom:entry">
    <index href="{substring-after(atom:link[1]/@href,$baseURI)}">
      <xsl:variable name="previous" select="preceding-sibling::atom:entry[1][atom:link]"/>
      <xsl:variable name="next" select="following-sibling::atom:entry[1][atom:link]"/>
      <xsl:if test="$previous">
        <previous title="{$previous/atom:title}" href="{substring-after($previous/atom:link[1]/@href,$baseURI)}"/>
      </xsl:if>
      <xsl:if test="$next">
        <next title="{$next/atom:title}" href="{substring-after($next/atom:link[1]/@href,$baseURI)}"/>
      </xsl:if>
    </index>
  </xsl:template>
</xsl:stylesheet>

