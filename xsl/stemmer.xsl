<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:fn="http://example.com/namespace"
    xmlns:porter2="http://example.com/namespace"
    exclude-result-prefixes="xs fn porter2"
    version="2.0">
    
    <xsl:import href="porter2.xsl"/>
    
    <xsl:import href="plugin:org.dita.base:xsl/common/output-message.xsl"/>
    <xsl:import href="plugin:org.dita.base:xsl/common/dita-utilities.xsl"/>
    
    <xsl:variable name="msgprefix">DS</xsl:variable>
    <xsl:param name="thisindextarget" />
    <xsl:param name="thisindexpath"/>
    <xsl:param name="OUTEXT" select="'.html'" />
    <xsl:param name="configfile" /><!-- generated search configs -->
    <xsl:param name="argsinputdir"/>
    <xsl:param name="thishref">
        <xsl:call-template name="replace-extension">
            <xsl:with-param name="filename"
                select="concat(fn:find-relative-path($argsinputdir,$thisindexpath),$thisindextarget)"/>
            <xsl:with-param name="extension" select="$OUTEXT"/>
        </xsl:call-template>
    </xsl:param>
    
    <xsl:function name="fn:find-relative-path" as="xs:string">
        <xsl:param name="basepath" as="xs:string"/>
        <xsl:param name="path" as="xs:string"/>
        <xsl:variable name="b" select="replace($basepath,'^/|/$','')"/>
        <xsl:variable name="p" select="replace($path,'^/|/$','')"/>
        <xsl:variable name="bend" select="fn:substring-after-last($b,'/')"/>
        <xsl:variable name="pstart" select="concat(fn:substring-before-last($p,$bend),$bend)"/>
        <xsl:variable name="pstart2" select="concat(fn:substring-before-last(fn:substring-before-last($p,$bend),$bend),$bend)"/>
        <xsl:choose>
            <xsl:when test="$p=('.','') or ends-with($b,$p)">
                <xsl:value-of select="''"/>
            </xsl:when>
            <xsl:when test="not($pstart='') and ends-with($b,$pstart)">
                <xsl:value-of select="concat(replace($p,concat($pstart,'/'),'','q'),'/')"/>
            </xsl:when>
            <xsl:when test="not($pstart2='') and ends-with($b,$pstart2)">
                <xsl:value-of select="concat(replace($p,concat($pstart2,'/'),'','q'),'/')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="concat($p,'/')"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="fn:substring-after-last" as="xs:string">
        <xsl:param name="arg1" as="xs:string"/>
        <xsl:param name="arg2" as="xs:string"/>
        <xsl:value-of select="tokenize($arg1,$arg2,'q')[last()]"/>
    </xsl:function>
    
    <xsl:function name="fn:substring-before-last" as="xs:string">
        <xsl:param name="arg1" as="xs:string"/>
        <xsl:param name="arg2" as="xs:string"/>
        <xsl:value-of select="string-join(reverse(subsequence(reverse(tokenize($arg1,$arg2,'q')),2)),$arg2)"/>
    </xsl:function>
    
    <xsl:param name="thisdir">
        <xsl:value-of select="concat(/processing-instruction('workdir-uri')[1],/processing-instruction('path2project-uri')[1])"/>
    </xsl:param>
    <xsl:param name="stemmer.debug" select="false()"/>
    
    <xsl:param name="classmaps">
        <classmap ditaclass=" topic/body " element="body" weight="1" />
        <classmap ditaclass=" topic/abstract " element="abstracts" weight="10"/>
        <classmap ditaclass=" topic/shortdesc " element="shortdesc" first="true" weight="15"/>
        <classmap ditaclass=" topic/keyword " element="keywords" weight="15"/>
        <classmap ditaclass=" topic/indexterm " element="indexterms" weight="15"/>
        <classmap ditaclass=" topic/title " element="titles" weight="7"/>
        <classmap ditaclass=" topic/title " element="firsttitle" first="true" weight="20" />
    </xsl:param>
    
    <xsl:output method="xml" encoding="UTF-8" omit-xml-declaration="yes" indent="yes"/>
    
    <!-- Static variables -->
    
    <xsl:variable name="searchconfigs">
        <xsl:copy-of select="document($configfile)"/>
    </xsl:variable>
    
    <xsl:variable name="stopwords" select="$searchconfigs/searchconfig/stopwords/text()"/>
    <xsl:variable name="exceptionlist">
        <xsl:copy-of select="$searchconfigs/searchconfig/exceptionalforms/exception"/>
    </xsl:variable>
    
    <xsl:variable name="classmapcount" select="count($classmaps/classmap)"/>
    
    <!-- 
        Possibly also add @locations:
            - for each stem instance, get its position in the topic after stop words are removed
            - divide the position by a resolution (say, 10 words) and make an integer
            - combine all the positions for each stem in a topic, removing duplicates
            This attribute would help prioritize topics where multiple terms are near each other
            (within +/- 1 of another stem's @location)
    -->
    
    <!-- === NODRAFT === -->
    
    <xsl:variable name="nodraft">
        <nodraft>
            <xsl:apply-templates select="/node()" mode="nodraft"/>
        </nodraft>
    </xsl:variable>
    
    <xsl:template match="*" mode="nodraft">
        <xsl:copy>
            <xsl:apply-templates select="node()|@class" mode="nodraft"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="text()" mode="nodraft">
        <!-- prestem -->
        <xsl:variable name="s1" select="lower-case(.)" />
        <!-- numeric "words" -->
        <xsl:variable name="s2a" select="replace($s1,'([0-9])[,\.]+([0-9])','$1$2')"/>
        <xsl:variable name="s2b" select="replace($s2a,'([0-9])[,\.]+([0-9])','$1$2')"/><!-- 2× to catch e.g., 1.5.4 without lookahead -->
        <xsl:variable name="s2c" select="replace($s2b,'([0-9][0-9,\.]*[0-9])',' $1 ')"/>
        <!-- digits2words -->
        <xsl:variable name="ones" select="replace(replace($s2c,'([a-z])1','$1one'),'1([a-z])','one$1')"/>
        <xsl:variable name="tos" select="replace(replace($ones,'([a-z])2','$1to'),'2([a-z])','to$1')"/>
        <xsl:variable name="fors" select="replace(replace($tos,'([a-z])4','$1for'),'4([a-z])','for$1')"/>
        <!-- strip non-word characters -->
        <xsl:variable name="s4" select='concat(" ",replace($fors,"[^a-z0-9&apos; ]"," ")," ")'/>
        <!-- strip stopwords -->
        <xsl:value-of select="normalize-space(replace($s4,concat('\s(',$stopwords,')\s'),' '))"/>
    </xsl:template>
    
    <xsl:template match="@class" mode="nodraft">
        <xsl:copy></xsl:copy>
    </xsl:template>
    
    <!-- remove stuff -->
    <xsl:template match="*[contains(@class,' topic/related-links ')]" mode="nodraft"></xsl:template>
    <xsl:template match="*[contains(@class,' topic/draft-comment ')]" mode="nodraft topicSummary"></xsl:template>
    <xsl:template match="*[contains(@class,' topic/required-cleanup ')]" mode="nodraft topicSummary"></xsl:template>
    <xsl:template match="processing-instruction()" mode="nodraft topicSummary"></xsl:template>
    <xsl:template match="comment()" mode="nodraft topicSummary"></xsl:template>
    
    
    <!-- === PARSE CLASSMAPS === -->
    
    <xsl:variable name="parseclassmaps">
        <xsl:call-template name="loop_through_classmaps"/>
    </xsl:variable>
    
    <xsl:template name="loop_through_classmaps">
        <xsl:param name="classmapcounter" select="$classmapcount"/>
        <xsl:param name="thisweight" select="$classmaps/classmap[position()=$classmapcounter]/@weight"/>
        <xsl:param name="thisclass" select="$classmaps/classmap[position()=$classmapcounter]/@ditaclass"/>
        <xsl:param name="thisfirst" select="$classmaps/classmap[position()=$classmapcounter]/@first or false()"/>
        <xsl:if test="not($classmapcounter = 0)">
            <xsl:choose>
                <xsl:when test="$thisfirst">
                    <xsl:apply-templates mode="getText" select="($nodraft//*[contains(@class,$thisclass)])[1]">
                        <xsl:with-param name="thisweight" select="$thisweight"/>
                    </xsl:apply-templates>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates mode="getText" select="$nodraft//*[contains(@class,$thisclass)]">
                        <xsl:with-param name="thisweight" select="$thisweight"/>
                    </xsl:apply-templates>
                </xsl:otherwise>
            </xsl:choose>
            <!-- Oops! I did it again. -->
            <xsl:call-template name="loop_through_classmaps">
                <xsl:with-param name="classmapcounter">
                    <xsl:value-of select="$classmapcounter - 1"/>
                </xsl:with-param>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>
    
    <xsl:template mode="getText" match="*">
        <xsl:param name="thisweight"/>
        <xsl:apply-templates mode="getTextChildren" select="*|text()">
            <xsl:with-param name="thisweight" select="$thisweight"/>
        </xsl:apply-templates>
    </xsl:template>
    
    <xsl:template mode="getTextChildren" match="*">
        <xsl:param name="thisweight"/>
        <xsl:apply-templates mode="getTextChildren" select="*|text()">
            <xsl:with-param name="thisweight" select="$thisweight"/>
        </xsl:apply-templates>
    </xsl:template>
    
    <xsl:template mode="getTextChildren" match="text()">
        <xsl:param name="thisweight"/>
        <xsl:param name="textwordlist" select="tokenize(.,'\s+')"/>
        <xsl:for-each select="$textwordlist">
            <word>
                <xsl:attribute name="weight" select="$thisweight"/>
                <xsl:value-of select="."/>
            </word>
        </xsl:for-each>
    </xsl:template>
    
    <!-- === STEMMER === -->
    
    <xsl:variable name="stems">
        <stems>
            <xsl:apply-templates select="$parseclassmaps//word" mode="getStems"/>
        </stems>
    </xsl:variable>
    
    <xsl:template match="*" mode="getStems">
        
        <xsl:param name="word" select="lower-case(./text())"/>
        <xsl:param name="stem">
            <xsl:choose>
                <xsl:when test="matches($word,'^[0-9]+$')">
                    <xsl:value-of select="$word"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="porter2:stem($word,$exceptionlist)"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:param>
        
        <stem>
            <xsl:attribute name="value" select="$stem"/>
            <xsl:attribute name="weight" select="./@weight"/>
            <xsl:attribute name="word" select="$word"/>
            <xsl:if test="$stemmer.debug">
                <xsl:message>
                    <xsl:value-of select="concat(substring(concat(./text(),'                                                  '),1,50),$stem)"/>
                </xsl:message>
            </xsl:if>
        </stem>
    </xsl:template>
    
    
    <!-- === COMBINE STEMS FOR TOPIC === -->
    
    <xsl:variable name="allstems">
        <xsl:apply-templates select="$stems" mode="combinestems"/>
    </xsl:variable>
    
    <xsl:template match="//stems" mode="combinestems">
        <xsl:for-each-group select="//stem" group-by="@value">
            <xsl:sort select="@value"/>
            <stem>
                <xsl:attribute name="value" select="current-grouping-key()"/>
                <xsl:attribute name="score" select="sum(current-group()/@weight)"/>
                <xsl:attribute name="href" select="$thishref"/>
                <xsl:attribute name="words" select="string-join(distinct-values(current-group()/@word),',')"/>
                <xsl:if test="$stemmer.debug">
                    <xsl:attribute name="tbs" select="string-join(current-group()/@tbs,',')"/>
                </xsl:if>
            </stem>
        </xsl:for-each-group>
    </xsl:template>
    
    <!-- === GET TOPIC SUMMARY INFO === -->
    
    <xsl:template match="*[contains(@class,' topic/topic ')]" mode="topicSummary">
        <xsl:variable name="schtitle"><xsl:apply-templates select="*[contains(@class, ' topic/titlealts ')]/*[contains(@class, ' topic/searchtitle ')]" mode="topicSummary"/></xsl:variable>
        <xsl:variable name="maintitle"><xsl:apply-templates select="*[contains(@class, ' topic/title ')]" mode="topicSummary"/></xsl:variable>
        <xsl:variable name="mapschtitle"><xsl:apply-templates select="*[contains(@class, ' topic/titlealts ')]/*[contains(@class, ' map/searchtitle ')]" mode="topicSummary"/></xsl:variable>
        <xsl:variable name="searchTitle">
            <xsl:choose>
                <xsl:when test="string-length($schtitle)> 0"><xsl:value-of select="normalize-space($schtitle)"/></xsl:when>
                <xsl:when test="string-length($mapschtitle)> 0"><xsl:value-of select="normalize-space($mapschtitle)"/></xsl:when>
                <xsl:when test="string-length($maintitle) > 0"><xsl:value-of select="normalize-space($maintitle)"/></xsl:when>
                <xsl:otherwise><xsl:text>[No Title]</xsl:text></xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="shortDesc"><xsl:apply-templates select="(.//*[contains(@class, ' topic/shortdesc ')])[1]" mode="topicSummary"/></xsl:variable>
        <topicSummary>
            <xsl:attribute name="href" select="$thishref"/>
            <xsl:attribute name="searchtitle" select="$searchTitle"/>
            <xsl:attribute name="shortdesc" select="$shortDesc"/>
        </topicSummary>
    </xsl:template>
    
    <xsl:template match="*" mode="topicSummary">
        <xsl:apply-templates select="node()|text()" mode="topicSummary"/>
    </xsl:template>
    
    <xsl:template match="text()" mode="topicSummary">
        <xsl:value-of select="replace(replace(.,'\s+',' '),'&quot;','&#x201c;')"/>
    </xsl:template>
    
    <xsl:template match="*[contains(@class,' topic/xref ')] | *[contains(@class,' topic/keyword ')]" 
        mode="topicSummary">
        <xsl:choose>
            <xsl:when test="string-length(normalize-space(string-join(.//text(),''))) > 0">
                <xsl:apply-templates select="node()|text()" mode="topicSummary"/>
            </xsl:when>
            <xsl:when test="string-length(./@href) > 0 and not(contains(./@href,'://'))">
                <!-- resolve title of referenced topic -->
                <xsl:value-of select="document(concat($thisdir, ./@href))//*[contains(@class, ' topic/topic ')][1]/*[contains(@class, ' topic/title ')]"/>
            </xsl:when>
            <xsl:otherwise>
                <!-- warn user that it's not being resolved -->
                <xsl:call-template name="output-message">
                    <xsl:with-param name="id">DS01</xsl:with-param>
                    <xsl:with-param name="msgparams">%1=<xsl:value-of select="$thisindextarget"/>;%2=<xsl:value-of select="./@href"/></xsl:with-param>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="*[contains(@class,' topic/desc ')]" mode="topicSummary">
        <!-- don't include in indexed short description -->
    </xsl:template>
    
    <!-- === OUTPUT === -->
    
    <xsl:template match="/*"><!-- if nested topics, treat as one unit -->
        <!-- problems to figure out (maybe all handled with preprocessing?):
            * topics not in flat output file structure
            * copy-to 
            * topics used as resource
             -->
        <xsl:copy-of select="$allstems"/>
        <xsl:apply-templates select="(/*[contains(@class,' topic/topic ')] | /dita/*[contains(@class,' topic/topic ')])[1]" mode="topicSummary"/>
    </xsl:template>
    
</xsl:stylesheet>