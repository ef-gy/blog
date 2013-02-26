<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
              xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
              xmlns:xhtml="http://www.w3.org/1999/xhtml"
              xmlns:math="http://www.w3.org/1998/Math/MathML"
              xmlns:svg="http://www.w3.org/2000/svg"
              version="1.0">
  <xsl:output method="html" encoding="UTF-8"
              indent="no"
              media-type="text/html" />

  <xsl:template match="@*">
    <xsl:copy>
      <xsl:apply-templates select="node()" />
    </xsl:copy>
  </xsl:template>

  <xsl:template match="/">
    <xsl:text disable-output-escaping='yes'>&lt;!DOCTYPE html&gt;</xsl:text>
    <xsl:apply-templates select="node()" />
  </xsl:template>

  <xsl:template match="math:*">
    <xsl:element name="{name()}">
      <xsl:apply-templates select="@*|node()" />
    </xsl:element>
  </xsl:template>

  <xsl:template match="xhtml:*">
    <xsl:element name="{name()}">
      <xsl:apply-templates select="@*|node()" />
    </xsl:element>
  </xsl:template>

  <xsl:template match="svg:*">
    <xsl:element name="{name()}">
      <xsl:apply-templates select="@*|node()" />
    </xsl:element>
  </xsl:template>

  <xsl:template match="xhtml:meta[@name='date'] | xhtml:meta[@name='mtime'] | xhtml:meta[@name='category']" />

  <xsl:template match="@xml:lang">
    <xsl:attribute name="lang"><xsl:value-of select="." /></xsl:attribute>
  </xsl:template>
</xsl:stylesheet>

