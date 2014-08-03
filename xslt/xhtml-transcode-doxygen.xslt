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
        <xhtml:script>

var width = $(window).width(),
    height = <xsl:choose><xsl:when test="$detail='mega-graph'">$(window).height()*2</xsl:when><xsl:otherwise>500</xsl:otherwise></xsl:choose>;

d3.selectAll('svg').each(function() {
  var svg = d3.select(this)
      .attr('height', height);

  var links = [];

  d3.select(this).select('metadata').selectAll('node').each(function(){
    var source = d3.select(this).select('label').text();

    d3.select(this).selectAll('childnode').each(function(){
      var cn = d3.select(this);
      d3.select("[id='"+cn.attr('refid')+"']").each(function(){
        var target = d3.select(this).select('label').text();

        links.push({ 'source': source, 'target': target, 'type': cn.attr('relation') });
      });
    });
  });

  var nodes = {};

  links.forEach(function(link) {
    link.source = nodes[link.source] || (nodes[link.source] = {name: link.source});
    link.target = nodes[link.target] || (nodes[link.target] = {name: link.target});
  });

  console.log(links);
  console.log(nodes);

  var force = d3.layout.force()
      .nodes(d3.values(nodes))
      .links(links)
      .size([width, height])
      .linkDistance(60)
      .charge(-300)
      .on('tick', tick)
      .start();

  svg.append('defs').selectAll('marker')
      .data(['include', 'public-inheritance', 'usage'])
    .enter().append('marker')
      .attr("id", function(d) { return d; })
      .attr("viewBox", "0 -5 10 10")
      .attr("refX", 15)
      .attr("refY", -1.5)
      .attr("markerWidth", 6)
      .attr("markerHeight", 6)
      .attr("orient", "auto")
    .append("path")
      .attr("d", "M0,-5L10,0L0,5");

  var path = svg.append("g").selectAll("path")
      .data(force.links())
    .enter().append("path")
      .attr("class", function(d) { return "link " + d.type; })
      .attr("marker-end", function(d) { return "url(#" + d.type + ")"; });

  var circle = svg.append("g").selectAll("circle")
      .data(force.nodes())
    .enter().append("circle")
      .attr("r", 6)
      .call(force.drag);

  var text = svg.append("g").selectAll("text")
      .data(force.nodes())
    .enter().append("text")
      .attr("x", 8)
      .attr("y", ".31em")
      .text(function(d) { return d.name; });

  // Use elliptical arc path segments to doubly-encode directionality.
  function tick() {
    path.attr("d", linkArc);
    circle.attr("transform", transform);
    text.attr("transform", transform);
  }

  function linkArc(d) {
    var dx = d.target.x - d.source.x,
        dy = d.target.y - d.source.y,
        dr = Math.sqrt(dx * dx + dy * dy);
    return "M" + d.source.x + "," + d.source.y + "A" + dr + "," + dr + " 0 0,1 " + d.target.x + "," + d.target.y;
  }

  function transform(d) {
    return "translate(" + d.x + "," + d.y + ")";
  }
});

        </xhtml:script>
      </xhtml:body>
    </xhtml:html>
  </xsl:template>

  <xsl:template match="compounddef">
    <xsl:if test="(ancestor-or-self::compounddef | descendant::memberdef)[@id=$detail]">
      <xsl:apply-templates select="node()" />
    </xsl:if>
  </xsl:template>

  <xsl:template match="memberdef">
    <xsl:if test="(ancestor-or-self::compounddef | ancestor-or-self::memberdef)[@id=$detail]">
      <xsl:copy>
        <xsl:apply-templates select="@*|node()" />
      </xsl:copy>
    </xsl:if>
  </xsl:template>

  <xsl:template match="compoundname">
    <xsl:choose>
      <xsl:when test="following-sibling::title"/>
      <xsl:otherwise>
        <xhtml:h1><xhtml:span><xsl:value-of select="../@kind"/></xhtml:span>&#160;<xsl:value-of select="."/></xhtml:h1>
      </xsl:otherwise>
    </xsl:choose>
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

  <xsl:template match="ulink[@url]">
    <xhtml:a href="{@url}"><xsl:value-of select="."/></xhtml:a>
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
    <xsl:choose>
      <xsl:when test="heading">
        <xsl:apply-templates select="node()"/>
      </xsl:when>
      <xsl:otherwise>
        <xhtml:p><xsl:apply-templates select="node()"/></xhtml:p>
      </xsl:otherwise>
    </xsl:choose>
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
    <xhtml:dt><xsl:apply-templates select="node()"/> [<xsl:value-of select="@direction"/>]</xhtml:dt>
  </xsl:template>

  <xsl:template match="parametername[@direction='in']">
    <xhtml:dt><xsl:apply-templates select="node()"/> [input]</xhtml:dt>
  </xsl:template>

  <xsl:template match="parameterdescription">
    <xhtml:dd><xsl:apply-templates select="node()"/></xhtml:dd>
  </xsl:template>

  <xsl:template match="incdepgraph">
    <svg:svg>
      <svg:metadata>
        <xsl:apply-templates select="node()"/>
      </svg:metadata>
    </svg:svg>
  </xsl:template>

  <xsl:template match="invincdepgraph">
    <svg:svg>
      <svg:metadata>
        <xsl:apply-templates select="node()"/>
      </svg:metadata>
    </svg:svg>
  </xsl:template>

  <xsl:template match="inheritancegraph">
    <svg:svg>
      <svg:metadata>
        <xsl:apply-templates select="node()"/>
      </svg:metadata>
    </svg:svg>
  </xsl:template>

  <xsl:template match="collaborationgraph">
    <svg:svg>
      <svg:metadata>
        <xsl:apply-templates select="node()"/>
      </svg:metadata>
    </svg:svg>
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
</xsl:stylesheet>
