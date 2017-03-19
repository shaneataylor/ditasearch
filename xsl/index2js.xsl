<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:fn="http://example.com/namespace"
    xmlns:dita-ot="http://dita-ot.sourceforge.net/ns/201007/dita-ot"
    xmlns:porter2="http://example.com/namespace"
    exclude-result-prefixes="xs fn porter2 dita-ot"
    version="2.0">
    
    <xsl:import href="porter2.xsl"/>
    
    <xsl:import href="plugin:org.dita.base:xsl/common/output-message.xsl"/>
    <xsl:import href="plugin:org.dita.base:xsl/common/dita-utilities.xsl"/>
    <xsl:variable name="msgprefix">DS</xsl:variable>
    
    <xsl:param name="scriptfile"/>
    
    <xsl:output method="text" encoding="UTF-8" indent="no"/>
    
    <xsl:variable name="script" as="xs:string">
        <xsl:copy-of select="unparsed-text($scriptfile)"/>
    </xsl:variable>
    
    <xsl:variable name="exceptionlist">
        <xsl:copy-of select="//exceptionalforms/exception"/>
    </xsl:variable>
    
    <xsl:function name="fn:substring-between">
        <xsl:param name="arg1" as="xs:string"/>
        <xsl:param name="arg2" as="xs:string"/>
        <xsl:param name="arg3" as="xs:string"/>
        <xsl:value-of select="substring-before(substring-after($arg1,$arg2),$arg3)"/>
    </xsl:function>
    
    <xsl:function name="fn:q" as="xs:string">
        <xsl:param name="arg" as="xs:string"/>
        <xsl:value-of select="concat('&#34;',$arg,'&#34;')"/>
    </xsl:function>
    
    <xsl:function name="fn:JSONobj" as="xs:string">
        <xsl:param name="key" as="xs:string"/>
        <xsl:param name="value" as="xs:string"/>
        <xsl:variable name="format" as="xs:string">{"KEY":"VALUE"}</xsl:variable>
        <xsl:value-of select="fn:JSONobj($key,$value,$format)"/>
    </xsl:function>
    
    <xsl:function name="fn:JSONobj" as="xs:string">
        <xsl:param name="key" as="xs:string"/>
        <xsl:param name="value" as="xs:string"/>
        <xsl:param name="format" as="xs:string"/>
        <xsl:value-of select="replace(replace($format,'KEY',$key),'VALUE',$value)"/>
    </xsl:function>
    
    <xsl:function name="fn:JSONify" as="xs:string">
        <xsl:param name="input" as="xs:string"/>
        <xsl:variable name="escape-bs" select="replace($input,'\\','&amp;#x5c;')"/>
        <xsl:variable name="escape-quotes" select="replace($escape-bs,'&quot;','&amp;#x22;')"/>
        <xsl:variable name="entity-dollar" select="replace($escape-quotes,'\$','&amp;#x24;')"/>
        <xsl:value-of select="$entity-dollar"/>
    </xsl:function>
    
    <xsl:template match="/">
        <!-- The sequence here must match ditasearch.js -->
        <xsl:value-of select="substring-before($script,'//==EXCEPTIONLIST==//')"/>
        <xsl:apply-templates select="//exceptionalforms/exception"/>
        <xsl:value-of select="fn:substring-between($script,'//==EXCEPTIONLIST==//','//==STRINGS==//')"/>
        <xsl:call-template name="addStrings"/>
        <xsl:value-of select="fn:substring-between($script,'//==STRINGS==//','//==SYNONYMS==//')"/>
        <xsl:call-template name="synonyms"/>
        <xsl:value-of select="fn:substring-between($script,'//==SYNONYMS==//','//==HELPINDEX==//')"/>
        <xsl:call-template name="helpindex"/>
        <xsl:value-of select="fn:substring-between($script,'//==HELPINDEX==//','//==TOPICSUMMARIES==//')"/>
        <xsl:call-template name="topicsummaries"/>
        <xsl:value-of select="substring-after($script,'//==TOPICSUMMARIES==//')"/>
    </xsl:template>
    
    <xsl:template match="exception">
        <xsl:value-of select="fn:JSONobj(@word,@stem)"/>
        <xsl:if test="count(following-sibling::*)>0"><xsl:text>,</xsl:text></xsl:if>
    </xsl:template>
    
    <xsl:template name="topicsummaries">
        <xsl:variable name="format1" as="xs:string">"KEY":VALUE</xsl:variable>
        <xsl:variable name="format2" as="xs:string">"KEY":"VALUE"</xsl:variable>
        <xsl:for-each select="//topicSummary">
            <xsl:sort select="@href"/>
            <xsl:if test="not(position() = 1)">,</xsl:if>
            <xsl:value-of select="fn:JSONobj(@href,
                concat('{',fn:JSONobj('searchtitle',fn:JSONify(@searchtitle),$format2),',',
                fn:JSONobj('shortdesc',fn:JSONify(@shortdesc),$format2),'}'),$format1)"/>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template name="helpindex">
        <xsl:variable name="format" as="xs:string">"KEY":[VALUE]</xsl:variable>
        <xsl:for-each-group select="//stem" group-by="@value">
            <xsl:sort select="@value"/>
            <xsl:if test="not(position() = 1)">,</xsl:if>
            <xsl:variable name="topics">
                <xsl:for-each select="current-group()">
                    <xsl:sort select="@score" order="descending" data-type="number"/>
                    <xsl:if test="not(position() = 1)">,</xsl:if>
                    <xsl:value-of select="fn:JSONobj(@href,@score)"/>
                </xsl:for-each>
            </xsl:variable>
            <xsl:value-of select="fn:JSONobj(current-grouping-key(),$topics,$format)"/>
        </xsl:for-each-group>
    </xsl:template>
    
    <xsl:template name="synonyms">
        <xsl:variable name="stemmedSyns">
            <xsl:apply-templates select="//synonym" mode="stemIt"/>
        </xsl:variable>
        <xsl:variable name="mergedSyns">
            <xsl:for-each-group select="$stemmedSyns/synonym" group-by="@term">
                <synonym>
                    <xsl:attribute name="term" select="current-grouping-key()"/>
                    <xsl:for-each-group select="current-group()/variant" group-by="text()">
                        <variant><xsl:value-of select="current-grouping-key()"/></variant>
                    </xsl:for-each-group>
                </synonym>
            </xsl:for-each-group>
        </xsl:variable>
        <xsl:apply-templates select="$mergedSyns/synonym" mode="toJSON"/>
    </xsl:template>
    
    <xsl:template match="synonym" mode="stemIt">
        <xsl:variable name="stemmedTerm">
            <xsl:call-template name="stemTerm">
                <xsl:with-param name="words" select="@term"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="stemmedVariants">
            <xsl:call-template name="stemVariants">
                <xsl:with-param name="words" select="variant"/>
            </xsl:call-template>
        </xsl:variable>
        <synonym>
            <xsl:attribute name="term" select="$stemmedTerm"/>
            <xsl:for-each select="distinct-values($stemmedVariants/variant)">
                <variant><xsl:value-of select="." /></variant>
            </xsl:for-each>
        </synonym>
    </xsl:template>
    
    <xsl:template match="synonym" mode="toJSON">
        <xsl:variable name="format" as="xs:string">"KEY":[VALUE]</xsl:variable>
        <xsl:variable name="variants">
            <xsl:apply-templates select="variant" mode="toJSON"/>
        </xsl:variable>
        <xsl:if test="not(position() = 1)">,</xsl:if>
        <xsl:value-of select="fn:JSONobj(@term,$variants,$format)"/>
    </xsl:template>
    
    <xsl:template match="variant" mode="toJSON">
        <xsl:if test="not(position() = 1)">,</xsl:if>
        <xsl:value-of select="fn:q(.)"/>
    </xsl:template>
    
    <xsl:template name="stemTerm">
        <xsl:param name="words"/>
        <xsl:param name="wordlist">
            <xsl:for-each select="tokenize(normalize-space($words),'\s+')">
                <word><xsl:value-of select="porter2:stem(.,$exceptionlist)"/></word>
            </xsl:for-each>
        </xsl:param>
        <xsl:for-each select="distinct-values($wordlist/word/text())">
            <xsl:value-of select="." />
            <xsl:if test="last()>position()"><xsl:text>_</xsl:text></xsl:if>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template name="stemVariants">
        <xsl:param name="words"/>
        <xsl:for-each select="$words">
            <variant><xsl:value-of select="porter2:stem(.,$exceptionlist)"/></variant>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template name="addStrings">
        <xsl:variable name="format" as="xs:string">KEY:"VALUE"</xsl:variable>
        <xsl:variable name="stringlist">
            <string name="searchdiv_aria_label"/>
            <string name="input_aria_label"/>
            <string name="input_placeholder"/>
            <string name="results_aria_label"/>
            <string name="results_no_results"/>
        </xsl:variable>
        <xsl:for-each select="$stringlist/string">
            <xsl:variable name="value">
                <xsl:call-template name="getVariable">
                    <xsl:with-param name="id" select="concat('ditasearch.',@name)"/>
                </xsl:call-template>
            </xsl:variable>
            <xsl:if test="not(position() = 1)">,</xsl:if>
            <xsl:value-of select="fn:JSONobj(@name,$value,$format)"/>
        </xsl:for-each>
    </xsl:template>
    
</xsl:stylesheet>