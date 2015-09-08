<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
              xmlns="http://www.w3.org/2005/Atom"
              xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
              xmlns:social="https://github.com/ef-gy/web-stat-tool"
							xmlns:atom="http://www.w3.org/2005/Atom"
							xmlns:xlink="http://www.w3.org/1999/xlink"
              version="1.0">
  <xsl:output method="xml" version="1.0" encoding="UTF-8"
              indent="no"
              media-type="application/xml" />

	<xsl:param name="domain"/>

  <xsl:strip-space elements="*" />

  <xsl:template match="@*|node()">
    <xsl:copy><xsl:apply-templates select="@*|node()"/></xsl:copy>
  </xsl:template>

  <xsl:template match="social:social">
    <feed>
		  <title>Most popular on <xsl:value-of select="$domain"/></title>
      <xsl:for-each select="social:url">
        <xsl:sort select="@total" data-type="number" order="descending"/>
				<xsl:if test="position() &lt;= 10">
				  <entry xlink:href="{@name}.xhtml"/>
				</xsl:if>
      </xsl:for-each>
    </feed>
  </xsl:template>
</xsl:stylesheet>
