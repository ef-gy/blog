<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
              xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
              xmlns:xhtml="http://www.w3.org/1999/xhtml"
              xmlns:atom="http://www.w3.org/2005/Atom"
              xmlns:xlink="http://www.w3.org/1999/xlink"
              xmlns="http://www.w3.org/2005/Atom"
              exclude-result-prefixes="xlink xhtml atom"
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

  <xsl:template match="atom:entry[@xlink:href]">
    <entry>
      <xsl:variable name="source" select="document(concat($documentRoot,'/',@xlink:href))" />

      <title><xsl:value-of select="$source/xhtml:html/xhtml:head/xhtml:title" /></title>
      <id>http://ef.gy/<xsl:value-of select="$source/xhtml:html/xhtml:head/xhtml:meta[@name='unix:name']/@content" /></id>
      <link href="/{$source/xhtml:html/xhtml:head/xhtml:meta[@name='unix:name']/@content}" rel="alternate" type="application/xhtml+xml" />
      <link href="/pdf/{$source/xhtml:html/xhtml:head/xhtml:meta[@name='unix:name']/@content}" rel="alternate" type="application/pdf" />
      <summary><xsl:value-of select="$source/xhtml:html/xhtml:head/xhtml:meta[@name='description']/@content" /></summary>
      <published><xsl:value-of select="$source/xhtml:html/xhtml:head/xhtml:meta[@name='date']/@content" /></published>
      <updated><xsl:value-of select="$source/xhtml:html/xhtml:head/xhtml:meta[@name='mtime']/@content" /></updated>
      <category term="{$source/xhtml:html/xhtml:head/xhtml:meta[@name='category']/@content}" />
      <author>
        <name><xsl:value-of select="$source/xhtml:html/xhtml:head/xhtml:meta[@name='author']/@content" /></name>
        <xsl:if test="$source/xhtml:html/xhtml:head/xhtml:meta[@name='author'][@content='Magnus Achim Deininger']">
          <email>magnus@ef.gy</email>
        </xsl:if>
      </author>

      <content type="application/xhtml+xml">
        <xsl:copy-of select="$source" />
      </content>

      <source>
        <xsl:copy-of select="../atom:title" />
        <xsl:copy-of select="../atom:link" />
      </source>
    </entry>
  </xsl:template>

  <xsl:template match="atom:feed[@xlink:href]">
    <xsl:for-each select="document(concat($documentRoot,'/',@xlink:href))/atom:feed">
      <xsl:apply-templates select="atom:entry | atom:feed"/>
    </xsl:for-each>
  </xsl:template>
</xsl:stylesheet>

