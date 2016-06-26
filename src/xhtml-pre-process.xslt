<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
              xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
              xmlns:xhtml="http://www.w3.org/1999/xhtml"
              xmlns:xlink="http://www.w3.org/1999/xlink"
              xmlns="http://www.w3.org/1999/xhtml"
              version="1.0">
  <xsl:output method="xml" version="1.0" encoding="UTF-8"
              indent="no"
              media-type="application/xhtml+xml" />

  <xsl:param name="documentRoot"/>
  <xsl:param name="ctime"/>
  <xsl:param name="mtime"/>
  <xsl:param name="name"/>

  <xsl:strip-space elements="*" />
  <xsl:preserve-space elements="xhtml:pre" />

  <xsl:template match="@*|node()">
    <xsl:copy><xsl:apply-templates select="@*|node()"/></xsl:copy>
  </xsl:template>

  <xsl:template match="//xhtml:html/xhtml:head">
    <xsl:copy><xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="xhtml:img/@src[substring-before(., '/') = '']">
    <xsl:attribute name="src">
      <xsl:value-of select="substring-after(., '/')"/>
    </xsl:attribute>
  </xsl:template>
</xsl:stylesheet>
