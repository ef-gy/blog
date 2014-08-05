<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
              xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
              xmlns:xhtml="http://www.w3.org/1999/xhtml"
              xmlns:svg="http://www.w3.org/2000/svg"
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
        <xhtml:script type="application/javascript" src="//cdnjs.cloudflare.com/ajax/libs/d3/3.4.11/d3.min.js"></xhtml:script>
        <xhtml:script type="application/javascript" src="//ajax.googleapis.com/ajax/libs/jquery/1.11.1/jquery.min.js"></xhtml:script>
        <xhtml:script type="application/javascript" src="/js/documentation-graphs"></xhtml:script>
      </xhtml:head>
      <xhtml:body>
        <xsl:choose>
          <xsl:when test="$detail='ls'">
            <xhtml:h1>Contents</xhtml:h1>
            <xhtml:ul>
              <xsl:for-each select="//@id[not(parent::node)]">
                <xhtml:li><xhtml:a href="./{.}"><xsl:value-of select="."/></xhtml:a></xhtml:li>
              </xsl:for-each>
            </xhtml:ul>
          </xsl:when>
          <xsl:when test="$detail='mega-graph'">
            <xhtml:h1>Full Project Graph</xhtml:h1>
            <svg:svg>
              <svg:metadata>
                <xsl:apply-templates select="//node"/>
              </svg:metadata>
            </svg:svg>
          </xsl:when>
        </xsl:choose>
        <xsl:apply-templates select="node()" />
      </xhtml:body>
    </xhtml:html>
  </xsl:template>

  <xsl:template match="compounddef">
    <xsl:if test="(ancestor-or-self::compounddef | descendant::memberdef)[@id=$detail]">
      <xsl:apply-templates select="compoundname | title"/>
      <xsl:apply-templates select="briefdescription | detaileddescription"/>
      <xsl:apply-templates select="node()[not(self::briefdescription or self::detaileddescription or self::compoundname or self::title)]"/>
    </xsl:if>
  </xsl:template>

  <xsl:template match="memberdef">
    <xsl:if test="(ancestor-or-self::compounddef | ancestor-or-self::memberdef)[@id=$detail]">
      <xsl:variable name="classes"><xsl:value-of select="concat(@kind,' ')"/>
        <xsl:value-of select="concat(@prot,' ')"/>
        <xsl:if test="@writable='yes'">writable </xsl:if>
        <xsl:if test="@readable='yes'">readable </xsl:if>
        <xsl:if test="@gettable='yes'">gettable </xsl:if>
        <xsl:if test="@settable='yes'">settable </xsl:if>
        <xsl:if test="@static='yes'">static</xsl:if>
      </xsl:variable>

      <xhtml:li class="{$classes}">
        <xsl:apply-templates select="node()" />
      </xhtml:li>
    </xsl:if>
  </xsl:template>

  <xsl:template match="sectiondef">
    <xsl:if test="memberdef">
      <xhtml:ul class="members">
        <xsl:apply-templates select="memberdef"/>
      </xhtml:ul>
    </xsl:if>
    <xsl:apply-templates select="node()[not(self::memberdef)]"/>
  </xsl:template>

  <xsl:template match="compoundname">
    <xsl:if test="not(following-sibling::title)">
      <xhtml:h1><xhtml:span><xsl:value-of select="../@kind"/></xhtml:span>&#160;<xsl:value-of select="."/></xhtml:h1>
    </xsl:if>
  </xsl:template>

  <xsl:template match="title">
    <xhtml:h1>
      <xsl:apply-templates select="node()"/>
    </xhtml:h1>
  </xsl:template>

  <xsl:template match="sect1">
    <xsl:apply-templates select="node()"/>
  </xsl:template>

  <xsl:template match="sect1[@id]/title">
    <xhtml:h1 id="{parent::*/@id}">
      <xsl:apply-templates select="node()"/>
    </xhtml:h1>
  </xsl:template>

  <xsl:template match="templateparamlist">
    <xhtml:ul>
      <xsl:apply-templates select="node()"/>
    </xhtml:ul>
  </xsl:template>

  <xsl:template match="includes">
    <xhtml:p class="include">#include &lt;<xhtml:a href="{@refid}"><xsl:value-of select="."/></xhtml:a>&gt;</xhtml:p>
  </xsl:template>

  <xsl:template match="includedby">
    <xhtml:p class="includedby">Included by <xhtml:a href="{@refid}"><xsl:value-of select="."/></xhtml:a></xhtml:p>
  </xsl:template>

  <xsl:template match="ulink[@url]">
    <xhtml:a href="{@url}"><xsl:value-of select="."/></xhtml:a>
  </xsl:template>

  <xsl:template match="ref[@refid]">
    <xhtml:a href="./{@refid}" class="{@kindref}"><xsl:value-of select="."/></xhtml:a>
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
    <xsl:apply-templates select="node()[not(simplesect[@kind='copyright'])]"/>

    <xsl:if test="descendant::simplesect[@kind='copyright' or @kind='see']">
      <xhtml:h2>Copyright</xhtml:h2>
      <xsl:apply-templates select="descendant::simplesect[@kind='copyright']"/>
    </xsl:if>

    <xsl:if test="descendant::simplesect[@kind='see']">
      <xhtml:h2>See Also</xhtml:h2>
      <xsl:apply-templates select="descendant::simplesect[@kind='see']"/>
    </xsl:if>
  </xsl:template>

  <xsl:template match="para">
    <xsl:choose>
      <xsl:when test="heading">
        <xsl:apply-templates select="node()"/>
      </xsl:when>
      <xsl:otherwise>
        <xhtml:p><xsl:apply-templates select="node()"/></xhtml:p>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="sectiondef[@kind='public-type']">
    <xhtml:h2>Public Member Types</xhtml:h2>
    <xsl:apply-templates select="node()"/>
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

  <xsl:template match="simplesect[@kind]/para">
    <xhtml:p class="{parent::node()/@kind}">
      <xsl:apply-templates select="node()"/>
    </xhtml:p>
  </xsl:template>

  <xsl:template match="parameterlist">
    <xhtml:dl class="{@kind}">
      <xsl:apply-templates select="node()"/>
    </xhtml:dl>
  </xsl:template>

  <xsl:template match="parameteritem">
    <xsl:apply-templates select="node()"/>
  </xsl:template>

  <xsl:template match="parameternamelist">
    <xsl:apply-templates select="node()"/>
  </xsl:template>

  <xsl:template match="parametername">
    <xhtml:dt><xsl:apply-templates select="node()"/></xhtml:dt>
  </xsl:template>

  <xsl:template match="parametername[@direction]">
    <xhtml:dt><xsl:apply-templates select="node()"/> [<xsl:value-of select="@direction"/>]</xhtml:dt>
  </xsl:template>

  <xsl:template match="parametername[@direction='in']">
    <xhtml:dt><xsl:apply-templates select="node()"/> [input]</xhtml:dt>
  </xsl:template>

  <xsl:template match="parameterdescription">
    <xhtml:dd><xsl:apply-templates select="node()"/></xhtml:dd>
  </xsl:template>

  <xsl:template match="incdepgraph | invincdepgraph | inheritancegraph | collaborationgraph">
    <xsl:if test="not(preceding-sibling::incdepgraph | preceding-sibling::invincdepgraph | preceding-sibling::inheritancegraph | preceding-sibling::collaborationgraph)">
      <svg:svg>
        <svg:metadata>
          <xsl:apply-templates select="following-sibling::incdepgraph/node() | following-sibling::invincdepgraph/node() | following-sibling::inheritancegraph/node() | following-sibling::collaborationgraph/node() | node()"/>
        </svg:metadata>
      </svg:svg>
    </xsl:if>
  </xsl:template>

  <xsl:template match="heading[@level=1]">
    <xhtml:h1><xsl:value-of select="."/></xhtml:h1>
  </xsl:template>

  <xsl:template match="heading[@level=2]">
    <xhtml:h2><xsl:value-of select="."/></xhtml:h2>
  </xsl:template>

  <xsl:template match="heading[@level=3]">
    <xhtml:h3><xsl:value-of select="."/></xhtml:h3>
  </xsl:template>

  <xsl:template match="heading[@level=4]">
    <xhtml:h4><xsl:value-of select="."/></xhtml:h4>
  </xsl:template>

  <xsl:template match="heading[@level=5]">
    <xhtml:h5><xsl:value-of select="."/></xhtml:h5>
  </xsl:template>

  <xsl:template match="heading[@level=6]">
    <xhtml:h6><xsl:value-of select="."/></xhtml:h6>
  </xsl:template>

  <xsl:template match="verbatim">
    <xhtml:pre><xsl:apply-templates select="node()"/></xhtml:pre>
  </xsl:template>

  <xsl:template match="programlisting">
    <xhtml:code>
      <xhtml:ol>
        <xsl:apply-templates select="node()"/>
      </xhtml:ol>
    </xhtml:code>
  </xsl:template>

  <xsl:template match="highlight">
    <xhtml:em><xsl:apply-templates select="@class|node()"/></xhtml:em>
  </xsl:template>

  <xsl:template match="codeline">
    <xhtml:li><xsl:apply-templates select="@class|node()"/></xhtml:li>
  </xsl:template>

  <xsl:template match="codeline[@lineno]">
    <xhtml:li value="{@lineno}"><xsl:apply-templates select="@class|node()"/></xhtml:li>
  </xsl:template>

  <xsl:template match="sp">&#160;</xsl:template>

  <xsl:template match="innerclass[@refid]">
    <xhtml:p class="inner-class {@prot}"><xhtml:a href="./{@refid}"><xsl:value-of select="."/></xhtml:a></xhtml:p>
  </xsl:template>

  <xsl:template match="innernamespace[@refid]">
    <xhtml:p class="inner-namespace {@prot}"><xhtml:a href="./{@refid}"><xsl:value-of select="."/></xhtml:a></xhtml:p>
  </xsl:template>

  <xsl:template match="location[@file]">
    <xhtml:p class="see">Defined in file <xhtml:cite><xsl:value-of select="@file"/></xhtml:cite> in the source code repository.</xhtml:p>
  </xsl:template>
</xsl:stylesheet>
