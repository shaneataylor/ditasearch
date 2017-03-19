<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <xsl:import href="plugin:org.dita.base:xsl/common/output-message.xsl"/>
    <xsl:import href="plugin:org.dita.base:xsl/common/dita-utilities.xsl"/>
    
    <xsl:variable name="msgprefix">DS</xsl:variable><!-- needed if not really functional -->
    <xsl:param name="configfile" select="''" as="xs:string"/>
    <xsl:param name="configfilefound" select="'false'" as="xs:string" />
    
    <xsl:output method="xml" encoding="UTF-8" omit-xml-declaration="yes" indent="yes"/>
    
    <xsl:variable name="userconfigs">
        <xsl:choose>
            <xsl:when test="$configfilefound = 'true'">
                <xsl:copy-of select="document($configfile)"/>
            </xsl:when>
            <xsl:otherwise><searchconfig nodata="true"/></xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    
    <xsl:template match="/">
        <xsl:choose>
            <xsl:when test="$userconfigs/searchconfig/@useDefaultConfigs='addToDefault'">
                <xsl:call-template name="output-message">
                    <xsl:with-param name="id">DS03</xsl:with-param>
                    <xsl:with-param name="msgparams">%1=<xsl:value-of select="$configfile"/></xsl:with-param>
                </xsl:call-template>
                <searchconfig>
                    <stopwords>
                        <xsl:apply-templates mode="getstopwords" 
                            select="$userconfigs/searchconfig/stopwords/stopword | /searchconfig/stopwords/stopword"/>
                    </stopwords>
                    <exceptionalforms>
                        <xsl:copy-of select="$userconfigs/searchconfig/exceptionalforms/exception"/>
                        <xsl:copy-of select="/searchconfig/exceptionalforms/exception"/>
                    </exceptionalforms>
                    <synonyms>
                        <xsl:copy-of select="$userconfigs/searchconfig/synonyms/synonym"/>
                        <xsl:copy-of select="/searchconfig/synonyms/synonym"/>
                    </synonyms>
                </searchconfig>
            </xsl:when>
            <xsl:when test="$userconfigs/searchconfig/@useDefaultConfigs='replaceDefault'">
                <xsl:call-template name="output-message">
                    <xsl:with-param name="id">DS04</xsl:with-param>
                    <xsl:with-param name="msgparams">%1=<xsl:value-of select="$configfile"/></xsl:with-param>
                </xsl:call-template>
                <searchconfig>
                    <stopwords>
                        <xsl:apply-templates mode="getstopwords" 
                            select="$userconfigs/searchconfig/stopwords/stopword"/>
                    </stopwords>
                    <xsl:copy-of select="$userconfigs/searchconfig/exceptionalforms"/>
                    <xsl:copy-of select="$userconfigs/searchconfig/synonyms"/>
                </searchconfig>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="output-message">
                    <xsl:with-param name="id">DS05</xsl:with-param>
                    <xsl:with-param name="msgparams">params</xsl:with-param>
                </xsl:call-template>
                <searchconfig>
                    <stopwords>
                        <xsl:apply-templates mode="getstopwords" 
                            select="/searchconfig/stopwords/stopword"/>
                    </stopwords>
                    <xsl:copy-of select="/searchconfig/exceptionalforms"/>
                    <xsl:copy-of select="/searchconfig/synonyms"/>
                </searchconfig>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- === PARSE STOPWORDS === -->
    <xsl:template mode="getstopwords" match="stopword">
        <xsl:value-of select="."/>
        <xsl:if test="not(position()=last())">
            <xsl:text>|</xsl:text>
        </xsl:if>
    </xsl:template>
    
</xsl:stylesheet>