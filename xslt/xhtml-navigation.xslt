<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
              xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
              xmlns:xhtml="http://www.w3.org/1999/xhtml"
              xmlns:social="http://ef.gy/2012/social"
              xmlns:atom="http://www.w3.org/2005/Atom"
              xmlns:georss="http://www.georss.org/georss"
              xmlns:data="http://ef.gy/2013/data"
              xmlns:wst="https://github.com/ef-gy/web-stat-tool"
              xmlns="http://www.w3.org/1999/xhtml"
              exclude-result-prefixes="xhtml social atom georss xsl data"
              version="1.0">
  <xsl:output method="xml" version="1.0" encoding="UTF-8"
              doctype-public="-//W3C//DTD XHTML 1.1//EN"
              doctype-system="http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd"
              indent="no"
              media-type="application/xhtml+xml" />

  <xsl:strip-space elements="*" />
  <xsl:preserve-space elements="xhtml:pre" />

  <xsl:param name="baseURI"/>
  <xsl:param name="documentRoot"/>
  <xsl:param name="DNT"/>

  <xsl:variable name="authors" select="document(concat($documentRoot,'/authors.xml'))/data:data/data:author"/>
  <xsl:variable name="social" select="document(concat($documentRoot,'/social-metadata.xml'))"/>

  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="xhtml:head">
    <head>
      <xsl:apply-templates select="@*|node()"/>
    </head>
  </xsl:template>

  <xsl:template match="xhtml:ul[@id='meta']">
    <xsl:if test="../../xhtml:head/xhtml:link[@rel='next'] | ../../xhtml:head/xhtml:link[@rel='prev']">
      <xsl:copy>
        <xsl:apply-templates select="@*|node()"/>

        <xsl:if test="../../xhtml:head/xhtml:link[@rel='next']"><li class="next"><a href="{../../xhtml:head/xhtml:link[@rel='next']/@href}"><xsl:value-of select="../../xhtml:head/xhtml:link[@rel='next']/@title"/></a></li></xsl:if>
        <xsl:if test="../../xhtml:head/xhtml:link[@rel='prev']"><li class="previous"><a href="{../../xhtml:head/xhtml:link[@rel='prev']/@href}"><xsl:value-of select="../../xhtml:head/xhtml:link[@rel='prev']/@title"/></a></li></xsl:if>

        <xsl:if test="not(../../xhtml:head/xhtml:link[@rel='next']) and not(../../xhtml:head/xhtml:link[@rel='prev']) and not(../../xhtml:head/xhtml:meta[@name='category'][@content='auxiliary'])">
          <li class="draft">this article has not yet been published</li>
        </xsl:if>
      </xsl:copy>
    </xsl:if>
  </xsl:template>

  <xsl:template match="social:grid">
    <xsl:variable name="author" select="@name"/>
    <xsl:variable name="authordata" select="$authors[@name=$author][1]"/>
    <xsl:if test="$authordata">
      <address>
      <xsl:attribute name="class">author-box</xsl:attribute>
      <h2>Written by <xsl:value-of select="$authordata/@display"/></h2>
      <xsl:if test="$authordata/@icon">
        <img src="{$authordata/@icon}" alt="Author Icon: {@name}"/>
      </xsl:if>
      <xsl:if test="$authordata/text()">
        <p><xsl:copy-of select="$authordata/* | $authordata/text()"/></p>
      </xsl:if>
      <xsl:if test="$authordata/@twitter">
        <p><a href="https://twitter.com/{$authordata/@twitter}" class="twitter-follow-button"><xsl:value-of select="$authordata/@twitter"/> on Twitter</a></p>
      </xsl:if>
      <xsl:if test="$authordata/@email">
        <p><a href="mailto:{$authordata/@email}">E-Mail the author.</a></p>
      </xsl:if>
      </address>
    </xsl:if>
  </xsl:template>

  <xsl:template match="social:social">
    <xsl:variable name="url" select="@url"/>
    <xsl:variable name="meta" select="$social/wst:social/wst:url[@id=$url]"/>
    <ul class="share">
      <li class="twitter"><a href="https://twitter.com/share?url={@url}&amp;via={@twitter}" onclick="javascript:window.open(this.href,'', 'menubar=no,toolbar=no,resizable=yes,scrollbars=yes,height=600,width=600');return false;">Twitter&#160;<span><xsl:value-of select="$meta/@twitter"/></span></a></li>
      <li class="linkedin"><a href="http://www.linkedin.com/shareArticle?mini=true&amp;url={@url}" onclick="javascript:window.open(this.href,'', 'menubar=no,toolbar=no,resizable=yes,scrollbars=yes,height=600,width=600');return false;">LinkedIn&#160;<span><xsl:value-of select="$meta/@linkedin"/></span></a></li>
      <li class="facebook"><a href="http://www.facebook.com/sharer.php?u={@url}" onclick="javascript:window.open(this.href,'', 'menubar=no,toolbar=no,resizable=yes,scrollbars=yes,height=600,width=630');return false;">Facebook&#160;<span><xsl:value-of select="$meta/@facebook"/></span></a></li>
      <li class="googleplus"><a href="https://plus.google.com/share?url={@url}" onclick="javascript:window.open(this.href,'', 'menubar=no,toolbar=no,resizable=yes,scrollbars=yes,height=600,width=600');return false;">Google+&#160;<span><xsl:value-of select="$meta/@google-plus"/></span></a></li>
      <li class="stumbleupon"><a href="http://www.stumbleupon.com/submit?url={@url}" onclick="javascript:window.open(this.href,'', 'menubar=no,toolbar=no,resizable=yes,scrollbars=yes,height=600,width=600');return false;">StumbleUpon&#160;<span><xsl:value-of select="$meta/@stumbleupon"/></span></a></li>
    </ul>
  </xsl:template>
</xsl:stylesheet>

