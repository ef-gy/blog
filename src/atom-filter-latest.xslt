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

	<xsl:param name="domain"/>

  <xsl:strip-space elements="*" />

  <xsl:template match="@*|node()">
    <xsl:copy><xsl:apply-templates select="@*|node()"/></xsl:copy>
  </xsl:template>

  <xsl:template match="atom:feed">
    <feed>
		  <title>Most recently on <xsl:value-of select="$domain"/></title>
      <xsl:for-each select="atom:entry">
        <xsl:sort select="atom:published | atom:updated[not(parent::node()/atom:published)]" order="descending"/>
				<xsl:if test="position() &lt;= 10">
				  <entry xlink:href="{substring-after(atom:id,'/')}.xhtml"/>
				</xsl:if>
      </xsl:for-each>
    </feed>
  </xsl:template>
</xsl:stylesheet>
