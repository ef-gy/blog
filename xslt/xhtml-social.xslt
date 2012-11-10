<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
              xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
              xmlns:xhtml="http://www.w3.org/1999/xhtml"
              xmlns:social="http://ef.gy/2012/social"
              xmlns:twitter="http://api.twitter.com"
              xmlns:atom="http://www.w3.org/2005/Atom"
              xmlns:georss="http://www.georss.org/georss"
              xmlns="http://www.w3.org/1999/xhtml"
              exclude-result-prefixes="xhtml social atom georss xsl"
              version="1.0">
  <xsl:output method="xml" version="1.0" encoding="UTF-8"
              doctype-public="-//W3C//DTD XHTML 1.1//EN"
              doctype-system="http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd"
              indent="no"
              media-type="application/xhtml+xml" />

  <xsl:strip-space elements="*" />
  <xsl:preserve-space elements="xhtml:pre" />

  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()" />
    </xsl:copy>
  </xsl:template>

  <xsl:template match="social:social">
    <xsl:variable name="tweets" select="document(concat('http://social.ef.gy/',@twitter))/rss/channel[1]"/>
    <ul id="social">
      <li class="share"><a href="https://twitter.com/share?url={@url}&amp;via={@twitter}" onclick="javascript:window.open(this.href,'', 'menubar=no,toolbar=no,resizable=yes,scrollbars=yes,height=600,width=600');return false;">tweet</a></li>
      <li><a href="http://www.linkedin.com/shareArticle?mini=true&amp;url={@url}" onclick="javascript:window.open(this.href,'', 'menubar=no,toolbar=no,resizable=yes,scrollbars=yes,height=600,width=600');return false;">share: linkedin</a></li>
      <li><a href="http://www.facebook.com/sharer.php?u={@url}" onclick="javascript:window.open(this.href,'', 'menubar=no,toolbar=no,resizable=yes,scrollbars=yes,height=600,width=630');return false;">share: facebook</a></li>
      <li><a href="https://www.xing.com/app/user?op=share&amp;url={@url}" onclick="javascript:window.open(this.href,'','');return false;">share: xing</a></li>
      <li><a href="https://plus.google.com/share?url={@url}" onclick="javascript:window.open(this.href,'', 'menubar=no,toolbar=no,resizable=yes,scrollbars=yes,height=600,width=600');return false;">share: google+</a></li>
    </ul>
  </xsl:template>
</xsl:stylesheet>

