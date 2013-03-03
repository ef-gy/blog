<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
              xmlns:xlink="http://www.w3.org/1999/xlink"
              xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
              xmlns:atom="http://www.w3.org/2005/Atom"
              xmlns:opf="http://www.idpf.org/2007/opf"
              xmlns:dc="http://purl.org/dc/elements/1.1/"
              xmlns:xhtml="http://www.w3.org/1999/xhtml"
              xmlns="http://www.idpf.org/2007/opf"
              version="1.0">
  <xsl:output method="xml" version="1.0" encoding="UTF-8"
              indent="no"
              media-type="application/xml" />

  <xsl:param name="documentRoot"/>
  <xsl:param name="baseURI"/>

  <xsl:strip-space elements="*" />

  <xsl:template match="@*|node()">
    <xsl:copy><xsl:apply-templates select="@*|node()"/></xsl:copy>
  </xsl:template>

  <xsl:template match="/atom:feed">
    <xsl:variable name="name" select="@xml:id"/>

    <package version="3.0" unique-identifier="{@xml:id}">
      <metadata>
        <dc:identifier id="pub-id"><xsl:value-of select="@xml:id"/></dc:identifier>
        <dc:title><xsl:value-of select="atom:title"/></dc:title>
        <dc:language>en</dc:language>
      </metadata>

      <manifest>
        <item id="css" href="ef.gy.book.css" media-type="text/css"/>
        <xsl:for-each select="atom:entry[@xlink:href]">
          <item id="i-{position()}" href="{concat(substring-before(@xlink:href,'.xhtml'),'.opf.xhtml')}" media-type="application/xhtml+xml"/>
        </xsl:for-each>
      </manifest>

      <spine>
        <xsl:for-each select="atom:entry[@xlink:href]">
          <itemref idref="i-{position()}"/>
        </xsl:for-each>
      </spine>
    </package>
  </xsl:template>

</xsl:stylesheet>
