<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
              xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
              xmlns:z="http://ef.gy/2013/0p"
              xmlns="http://ef.gy/2013/0p"
              version="1.1">
  <xsl:output method="xml" version="1.0" encoding="UTF-8"
              indent="no"
              media-type="application/xml" />

  <xsl:strip-space elements="*" />

  <xsl:param name="documentRoot"/>

  <xsl:template match="@*|node()">
    <xsl:copy><xsl:apply-templates select="@*|node()"/></xsl:copy>
  </xsl:template>

  <xsl:template name="bit">
    <xsl:param name="x"/>
    <xsl:param name="y"/>
    <xsl:variable
        name="n"
        select="number(boolean(z:bit[@x=($x - 1)][@y=($y - 1)]))
              + number(boolean(z:bit[@x=($x    )][@y=($y - 1)]))
              + number(boolean(z:bit[@x=($x + 1)][@y=($y - 1)]))
              + number(boolean(z:bit[@x=($x - 1)][@y=($y    )]))
              + number(boolean(z:bit[@x=($x + 1)][@y=($y    )]))
              + number(boolean(z:bit[@x=($x - 1)][@y=($y + 1)]))
              + number(boolean(z:bit[@x=($x    )][@y=($y + 1)]))
              + number(boolean(z:bit[@x=($x + 1)][@y=($y + 1)]))"/>
    <xsl:if test="($n = 3) or (($n = 2) and z:bit[@x=($x)][@y=($y)])">
      <bit x="{$x}" y="{$y}"/>
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
    <xsl:document href="{$documentRoot}/game-of-life.xml">
      <game-of-life>
        <xsl:call-template name="bit-loop-y">
          <xsl:with-param name="x" select="$minx - 1"/>
          <xsl:with-param name="y" select="$miny - 1"/>
          <xsl:with-param name="maxx" select="$maxx + 1"/>
          <xsl:with-param name="maxy" select="$maxy + 1"/>
        </xsl:call-template>
      </game-of-life>
    </xsl:document>
    <xsl:copy-of select="."/>
  </xsl:template>

  <!--
  <xsl:template name="bit">
    <xsl:param name="x"/>
    <xsl:param name="y"/>
    <xsl:variable
        name="n"
        select="number(boolean(../z:bit[@x=($x - 1)][@y=($y - 1)]))
              + number(boolean(../z:bit[@x=($x    )][@y=($y - 1)]))
              + number(boolean(../z:bit[@x=($x + 1)][@y=($y - 1)]))
              + number(boolean(../z:bit[@x=($x - 1)][@y=($y    )]))
              + number(boolean(../z:bit[@x=($x + 1)][@y=($y    )]))
              + number(boolean(../z:bit[@x=($x - 1)][@y=($y + 1)]))
              + number(boolean(../z:bit[@x=($x    )][@y=($y + 1)]))
              + number(boolean(../z:bit[@x=($x + 1)][@y=($y + 1)]))"/>
    <xsl:if test="($n = 3) or (($n = 2) and ../z:bit[@x=($x)][@y=($y)])">
      <bit x="{$x}" y="{$y}"/>
    </xsl:if>
  </xsl:template>

  <xsl:template match="z:bit">
    <xsl:call-template name="bit">
      <xsl:with-param name="x" select="@x"/>
      <xsl:with-param name="y" select="@y"/>
    </xsl:call-template>
    <xsl:call-template name="bit">
      <xsl:with-param name="x" select="@x + 1"/>
      <xsl:with-param name="y" select="@y"/>
    </xsl:call-template>
    <xsl:call-template name="bit">
      <xsl:with-param name="x" select="@x - 1"/>
      <xsl:with-param name="y" select="@y"/>
    </xsl:call-template>
    <xsl:call-template name="bit">
      <xsl:with-param name="x" select="@x"/>
      <xsl:with-param name="y" select="@y - 1"/>
    </xsl:call-template>
    <xsl:call-template name="bit">
      <xsl:with-param name="x" select="@x + 1"/>
      <xsl:with-param name="y" select="@y - 1"/>
    </xsl:call-template>
    <xsl:call-template name="bit">
      <xsl:with-param name="x" select="@x - 1"/>
      <xsl:with-param name="y" select="@y - 1"/>
    </xsl:call-template>
    <xsl:call-template name="bit">
      <xsl:with-param name="x" select="@x"/>
      <xsl:with-param name="y" select="@y + 1"/>
    </xsl:call-template>
    <xsl:call-template name="bit">
      <xsl:with-param name="x" select="@x + 1"/>
      <xsl:with-param name="y" select="@y + 1"/>
    </xsl:call-template>
    <xsl:call-template name="bit">
      <xsl:with-param name="x" select="@x - 1"/>
      <xsl:with-param name="y" select="@y + 1"/>
    </xsl:call-template>
  </xsl:template>
  -->
</xsl:stylesheet>
