<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
              xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
              xmlns:xhtml="http://www.w3.org/1999/xhtml"
              xmlns:source="http://ef.gy/2012/source"
              xmlns:atom="http://www.w3.org/2005/Atom"
              xmlns="http://www.w3.org/2005/Atom"
              exclude-result-prefixes="source xhtml atom"
              version="1.0">
  <xsl:output method="xml" version="1.0" encoding="UTF-8"
              indent="no"
              media-type="application/atom+xml"/>

  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()" />
    </xsl:copy>
  </xsl:template>

  <xsl:template match="atom:entry[atom:category/@term='Forum Post']" />
  <xsl:template match="atom:entry[atom:category/@term='Image']" />
  <xsl:template match="atom:entry[atom:category/@term='Project Issue']" />

  <xsl:template match="atom:name/text()[.='jyujin']">Magnus Achim Deininger</xsl:template>
  <xsl:template match="xhtml:meta[@name='author'][@content='jyujin']">
    <xsl:copy>
      <xsl:attribute name="name">author</xsl:attribute>
      <xsl:attribute name="content">Magnus Achim Deininger</xsl:attribute>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="atom:name/text()[.='syntropy']">Joshua Michael Keyes</xsl:template>
  <xsl:template match="xhtml:meta[@name='author'][@content='syntropy']">
    <xsl:copy>
      <xsl:attribute name="name">author</xsl:attribute>
      <xsl:attribute name="content">Joshua Michael Keyes</xsl:attribute>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="atom:name/text()[.='stable-entropy']">Joshua Michael Keyes</xsl:template>
  <xsl:template match="xhtml:meta[@name='author'][@content='stable-entropy']">
    <xsl:copy>
      <xsl:attribute name="name">author</xsl:attribute>
      <xsl:attribute name="content">Joshua Michael Keyes</xsl:attribute>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="atom:name/text()[.='aidanjt']">Aidan Taniane</xsl:template>
  <xsl:template match="xhtml:meta[@name='author'][@content='aidanjt']">
    <xsl:copy>
      <xsl:attribute name="name">author</xsl:attribute>
      <xsl:attribute name="content">Aidan Taniane</xsl:attribute>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="atom:name/text()[.='creidiki']">Leonardo Valeri Manera</xsl:template>
  <xsl:template match="xhtml:meta[@name='author'][@content='creidiki']">
    <xsl:copy>
      <xsl:attribute name="name">author</xsl:attribute>
      <xsl:attribute name="content">Leonardo Valeri Manera</xsl:attribute>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="atom:name/text()[.='rmh3093']">Ryan Hope</xsl:template>
  <xsl:template match="xhtml:meta[@name='author'][@content='rmh3093']">
    <xsl:copy>
      <xsl:attribute name="name">author</xsl:attribute>
      <xsl:attribute name="content">Ryan Hope</xsl:attribute>
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>

