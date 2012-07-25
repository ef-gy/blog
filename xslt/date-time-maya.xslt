<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    xmlns:dt="http://ef.gy/2012/date-time"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns="http://ef.gy/2012/date-time"
    version="1.0">
  <xsl:output method="xml" version="1.0" encoding="UTF-8"
              indent="no"
              media-type="application/xml" />

  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>

  <xsl:variable name="unixEpoch">1856305</xsl:variable>
  <xsl:variable name="unixSecondsPerDay">86400</xsl:variable>

  <dt:day-names>
    <dt:tzolkin>Ajaw</dt:tzolkin>
    <dt:tzolkin>Imix</dt:tzolkin>
    <dt:tzolkin>Ik</dt:tzolkin>
    <dt:tzolkin>Ak'b'al</dt:tzolkin>
    <dt:tzolkin>K'an</dt:tzolkin>
    <dt:tzolkin>Chikchan</dt:tzolkin>
    <dt:tzolkin>Kimi</dt:tzolkin>
    <dt:tzolkin>Manik'</dt:tzolkin>
    <dt:tzolkin>Lamat</dt:tzolkin>
    <dt:tzolkin>Muluk</dt:tzolkin>
    <dt:tzolkin>Ok</dt:tzolkin>
    <dt:tzolkin>Chuwen</dt:tzolkin>
    <dt:tzolkin>Eb'</dt:tzolkin>
    <dt:tzolkin>B'en</dt:tzolkin>
    <dt:tzolkin>Ix</dt:tzolkin>
    <dt:tzolkin>Men</dt:tzolkin>
    <dt:tzolkin>Kib'</dt:tzolkin>
    <dt:tzolkin>Kab'an</dt:tzolkin>
    <dt:tzolkin>Etz'nab'</dt:tzolkin>
    <dt:tzolkin>Kawak</dt:tzolkin>
    <dt:haab>Pop</dt:haab>
    <dt:haab>Wo'</dt:haab>
    <dt:haab>Sip</dt:haab>
    <dt:haab>Sotz'</dt:haab>
    <dt:haab>Tzek</dt:haab>
    <dt:haab>Xul</dt:haab>
    <dt:haab>Yaxk'in</dt:haab>
    <dt:haab>Mol</dt:haab>
    <dt:haab>Ch'en</dt:haab>
    <dt:haab>Yax</dt:haab>
    <dt:haab>Sak'</dt:haab>
    <dt:haab>Keh</dt:haab>
    <dt:haab>Mak</dt:haab>
    <dt:haab>K'ank'in</dt:haab>
    <dt:haab>Muwan'</dt:haab>
    <dt:haab>Pax</dt:haab>
    <dt:haab>K'ayab</dt:haab>
    <dt:haab>Kumk'u</dt:haab>
    <dt:haab>Wayeb'</dt:haab>
  </dt:day-names>

  <xsl:variable name="dayNames" select="document('')//dt:day-names" />

  <xsl:template name="long-count">
    <xsl:param name="unix" />
 
    <xsl:variable name="k" select="$unixEpoch + floor($unix div $unixSecondsPerDay)" />

    <xsl:variable name="kin" select="floor($k mod 20)" />
    <xsl:variable name="k2" select="$k div 20" />

    <xsl:variable name="winal" select="floor($k2 mod 18)" />
    <xsl:variable name="k3" select="$k2 div 18" />

    <xsl:variable name="tun" select="floor($k3 mod 20)" />
    <xsl:variable name="k4" select="$k3 div 20" />

    <xsl:variable name="katun" select="floor($k4 mod 20)" />
    <xsl:variable name="k5" select="$k4 div 20" />

    <xsl:variable name="baktun" select="floor($k5 mod 20)" />
    <xsl:variable name="k6" select="$k5 div 20" />

    <xsl:variable name="piktun" select="floor($k6 mod 20)" />
    <xsl:variable name="k7" select="$k6 div 20" />

    <xsl:variable name="kalabtun" select="floor($k7 mod 20)" />
    <xsl:variable name="k8" select="$k7 div 20" />

    <xsl:variable name="kinchiltun" select="floor($k8 mod 20)" />
    <xsl:variable name="k9" select="$k8 div 20" />

    <xsl:variable name="alautun" select="floor($k9 mod 20)" />

    <xsl:choose>
     <xsl:when test="floor($k6) = 0">
      <xsl:copy-of select="concat($baktun,'.',$katun,'.',$tun,'.',$winal,'.',$kin)" />
     </xsl:when>
     <xsl:otherwise>
      <xsl:copy-of select="concat($alautun,'.',$kinchiltun,'.',$kalabtun,'.',$piktun,'.',$baktun,'.',$katun,'.',$tun,'.',$winal,'.',$kin)" />
     </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="tzolkin">
    <xsl:param name="unix" />
 
    <xsl:variable name="kin" select="$unixEpoch + floor($unix div $unixSecondsPerDay)" />

    <xsl:variable name="num" select="floor(($kin + 4) mod 13)" />
    <xsl:variable name="day" select="floor($kin mod 20)" />

    <xsl:choose>
     <xsl:when test="$num = 0">
      <xsl:copy-of select="concat('13 ',$dayNames/tzolkin[$day+1])"/>
     </xsl:when>
     <xsl:otherwise>
      <xsl:copy-of select="concat($num,' ',$dayNames/dt:tzolkin[$day+1])"/>
     </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="haab">
    <xsl:param name="unix" />

    <xsl:variable name="kin" select="floor((($unixEpoch + ($unix div $unixSecondsPerDay)) - 17) mod 365)" />

    <xsl:variable name="num" select="floor($kin mod 20)" />
    <xsl:variable name="day" select="floor($kin div 20)" />

    <xsl:copy-of select="concat($num,' ',$dayNames/dt:haab[$day+1])"/>
  </xsl:template>

  <xsl:template name="unix-to-maya">
   <xsl:param name="unix"/>

   <xsl:call-template name="long-count">
    <xsl:with-param name="unix" select="$unix" />
   </xsl:call-template>
   <xsl:copy-of select="' '"/>
   <xsl:call-template name="tzolkin">
    <xsl:with-param name="unix" select="$unix" />
   </xsl:call-template>
   <xsl:copy-of select="' '"/>
   <xsl:call-template name="haab">
    <xsl:with-param name="unix" select="$unix" />
   </xsl:call-template>
  </xsl:template>

  <xsl:template match="dt:date[@unix][@to='maya']">
   <xsl:call-template name="unix-to-maya">
    <xsl:with-param name="unix" select="@unix" />
   </xsl:call-template>
  </xsl:template>
</xsl:stylesheet>
