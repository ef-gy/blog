<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
              xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
              xmlns:xhtml="http://www.w3.org/1999/xhtml"
              xmlns:atom="http://www.w3.org/2005/Atom"
              xmlns:source="http://ef.gy/2012/source"
              xmlns="http://www.w3.org/1999/xhtml"
              exclude-result-prefixes="source"
              version="1.0">
  <xsl:output method="xml" version="1.0" encoding="UTF-8"
              doctype-public="-//W3C//DTD XHTML 1.1//EN"
              doctype-system="http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd"
              indent="no"
              media-type="application/xhtml+xml" />

  <xsl:key name="entry-by-category" match="atom:entry" use="atom:category/@term" />
  <xsl:key name="entry-by-updated" match="atom:entry" use="atom:updated" />

  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()" />
    </xsl:copy>
  </xsl:template>

  <xsl:template match="//atom:feed">
    <html>
      <head>
        <xsl:choose>
          <xsl:when test="atom:title='http://ef.gy/ Articles'">
            <title>Articles</title>
          </xsl:when>
          <xsl:otherwise>
            <title><xsl:value-of select="atom:title" /></title>
          </xsl:otherwise>
        </xsl:choose>
        <link rel="alternate" type="application/atom+xml" href="{atom:link[@rel='self']/@href}" />
      </head>
      <body id="feed">
        <xsl:for-each select="atom:entry[count(. | key('entry-by-category', atom:category/@term)[1]) = 1]">
          <xsl:sort select="atom:category/@term" />
          <h1><xsl:value-of select="atom:category/@term" /></h1>
          <ul>
            <xsl:for-each select="key('entry-by-category', atom:category/@term)">
              <li>
                <a href="{atom:link/@href}">
                  <span><xsl:value-of select="atom:title" /></span>
                  <xsl:value-of select="concat(' ',atom:summary)" />
                  <span class="author"><xsl:value-of select="concat(' ',substring-before(atom:author/atom:name,' '))" /></span>
                </a>
              </li>
            </xsl:for-each>
          </ul>
        </xsl:for-each>
      </body>
    </html>
  </xsl:template>
</xsl:stylesheet>

