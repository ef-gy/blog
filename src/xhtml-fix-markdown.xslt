<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
              xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
              xmlns:xhtml="http://www.w3.org/1999/xhtml"
              xmlns="http://www.w3.org/1999/xhtml"
              version="1.0"
              exclude-result-prefixes="xhtml xsl">
  <xsl:output method="xml" version="1.0" encoding="UTF-8"
              indent="no"
              media-type="application/xhtml+xml" />

  <xsl:strip-space elements="*" />
  <xsl:preserve-space elements="xhtml:pre" />

  <xsl:template match="@*|node()">
    <xsl:copy><xsl:apply-templates select="@*|node()"/></xsl:copy>
  </xsl:template>

  <xsl:template match="xhtml:head">
    <xsl:copy><xsl:apply-templates select="@*|node()"/>
      <title><xsl:value-of select="//xhtml:h1[1]"/></title>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="//xhtml:h1[1]"/>

  <xsl:template match="xhtml:h2">
    <h1><xsl:apply-templates select="@*|node()"/></h1>
  </xsl:template>

  <xsl:template match="xhtml:h3">
    <h2><xsl:apply-templates select="@*|node()"/></h2>
  </xsl:template>

  <xsl:template match="xhtml:h4">
    <h3><xsl:apply-templates select="@*|node()"/></h3>
  </xsl:template>

  <xsl:template match="xhtml:h5">
    <h4><xsl:apply-templates select="@*|node()"/></h4>
  </xsl:template>

  <xsl:template match="xhtml:h6">
    <h5><xsl:apply-templates select="@*|node()"/></h5>
  </xsl:template>
</xsl:stylesheet>
