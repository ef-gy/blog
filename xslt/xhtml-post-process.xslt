<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
              xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
              xmlns:xhtml="http://www.w3.org/1999/xhtml"
              xmlns:math="http://www.w3.org/1998/Math/MathML"
              xmlns:svg="http://www.w3.org/2000/svg"
              xmlns="http://www.w3.org/1999/xhtml"
              version="1.0">
  <xsl:output method="xml" version="1.0" encoding="UTF-8"
              doctype-public="-//W3C//DTD XHTML 1.1//EN"
              doctype-system="http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd"
              indent="no"
              media-type="application/xhtml+xml" />

  <xsl:param name="documentRoot"/>

  <xsl:template match="*|@*">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()" />
    </xsl:copy>
  </xsl:template>

  <xsl:template match="xhtml:head">
    <xhtml:head>
      <xsl:if test="xhtml:link[@rel='stylesheet'][substring-after(@href,'/css/')]">
        <link rel="stylesheet">
          <xsl:attribute name="href">/css/<xsl:for-each select="xhtml:link[@rel='stylesheet'][substring-after(@href,'/css/')]"><xsl:if test="not(position()=1)">+</xsl:if><xsl:value-of select="substring-after(@href,'/css/')"/></xsl:for-each></xsl:attribute>
        </link>
      </xsl:if>
      <xsl:apply-templates select="xhtml:link[@rel='stylesheet'][not(substring-after(@href,'/css/'))]"/>
      <xsl:apply-templates select="*[not(self::xhtml:script) and not(self::xhtml:link[@rel='stylesheet'])]"/>
      <xsl:if test="xhtml:script[@src][substring-after(@src,'/js/')]">
        <script type="text/javascript" async="async">
          <xsl:attribute name="src">/js/<xsl:for-each select="xhtml:script[@src][substring-after(@src,'/js/')]"><xsl:if test="not(position()=1)">+</xsl:if><xsl:value-of select="substring-after(@src,'/js/')"/></xsl:for-each></xsl:attribute>
        </script>
      </xsl:if>
      <xsl:apply-templates select="xhtml:script[@src][not(substring-after(@src,'/js/'))]"/>
      <xsl:if test="//xhtml:script[not(@src)]">
        <script type="text/javascript">
          <xsl:apply-templates select="//xhtml:script[not(@src)]/text()"/>
        </script>
      </xsl:if>
      <xsl:if test="//xhtml:style">
        <script type="text/javascript">
          <xsl:apply-templates select="//xhtml:style/text()"/>
        </script>
      </xsl:if>
    </xhtml:head>
  </xsl:template>

  <xsl:template match="xhtml:script[not(@src)]"/>
</xsl:stylesheet>
