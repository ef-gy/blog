<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
              xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
              xmlns:svg="http://www.w3.org/2000/svg"
              xmlns:xlink="http://www.w3.org/1999/xlink"
              xmlns:xhtml="http://www.w3.org/1999/xhtml"
              xmlns:pmml2svg="https://sourceforge.net/projects/pmml2svg/"
              xmlns="http://www.w3.org/1999/xhtml"
              exclude-result-prefixes="svg"
              version="1.1">
  <xsl:output method="xml" version="1.0" encoding="UTF-8"
              indent="no"
              media-type="application/xml" />

  <xsl:param name="tmpdir"/>

  <xsl:strip-space elements="*" />

  <xsl:template match="@*|node()">
    <xsl:copy><xsl:apply-templates select="@*|node()"/></xsl:copy>
  </xsl:template>

  <xsl:template match="xhtml:*/svg:svg[svg:metadata/pmml2svg:*]">
    <xsl:variable name="filename" select="concat($tmpdir, '/temp-',position(),'.svg')"/>
    <xsl:document href="{$filename}">
      <xsl:copy>
        <xsl:apply-templates select="@*|node()"/>
      </xsl:copy>
    </xsl:document>
    <img xlink:href="{$filename}"/>
  </xsl:template>

</xsl:stylesheet>

