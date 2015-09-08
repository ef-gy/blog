<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
              xmlns="http://www.w3.org/2005/Atom"
              xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
							xmlns:atom="http://www.w3.org/2005/Atom"
							xmlns:xlink="http://www.w3.org/1999/xlink"
              version="1.0">
  <xsl:output method="xml" version="1.0" encoding="UTF-8"
              indent="no"
              media-type="application/xml" />

  <xsl:param name="documentRoot"/>

  <xsl:strip-space elements="*" />

  <xsl:template match="@*|node()">
    <xsl:copy><xsl:apply-templates select="@*|node()"/></xsl:copy>
  </xsl:template>

  <xsl:template match="atom:feed[@xlink:href]">
    <xsl:for-each select="document(concat($documentRoot,'/',@xlink:href))/atom:feed">
      <xsl:apply-templates select="atom:entry | atom:feed"/>
    </xsl:for-each>
  </xsl:template>
</xsl:stylesheet>
