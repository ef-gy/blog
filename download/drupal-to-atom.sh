#!/bin/bash

# configuration parameters for the scripts
name=kyuba
database=drupal-${name}
user=root
prefix=
timezone=Z
categoryprefix=${name}.org
fileprefix=${name}:
tbase=/tmp/drupal-x-

cat > ${tbase}pre-sed.xslt <<atomManglePreSedSQL
<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xhtml="http://www.w3.org/1999/xhtml"
    xmlns:atom="http://www.w3.org/2005/Atom"
    xmlns="http://www.w3.org/2005/Atom"
    exclude-result-prefixes="xhtml atom"
    version="1.0">
  <xsl:output method="xml" version="1.0" encoding="UTF-8"
              indent="no"
              media-type="application/atom+xml" />

  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="atom:summary/text()">
    <xsl:variable name="text" select="translate(normalize-space(.),'*[]&lt;>=','-()')"/>
    <xsl:value-of select="substring(\$text,1,160)"/>
    <xsl:if test="string-length(\$text) > 160">...</xsl:if>
  </xsl:template>

  <xsl:template match="atom:category/@term[.='blog']">
    <xsl:attribute name="term">Blog Post</xsl:attribute>
  </xsl:template>

  <xsl:template match="atom:category/@term[.='forum']">
    <xsl:attribute name="term">Forum Post</xsl:attribute>
  </xsl:template>

  <xsl:template match="atom:category/@term[.='project_project']">
    <xsl:attribute name="term">Project Description</xsl:attribute>
  </xsl:template>

  <xsl:template match="atom:category/@term[.='project_release']">
    <xsl:attribute name="term">Project Release</xsl:attribute>
  </xsl:template>

  <xsl:template match="atom:category/@term[.='project_issue']">
    <xsl:attribute name="term">Project Issue</xsl:attribute>
  </xsl:template>

  <xsl:template match="atom:category/@term[.='page']">
    <xsl:attribute name="term">Page</xsl:attribute>
  </xsl:template>

  <xsl:template match="atom:category/@term[.='book']">
    <xsl:attribute name="term">Book</xsl:attribute>
  </xsl:template>

  <xsl:template match="atom:category/@term[.='image']">
    <xsl:attribute name="term">Image</xsl:attribute>
  </xsl:template>

  <xsl:template match="atom:feed/atom:title|atom:subtitle">
    <xsl:copy>
      <xsl:value-of select="substring-before(substring-after(text(),'&quot;'),'&quot;')"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="atom:content[@type='text']">
    <content type='application/xhtml+xml'>
      <html xmlns="http://www.w3.org/1999/xhtml">
        <head>
          <title><xsl:value-of select="../atom:title"/></title>
          <meta name="date" content="{../atom:updated}"/>
          <meta name="author" content="{../atom:author/atom:name}"/>
          <meta name="mtime" content="{../atom:updated}"/>
          <meta name="unix:name" content="{translate(concat('${fileprefix}',translate(normalize-space(translate(../atom:title,'=()&lt;>[]?#!&quot;/!','             ')),' ','-')),'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')}"/>
        </head>
        <body>
          <xsl:value-of select="."/>
        </body>
      </html>
    </content>
  </xsl:template>
</xsl:stylesheet>
atomManglePreSedSQL

cat > ${tbase}post-sed.xslt <<atomManglePostSedSQL
<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xhtml="http://www.w3.org/1999/xhtml"
    xmlns:atom="http://www.w3.org/2005/Atom"
    xmlns="http://www.w3.org/1999/xhtml"
    exclude-result-prefixes="xhtml atom"
    version="1.0">
  <xsl:output method="xml" version="1.0" encoding="UTF-8"
              indent="no"
              media-type="application/atom+xml" />

  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="atom:content/xhtml:html/xhtml:head">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
      <meta name="description" content="{../../../atom:summary}"/>
      <meta name="category" content="{../../../atom:category/@term}"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="xhtml:body/text()">
    <xsl:variable name="text" select="normalize-space(.)"/>
    <xsl:if test="string-length(\$text)>0"><p>
      <xsl:value-of select="\$text"/>
    </p></xsl:if>
  </xsl:template>

  <xsl:template match="xhtml:body/xhtml:br"/>
  <xsl:template match="xhtml:body/xhtml:code/xhtml:br"/>

  <xsl:template match="xhtml:body/xhtml:ul">
    <xsl:variable name="name" select="local-name()"/>

    <xsl:if test="local-name(preceding-sibling::*[position()=1]) != \$name">
      <xsl:copy>
        <xsl:apply-templates />
        <xsl:apply-templates select="following-sibling::*[1][local-name()=\$name]" mode="next"/>
      </xsl:copy>
    </xsl:if>
  </xsl:template>

  <xsl:template match="xhtml:body/xhtml:ul" mode="next">
    <xsl:variable name="name" select="local-name()"/>
    <xsl:apply-templates />
    <xsl:apply-templates select="following-sibling::*[1][local-name()=\$name]" mode="next"/>
  </xsl:template>

  <xsl:template match="xhtml:a[@rel='need-lookup']">
    <xsl:variable name="href" select="@href"/>
    <xsl:choose>
      <xsl:when test="//xhtml:head[xhtml:title=\$href]">
        <xsl:copy>
          <xsl:attribute name="href">
            <xsl:value-of select="//xhtml:head[xhtml:title=\$href]/xhtml:meta[@name='unix:name']/@content"/>
          </xsl:attribute>
          <xsl:copy-of select="text()"/>
        </xsl:copy>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy-of select="."/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
