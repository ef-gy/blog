<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
              xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
              xmlns:xhtml="http://www.w3.org/1999/xhtml"
              xmlns:svg="http://www.w3.org/2000/svg"
              xmlns="http://www.w3.org/1999/xhtml"
              version="1.0">
  <xsl:output method="xml" version="1.0" encoding="UTF-8"
              indent="no"
              media-type="application/xhtml+xml" />

  <xsl:param name="documentRoot"/>
  <xsl:param name="baseURI"/>

  <xsl:strip-space elements="*" />
  <xsl:preserve-space elements="xhtml:pre" />

  <xsl:template match="@*|node()">
    <xsl:copy><xsl:apply-templates select="@*|node()"/></xsl:copy>
  </xsl:template>

  <xsl:template match="xhtml:img[substring-after(@src, '/svg/') != '']">
    <xsl:variable name="svg" select="document(concat($documentRoot,'/',substring-after(@src, '/svg/'),'.svg'))/svg:svg"/>
    <svg xmlns="http://www.w3.org/2000/svg">
      <xsl:apply-templates select="$svg/@* | @id | @preserveAspectRatio | $svg/*"/>
    </svg>
  </xsl:template>

  <xsl:template match="svg:*[@id='gnuplot_canvas']//@id"/>

  <xsl:template match="xhtml:img/@src[substring-before(., '/') = '']">
    <xsl:attribute name="src">
      <xsl:value-of select="substring-after(., '/')"/>
    </xsl:attribute>
  </xsl:template>
</xsl:stylesheet>
