<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
              xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
              xmlns:xhtml="http://www.w3.org/1999/xhtml"
              xmlns:math="http://www.w3.org/1998/Math/MathML"
              xmlns:svg="http://www.w3.org/2000/svg"
              version="1.0">
  <xsl:output method="xml" version="1.0" encoding="UTF-8"
              doctype-public="-//W3C//DTD XHTML 1.1//EN"
              doctype-system="http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd"
              indent="no"
              media-type="application/xhtml+xml" />

  <xsl:template match="*|@*">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()" />
    </xsl:copy>
  </xsl:template>

  <xsl:template match="xhtml:head">
    <xhtml:head>
      <xsl:apply-templates select="*[not(self::xhtml:script)]"/>
      <xsl:apply-templates select="xhtml:script[@src]"/>
      <xsl:if test="xhtml:script[not(@src)]">
        <xhtml:script type="text/javascript">
          <xsl:apply-templates select="xhtml:script[not(@src)]/text()"/>
        </xhtml:script>
      </xsl:if>
    </xhtml:head>
  </xsl:template>

</xsl:stylesheet>