</xsl:stylesheet>
atomManglePostSedSQL

cat > ${tbase}db-to-xhtml.sql <<drupalExtractionSQL
select v.entry
from (
    select 1 as seq,
        concat(
                '<?xml version="1.0" encoding="utf-8"?>',
                '<feed xmlns="http://www.w3.org/2005/Atom">',
                '<title><![CDATA[',(select value from ${prefix}variable where name='site_name'),']]></title>',
                '<subtitle><![CDATA[',(select value from ${prefix}variable where name='site_slogan'),']]></subtitle>',
                '<updated>',(select replace(from_unixtime(timestamp),' ','T') from ${prefix}node_revisions order by timestamp desc limit 1),'${timezone}</updated>',
                '<link rel="self" href="${database}"/>',
                '<id></id>'
              )
        as entry
    union
    select
        2 as seq,
        concat(
                '<entry>',
                '<title><![CDATA[',${prefix}node.title,']]></title>',
                '<updated>',replace(from_unixtime(timestamp),' ','T'), '${timezone}</updated>',
                '<author><name><![CDATA[',${prefix}users.name,']]></name><email><![CDATA[',${prefix}users.mail,']]></email></author>',
                '<id>drupal:${database}:${prefix}:',${prefix}node_revisions.nid,':',${prefix}node_revisions.vid,'</id>',
                '<summary><![CDATA[',teaser,']]></summary>',
                '<content type="text"><![CDATA[',body,']]></content>',
                '<category term="',type,'" />',
                '<category term="${categoryprefix}"/>',
                '</entry>'
              )
        as entry
    from ${prefix}node
    left join ${prefix}node_revisions on ${prefix}node.vid = ${prefix}node_revisions.vid
    left join ${prefix}users on ${prefix}users.uid = ${prefix}node_revisions.uid
    union
    select
        3 as seq,
        '</feed>' as entry
) as v
order by v.seq;
drupalExtractionSQL

cat ${tbase}db-to-xhtml.sql\
    | mysql -s -r -u ${user} ${database} -p\
    | xsltproc ${tbase}pre-sed.xslt -\
    | sed -e\
    's#======\([^=]\+\)======#<h5>\1</h5>#g;
     s#=====\([^=]\+\)=====#<h4>\1</h4>#g;
     s#====\([^=]\+\)====#<h3>\1</h3>#g;
     s#===\([^=]\+\)===#<h2>\1</h2>#g;
     s#==\([^=]\+\)==#<h1>\1</h1>#g;
     s#^ *\*\*\*\* \+\([^<]\+\)#<ul><ul><ul><ul><li>\1</li></ul></ul></ul></ul>#g;
     s#^ *\*\*\* \+\([^<]\+\)#<ul><ul><ul><li>\1</li></ul></ul></ul>#g;
     s#^ *\*\* \+\([^<]\+\)#<ul><ul><li>\1</li></ul></ul>#g;
     s#^ *\* \+\([^<]\+\)#<ul><li>\1</li></ul>#g;
     s#\[\[\([^]"<>]\+\)\]\]#<a href="\1" rel="need-lookup">\1</a>#g;
     s#^$#<br/>#;
     s#^---*#<hr/>#;
     s#.lt.\(/\?code\).gt.#<\1>#g' \
    | xsltproc ${tbase}post-sed.xslt -\
    > ${database}.atom
