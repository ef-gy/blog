<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
              xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
              xmlns:opf="http://www.idpf.org/2007/opf"
              xmlns="http://www.idpf.org/2007/opf"
              version="1.1">
  <xsl:output method="text" version="1.0" encoding="UTF-8"
              indent="no"
              media-type="application/xml" />

  <xsl:template match="text()"/>

  <xsl:template match="opf:manifest/opf:item">
    <xsl:value-of select="concat(@href,' ')"/>
  </xsl:template>
</xsl:stylesheet>
