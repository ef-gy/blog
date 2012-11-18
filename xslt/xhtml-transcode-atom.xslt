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

  <xsl:param name="target"/>
  <xsl:param name="collection"/>

  <xsl:key name="entry-by-category" match="atom:entry" use="atom:category[1]/@term" />
  <xsl:key name="entry-by-updated" match="atom:entry" use="atom:updated" />

  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()" />
    </xsl:copy>
  </xsl:template>

  <xsl:template match="//xhtml:meta/atom:feed">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()" />
    </xsl:copy>
  </xsl:template>

  <xsl:template match="/atom:feed">
   <xsl:choose>
    <xsl:when test="(string-length($target) > 0) and //xhtml:html[xhtml:head/xhtml:meta/@name='unix:name'][xhtml:head/xhtml:meta/@content=$target]"><xsl:copy-of select="//xhtml:html[xhtml:head/xhtml:meta/@name='unix:name'][xhtml:head/xhtml:meta/@content=$target]"/></xsl:when>
    <xsl:otherwise><html>
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
              <xsl:sort select="atom:updated" order="descending"/>
              <li>
                <a>
                  <xsl:attribute name="href">
                    <xsl:choose>
                      <xsl:when test="atom:link/@href"><xsl:value-of select="atom:link/@href"/></xsl:when>
                      <xsl:when test="atom:category[@term='einit.org']">
                        <xsl:value-of select="concat('/',atom:content/xhtml:html/xhtml:head/xhtml:meta[@name='unix:name']/@content,'@drupal-einit')"/>
                      </xsl:when>
                      <xsl:when test="atom:category[@term='kyuba.org']">
                        <xsl:value-of select="concat('/',atom:content/xhtml:html/xhtml:head/xhtml:meta[@name='unix:name']/@content,'@drupal-kyuba')"/>
                      </xsl:when>
                      <xsl:otherwise><xsl:value-of select="concat('/',atom:content/xhtml:html/xhtml:head/xhtml:meta[@name='unix:name']/@content,'@',$collection)"/></xsl:otherwise>
                    </xsl:choose>
                  </xsl:attribute>
                  <span><xsl:value-of select="atom:title" /></span>
                  <xsl:value-of select="concat(' ',atom:summary)" />
                  <xsl:if test="atom:category[2]"><span class="secondary-category"><xsl:value-of select="concat(' ',atom:category[2]/@term)" /></span></xsl:if>
                  <xsl:choose>
                    <xsl:when test="substring-before(atom:author/atom:name,' ')"><span class="author"><xsl:value-of select="concat(' ',substring-before(atom:author/atom:name,' '))" /></span></xsl:when>
                    <xsl:when test="atom:author/atom:name/text()"><span class="author"><xsl:value-of select="concat(' ',atom:author/atom:name)" /></span></xsl:when>
                    <xsl:otherwise/>
                  </xsl:choose>
                  <span class="updated"><xsl:value-of select="concat(' ',substring-before(atom:updated,'T'))" /></span>
                </a>
              </li>
            </xsl:for-each>
          </ul>
        </xsl:for-each>
      </body>
    </html></xsl:otherwise>
   </xsl:choose>
  </xsl:template>
</xsl:stylesheet>

