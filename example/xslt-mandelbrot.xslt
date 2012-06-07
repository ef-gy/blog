<?xml version="1.0" ?>
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:svg="http://www.w3.org/2000/svg"
  xmlns:gfx="http://becquerel.org/graphics/2011"
  xmlns="http://www.w3.org/2000/svg">

  <xsl:template name="mandelbrot-pixel">
    <xsl:param name="x" />
    <xsl:param name="y" />
    <xsl:param name="zr" select="0" />
    <xsl:param name="zi" select="0" />
    <xsl:param name="cr" />
    <xsl:param name="ci" />
    <xsl:param name="i" />
    <xsl:param name="iterations" />

    <xsl:choose>
      <xsl:when test="(($zr * $zr) + ($zi * $zi) &lt; 4) and ($i &gt; 0)">
        <xsl:call-template name="mandelbrot-pixel">
          <xsl:with-param name="x" select="$x" />
          <xsl:with-param name="y" select="$y" />
          <xsl:with-param name="zr" select="$zr*$zr - $zi*$zi + $cr" />
          <xsl:with-param name="zi" select="2*$zr*$zi + $ci" />
          <xsl:with-param name="cr" select="$cr" />
          <xsl:with-param name="ci" select="$ci" />
          <xsl:with-param name="i" select="$i - 1" />
          <xsl:with-param name="iterations" select="$iterations" />
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="($zr * $zr) + ($zi * $zi) &lt; 4">
        <circle cx="{$x}" cy="{$y}" r="1" fill="black" stroke="none" />
      </xsl:when>
      <xsl:otherwise>
        <circle cx="{$x}" cy="{$y}" r="1" fill="hsl({$i * 360 div $iterations},50%,50%)" stroke="none" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="mandelbrot-loop-y">
    <xsl:param name="cx" />
    <xsl:param name="cy" />
    <xsl:param name="mx" />
    <xsl:param name="my" />
    <xsl:param name="zr0" />
    <xsl:param name="zi0" />
    <xsl:param name="zr1" />
    <xsl:param name="zi1" />
    <xsl:param name="iterations" />

    <xsl:choose>
      <xsl:when test="$cy &lt; $my">
        <xsl:call-template name="mandelbrot-loop-y">
          <xsl:with-param name="cx" select="$cx" />
          <xsl:with-param name="cy" select="$cy+1" />
          <xsl:with-param name="mx" select="$mx" />
          <xsl:with-param name="my" select="$my" />
          <xsl:with-param name="zr0" select="$zr0" />
          <xsl:with-param name="zi0" select="$zi0" />
          <xsl:with-param name="zr1" select="$zr1" />
          <xsl:with-param name="zi1" select="$zi1" />
          <xsl:with-param name="iterations" select="$iterations" />
        </xsl:call-template>
      </xsl:when>
    </xsl:choose>

    <xsl:call-template name="mandelbrot-pixel">
      <xsl:with-param name="x" select="$cx" />
      <xsl:with-param name="y" select="$cy" />
      <xsl:with-param name="cr" select="$zr0 + $zr1 * $cx div $mx" />
      <xsl:with-param name="ci" select="$zi0 + $zi1 * $cy div $my" />
      <xsl:with-param name="i" select="$iterations" />
      <xsl:with-param name="iterations" select="$iterations" />
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="mandelbrot-loop">
    <xsl:param name="cx" />
    <xsl:param name="cy" />
    <xsl:param name="mx" />
    <xsl:param name="my" />
    <xsl:param name="zr0" />
    <xsl:param name="zi0" />
    <xsl:param name="zr1" />
    <xsl:param name="zi1" />
    <xsl:param name="iterations" />

    <xsl:choose>
      <xsl:when test="$cx &lt; $mx">
        <xsl:call-template name="mandelbrot-loop">
          <xsl:with-param name="cx" select="$cx+1" />
          <xsl:with-param name="cy" select="0" />
          <xsl:with-param name="mx" select="$mx" />
          <xsl:with-param name="my" select="$my" />
          <xsl:with-param name="zr0" select="$zr0" />
          <xsl:with-param name="zi0" select="$zi0" />
          <xsl:with-param name="zr1" select="$zr1" />
          <xsl:with-param name="zi1" select="$zi1" />
          <xsl:with-param name="iterations" select="$iterations" />
        </xsl:call-template>
      </xsl:when>
    </xsl:choose>

    <xsl:call-template name="mandelbrot-loop-y">
      <xsl:with-param name="cx" select="$cx" />
      <xsl:with-param name="cy" select="0" />
      <xsl:with-param name="mx" select="$mx" />
      <xsl:with-param name="my" select="$my" />
      <xsl:with-param name="zr0" select="$zr0" />
      <xsl:with-param name="zi0" select="$zi0" />
      <xsl:with-param name="zr1" select="$zr1" />
      <xsl:with-param name="zi1" select="$zi1" />
      <xsl:with-param name="iterations" select="$iterations" />
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="gfx:mandelbrot">
    <svg width="100%" height="100%" viewBox="0 0 {@width} {@height}">
      <xsl:variable name="zr1">
        <xsl:choose>
          <xsl:when test="(@zr0 &lt; 0) and (@zr1 &lt; 0)">
            <xsl:value-of select="(@zr0 * (-1)) + (@zr1 * (-1))" />
          </xsl:when>
          <xsl:when test="@zr0 &lt; 0">
            <xsl:value-of select="(@zr0 * (-1)) + @zr1" />
          </xsl:when>
          <xsl:when test="@zr1 &lt; 0">
            <xsl:value-of select="@zr0 + (@zr1 * (-1))" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="@zr0 + @zr1" />
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:variable name="zi1">
        <xsl:choose>
          <xsl:when test="(@zi0 &lt; 0) and (@zi1 &lt; 0)">
            <xsl:value-of select="(@zi0 * (-1)) + (@zi1 * (-1))" />
          </xsl:when>
          <xsl:when test="@zi0 &lt; 0">
            <xsl:value-of select="(@zi0 * (-1)) + @zi1" />
          </xsl:when>
          <xsl:when test="@zi1 &lt; 0">
            <xsl:value-of select="@zi0 + (@zi1 * (-1))" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="@zi0 + @zi1" />
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:call-template name="mandelbrot-loop">
        <xsl:with-param name="cx" select="0" />
        <xsl:with-param name="cy" select="0" />
        <xsl:with-param name="mx" select="@width" />
        <xsl:with-param name="my" select="@height" />
        <xsl:with-param name="zr0" select="@zr0" />
        <xsl:with-param name="zi0" select="@zi0" />
        <xsl:with-param name="zr1" select="$zr1" />
        <xsl:with-param name="zi1" select="$zi1" />
        <xsl:with-param name="iterations" select="@iterations" />
      </xsl:call-template>
    </svg>
  </xsl:template>
</xsl:stylesheet>
