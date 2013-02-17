<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
              xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
              xmlns:xhtml="http://www.w3.org/1999/xhtml"
              xmlns:atom="http://www.w3.org/2005/Atom"
              xmlns:source="http://ef.gy/2012/source"
              xmlns:data="http://ef.gy/2013/data"
              xmlns:str="http://exslt.org/strings"
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
  <xsl:param name="documentRoot"/>

  <xsl:variable name="weights" select="document(concat($documentRoot, '/data.xml'))//data:weight"/>

  <xsl:key name="entry-by-category" match="atom:entry" use="atom:category[1]/@term" />

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

  <xsl:template match="xhtml:meta/atom:feed">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:for-each select="atom:entry">
        <xsl:sort select="atom:published | atom:updated[not(parent::node()/atom:published)]" order="descending"/>
        <xsl:copy-of select="."/>
      </xsl:for-each>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="/atom:feed">
   <xsl:choose>
    <xsl:when test="(string-length($target) > 0) and atom:entry/atom:content/xhtml:html[xhtml:head/xhtml:meta/@name='unix:name'][xhtml:head/xhtml:meta/@content=str:decode-uri($target)]"><xsl:copy-of select="atom:entry/atom:content/xhtml:html[xhtml:head/xhtml:meta/@name='unix:name'][xhtml:head/xhtml:meta/@content=str:decode-uri($target)]"/></xsl:when>
    <xsl:otherwise><html>
      <head>
        <title><xsl:value-of select="atom:title" /></title>
        <xsl:choose>
          <xsl:when test="@xml:id">
            <link rel="alternate" type="application/atom+xml" href="http://ef.gy/atom/{@xml:id}" />
          </xsl:when>
          <xsl:when test="atom:link[@rel='self']/@href">
            <link rel="alternate" type="application/atom+xml" href="{atom:link[@rel='self']/@href}" />
          </xsl:when>
        </xsl:choose>
      </head>
      <body id="feed">
          <ul>
            <xsl:for-each select="atom:entry">
              <xsl:sort select="atom:published | atom:updated[not(parent::node()/atom:published)]" order="descending"/>
              <xsl:variable name="tname" select="atom:content/xhtml:html/xhtml:head/xhtml:meta[@name='unix:name']/@content"/>
              <xsl:choose>
                <xsl:when test="($target='home' or $target='') and ((position() = 1) or ($weights[@name=$tname] &gt;= 5))">
                  <li class="large"><h1><xsl:value-of select="atom:content/xhtml:html/xhtml:head/xhtml:title"/></h1>
                  <ul>
                    <li class="published"><xsl:value-of select="(atom:published | atom:updated)[1]"/></li>
                    <li class="author"><xsl:value-of select="atom:author/atom:name"/></li>
                  </ul>
                  <xsl:for-each select="atom:content/xhtml:html/xhtml:body/xhtml:*">
                    <xsl:if test="position() &lt; 5">
                      <xsl:choose>
                        <xsl:when test="name(.) = 'p'">
                          <xsl:copy-of select="."/>
                        </xsl:when>
                        <xsl:when test="name(.) = 'h1'">
                          <h2><xsl:copy-of select="@*"/><xsl:copy-of select="text()"/></h2>
                        </xsl:when>
                      </xsl:choose>
                    </xsl:if>
                  </xsl:for-each>
                  <ul><li><a><xsl:attribute name="href">
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
                  </xsl:attribute>read more...</a></li></ul>
                  </li>
                </xsl:when>
                <xsl:when test="($target='home' or $target='') and ((position() &lt; 3) or ($weights[@name=$tname] &gt;= 3))">
                  <li class="medium"><h1><xsl:value-of select="atom:content/xhtml:html/xhtml:head/xhtml:title"/></h1>
                  <ul>
                    <li class="published"><xsl:value-of select="(atom:published | atom:updated)[1]"/></li>
                    <li class="author"><xsl:value-of select="atom:author/atom:name"/></li>
                  </ul>
                  <xsl:for-each select="atom:content/xhtml:html/xhtml:body/xhtml:p">
                    <xsl:if test="position() &lt; 3">
                      <xsl:choose>
                        <xsl:when test="name(.) = 'p'">
                          <xsl:copy-of select="."/>
                        </xsl:when>
                        <xsl:when test="name(.) = 'h1'">
                          <h2><xsl:copy-of select="@*"/><xsl:copy-of select="text()"/></h2>
                        </xsl:when>
                      </xsl:choose>
                    </xsl:if>
                  </xsl:for-each>
                  <ul><li><a><xsl:attribute name="href">
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
                  </xsl:attribute>read more...</a></li></ul>
                  </li>
                </xsl:when>
                <xsl:otherwise>
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
                      <xsl:if test="substring-before(atom:category[1]/@term,'/')='download'"><span class="secondary-category"><xsl:value-of select="' download'"/></span></xsl:if>
                      <xsl:choose>
                        <xsl:when test="substring-before(atom:author/atom:name,' ')"><span class="author"><xsl:value-of select="concat(' ',substring-before(atom:author/atom:name,' '))" /></span></xsl:when>
                        <xsl:when test="atom:author/atom:name/text()"><span class="author"><xsl:value-of select="concat(' ',atom:author/atom:name)" /></span></xsl:when>
                        <xsl:otherwise/>
                      </xsl:choose>
                      <span class="updated"><xsl:value-of select="concat(' ',substring-before(atom:updated,'T'))" /></span>
                    </a>
                  </li>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:for-each>
          </ul>
      </body>
    </html></xsl:otherwise>
   </xsl:choose>
  </xsl:template>
</xsl:stylesheet>

