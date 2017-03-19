<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:dita-ot="http://dita-ot.sourceforge.net/ns/201007/dita-ot"
    xmlns:dita2html="http://dita-ot.sourceforge.net/ns/200801/dita2html"
    xmlns:ditamsg="http://dita-ot.sourceforge.net/ns/200704/ditamsg"
    version="2.0"
    exclude-result-prefixes="xs dita-ot dita2html ditamsg">
    
    <!-- PATH2PROJ defined by topic.xsl -->
    <xsl:param name="args.ditasearch.nohtml"/>
    
    <xsl:variable name="add-search-html" as="xs:boolean">
        <xsl:value-of select="not(normalize-space(lower-case($args.ditasearch.nohtml)) = ('yes','true'))"/>
    </xsl:variable>
    
    <xsl:template match="/|node()|@*" mode="gen-user-header" priority="0.5">
        <!-- Other templates should take precedence and can call ditasearch-header -->
        <xsl:if test="$add-search-html">
            <xsl:call-template name="ditasearch-header"/>
        </xsl:if>
    </xsl:template>
    
    <xsl:template name="ditasearch-header">
        <div class="ditasearch" data-searchroot="{$PATH2PROJ}"></div>
    </xsl:template>
    
    <xsl:template match="/|node()|@*" mode="gen-user-footer" priority="0.5">
        <!-- Other templates should take precedence and can call ditasearch-footer -->
        <xsl:if test="$add-search-html">
            <xsl:call-template name="ditasearch-footer"/>
        </xsl:if>
    </xsl:template>
    
    <xsl:template name="ditasearch-footer">
        <script src="{$PATH2PROJ}ditasearch.js"></script>
    </xsl:template>
    
</xsl:stylesheet>