<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
              xmlns:atom="http://www.w3.org/2005/Atom"
              xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
              xmlns:xhtml="http://www.w3.org/1999/xhtml"
              xmlns:docbook="http://docbook.org/ns/docbook"
              xmlns:xlink="http://www.w3.org/1999/xlink"
              xmlns:mathml="http://www.w3.org/1998/Math/MathML"
              xmlns:svg="http://www.w3.org/2000/svg"
              xmlns="http://docbook.org/ns/docbook"
              version="1.0">
  <xsl:output method="xml" version="1.0" encoding="UTF-8"
              indent="no"
              media-type="application/docbook+xml" />

  <xsl:param name="documentRoot"/>
  <xsl:param name="baseURI"/>

  <xsl:strip-space elements="*" />
  <xsl:preserve-space elements="docbook:literallayout" />

  <xsl:template match="@*|node()">
    <xsl:copy><xsl:apply-templates select="@*|node()"/></xsl:copy>
  </xsl:template>

  <xsl:template match="xhtml:html">
    <article>
      <xsl:if test=". = /xhtml:html">
        <xsl:attribute name="version">5.0</xsl:attribute>
      </xsl:if>
      <xsl:apply-templates select="@*|node()"/>
    </article>
  </xsl:template>

  <xsl:template match="xhtml:p">
    <para>
      <xsl:apply-templates select="@*|node()"/>
    </para>
  </xsl:template>

  <xsl:template match="xhtml:head">
    <info>
      <xsl:apply-templates select="@*|node()"/>
    </info>
  </xsl:template>

  <xsl:template match="xhtml:body">
    <xsl:if test="../xhtml:head/xhtml:meta[@name='unix:name']/@content">
      <anchor><xsl:attribute name="xml:id"><xsl:value-of select="translate(../xhtml:head/xhtml:meta[@name='unix:name']/@content,&quot;:,'*&quot;,'----')"/></xsl:attribute></anchor>
      <note>
        <xsl:choose>
          <xsl:when test="../../../atom:category[@term='einit.org']">
            <para>The following was transcribed from an XHTML document available at <link xlink:href="{concat($baseURI,'/',../xhtml:head/xhtml:meta[@name='unix:name']/@content)}@drupal-einit"/>.</para>
          </xsl:when>
          <xsl:when test="../../../atom:category[@term='kyuba.org']">
            <para>The following was transcribed from an XHTML document available at <link xlink:href="{concat($baseURI,'/',../xhtml:head/xhtml:meta[@name='unix:name']/@content)}@drupal-kyuba"/>.</para>
          </xsl:when>
          <xsl:otherwise>
            <para>The following was transcribed from an XHTML document available at <link xlink:href="{concat($baseURI,'/',../xhtml:head/xhtml:meta[@name='unix:name']/@content)}"/>.</para>
          </xsl:otherwise>
        </xsl:choose>
      </note>
    </xsl:if>
    <xsl:apply-templates select="xhtml:h1 | xhtml:p[not(preceding-sibling::xhtml:h1)]"/>
  </xsl:template>

  <xsl:template match="xhtml:title">
    <title>
      <xsl:apply-templates select="@*|node()"/>
    </title>
  </xsl:template>

  <xsl:template match="xhtml:meta[@name='author']">
    <author>
      <personname>
        <xsl:value-of select="@content"/>
      </personname>
    </author>
  </xsl:template>

  <xsl:template match="xhtml:meta[@name='description']">
    <abstract>
      <para>
        <xsl:value-of select="@content"/>
      </para>
    </abstract>
  </xsl:template>

  <xsl:template match="xhtml:pre">
    <literallayout>
      <xsl:apply-templates select="@*|node()"/>
    </literallayout>
  </xsl:template>

  <xsl:template match="xhtml:code">
    <code>
      <xsl:apply-templates select="@*|node()"/>
    </code>
  </xsl:template>

  <xsl:template match="xhtml:em">
    <emphasis>
      <xsl:apply-templates select="@*|node()"/>
    </emphasis>
  </xsl:template>

  <xsl:template match="@class">
    <xsl:attribute name="role">
      <xsl:value-of select="."/>
    </xsl:attribute>
  </xsl:template>

  <xsl:template match="xhtml:meta"/>

  <xsl:template match="xhtml:h1">
    <section>
      <title><xsl:apply-templates select="@*|node()"/></title>
      <xsl:variable name="nodes" select="following-sibling::node()"/>
      <xsl:variable name="next" select="$nodes[self::xhtml:h1]"/>
      <xsl:variable name="nexta" select="$nodes[self::xhtml:h1
                                            or self::xhtml:h2
                                            or self::xhtml:h3
                                            or self::xhtml:h4
                                            or self::xhtml:h5
                                            or self::xhtml:h6]"/>
      <xsl:apply-templates select="$nodes[(not(preceding-sibling::* = $nexta) or ((preceding-sibling::* = $nexta) and not (preceding-sibling::* = $next) and (self::xhtml:h1 or self::xhtml:h2 or self::xhtml:h3 or self::xhtml:h4 or self::xhtml:h5 or self::xhtml:h6))) and not (. = $next)]"/>
    </section>
  </xsl:template>

  <xsl:template match="xhtml:h2">
    <section>
      <title><xsl:apply-templates select="@*|node()"/></title>
      <xsl:variable name="nodes" select="following-sibling::node()"/>
      <xsl:variable name="next" select="$nodes[self::xhtml:h1
                                            or self::xhtml:h2]"/>
      <xsl:variable name="nexta" select="$nodes[self::xhtml:h1
                                            or self::xhtml:h2
                                            or self::xhtml:h3
                                            or self::xhtml:h4
                                            or self::xhtml:h5
                                            or self::xhtml:h6]"/>
      <xsl:apply-templates select="$nodes[(not(preceding-sibling::* = $nexta) or ((preceding-sibling::* = $nexta) and not (preceding-sibling::* = $next) and (self::xhtml:h1 or self::xhtml:h2 or self::xhtml:h3 or self::xhtml:h4 or self::xhtml:h5 or self::xhtml:h6))) and not (. = $next)]"/>
    </section>
  </xsl:template>

  <xsl:template match="xhtml:h3">
    <section>
      <title><xsl:apply-templates select="@*|node()"/></title>
      <xsl:variable name="nodes" select="following-sibling::node()"/>
      <xsl:variable name="next" select="$nodes[self::xhtml:h1
                                            or self::xhtml:h2
                                            or self::xhtml:h3]"/>
      <xsl:variable name="nexta" select="$nodes[self::xhtml:h1
                                            or self::xhtml:h2
                                            or self::xhtml:h3
                                            or self::xhtml:h4
                                            or self::xhtml:h5
                                            or self::xhtml:h6]"/>
      <xsl:apply-templates select="$nodes[(not(preceding-sibling::* = $nexta) or ((preceding-sibling::* = $nexta) and not (preceding-sibling::* = $next) and (self::xhtml:h1 or self::xhtml:h2 or self::xhtml:h3 or self::xhtml:h4 or self::xhtml:h5 or self::xhtml:h6))) and not (. = $next)]"/>
    </section>
  </xsl:template>

  <xsl:template match="xhtml:h4">
    <section>
      <title><xsl:apply-templates select="@*|node()"/></title>
      <xsl:variable name="nodes" select="following-sibling::node()"/>
      <xsl:variable name="next" select="$nodes[self::xhtml:h1
                                            or self::xhtml:h2
                                            or self::xhtml:h3
                                            or self::xhtml:h4]"/>
      <xsl:variable name="nexta" select="$nodes[self::xhtml:h1
                                            or self::xhtml:h2
                                            or self::xhtml:h3
                                            or self::xhtml:h4
                                            or self::xhtml:h5
                                            or self::xhtml:h6]"/>
      <xsl:apply-templates select="$nodes[(not(preceding-sibling::* = $nexta) or ((preceding-sibling::* = $nexta) and not (preceding-sibling::* = $next) and (self::xhtml:h1 or self::xhtml:h2 or self::xhtml:h3 or self::xhtml:h4 or self::xhtml:h5 or self::xhtml:h6))) and not (. = $next)]"/>
    </section>
  </xsl:template>

  <xsl:template match="xhtml:h5">
    <section>
      <title><xsl:apply-templates select="@*|node()"/></title>
      <xsl:variable name="nodes" select="following-sibling::node()"/>
      <xsl:variable name="next" select="$nodes[self::xhtml:h1
                                            or self::xhtml:h2
                                            or self::xhtml:h3
                                            or self::xhtml:h4
                                            or self::xhtml:h5]"/>
      <xsl:variable name="nexta" select="$nodes[self::xhtml:h1
                                            or self::xhtml:h2
                                            or self::xhtml:h3
                                            or self::xhtml:h4
                                            or self::xhtml:h5
                                            or self::xhtml:h6]"/>
      <xsl:apply-templates select="$nodes[(not(preceding-sibling::* = $nexta) or ((preceding-sibling::* = $nexta) and not (preceding-sibling::* = $next) and (self::xhtml:h1 or self::xhtml:h2 or self::xhtml:h3 or self::xhtml:h4 or self::xhtml:h5 or self::xhtml:h6))) and not (. = $next)]"/>
      <!--
      <xsl:apply-templates select="$nodes[not(preceding-sibling::* = $next) and not (. = $next)]"/>
      -->
    </section>
  </xsl:template>

  <xsl:template match="xhtml:h6">
    <section>
      <title><xsl:apply-templates select="@*|node()"/></title>
      <xsl:variable name="nodes" select="following-sibling::node()"/>
      <xsl:variable name="next" select="$nodes[self::xhtml:h1
                                            or self::xhtml:h2
                                            or self::xhtml:h3
                                            or self::xhtml:h4
                                            or self::xhtml:h5
                                            or self::xhtml:h6]"/>
      <xsl:variable name="nexta" select="$nodes[self::xhtml:h1
                                            or self::xhtml:h2
                                            or self::xhtml:h3
                                            or self::xhtml:h4
                                            or self::xhtml:h5
                                            or self::xhtml:h6]"/>
      <xsl:apply-templates select="$nodes[(not(preceding-sibling::* = $nexta) or ((preceding-sibling::* = $nexta) and not (preceding-sibling::* = $next) and (self::xhtml:h1 or self::xhtml:h2 or self::xhtml:h3 or self::xhtml:h4 or self::xhtml:h5 or self::xhtml:h6))) and not (. = $next)]"/>
    </section>
  </xsl:template>

  <xsl:template match="xhtml:ul">
    <itemizedlist>
      <xsl:apply-templates select="@*|node()"/>
    </itemizedlist>
  </xsl:template>

  <xsl:template match="xhtml:li">
    <listitem>
      <para>
        <xsl:apply-templates select="@*|node()"/>
      </para>
    </listitem>
  </xsl:template>

  <xsl:template match="xhtml:sub">
    <subscript>
      <xsl:apply-templates select="@*|node()"/>
    </subscript>
  </xsl:template>

  <xsl:template match="xhtml:sup">
    <superscript>
      <xsl:apply-templates select="@*|node()"/>
    </superscript>
  </xsl:template>

  <xsl:template match="xhtml:q">
    <quote>
      <xsl:apply-templates select="@*|node()"/>
    </quote>
  </xsl:template>

  <xsl:template match="xhtml:ins">
    <emphasis role="inserted">
      <xsl:apply-templates select="@*|node()"/>
    </emphasis>
  </xsl:template>

  <xsl:template match="xhtml:del">
    <emphasis role="deleted">
      <xsl:apply-templates select="@*|node()"/>
    </emphasis>
  </xsl:template>

  <xsl:template match="xhtml:table">
    <informaltable>
      <xsl:apply-templates select="@*|node()"/>
    </informaltable>
  </xsl:template>

  <xsl:template match="xhtml:tbody">
    <tbody>
      <xsl:apply-templates select="@*|node()"/>
    </tbody>
  </xsl:template>

  <xsl:template match="xhtml:tr">
    <tr>
      <xsl:apply-templates select="@*|node()"/>
    </tr>
  </xsl:template>

  <xsl:template match="xhtml:td">
    <td>
      <xsl:apply-templates select="@*|node()"/>
    </td>
  </xsl:template>

  <xsl:template match="xhtml:th">
    <th>
      <xsl:apply-templates select="@*|node()"/>
    </th>
  </xsl:template>

  <xsl:template match="xhtml:img">
    <figure>
      <xsl:choose>
        <xsl:when test="@title">
          <title><xsl:value-of select="@title"/></title>
        </xsl:when>
        <xsl:otherwise>
          <title><xsl:value-of select="@alt"/></title>
        </xsl:otherwise>
      </xsl:choose>
      <mediaobject>
        <xsl:variable name="bsvg" select="substring-after(@src,'/svg/')"/>
        <xsl:variable name="bjpeg" select="substring-after(@src,'/jpeg/')"/>
        <xsl:variable name="bpng" select="substring-after(@src,'/png/')"/>
        <xsl:choose>
          <xsl:when test="$bsvg != ''">
            <imageobject>
              <imagedata fileref="{concat($documentRoot,'/',$bsvg)}.svg"/>
            </imageobject>
          </xsl:when>
          <xsl:when test="$bjpeg != ''">
            <imageobject>
              <imagedata fileref="{concat($documentRoot,'/jpeg/',$bjpeg)}.jpeg"/>
            </imageobject>
          </xsl:when>
          <xsl:when test="$bpng != ''">
            <imageobject>
              <imagedata fileref="{concat($documentRoot,'/png/',$bpng)}.png"/>
            </imageobject>
          </xsl:when>
          <xsl:otherwise>
            <imageobject>
              <imagedata fileref="{concat($documentRoot,'/',@src)}"/>
            </imageobject>
          </xsl:otherwise>
        </xsl:choose>
      </mediaobject>
    </figure>
  </xsl:template>

  <xsl:template match="svg:svg">
    <inlinemediaobject>
      <imageobject>
        <imagedata>
          <svg:svg>
            <xsl:apply-templates select="@*|node()"/>
          </svg:svg>
        </imagedata>
      </imageobject>
    </inlinemediaobject>
  </xsl:template>

  <xsl:template match="xhtml:a[@href]">
    <link>
      <xsl:choose>
        <xsl:when test="(substring-before(@href,':') = 'http') or (substring-before(@href,':') = 'https') or (substring-before(@href,':') = 'mailto')">
          <xsl:attribute name="xlink:href"><xsl:value-of select="@href"/></xsl:attribute>
        </xsl:when>
        <xsl:when test="substring(@href,1,1) = '/'">
          <xsl:attribute name="xlink:href"><xsl:value-of select="concat($baseURI,@href)"/></xsl:attribute>
        </xsl:when>
        <xsl:otherwise>
          <xsl:attribute name="linkend"><xsl:value-of select="translate(@href,&quot;:,'*&quot;,'----')"/></xsl:attribute>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="node()"/>
    </link>
  </xsl:template>

  <xsl:template match="xhtml:div">
    <xsl:apply-templates select="node()"/>
  </xsl:template>

  <xsl:template match="xhtml:div[@class='figure']">
    <informalfigure>
      <xsl:apply-templates select="node()"/>
    </informalfigure>
  </xsl:template>

  <xsl:template match="xhtml:*/@class">
    <xsl:attribute name="role">
      <xsl:value-of select="."/>
    </xsl:attribute>
  </xsl:template>

  <xsl:template match="xhtml:span">
    <xsl:apply-templates select="node()"/>
  </xsl:template>

  <xsl:template match="xhtml:br"/>

  <xsl:template match="mathml:math">
    <equation>
      <xsl:copy>
        <xsl:apply-templates select="@*|node()"/>
      </xsl:copy>
    </equation>
  </xsl:template>

  <xsl:template match="xhtml:p/mathml:math">
    <inlineequation>
      <xsl:copy>
        <xsl:apply-templates select="@*|node()"/>
      </xsl:copy>
    </inlineequation>
  </xsl:template>

  <xsl:template match="xhtml:style | xhtml:input | xhtml:label | xhtml:form"/>

  <xsl:template match="xhtml:dl">
    <variablelist>
      <xsl:apply-templates select="@*|xhtml:dt"/>
    </variablelist>
  </xsl:template>

  <xsl:template match="xhtml:dt">
    <varlistentry>
      <xsl:variable name="nodes" select="following-sibling::node()"/>
      <xsl:variable name="next" select="$nodes[self::xhtml:dt]"/>
      <term><xsl:apply-templates select="@*|node()"/></term>
      <listitem>
        <xsl:apply-templates select="$nodes[not(preceding-sibling::* = $next) and not (. = $next)]"/>
      </listitem>
    </varlistentry>
  </xsl:template>

  <xsl:template match="xhtml:dd">
    <para>
      <xsl:apply-templates select="@*|node()"/>
    </para>
  </xsl:template>
</xsl:stylesheet>
