<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
              xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
              xmlns:xhtml="http://www.w3.org/1999/xhtml"
              xmlns:math="http://www.w3.org/1998/Math/MathML"
              xmlns="http://www.w3.org/1999/xhtml"
              exclude-result-prefixes="xhtml math"
              version="1.0">
  <xsl:output method="xml" version="1.0" encoding="UTF-8"
              doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN"
              doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"
              indent="no"
              media-type="text/html" />

  <xsl:param name="documentRoot"/>
  <xsl:param name="disqusShortname"/>

  <xsl:param name="baseURI"/>
  <xsl:param name="DNT"/>

  <xsl:variable name="nosocial" select="($baseURI = 'http://vturtipc7vmz6xjy.onion') or ($DNT = '1')"/>

  <xsl:strip-space elements="*" />
  <xsl:preserve-space elements="xhtml:pre" />

  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()" />
    </xsl:copy>
  </xsl:template>

  <xsl:template match="xhtml:head">
    <head>
      <xsl:apply-templates select="node()"/>
      <link href="/css/ef.gy.doxygen" rel="stylesheet" type="text/css" />
      <meta name="viewport" content="width=device-width, initial-scale=1"/>
    </head>
  </xsl:template>

  <xsl:template match="xhtml:script[@src!=''][not(text())]">
    <script><xsl:apply-templates select="@*" />/**/</script>
  </xsl:template>

  <xsl:template match="xhtml:iframe">
    <iframe><xsl:apply-templates select="@*" />/**/</iframe>
  </xsl:template>

  <xsl:template match="xhtml:script[@src='jquery.js']">
    <script type="text/javascript" src="/js/jquery">/**/</script>
  </xsl:template>

<!--
  <xsl:template match="xhtml:*[xhtml:a/@name][not(self::xhtml:map)]">
    <xsl:copy>
      <xsl:attribute name="id"><xsl:value-of select="xhtml:a/@name"/></xsl:attribute>
      <xsl:apply-templates select="@*" />
      <xsl:apply-templates select="node()[not(self::xhtml:a/@name)]" />
    </xsl:copy>
  </xsl:template>
  -->

  <xsl:template match="xhtml:meta"/>
  <xsl:template match="comment()"/>

  <xsl:template match="xhtml:body">
    <body>
      <xsl:apply-templates select="@*|node()"/>
      <xsl:if test="$disqusShortname != ''">
        <div id="comment-pane">
          <div id="disqus_thread">Loading Disqus...</div>
          <script type="text/javascript">var disqus_shortname = '<xsl:value-of select="$disqusShortname"/>'; (function() { var dsq = document.createElement('script'); dsq.type = 'text/javascript'; dsq.async = true; dsq.src = '//' + disqus_shortname + '.disqus.com/embed.js'; (document.getElementsByTagName('head')[0] || document.getElementsByTagName('body')[0]).appendChild(dsq); })();</script>
          <noscript>Please enable JavaScript to view the <a href="http://disqus.com/?ref_noscript">comments powered by Disqus.</a></noscript>
          <a href="http://disqus.com" class="dsq-brlink">comments powered by <span class="logo-disqus">Disqus</span></a>
        </div>
      </xsl:if>
    </body>
  </xsl:template>
</xsl:stylesheet>

