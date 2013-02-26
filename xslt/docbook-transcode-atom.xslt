<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
              xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
              xmlns:atom="http://www.w3.org/2005/Atom"
              xmlns:docbook="http://docbook.org/ns/docbook"
              xmlns="http://docbook.org/ns/docbook"
              version="1.0">
  <xsl:output method="xml" version="1.0" encoding="UTF-8"
              indent="no"
              media-type="application/xml" />

  <xsl:param name="licence"/>
  <xsl:param name="dblatexWorkaround"/>

  <xsl:strip-space elements="*" />
  <xsl:preserve-space elements="docbook:literallayout" />

  <xsl:template match="@*|node()">
    <xsl:copy><xsl:apply-templates select="@*|node()"/></xsl:copy>
  </xsl:template>

  <xsl:template match="/atom:feed">
    <book version="5.0">
      <xsl:call-template name="root-info">
        <xsl:with-param name="self" select="."/>
      </xsl:call-template>

      <xsl:apply-templates select="atom:entry"/>

      <colophon>
        <para>This book was transcoded to DocBook 5 from a set of Atom and XHTML files.</para>
        <para>The hierarchical structure of the individual chapters was reconstructed automatically from the XHTML input files' flat hierarchy and as such may not be entirely accurate and will depend on the quality of the original files.</para>
        <para>Certain features of the source files may not be represented in some target formats. This includes such features as hyperlinks, inline images, tabulations and special formatting. Additionally, some of these features might be present but not behave as originally intended.</para>
      </colophon>
    </book>
  </xsl:template>

  <xsl:template match="atom:feed">
    <book>
      <xsl:call-template name="info">
        <xsl:with-param name="self" select="."/>
      </xsl:call-template>

      <xsl:apply-templates select="atom:entry"/>
    </book>
  </xsl:template>

  <xsl:template match="atom:title">
    <title>
      <xsl:apply-templates select="@*|node()"/>
    </title>
  </xsl:template>

  <xsl:template match="atom:subtitle">
    <subtitle>
      <xsl:apply-templates select="@*|node()"/>
    </subtitle>
  </xsl:template>

  <xsl:template match="atom:link">
    <bibliosource class="uri">
      <xsl:value-of select="@href"/>
    </bibliosource>
  </xsl:template>

  <xsl:template match="atom:published">
    <pubdate>
      <xsl:apply-templates select="@*|node()"/>
    </pubdate>
  </xsl:template>

  <xsl:template match="atom:category">
    <subjectset>
      <subject>
        <subjectterm>
          <xsl:value-of select="@term"/>
        </subjectterm>
      </subject>
    </subjectset>
  </xsl:template>

  <xsl:template match="atom:updated">
    <date>
      <xsl:apply-templates select="@*|node()"/>
    </date>
  </xsl:template>

  <xsl:template match="atom:summary">
    <abstract>
      <para>
        <xsl:apply-templates select="@*|node()"/>
      </para>
    </abstract>
  </xsl:template>

  <xsl:template match="atom:author">
    <author>
      <xsl:apply-templates select="@*|node()"/>
    </author>
  </xsl:template>

  <xsl:template match="atom:author/atom:name">
    <personname>
      <xsl:apply-templates select="@*|node()"/>
    </personname>
  </xsl:template>

  <xsl:template match="atom:author/atom:email">
    <email>
      <xsl:apply-templates select="@*|node()"/>
    </email>
  </xsl:template>

  <xsl:template match="atom:content[docbook:*]">
    <xsl:apply-templates select="node()"/>
  </xsl:template>

  <xsl:template name="info">
    <xsl:param name="self"/>
    <info>
      <xsl:apply-templates
        select="$self/atom:title
              | $self/atom:subtitle
              | $self/atom:link
              | $self/atom:published
              | $self/atom:updated
              | $self/atom:author
              | $self/atom:summary
              | $self/atom:category
              | node()/docbook:info/*"/>
    </info>
  </xsl:template>

  <xsl:template name="root-info">
    <xsl:param name="self"/>
    <info>
      <xsl:apply-templates
        select="$self/atom:title
              | $self/atom:subtitle
              | $self/atom:link
              | $self/atom:published
              | $self/atom:updated
              | $self/atom:author
              | $self/atom:summary
              | $self/atom:category
              | node()/docbook:info/*"/>

      <xsl:for-each select="$self/descendant::atom:author[not(atom:name = preceding::atom:name)]">
        <xsl:apply-templates select="."/>
      </xsl:for-each>

      <xsl:if test="$licence">
        <legalnotice>
          <xsl:copy-of select="$licence//docbook:legalnotice/docbook:*"/>
        </legalnotice>
      </xsl:if>
    </info>
  </xsl:template>

  <xsl:template name="non-info">
    <xsl:param name="self"/>
    <xsl:variable name="cur" select="."/>
    <xsl:apply-templates
        select="($self/node() | node())
            [   not (self::atom:title)
            and not (self::atom:subtitle)
            and not (self::atom:link)
            and not (self::atom:published)
            and not (self::atom:updated)
            and not (self::atom:author)
            and not (self::atom:summary)
            and not (self::atom:category)
            and not (self::atom:link)
            and not (. = $cur)
            ]"/>
  </xsl:template>

  <xsl:template match="atom:entry[atom:content/docbook:*]">
    <xsl:variable name="self" select="."/>
    <xsl:for-each select="atom:content/docbook:*">
      <xsl:choose>
        <xsl:when test="$dblatexWorkaround = 1">
          <chapter>
            <xsl:call-template name="info">
              <xsl:with-param name="self" select="$self"/>
            </xsl:call-template>
            <xsl:call-template name="non-info">
              <xsl:with-param name="self" select="$self"/>
            </xsl:call-template>
          </chapter>
        </xsl:when>
        <xsl:otherwise>
          <xsl:copy>
            <xsl:call-template name="info">
              <xsl:with-param name="self" select="$self"/>
            </xsl:call-template>
            <xsl:call-template name="non-info">
              <xsl:with-param name="self" select="$self"/>
            </xsl:call-template>
          </xsl:copy>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="atom:entry"/>

  <xsl:template match="atom:id"/>
  <xsl:template match="atom:source"/>
  <xsl:template match="atom:content/docbook:*/docbook:info"/>

</xsl:stylesheet>
