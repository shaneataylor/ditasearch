<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:dita-ot="http://dita-ot.sourceforge.net/ns/201007/dita-ot"
    xmlns:dita2html="http://dita-ot.sourceforge.net/ns/200801/dita2html"
    xmlns:ditamsg="http://dita-ot.sourceforge.net/ns/200704/ditamsg"
    xmlns:exsl="http://exslt.org/common" xmlns:java="org.dita.dost.util.ImgUtils"
    xmlns:url="org.dita.dost.util.URLUtils"
    exclude-result-prefixes="dita-ot dita2html ditamsg exsl java url">

    <xsl:output encoding="UTF-8" method="text"/>
    
    <xsl:template match="/">
        <xsl:apply-templates select="job/files/file[@format='dita'][not(@resource-only='true')]"/>
    </xsl:template>
    
    <xsl:template match="file">
        <xsl:value-of select="concat(@path,'&#x0D;&#x0A;')"/><!-- @copy-to files are already included -->
    </xsl:template>
    
    <xsl:template match="*|text()|@*"/>
    
</xsl:stylesheet>
