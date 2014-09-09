<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
              xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
              xmlns:atom="http://www.w3.org/2005/Atom"
              xmlns:data="http://ef.gy/2013/data"
              xmlns="http://www.w3.org/2005/Atom"
              exclude-result-prefixes="data atom"
              version="1.0">
  <xsl:output method="xml" version="1.0" encoding="UTF-8"
              indent="no"
              media-type="application/atom+xml"/>

  <xsl:param name="documentRoot"/>

  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()" />
    </xsl:copy>
  </xsl:template>

  <xsl:template match="/atom:feed">
    <feed>
      <xsl:for-each select="atom:entry">
        <xsl:sort select="atom:published | atom:updated" order="descending"/>
        <xsl:apply-templates select="."/>
      </xsl:for-each>
    </feed>
  </xsl:template>
</xsl:stylesheet>

