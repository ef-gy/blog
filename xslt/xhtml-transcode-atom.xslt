<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
              xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
              xmlns:xhtml="http://www.w3.org/1999/xhtml"
              xmlns:atom="http://www.w3.org/2005/Atom"
              xmlns:data="http://ef.gy/2013/data"
              xmlns:str="http://exslt.org/strings"
              xmlns:svg="http://www.w3.org/2000/svg"
              xmlns="http://www.w3.org/1999/xhtml"
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
          <xsl:choose>
            <xsl:when test="atom:subtitle">
              <title><xsl:value-of select="atom:title"/> :: <xsl:value-of select="atom:subtitle"/></title>
            </xsl:when>
            <xsl:otherwise>
              <title><xsl:value-of select="atom:title"/></title>
            </xsl:otherwise>
          </xsl:choose>
          <xsl:choose>
            <xsl:when test="@xml:id">
              <link rel="alternate" type="application/atom+xml" href="http://ef.gy/atom/{@xml:id}" />
            </xsl:when>
            <xsl:when test="atom:link[@rel='self']/@href">
              <link rel="alternate" type="application/atom+xml" href="{atom:link[@rel='self']/@href}" />
            </xsl:when>
          </xsl:choose>
        </head>
        <body id="full">
          <ul id="feed">
            <xsl:for-each select="atom:entry">
              <xsl:sort select="atom:published | atom:updated[not(parent::node()/atom:published)]" order="descending"/>

              <xsl:variable name="tname" select="atom:content/xhtml:html/xhtml:head/xhtml:meta[@name='unix:name']/@content"/>
              <xsl:variable name="link">
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
              </xsl:variable>
              <xsl:choose>
                <xsl:when test="($target='home' or $target='') and ((position() = 1) or ($weights[@name=$tname] &gt;= 5))">
                  <li class="large"><h1><a href="{$link}"><xsl:value-of select="atom:content/xhtml:html/xhtml:head/xhtml:title"/></a></h1>
                  <ul>
                    <li class="published"><xsl:value-of select="(atom:published | atom:updated)[1]"/></li>
                    <xsl:if test="atom:author/atom:name != 'Magnus Achim Deininger'">
                      <li class="author"><xsl:value-of select="atom:author/atom:name"/></li>
                    </xsl:if>
                  </ul>
                  <xsl:for-each select="atom:content/xhtml:html/xhtml:body/xhtml:* | atom:content/xhtml:html/xhtml:body/svg:*">
                    <xsl:if test="position() &lt; 5">
                      <xsl:choose>
                        <xsl:when test="self::xhtml:p">
                          <xsl:copy-of select="."/>
                        </xsl:when>
                        <xsl:when test="self::xhtml:h1">
                          <h2><xsl:copy-of select="@*"/><xsl:copy-of select="text()"/></h2>
                        </xsl:when>
                        <xsl:when test="self::svg:svg">
                          <xsl:copy-of select="."/>
                        </xsl:when>
                      </xsl:choose>
                    </xsl:if>
                  </xsl:for-each>
                  <p><a href="{$link}">(read on...)</a></p>
                  </li>
                </xsl:when>
                <xsl:when test="($target='home' or $target='') and ((position() &lt; 3) or ($weights[@name=$tname] &gt;= 3))">
                  <li class="medium"><h1><a href="{$link}"><xsl:value-of select="atom:content/xhtml:html/xhtml:head/xhtml:title"/></a></h1>
                  <ul>
                    <li class="published"><xsl:value-of select="(atom:published | atom:updated)[1]"/></li>
                    <xsl:if test="atom:author/atom:name != 'Magnus Achim Deininger'">
                      <li class="author"><xsl:value-of select="atom:author/atom:name"/></li>
                    </xsl:if>
                  </ul>
                  <xsl:for-each select="atom:content/xhtml:html/xhtml:body/xhtml:p | atom:content/xhtml:html/xhtml:body/svg:svg">
                    <xsl:if test="position() &lt; 3">
                      <xsl:choose>
                        <xsl:when test="self::xhtml:p">
                          <xsl:copy-of select="."/>
                        </xsl:when>
                        <xsl:when test="self::svg:svg">
                          <xsl:copy-of select="."/>
                        </xsl:when>
                      </xsl:choose>
                    </xsl:if>
                  </xsl:for-each>
                  <p><a href="{$link}">(read on...)</a></p>
                  </li>
                </xsl:when>
                <xsl:otherwise>
                  <li class="small"><h1><a href="{$link}"><xsl:value-of select="atom:content/xhtml:html/xhtml:head/xhtml:title"/></a></h1>
                  <ul>
                    <li class="published"><xsl:value-of select="(atom:published | atom:updated)[1]"/></li>
                    <xsl:if test="atom:author/atom:name != 'Magnus Achim Deininger'">
                      <li class="author"><xsl:value-of select="atom:author/atom:name"/></li>
                    </xsl:if>
                  </ul>
                  <p>
                    <xsl:value-of select="atom:summary"/>
                  </p>
                  <p><a href="{$link}">(read on...)</a></p>
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

