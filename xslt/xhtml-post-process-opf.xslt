<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
              xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
              xmlns:svg="http://www.w3.org/2000/svg"
              xmlns:xlink="http://www.w3.org/1999/xlink"
              xmlns:xhtml="http://www.w3.org/1999/xhtml"
              xmlns:pmml2svg="https://sourceforge.net/projects/pmml2svg/"
              xmlns:inkscape="http://www.inkscape.org/namespaces/inkscape"
              xmlns:sodipodi="http://sodipodi.sourceforge.net/DTD/sodipodi-0.dtd"
              xmlns="http://www.w3.org/1999/xhtml"
              exclude-result-prefixes="svg"
              version="1.1">
  <xsl:output method="xml" version="1.0" encoding="UTF-8"
              indent="no"
              media-type="application/xml" />

  <xsl:strip-space elements="*" />

  <xsl:template match="xhtml:head">
    <head>
      <link rel="stylesheet" href="book.css" type="text/css"/>
      <xsl:apply-templates select="node()"/>
    </head>
  </xsl:template>

  <xsl:template match="xhtml:body">
    <body>
      <h1><xsl:value-of select="../xhtml:head/xhtml:title"/></h1>
      <xsl:apply-templates select="node()"/>
    </body>
  </xsl:template>

  <xsl:template match="xhtml:h1">
    <h2><xsl:apply-templates select="@*|node()"/></h2>
  </xsl:template>
  <xsl:template match="xhtml:h2">
    <h3><xsl:apply-templates select="@*|node()"/></h3>
  </xsl:template>
  <xsl:template match="xhtml:h3">
    <h4><xsl:apply-templates select="@*|node()"/></h4>
  </xsl:template>
  <xsl:template match="xhtml:h4">
    <h5><xsl:apply-templates select="@*|node()"/></h5>
  </xsl:template>
  <xsl:template match="xhtml:h5">
    <h6><xsl:apply-templates select="@*|node()"/></h6>
  </xsl:template>

  <xsl:template match="@*|node()">
    <xsl:copy><xsl:apply-templates select="@*|node()"/></xsl:copy>
  </xsl:template>

  <xsl:template match="xhtml:img[@xlink:href]">
    <xsl:apply-templates select="document(@xlink:href)/svg:*"/>
  </xsl:template>

  <xsl:template match="xhtml:img[@src]">
    <xsl:variable name="bjpeg" select="substring-after(@src,'jpeg/')"/>
    <xsl:variable name="bpng" select="substring-after(@src,'png/')"/>
    <xsl:choose>
      <xsl:when test="$bjpeg != ''">
        <img src="jpeg/{$bjpeg}.jpeg">
          <xsl:apply-templates select="@alt | @style | @title | @class"/>
        </img>
      </xsl:when>
      <xsl:when test="$bpng != ''">
        <img src="png/{$bpng}.png">
          <xsl:apply-templates select="@alt | @style | @title | @class"/>
        </img>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <!--
  <xsl:template match="svg:svg[svg:metadata/pmml2svg:*]//@style">
    <xsl:attribute name="style">fill:#000</xsl:attribute>
  </xsl:template>-->

  <xsl:template match="svg:metadata"/>

  <xsl:template match="inkscape:*"/>
  <xsl:template match="@inkscape:*"/>
  <xsl:template match="sodipodi:*"/>
  <xsl:template match="@sodipodi:*"/>

<!--
  <xsl:template match="svg:svg[.//pmml2svg:* | .//@pmml2svg:*]/@height">
    <xsl:attribute name="height">
      <xsl:value-of select="concat(number(substring-before(.,'px'))*0.02,'em')"/>
    </xsl:attribute>
  </xsl:template>
  <xsl:template match="svg:svg[.//pmml2svg:* | .//@pmml2svg:*]/@width">
    <xsl:attribute name="width">
      <xsl:value-of select="concat(number(substring-before(.,'px'))*0.02,'em')"/>
    </xsl:attribute>
  </xsl:template>
-->

  <xsl:template match="pmml2svg:*"/>
  <xsl:template match="@pmml2svg:*"/>
<!--
  <xsl:template match="@font-family"/>
  <xsl:template match="svg:*[@pmml2svg:* | pmml2svg:*]//@style"/>
  -->

</xsl:stylesheet>

