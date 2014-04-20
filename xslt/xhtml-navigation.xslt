<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
              xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
              xmlns:xhtml="http://www.w3.org/1999/xhtml"
              xmlns:social="http://ef.gy/2012/social"
              xmlns:atom="http://www.w3.org/2005/Atom"
              xmlns:georss="http://www.georss.org/georss"
              xmlns:data="http://ef.gy/2013/data"
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

  <xsl:param name="documentRoot"/>

  <xsl:variable name="authors" select="document(concat($documentRoot,'/authors.xml'))/data:data/data:author"/>

  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="xhtml:head">
    <head>
      <xsl:apply-templates select="@*|node()"/>
      <xsl:if test="//social:social/@flattr">
        <link rel="payment" href="https://flattr.com/submit/auto?url={//social:social/@url}&amp;user_id={//social:social/@flattr}&amp;title={translate(/xhtml:html/xhtml:head/xhtml:title,'&#34; ',&#34;&#39;+&#34;)}&amp;description={translate(/xhtml:html/xhtml:head/xhtml:meta[@name='description']/@content,'&#34; ',&#34;&#39;+&#34;)}"/>
      </xsl:if>
    </head>
  </xsl:template>

  <xsl:template match="xhtml:ul[@id='meta']">
    <xsl:if test="node() | ../../xhtml:head/xhtml:link[@rel='next'] | ../../xhtml:head/xhtml:link[@rel='prev']">
      <xsl:copy>
        <xsl:apply-templates select="@*|node()"/>

        <xsl:if test="../../xhtml:head/xhtml:link[@rel='next']"><li class="next"><a href="{../../xhtml:head/xhtml:link[@rel='next']/@href}"><xsl:value-of select="../../xhtml:head/xhtml:link[@rel='next']/@title"/></a></li></xsl:if>
        <xsl:if test="../../xhtml:head/xhtml:link[@rel='prev']"><li class="previous"><a href="{../../xhtml:head/xhtml:link[@rel='prev']/@href}"><xsl:value-of select="../../xhtml:head/xhtml:link[@rel='prev']/@title"/></a></li></xsl:if>

        <xsl:if test="not(../../xhtml:head/xhtml:link[@rel='next']) and not (../../xhtml:head/xhtml:link[@rel='prev'])">
          <li class="draft">this article has not yet been published</li>
        </xsl:if>
      </xsl:copy>
    </xsl:if>
  </xsl:template>

  <xsl:template match="social:grid">
    <xsl:variable name="author" select="@name"/>
    <xsl:variable name="authordata" select="$authors[@name=$author][1]"/>
    <address>
    <xsl:choose>
      <xsl:when test="@author-box='yes'">
        <xsl:attribute name="class">author-box</xsl:attribute>
        <span>Written by <xsl:value-of select="@name"/></span>
      </xsl:when>
      <xsl:otherwise>
        <span>Author Profile: <xsl:value-of select="@name"/></span>
      </xsl:otherwise>
    </xsl:choose>
    <ul class="social-grid">
      <xsl:if test="$authordata/@image">
        <li class="image"><img src="{$authordata/@image}" alt="Author Mugshot: {@name}"/></li>
      </xsl:if>
      <xsl:if test="$authordata/@skype">
        <li class="skype"><a href="skype:{$authordata/@skype}">Skype</a></li>
      </xsl:if>
      <xsl:if test="$authordata/@twitter">
        <li class="twitter"><a href="https://twitter.com/{$authordata/@twitter}">Twitter</a></li>
      </xsl:if>
      <xsl:if test="$authordata/@linkedin">
        <li class="linkedin"><a href="http://www.linkedin.com/in/{$authordata/@linkedin}">LinkedIn</a></li>
      </xsl:if>
      <xsl:if test="$authordata/@facebook">
        <li class="facebook"><a href="https://www.facebook.com/{$authordata/@facebook}">Facebook</a></li>
      </xsl:if>
      <xsl:if test="$authordata/@xing">
        <li class="xing"><a href="http://www.xing.com/profiles/{$authordata/@xing}">Xing</a></li>
      </xsl:if>
      <xsl:if test="$authordata/@googleplus">
        <li class="googleplus"><a href="https://plus.google.com/{$authordata/@googleplus}">Google+</a></li>
      </xsl:if>
      <xsl:if test="$authordata/@flattr">
        <li class="flattr"><a href="https://flattr.com/profile/{$authordata/@flattr}">Flattr</a></li>
      </xsl:if>
      <xsl:if test="$authordata/@email">
        <li class="email"><a href="mailto:{$authordata/@email}">E-Mail</a></li>
      </xsl:if>
      <xsl:if test="$authordata/@irc">
        <li class="irc"><a href="{$authordata/@irc}">IRC</a></li>
      </xsl:if>
      <xsl:if test="$authordata/@phone">
        <li class="phone"><a href="tel:{$authordata/@phone}">Phone</a></li>
      </xsl:if>
      <xsl:if test="$authordata/text()">
        <li class="bio"><xsl:copy-of select="$authordata/* | $authordata/text()"/></li>
      </xsl:if>
    </ul>
    </address>
  </xsl:template>

  <xsl:template match="social:social">
    <ul id="social">
      <xsl:if test="@twitter">
        <li class="twitter"><a href="https://twitter.com/share?url={@url}&amp;via={@twitter}" onclick="javascript:window.open(this.href,'', 'menubar=no,toolbar=no,resizable=yes,scrollbars=yes,height=600,width=600');return false;">Twitter</a></li>
      </xsl:if>
      <li class="linkedin"><a href="http://www.linkedin.com/shareArticle?mini=true&amp;url={@url}" onclick="javascript:window.open(this.href,'', 'menubar=no,toolbar=no,resizable=yes,scrollbars=yes,height=600,width=600');return false;">LinkedIn</a></li>
      <li class="facebook"><a href="http://www.facebook.com/sharer.php?u={@url}" onclick="javascript:window.open(this.href,'', 'menubar=no,toolbar=no,resizable=yes,scrollbars=yes,height=600,width=630');return false;">Facebook</a></li>
      <li class="xing"><a href="https://www.xing.com/app/user?op=share&amp;url={@url}" onclick="javascript:window.open(this.href,'','');return false;">Xing</a></li>
      <li class="googleplus"><a href="https://plus.google.com/share?url={@url}" onclick="javascript:window.open(this.href,'', 'menubar=no,toolbar=no,resizable=yes,scrollbars=yes,height=600,width=600');return false;">Google+</a></li>
      <li class="stumbleupon"><a href="http://www.stumbleupon.com/submit?url={@url}" onclick="javascript:window.open(this.href,'', 'menubar=no,toolbar=no,resizable=yes,scrollbars=yes,height=600,width=600');return false;">StumbleUpon</a></li>
      <xsl:if test="@flattr">
        <li class="flattr"><a href="https://flattr.com/submit/auto?url={@url}&amp;user_id={@flattr}&amp;title={translate(/xhtml:html/xhtml:head/xhtml:title,'&#34; ',&#34;&#39;+&#34;)}&amp;description={translate(/xhtml:html/xhtml:head/xhtml:meta[@name='description']/@content,'&#34; ',&#34;&#39;+&#34;)}" onclick="javascript:window.open(this.href,'', 'menubar=no,toolbar=no,resizable=yes,scrollbars=yes,height=600,width=600');return false;">Flattr</a></li>
      </xsl:if>
    </ul>
  </xsl:template>

  <xsl:template match="social:follow">
    <a href="https://twitter.com/{@twitter}" class="twitter-follow-button">follow <xsl:value-of select="@twitter"/> on Twitter</a>
    <script>!function(d,s,id){var js,fjs=d.getElementsByTagName(s)[0],p=/^http:/.test(d.location)?'http':'https';if(!d.getElementById(id)){js=d.createElement(s);js.id=id;js.src=p+'://platform.twitter.com/widgets.js';fjs.parentNode.insertBefore(js,fjs);}}(document, 'script', 'twitter-wjs');</script>
  </xsl:template>
</xsl:stylesheet>

