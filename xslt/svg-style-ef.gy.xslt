<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
              xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
              xmlns:svg="http://www.w3.org/2000/svg"
              xmlns="http://www.w3.org/2000/svg"
              xmlns:xlink="http://www.w3.org/1999/xlink"
              exclude-result-prefixes="svg"
              version="1.0">
  <xsl:output method="xml" version="1.0" encoding="UTF-8"
              doctype-public="-//W3C//DTD SVG 1.1//EN"
              doctype-system="http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd"
              indent="no"
              media-type="image/svg+xml" />

  <xsl:strip-space elements="*" />

  <xsl:template match="@*">
    <xsl:copy>
      <xsl:apply-templates select="node()" />
    </xsl:copy>
  </xsl:template>

  <xsl:template match="svg:*">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()" />
    </xsl:copy>
  </xsl:template>

  <xsl:template match="svg:metadata/*">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()" />
    </xsl:copy>
  </xsl:template>

<!--
  <xsl:template match="/svg:svg">
    <xsl:processing-instruction name="xml-stylesheet">
      <xsl:text>type="text/css" href="/css/ef.gy"</xsl:text>
    </xsl:processing-instruction>
    <svg>
      <xsl:apply-templates select="@*|node()" />
    </svg>
  </xsl:template>
  -->
</xsl:stylesheet>

