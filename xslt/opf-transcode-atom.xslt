<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
              xmlns:xlink="http://www.w3.org/1999/xlink"
              xmlns:svg="http://www.w3.org/2000/svg"
              xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
              xmlns:atom="http://www.w3.org/2005/Atom"
              xmlns:opf="http://www.idpf.org/2007/opf"
              xmlns:epub="http://www.idpf.org/2007/ops"
              xmlns:dc="http://purl.org/dc/elements/1.1/"
              xmlns:xhtml="http://www.w3.org/1999/xhtml"
              xmlns="http://www.idpf.org/2007/opf"
              version="1.0">
  <xsl:output method="xml" version="1.0" encoding="UTF-8"
              indent="no"
              media-type="application/xml" />

  <xsl:param name="builddir"/>

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
        <xsl:document href="{$builddir}/{$name}/cover.xhtml">
          <html xml:lang="en" xmlns="http://www.w3.org/1999/xhtml">
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
                <xsl:for-each select="atom:entry/atom:author[not(.=preceding::atom:author)]">
                  <li><xsl:value-of select="atom:name"/></li>
                </xsl:for-each>
              </ul>
              <p>This ebook was automatically transcribed from source documents available at <a href="http://ef.gy/source-code">ef.gy</a>. Certain elements of the source documents may not be present in this ebook transcript due to technical limitations.</p>
            </body>
          </html>
        </xsl:document>
        <item id="cover" href="cover.xhtml" media-type="application/xhtml+xml"/>

        <xsl:document href="{$builddir}/{$name}/toc.xhtml">
          <html xml:lang="en" xmlns="http://www.w3.org/1999/xhtml">
            <head>
              <title>Table of Contents</title>
              <link href="book.css" rel="stylesheet" type="text/css"/>
            </head>
            <body>
              <h1>Table of Contents</h1>
              <nav epub:type="toc">
                <h2>Main Content</h2>
                <ol>
                  <li><a href="cover.xhtml">Cover</a></li>
                  <li><a href="toc.xhtml">Table of Contents</a></li>
                  <xsl:for-each select="atom:entry[atom:content[@type='application/xhtml+xml']]">
                    <li><a href="content-{position()}.xhtml"><xsl:value-of select="atom:content/xhtml:html/xhtml:head/xhtml:title"/></a></li>
                  </xsl:for-each>
                </ol>
              </nav>
            </body>
          </html>
        </xsl:document>
        <item id="toc" href="toc.xhtml" media-type="application/xhtml+xml" properties="nav"/>
        <item id="css" href="book.css" media-type="text/css"/>
        <item id="cover-css" href="ef.gy.cover.css" media-type="text/css"/>
        <xsl:for-each select="atom:entry[atom:content[@type='application/xhtml+xml']]">
          <xsl:document href="{$builddir}/{$name}/content-{position()}.xhtml">
            <xsl:copy-of select="atom:content/xhtml:html"/>
          </xsl:document>
          <item id="xhtml-{position()}" href="content-{position()}.xhtml" media-type="application/xhtml+xml">
            <xsl:if test=".//svg:svg">
              <xsl:attribute name="properties">svg</xsl:attribute>
            </xsl:if>
          </item>
        </xsl:for-each>
        <xsl:for-each select=".//xhtml:img">
          <xsl:variable name="bjpeg" select="substring-after(@src,'jpeg/')"/>
          <xsl:variable name="bpng" select="substring-after(@src,'png/')"/>
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
        <itemref idref="toc"/>
        <xsl:for-each select="atom:entry[atom:content[@type='application/xhtml+xml']]">
          <itemref idref="xhtml-{position()}"/>
        </xsl:for-each>
      </spine>
    </package>
  </xsl:template>
</xsl:stylesheet>
