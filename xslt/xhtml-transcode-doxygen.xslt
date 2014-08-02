<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
              xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
              xmlns:xhtml="http://www.w3.org/1999/xhtml"
              version="1.0">
  <xsl:output method="xml" version="1.0" encoding="UTF-8"
              doctype-public="-//W3C//DTD XHTML 1.1//EN"
              doctype-system="http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd"
              indent="no"
              media-type="application/xhtml+xml" />

  <xsl:param name="package"/>
  <xsl:param name="detail"/>

  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()" />
    </xsl:copy>
  </xsl:template>

  <xsl:template match="doxygen">
    <xhtml:html>
      <xhtml:head>
        <xhtml:title>Project documentation: <xsl:value-of select="$package"/>: <xsl:value-of select="$detail"/></xhtml:title>
        <xhtml:meta name="doxygen-version" content="{@version}"/>
        <xhtml:link href="/css/documentation" rel="stylesheet" type="text/css"/>
      </xhtml:head>
      <xhtml:body>
        <xsl:apply-templates select="node()" />
      </xhtml:body>
    </xhtml:html>
  </xsl:template>

  <xsl:template match="compounddef">
    <xsl:if test="@id=$detail">
      <xsl:copy>
        <xsl:apply-templates select="@*|node()" />
      </xsl:copy>
    </xsl:if>
  </xsl:template>

  <xsl:template match="compoundname">
    <xhtml:h1><xsl:value-of select="."/></xhtml:h1>
  </xsl:template>

  <xsl:template match="templateparamlist">
    <xhtml:ul>
      <xsl:apply-templates select="node()"/>
    </xhtml:ul>
  </xsl:template>

  <xsl:template match="includes">
    <xhtml:p class="include">#include &lt;<xhtml:a href="{@refid}"><xsl:value-of select="."/></xhtml:a>&gt;</xhtml:p>
  </xsl:template>

  <xsl:template match="param">
    <xhtml:li>
      <xsl:apply-templates select="node()"/>
    </xhtml:li>
  </xsl:template>

  <xsl:template match="briefdescription">
    <xsl:apply-templates select="node()"/>
  </xsl:template>

  <xsl:template match="briefdescription/para">
    <xhtml:p class="brief"><xsl:apply-templates select="node()"/></xhtml:p>
  </xsl:template>

  <xsl:template match="detaileddescription">
    <xsl:apply-templates select="node()"/>
  </xsl:template>

  <xsl:template match="para">
    <xhtml:p><xsl:apply-templates select="node()"/></xhtml:p>
  </xsl:template>

  <xsl:template match="sectiondef[@kind='public-func']">
    <xhtml:h2>Public Member Functions</xhtml:h2>
    <xsl:apply-templates select="node()"/>
  </xsl:template>

  <xsl:template match="sectiondef[@kind='public-attrib']">
    <xhtml:h2>Public Member Attributes</xhtml:h2>
    <xsl:apply-templates select="node()"/>
  </xsl:template>

  <xsl:template match="para[simplesect]">
    <xsl:apply-templates select="node()"/>
  </xsl:template>

  <xsl:template match="simplesect">
    <xsl:apply-templates select="node()"/>
  </xsl:template>

  <xsl:template match="simplesect[@kind='copyright']/para">
    <xhtml:p class="copyright">
      <xsl:apply-templates select="node()"/>
    </xhtml:p>
  </xsl:template>
</xsl:stylesheet>
