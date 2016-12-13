<?xml version="1.0"?>

<!--

    $HeadURL$

    $Revision$
    $Date$

    $Author$

    Copyright (c) 2009,2010 California Institute of Technology.
    All rights reserved.

-->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
<!--
<xsl:import href="/usr/share/sgml/docbook/xsl-stylesheets/xhtml/docbook.xsl"/>
-->
<xsl:import href="/usr/share/xml/docbook/stylesheet/nwalsh/xhtml/docbook.xsl"/>

<xsl:template match="h:*" xmlns:h="http://www.w3.org/1999/xhtml">
   <xsl:copy>
     <xsl:copy-of select="@*"/>
     <xsl:apply-templates/>
   </xsl:copy>
</xsl:template>

</xsl:stylesheet>
