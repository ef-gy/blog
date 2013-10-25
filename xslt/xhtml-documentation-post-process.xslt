<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
              xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
              xmlns:xhtml="http://www.w3.org/1999/xhtml"
              xmlns:math="http://www.w3.org/1998/Math/MathML"
              xmlns="http://www.w3.org/1999/xhtml"
              exclude-result-prefixes="xhtml math"
              version="1.0">
  <xsl:output method="xml" version="1.0" encoding="UTF-8"
              doctype-public="-//W3C//DTD XHTML 1.1//EN"
              doctype-system="http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd"
              indent="no"
              media-type="application/xhtml+xml" />

  <xsl:param name="target"/>
  <xsl:param name="collection"/>
  <xsl:param name="userCountry"/>
  <xsl:param name="cookieDisqus"/>
  <xsl:param name="documentRoot"/>

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
    </head>
  </xsl:template>

  <xsl:template match="xhtml:script[@src='jquery.js']">
    <script type="text/javascript" src="/js/jquery"/>
  </xsl:template>

  <xsl:template match="comment()"/>

  <xsl:template match="xhtml:body">
    <body>
      <xsl:apply-templates select="@*|node()"/>
      <div id="comment-pane">
          <div id="disqus_thread"/>
          <xsl:choose>
            <xsl:when test="($userCountry = 'DEU') and ($cookieDisqus != 'on')">
              <script type="text/javascript">var disqus_shortname = 'efgy';</script>
              <a id="comments" class="dsq-brlink" href="http://disqus.com" onclick="var dsq = document.createElement('script'); dsq.type = 'text/javascript'; dsq.async = true; dsq.src = '//' + disqus_shortname + '.disqus.com/embed.js'; (document.getElementsByTagName('head')[0] || document.getElementsByTagName('body')[0]).appendChild(dsq); document.cookie='disqus=on'; return false;">comments powered by <span class="logo-disqus">Disqus</span>; Comments are not shown by default for privacy reasons, click here to enable them. This will make your browser request data from the third-party disqus.com servers and may additionally request data from the Google Analytics servers. Clicking this link will also set a cookie that will automatically load disqus comments on further page loads on this website. If you change your mind later, simply remove this cookie in your browser.</a>
              <noscript>Please enable JavaScript to view the <a href="http://disqus.com/?ref_noscript">comments powered by Disqus.</a></noscript>
            </xsl:when>
            <xsl:otherwise>
              <script type="text/javascript">var disqus_shortname = 'efgy'; (function() { var dsq = document.createElement('script'); dsq.type = 'text/javascript'; dsq.async = true; dsq.src = '//' + disqus_shortname + '.disqus.com/embed.js'; (document.getElementsByTagName('head')[0] || document.getElementsByTagName('body')[0]).appendChild(dsq); })();</script>
              <noscript>Please enable JavaScript to view the <a href="http://disqus.com/?ref_noscript">comments powered by Disqus.</a></noscript>
              <a href="http://disqus.com" class="dsq-brlink">comments powered by <span class="logo-disqus">Disqus</span></a>
            </xsl:otherwise>
          </xsl:choose>
      </div>
    </body>
  </xsl:template>
</xsl:stylesheet>

