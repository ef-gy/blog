<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
              xmlns:atom="http://www.w3.org/2005/Atom"
              xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
              xmlns:xhtml="http://www.w3.org/1999/xhtml"
              xmlns:xlink="http://www.w3.org/1999/xlink"
              xmlns:mathml="http://www.w3.org/1998/Math/MathML"
              xmlns:svg="http://www.w3.org/2000/svg"
              xmlns:opf="http://www.idpf.org/2007/opf"
              xmlns:dc="http://purl.org/dc/elements/1.1/"
              xmlns:pmml2svg="https://sourceforge.net/projects/pmml2svg/"
              xmlns="http://www.idpf.org/2007/opf"
              version="1.1">
  <xsl:output method="xml" version="1.0" encoding="UTF-8"
              indent="no"
              media-type="application/xml" />

  <xsl:param name="documentRoot"/>
  <xsl:param name="baseURI"/>

  <xsl:template match="@*|node()">
    <xsl:copy><xsl:apply-templates select="@*|node()"/></xsl:copy>
  </xsl:template>

  <xsl:template match="/xhtml:html">
    <xsl:variable name="name" select="xhtml:head/xhtml:meta[@name='unix:name']/@content"/>

    <package version="3.0" unique-identifier="{$name}">
      <metadata>
        <dc:identifier id="pub-id"><xsl:value-of select="$name"/></dc:identifier>
        <dc:title><xsl:value-of select="xhtml:head/xhtml:title"/></dc:title>
        <dc:language>en</dc:language>
        <dc:creator><xsl:value-of select="xhtml:head/xhtml:meta[@name='author']/@content"/></dc:creator>
        <meta property="dcterms:modified"><xsl:value-of select="xhtml:head/xhtml:meta[@name='mtime']/@content"/></meta>
      </metadata>

      <manifest>
        <xsl:document href=".build/{$name}.cover.opf.xhtml">
          <html xml:lang="en">
            <head>
              <link rel="stylesheet" href="ef.gy.cover.css" type="text/css"/>
              <title>Cover</title>
            </head>
            <body id="cover">
              <h1>ef.gy</h1>
              <h2><xsl:value-of select="xhtml:head/xhtml:title"/></h2>
              <p>Written by <xsl:value-of select="xhtml:head/xhtml:meta[@name='author']/@content"/>.</p>
              <p>This ebook was automatically transcribed from an XHTML file available at <a href="http://ef.gy/{@name}">ef.gy</a>. Certain elements of the source document may not be present in this ebook transcript due to technical limitations.</p>
            </body>
          </html>
        </xsl:document>
        <item id="cover" href="{$name}.cover.opf.xhtml" media-type="application/xhtml+xml"/>
        <!--<item id="cover" href="{$name}.cover.opf.svg" media-type="image/svg+xml" properties="cover-image"/>-->
        <item id="css" href="ef.gy.book.css" media-type="text/css"/>
        <item id="cover-css" href="ef.gy.cover.css" media-type="text/css"/>
        <item id="main" href="{$name}.opf.xhtml" media-type="application/xhtml+xml">
          <xsl:if test=".//svg:svg">
            <xsl:attribute name="properties">svg</xsl:attribute>
          </xsl:if>
        </item>
        <xsl:for-each select=".//xhtml:img">
          <xsl:variable name="bjpeg" select="substring-after(@src,'/jpeg/')"/>
          <xsl:variable name="bpng" select="substring-after(@src,'/png/')"/>
          <xsl:choose>
            <xsl:when test="$bjpeg != ''">
              <item id="{$bjpeg}" href="jpeg/{$bjpeg}.jpeg" media-type="image/jpeg"/>
            </xsl:when>
            <xsl:when test="$bpng != ''">
              <item id="{$bpng}" href="png/{$bpng}.png" media-type="image/png"/>
            </xsl:when>
          </xsl:choose>
        </xsl:for-each>
      </manifest>

      <spine>
        <itemref idref="cover"/>
        <itemref idref="main"/>
      </spine>
    </package>
  </xsl:template>
</xsl:stylesheet>
