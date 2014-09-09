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

  <xsl:param name="documentRoot"/>
  <xsl:param name="baseURI"/>

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
      <html xml:lang="en">
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
              <link rel="alternate" type="application/atom+xml" href="{$baseURI}/atom/{@xml:id}" />
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
              <xsl:variable name="link" select="atom:link/@href"/>
              <xsl:choose>
                <xsl:when test="not($link)">
                  <li class="large"><h1><xsl:value-of select="atom:content/xhtml:html/xhtml:head/xhtml:title"/></h1>
                  <ul>
                    <li class="published"><xsl:value-of select="(atom:published | atom:updated)[1]"/></li>
                    <xsl:choose>
                      <xsl:when test="contains(atom:author/atom:name, ' ')">
                        <li class="author"><xsl:value-of select="substring-before(atom:author/atom:name, ' ')"/></li>
                      </xsl:when>
                      <xsl:otherwise>
                        <li class="author"><xsl:value-of select="atom:author/atom:name"/></li>
                      </xsl:otherwise>
                    </xsl:choose>
                  </ul>
                  <xsl:for-each select="atom:content/xhtml:html/xhtml:body/xhtml:* | atom:content/xhtml:html/xhtml:body/svg:*">
                    <xsl:choose>
                      <xsl:when test="self::xhtml:h1">
                        <h2><xsl:copy-of select="@*"/><xsl:copy-of select="text()"/></h2>
                      </xsl:when>
                      <xsl:when test="self::xhtml:h2">
                        <h3><xsl:copy-of select="@*"/><xsl:copy-of select="text()"/></h3>
                      </xsl:when>
                      <xsl:when test="self::xhtml:h3">
                        <h4><xsl:copy-of select="@*"/><xsl:copy-of select="text()"/></h4>
                      </xsl:when>
                      <xsl:when test="self::xhtml:h4">
                        <h5><xsl:copy-of select="@*"/><xsl:copy-of select="text()"/></h5>
                      </xsl:when>
                      <xsl:when test="self::xhtml:h5">
                        <h6><xsl:copy-of select="@*"/><xsl:copy-of select="text()"/></h6>
                      </xsl:when>
                      <xsl:otherwise>
                        <xsl:copy-of select="."/>
                      </xsl:otherwise>
                    </xsl:choose>
                  </xsl:for-each>
                  </li>
                </xsl:when>
                <xsl:when test="(position() = 1) or ($weights[@name=$tname] &gt;= 5)">
                  <li class="large"><h1><a href="{$link}"><xsl:value-of select="atom:content/xhtml:html/xhtml:head/xhtml:title"/></a></h1>
                  <ul>
                    <li class="published"><xsl:value-of select="(atom:published | atom:updated)[1]"/></li>
                    <xsl:choose>
                      <xsl:when test="contains(atom:author/atom:name, ' ')">
                        <li class="author"><xsl:value-of select="substring-before(atom:author/atom:name, ' ')"/></li>
                      </xsl:when>
                      <xsl:otherwise>
                        <li class="author"><xsl:value-of select="atom:author/atom:name"/></li>
                      </xsl:otherwise>
                    </xsl:choose>
                  </ul>
                  <xsl:for-each select="atom:content/xhtml:html/xhtml:body/xhtml:* | atom:content/xhtml:html/xhtml:body/svg:*">
                    <xsl:if test="position() &lt; 5">
                      <xsl:choose>
                        <xsl:when test="self::xhtml:h1">
                          <h2><xsl:copy-of select="@*"/><xsl:copy-of select="text()"/></h2>
                        </xsl:when>
                        <xsl:when test="self::xhtml:h2">
                          <h3><xsl:copy-of select="@*"/><xsl:copy-of select="text()"/></h3>
                        </xsl:when>
                        <xsl:when test="self::xhtml:h3">
                          <h4><xsl:copy-of select="@*"/><xsl:copy-of select="text()"/></h4>
                        </xsl:when>
                        <xsl:when test="self::xhtml:h4">
                          <h5><xsl:copy-of select="@*"/><xsl:copy-of select="text()"/></h5>
                        </xsl:when>
                        <xsl:when test="self::xhtml:h5">
                          <h6><xsl:copy-of select="@*"/><xsl:copy-of select="text()"/></h6>
                        </xsl:when>
                        <xsl:otherwise>
                          <xsl:copy-of select="."/>
                        </xsl:otherwise>
                      </xsl:choose>
                    </xsl:if>
                  </xsl:for-each>
                  <p class="continue"><a href="{$link}">continue reading</a></p>
                  </li>
                </xsl:when>
                <xsl:otherwise>
                  <li class="medium"><h1><a href="{$link}"><xsl:value-of select="atom:content/xhtml:html/xhtml:head/xhtml:title"/></a></h1>
                  <ul>
                    <li class="published"><xsl:value-of select="(atom:published | atom:updated)[1]"/></li>
                    <xsl:choose>
                      <xsl:when test="contains(atom:author/atom:name, ' ')">
                        <li class="author"><xsl:value-of select="substring-before(atom:author/atom:name, ' ')"/></li>
                      </xsl:when>
                      <xsl:otherwise>
                        <li class="author"><xsl:value-of select="atom:author/atom:name"/></li>
                      </xsl:otherwise>
                    </xsl:choose>
                  </ul>
                  <xsl:for-each select="atom:content/xhtml:html/xhtml:body/xhtml:p | atom:content/xhtml:html/xhtml:body/xhtml:img | atom:content/xhtml:html/xhtml:body/xhtml:blockquote | atom:content/xhtml:html/xhtml:body/svg:svg">
                    <xsl:if test="position() &lt; 3">
                      <xsl:choose>
                        <xsl:when test="self::xhtml:h1">
                          <h2><xsl:copy-of select="@*"/><xsl:copy-of select="text()"/></h2>
                        </xsl:when>
                        <xsl:when test="self::xhtml:h2">
                          <h3><xsl:copy-of select="@*"/><xsl:copy-of select="text()"/></h3>
                        </xsl:when>
                        <xsl:when test="self::xhtml:h3">
                          <h4><xsl:copy-of select="@*"/><xsl:copy-of select="text()"/></h4>
                        </xsl:when>
                        <xsl:when test="self::xhtml:h4">
                          <h5><xsl:copy-of select="@*"/><xsl:copy-of select="text()"/></h5>
                        </xsl:when>
                        <xsl:when test="self::xhtml:h5">
                          <h6><xsl:copy-of select="@*"/><xsl:copy-of select="text()"/></h6>
                        </xsl:when>
                        <xsl:otherwise>
                          <xsl:copy-of select="."/>
                        </xsl:otherwise>
                      </xsl:choose>
                    </xsl:if>
                  </xsl:for-each>
                  <p class="continue"><a href="{$link}">continue reading</a></p>
                  </li>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:for-each>
          </ul>
        </body>
      </html>
  </xsl:template>
</xsl:stylesheet>

