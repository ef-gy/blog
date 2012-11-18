<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
              xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
              xmlns:xhtml="http://www.w3.org/1999/xhtml"
              xmlns:source="http://ef.gy/2012/source"
              xmlns:atom="http://www.w3.org/2005/Atom"
              xmlns="http://www.w3.org/1999/xhtml"
              exclude-result-prefixes="source xhtml atom"
              version="1.0">
  <xsl:output method="xml" version="1.0" encoding="UTF-8"
              indent="no"
              media-type="application/atom+xml"/>

  <xsl:param name="target"/>
  <xsl:param name="collection"/>

  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()" />
    </xsl:copy>
  </xsl:template>

  <xsl:template match="xhtml:head">
    <head>
      <xsl:apply-templates select="@*|node()" />
      <xsl:if test="xhtml:meta[@name='unix:name'] and ((string-length($target) = 0) or (xhtml:meta[@name='unix:name']/@content = $target))"><meta name="context">
        <xsl:copy-of select="document('/srv/http/ef.gy/site+archives.atom')/atom:feed" />
      </meta></xsl:if>
    </head>
  </xsl:template>
</xsl:stylesheet>

