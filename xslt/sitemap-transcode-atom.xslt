<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
              xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
              xmlns:atom="http://www.w3.org/2005/Atom"
              xmlns:sitemap="http://www.sitemaps.org/schemas/sitemap/0.9"
              xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
              xmlns="http://www.sitemaps.org/schemas/sitemap/0.9"
              version="1.0">
  <xsl:output method="xml" version="1.0" encoding="UTF-8"
              indent="no"
              media-type="application/xml" />

  <xsl:strip-space elements="*" />

  <xsl:template match="/atom:feed">
    <urlset xsi:schemaLocation="http://www.sitemaps.org/schemas/sitemap/0.9 http://www.sitemaps.org/schemas/sitemap/0.9/sitemap.xsd">
      <xsl:apply-templates select="descendant::atom:link"/>
    </urlset>
  </xsl:template>

  <xsl:template match="atom:link[@rel!='payment']">
    <url>
      <loc><xsl:value-of select="@href"/></loc>
      <xsl:if test="../atom:updated">
        <lastmod><xsl:value-of select="../atom:updated"/></lastmod>
      </xsl:if>
    </url>
  </xsl:template>
</xsl:stylesheet>
