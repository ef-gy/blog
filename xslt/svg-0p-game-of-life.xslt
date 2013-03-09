<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
              xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
              xmlns:z="http://ef.gy/2013/0p"
              xmlns:svg="http://www.w3.org/2000/svg"
              xmlns="http://www.w3.org/2000/svg"
              version="1.1">
  <xsl:output method="xml" version="1.0" encoding="UTF-8"
              indent="no"
              media-type="image/svg+xml" />

  <xsl:strip-space elements="*" />

  <xsl:param name="documentRoot"/>

  <xsl:template match="@*|node()">
    <xsl:copy><xsl:apply-templates select="@*|node()"/></xsl:copy>
  </xsl:template>

  <xsl:template name="bit">
    <xsl:param name="x"/>
    <xsl:param name="y"/>
    <xsl:if test="z:bit[@x=($x)][@y=($y)]">
      <rect x="{$x}" y="{$y}" width="1" height="1"/>
    </xsl:if>
  </xsl:template>

  <xsl:template name="bit-loop-x">
    <xsl:param name="x"/>
    <xsl:param name="y"/>
    <xsl:param name="maxx"/>
    <xsl:param name="maxy"/>
    <xsl:call-template name="bit">
      <xsl:with-param name="x" select="$x"/>
      <xsl:with-param name="y" select="$y"/>
    </xsl:call-template>
    <xsl:if test="$x &lt; $maxx">
      <xsl:call-template name="bit-loop-x">
        <xsl:with-param name="x" select="$x + 1"/>
        <xsl:with-param name="y" select="$y"/>
        <xsl:with-param name="maxx" select="$maxx"/>
        <xsl:with-param name="maxy" select="$maxy"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <xsl:template name="bit-loop-y">
    <xsl:param name="x"/>
    <xsl:param name="y"/>
    <xsl:param name="maxx"/>
    <xsl:param name="maxy"/>
    <xsl:call-template name="bit-loop-x">
      <xsl:with-param name="x" select="$x"/>
      <xsl:with-param name="y" select="$y"/>
      <xsl:with-param name="maxx" select="$maxx"/>
      <xsl:with-param name="maxy" select="$maxy"/>
    </xsl:call-template>
    <xsl:if test="$y &lt; $maxy">
      <xsl:call-template name="bit-loop-y">
        <xsl:with-param name="x" select="$x"/>
        <xsl:with-param name="y" select="$y + 1"/>
        <xsl:with-param name="maxx" select="$maxx"/>
        <xsl:with-param name="maxy" select="$maxy"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <xsl:template match="z:game-of-life">
    <xsl:variable name="minx" select="z:bit/@x[not(. &gt; ../../z:bit/@x)][1]"/>
    <xsl:variable name="maxx" select="z:bit/@x[not(. &lt; ../../z:bit/@x)][1]"/>
    <xsl:variable name="miny" select="z:bit/@y[not(. &gt; ../../z:bit/@y)][1]"/>
    <xsl:variable name="maxy" select="z:bit/@y[not(. &lt; ../../z:bit/@y)][1]"/>
    <xsl:processing-instruction name="xml-stylesheet">
      <xsl:text>type="text/css" href="/css/game-of-life"</xsl:text>
    </xsl:processing-instruction>
    <svg viewBox="{$minx - 1} {$miny - 1} {$maxx + 3} {$maxy + 3}">
      <xsl:call-template name="bit-loop-y">
        <xsl:with-param name="x" select="$minx"/>
        <xsl:with-param name="y" select="$miny"/>
        <xsl:with-param name="maxx" select="$maxx"/>
        <xsl:with-param name="maxy" select="$maxy"/>
      </xsl:call-template>
    </svg>
  </xsl:template>
</xsl:stylesheet>
