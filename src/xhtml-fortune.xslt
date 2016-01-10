<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
              xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
              xmlns:xhtml="http://www.w3.org/1999/xhtml"
              xmlns:fortune="http://ef.gy/2012/fortune"
              xmlns="http://www.w3.org/1999/xhtml"
              xmlns:date="http://exslt.org/dates-and-times"
              version="1.0">
  <xsl:output method="xml" version="1.0" encoding="UTF-8"
              doctype-public="-//W3C//DTD XHTML 1.1//EN"
              doctype-system="http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd"
              indent="no"
              media-type="application/xhtml+xml" />

  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()" />
    </xsl:copy>
  </xsl:template>

  <xsl:template match="fortune:fortune">
    <html>
      <head>
        <title>Fortune #<xsl:value-of select="@quoteID"/></title>
      </head>
      <body>
        <blockquote cite="file://{@sourceFile}">
          <pre><xsl:copy-of select="text()"/></pre>
        </blockquote>
      </body>
    </html>
  </xsl:template>
</xsl:stylesheet>

