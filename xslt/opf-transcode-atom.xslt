<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
              xmlns:xlink="http://www.w3.org/1999/xlink"
              xmlns:svg="http://www.w3.org/2000/svg"
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

  <xsl:strip-space elements="*" />

  <xsl:template match="/atom:feed">
    <xsl:variable name="name" select="@xml:id"/>

    <package version="3.0" unique-identifier="{@xml:id}">
      <metadata>
        <dc:identifier id="pub-id"><xsl:value-of select="@xml:id"/></dc:identifier>
        <xsl:choose>
          <xsl:when test="atom:subtitle">
            <dc:title id="title"><xsl:value-of select="atom:title"/>/<xsl:value-of select="atom:subtitle"/></dc:title>
            <meta refines="#title" property="title-type">main</meta>
            <dc:title id="alternate"><xsl:value-of select="atom:title"/></dc:title>
            <meta refines="#alternate" property="title-type">alternate</meta>
            <dc:title id="subtitle"><xsl:value-of select="atom:subtitle"/></dc:title>
            <meta refines="#subtitle" property="title-type">subtitle</meta>
          </xsl:when>
          <xsl:otherwise>
            <dc:title id="title"><xsl:value-of select="atom:title"/></dc:title>
            <meta refines="#title" property="title-type">main</meta>
          </xsl:otherwise>
        </xsl:choose>
        <dc:language>en</dc:language>
      </metadata>

      <manifest>
        <xsl:document href=".build/{$name}.cover.opf.xhtml">
          <html xml:lang="en">
            <head>
              <title>Cover</title>
              <link rel="stylesheet" href="ef.gy.cover.css" type="text/css"/>
            </head>
            <body id="cover">
              <h1><xsl:value-of select="atom:title"/></h1>
              <xsl:if test="atom:subtitle">
                <h2><xsl:value-of select="atom:subtitle"/></h2>
              </xsl:if>
              <p>Written by...</p>
              <ul>
                <xsl:for-each select="atom:entry/atom:author">
                  <li><xsl:value-of select="atom:name"/></li>
                </xsl:for-each>
              </ul>
              <p>This ebook was automatically transcribed from source documents available at <a href="http://ef.gy/source-code">ef.gy</a>. Certain elements of the source documents may not be present in this ebook transcript due to technical limitations.</p>
            </body>
          </html>
        </xsl:document>
        <item id="cover" href="{$name}.cover.opf.xhtml" media-type="application/xhtml+xml"/>
        <item id="css" href="ef.gy.book.css" media-type="text/css"/>
        <item id="cover-css" href="ef.gy.cover.css" media-type="text/css"/>
        <xsl:for-each select="atom:entry[.//xhtml:meta[@name='unix:name']]">
          <xsl:if test="substring-after(atom:id,'drupal:')=''">
            <item id="item-{position()}" href="{atom:content/xhtml:html/xhtml:head/xhtml:meta[@name='unix:name']/@content}.opf.xhtml" media-type="application/xhtml+xml">
              <xsl:if test=".//svg:svg">
                <xsl:attribute name="properties">svg</xsl:attribute>
              </xsl:if>
            </item>
          </xsl:if>
        </xsl:for-each>
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
        <xsl:for-each select="atom:entry[.//xhtml:meta[@name='unix:name']]">
          <xsl:if test="substring-after(atom:id,'drupal:')=''">
            <itemref idref="item-{position()}"/>
          </xsl:if>
        </xsl:for-each>
      </spine>
    </package>
  </xsl:template>
</xsl:stylesheet>
