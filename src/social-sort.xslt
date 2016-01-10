<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
              xmlns="https://github.com/ef-gy/web-stat-tool"
              xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
              xmlns:social="https://github.com/ef-gy/web-stat-tool"
              version="1.0">
  <xsl:output method="xml" version="1.0" encoding="UTF-8"
              indent="no"
              media-type="application/xml" />

  <xsl:param name="base"/>

  <xsl:strip-space elements="*" />

  <xsl:template match="@*|node()">
    <xsl:copy><xsl:apply-templates select="@*|node()"/></xsl:copy>
  </xsl:template>

  <xsl:template match="social:social">
    <xsl:copy>
      <xsl:for-each select="social:url">
        <xsl:sort select="@total" data-type="number" order="descending"/>
				<xsl:copy>
          <xsl:apply-templates select="@*"/>
					<xsl:attribute name="name"><xsl:value-of select="substring-after(@id,$base)"/></xsl:attribute>
				</xsl:copy>
      </xsl:for-each>
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>
