<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:porter2="http://example.com/namespace"
    exclude-result-prefixes="xs porter2"
    version="2.0">
    
    <!-- Variables -->
    
    <xsl:variable name="porter2:apos">'</xsl:variable>
    
    <xsl:variable name="porter2:nonwordchars">[^a-z']</xsl:variable>
    
    <xsl:variable name="porter2:exceptionlist">
        <exception word="skis" stem="ski" />
        <exception word="skies" stem="sky" />
        <exception word="dying" stem="die" />
        <exception word="lying" stem="lie" />
        <exception word="tying" stem="tie" />
        <exception word="idly" stem="idl" />
        <exception word="gently" stem="gentl" />
        <exception word="ugly" stem="ugli" />
        <exception word="early" stem="earli" />
        <exception word="only" stem="onli" />
        <exception word="singly" stem="singl" />
        <!-- don't change -->
        <exception word="sky" stem="sky" />
        <exception word="news" stem="news" />
        <exception word="howe" stem="howe" />
        <exception word="atlas" stem="atlas" />
        <exception word="cosmos" stem="cosmos" />
        <exception word="bias" stem="bias" />
        <exception word="andes" stem="andes" />
    </xsl:variable>
    
    <xsl:variable name="porter2:post_s1a_exceptions">
        <exception word="inning" stem="inning" />
        <exception word="outing" stem="outing" />
        <exception word="canning" stem="canning" />
        <exception word="herring" stem="herring" />
        <exception word="earring" stem="earring" />
        <exception word="proceed" stem="proceed" />
        <exception word="exceed" stem="exceed" />
        <exception word="succeed" stem="succeed" />
    </xsl:variable>
    
    <xsl:variable name="porter2:s0_sfxs">('|'s|'s')$</xsl:variable>
    
    <xsl:variable name="porter2:s1a_replacements">
        <replacements>
            <!-- ordered longest to shortest -->
            <replace suffix="sses" with="ss"/>
            <replace suffix="ied" with="i|ie" complexrule="s1a"/>
            <replace suffix="ies" with="i|ie" complexrule="s1a"/>
            <replace suffix="us" with="us"/>
            <replace suffix="ss" with="ss"/>
            <replace suffix="s" with="" ifprecededby="[aeiouy].+"/>
        </replacements>
    </xsl:variable>
    
    <xsl:variable name="porter2:s1b_replacements">
        <replacements>
            <!-- ordered longest to shortest -->
            <replace suffix="eedly" with="ee" ifin="R1"/>
            <replace suffix="ingly" with="" ifprecededby="[aeiouy].*" complexrule="s1b"/>
            <replace suffix="edly" with="" ifprecededby="[aeiouy].*" complexrule="s1b"/>
            <replace suffix="eed" with="ee" ifin="R1"/>
            <replace suffix="ing" with="" ifprecededby="[aeiouy].*" complexrule="s1b"/>
            <replace suffix="ed" with="" ifprecededby="[aeiouy].*" complexrule="s1b"/>
        </replacements>
    </xsl:variable>
    
    <xsl:variable name="porter2:s2_replacements">
        <replacements>
            <!-- ordered longest to shortest -->
            <replace suffix="ational" with="ate" ifin="R1" />
            <replace suffix="ization" with="ize"  ifin="R1" />
            <replace suffix="fulness" with="ful"  ifin="R1" />
            <replace suffix="ousness" with="ous"  ifin="R1" />
            <replace suffix="iveness" with="ive"  ifin="R1" />
            <replace suffix="tional" with="tion" ifin="R1" />
            <replace suffix="biliti" with="ble"  ifin="R1" />
            <replace suffix="lessli" with="less"  ifin="R1" />
            <replace suffix="entli" with="ent"  ifin="R1" />
            <replace suffix="ation" with="ate"  ifin="R1" />
            <replace suffix="alism" with="al"  ifin="R1" />
            <replace suffix="aliti" with="al"  ifin="R1" />
            <replace suffix="ousli" with="ous"  ifin="R1" />
            <replace suffix="iviti" with="ive"  ifin="R1" />
            <replace suffix="fulli" with="ful"  ifin="R1" />
            <replace suffix="enci" with="ence" ifin="R1" />
            <replace suffix="anci" with="ance" ifin="R1" />
            <replace suffix="abli" with="able" ifin="R1" />
            <replace suffix="izer" with="ize"  ifin="R1" />
            <replace suffix="ator" with="ate"  ifin="R1" />
            <replace suffix="alli" with="al"  ifin="R1" />
            <replace suffix="bli" with="ble"  ifin="R1" />
            <replace suffix="ogi" with="og" ifin="R1" ifprecededby="l" />
            <replace suffix="li" with="" ifin="R1" ifprecededby="[cdeghkmnrt]" />
        </replacements>
    </xsl:variable>
    
    <xsl:variable name="porter2:s3_replacements">
        <replacements>
            <!-- ordered longest to shortest -->
            <replace suffix="ational" with="ate" ifin="R1" />
            <replace suffix="tional" with="tion" ifin="R1" />
            <replace suffix="alize" with="al" ifin="R1" />
            <replace suffix="ative" with="" ifin="R1,R2" />
            <replace suffix="icate" with="ic" ifin="R1" />
            <replace suffix="iciti" with="ic" ifin="R1" />
            <replace suffix="ical" with="ic" ifin="R1" />
            <replace suffix="ness" with="" ifin="R1" />
            <replace suffix="ful" with="" ifin="R1" />
        </replacements>
    </xsl:variable>
    
    <xsl:variable name="porter2:s4_replacements">
        <replacements>
            <!-- ordered longest to shortest -->
            <replace suffix="ement" with="" ifin="R2" />
            <replace suffix="ance" with="" ifin="R2" />
            <replace suffix="ence" with="" ifin="R2" />
            <replace suffix="able" with="" ifin="R2" />
            <replace suffix="ible" with="" ifin="R2" />
            <replace suffix="ment" with="" ifin="R2" />
            <replace suffix="ant" with="" ifin="R2" />
            <replace suffix="ate" with="" ifin="R2" />
            <replace suffix="ent" with="" ifin="R2" />
            <replace suffix="ion" with="" ifin="R2" ifprecededby="[st]"/>
            <replace suffix="ism" with="" ifin="R2" />
            <replace suffix="iti" with="" ifin="R2" />
            <replace suffix="ive" with="" ifin="R2" />
            <replace suffix="ize" with="" ifin="R2" />
            <replace suffix="ous" with="" ifin="R2" />
            <replace suffix="ic" with="" ifin="R2" />
            <replace suffix="er" with="" ifin="R2" />
            <replace suffix="al" with="" ifin="R2" />
        </replacements>
    </xsl:variable>
    
    <xsl:variable name="porter2:s5_replacements">
        <replacements>
            <!-- ordered longest to shortest -->
            <replace suffix="e" with="" complexrule="s5"/>
            <replace suffix="l" with="" ifin="R2" ifprecededby="l"/>
        </replacements>
    </xsl:variable>
    
    <!-- Functions -->
    
    <xsl:function name="porter2:R1" as="xs:string">
        <xsl:param name="thisword" as="xs:string"/>
        <xsl:choose>
            <xsl:when test="matches($thisword,'^(gener|commun|arsen)')">   <!-- exceptions -->
                <xsl:value-of select="replace($thisword,'^(gener|commun|arsen)','')"/>
            </xsl:when>
            <xsl:when test="matches($thisword,'^.*?[aeiouy][^aeiouy]')">
                <xsl:value-of  select="replace($thisword,'^.*?[aeiouy][^aeiouy]','')"/>
            </xsl:when>
            <xsl:otherwise><xsl:text></xsl:text></xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="porter2:R2base" as="xs:string">
        <xsl:param name="thisword" as="xs:string"/>
        <xsl:choose>
            <xsl:when test="matches($thisword,'^.*?[aeiouy][^aeiouy]')">
                <xsl:value-of  select="replace($thisword,'^.*?[aeiouy][^aeiouy]','')"/>
            </xsl:when>
            <xsl:otherwise><xsl:text></xsl:text></xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="porter2:R2" as="xs:string">
        <xsl:param name="thisword" as="xs:string"/>
        <xsl:value-of select="porter2:R2base(porter2:R1($thisword))"/>
    </xsl:function>
    
    <xsl:function name="porter2:endsWithShortSyllable" as="xs:boolean">
        <xsl:param name="thisword" as="xs:string"/>
        <xsl:value-of select="(matches($thisword,'[^aeiouy][aeiouy][^aeiouywxY]$') or matches($thisword,'^[aeiouy][^aeiouy]$'))"/>
    </xsl:function>
    
    <xsl:function name="porter2:isShort" as="xs:boolean">
        <xsl:param name="thisword" as="xs:string"/>
        <xsl:value-of 
            select="string-length(porter2:R1($thisword))=0 and porter2:endsWithShortSyllable($thisword)"/>
    </xsl:function>
    
    <xsl:function name="porter2:stem" as="xs:string">
        <xsl:param name="thisword" as="xs:string"/>
        <xsl:call-template name="porter2:stemOrException">
            <xsl:with-param name="word" select="replace(lower-case($thisword),$porter2:nonwordchars,'')"/>
        </xsl:call-template>
    </xsl:function>
    
    <xsl:function name="porter2:stem" as="xs:string">
        <xsl:param name="thisword" as="xs:string"/>
        <xsl:param name="customexceptions" />
        <xsl:call-template name="porter2:stemOrException">
            <xsl:with-param name="word" select="replace(lower-case($thisword),$porter2:nonwordchars,'')"/>
            <xsl:with-param name="exceptionlist" select="$customexceptions"/>
        </xsl:call-template>
    </xsl:function>
    
    <!-- Templates -->
    
    <xsl:template name="porter2:stemOrException">
        
        <xsl:param name="word" />
        <xsl:param name="exceptionlist" select="$porter2:exceptionlist"/>
        <xsl:param name="exceptionstem" select="$exceptionlist/exception[@word=$word][1]/@stem"/>
        
        <xsl:choose>
            <xsl:when test="string-length($word) &lt;= 2">
                <xsl:value-of select="$word"/>
            </xsl:when>
            <xsl:when test="string-length($exceptionstem)!=0">
                <xsl:value-of select="$exceptionstem"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="porter2:getStem">
                    <xsl:with-param name="word" select="$word"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
        
    </xsl:template>
    
    
    <xsl:template name="porter2:getStem">
        
        <xsl:param name="word"/>
        
        <xsl:param name="noinitpostrophes" select="replace($word,concat('^',$porter2:apos),'')"/>
        
        <xsl:param name="consonantY" select="replace($noinitpostrophes,'(^|[aeiouy])y','$1Y')"/>
        
        <xsl:param name="s0" select="replace($consonantY,$porter2:s0_sfxs,'')"/>
        
        <xsl:param name="s1a">
            <xsl:apply-templates select="$porter2:s1a_replacements" mode="porter2:replace_suffix">
                <xsl:with-param name="thisword" select="$s0"/>
            </xsl:apply-templates>
        </xsl:param>
        
        <xsl:param name="s1b">
            <xsl:apply-templates select="$porter2:s1b_replacements" mode="porter2:replace_suffix">
                <xsl:with-param name="thisword" select="$s1a"/>
            </xsl:apply-templates>
        </xsl:param>
        
        <xsl:param name="s1c">
            <xsl:value-of select="replace($s1b,'(.[^aeiouy])[yY]$','$1i')"/>
        </xsl:param>
        
        <xsl:param name="s2">
            <xsl:apply-templates select="$porter2:s2_replacements" mode="porter2:replace_suffix">
                <xsl:with-param name="thisword" select="$s1c"/>
            </xsl:apply-templates>
        </xsl:param>
        
        <xsl:param name="s3">
            <xsl:apply-templates select="$porter2:s3_replacements" mode="porter2:replace_suffix">
                <xsl:with-param name="thisword" select="$s2"/>
            </xsl:apply-templates>
        </xsl:param>
        
        <xsl:param name="s4">
            <xsl:apply-templates select="$porter2:s4_replacements" mode="porter2:replace_suffix">
                <xsl:with-param name="thisword" select="$s3"/>
            </xsl:apply-templates>
        </xsl:param>
        
        <xsl:param name="s5">
            <xsl:apply-templates select="$porter2:s5_replacements" mode="porter2:replace_suffix">
                <xsl:with-param name="thisword" select="$s4"/>
            </xsl:apply-templates>
        </xsl:param>
        
        <xsl:param name="post_s1a_exception" select="$porter2:post_s1a_exceptions/exception[@word=$s1a][1]/@stem"/>
        
        <xsl:value-of select="($post_s1a_exception,lower-case($s5))[1]"/>
        
    </xsl:template>

    <xsl:template mode="porter2:replace_suffix" match="//replacements">
        <xsl:param name="thisword" as="xs:string"/>
        <xsl:param name="replace" select="./replace[matches($thisword,concat(@suffix,'$'))][1]"/>
        <xsl:param name="restrictions">
            <xsl:if test="contains($replace/@ifin,'R1')"><xsl:text>R1</xsl:text></xsl:if>
            <xsl:if test="contains($replace/@ifin,'R2')"><xsl:text>R2</xsl:text></xsl:if>
            <xsl:if test="string-length($replace/@ifprecededby)>0"><xsl:text>PrecededBy</xsl:text></xsl:if>
            <xsl:if test="string-length($replace/@complexrule)>0">
                <xsl:value-of select="concat('ComplexRule_',$replace/@complexrule)"/>
            </xsl:if>
        </xsl:param>
        <xsl:param name="precededsuffix" select="concat($replace/@ifprecededby,$replace/@suffix,'$')"/>
        <xsl:param name="suffix" select="concat($replace/@suffix,'$')"/>
        
        <xsl:choose>
            <xsl:when test="0=count($replace)"><!-- no matches -->
                <xsl:value-of select="$thisword"/>
            </xsl:when>
            
            <!-- no restrictions -->
            <xsl:when test="string-length($restrictions)=0">
                <xsl:value-of select="replace($thisword,$suffix,$replace/@with)"/>
            </xsl:when>
            
            <!-- restrictions -->
            <xsl:when test="$restrictions='R1' and matches(porter2:R1($thisword),$suffix)">
                <xsl:value-of select="replace($thisword,$suffix,$replace/@with)"/>
            </xsl:when>
            
            <xsl:when test="$restrictions='R2' and matches(porter2:R2($thisword),$suffix)">
                <xsl:value-of select="replace($thisword,$suffix,$replace/@with)"/>
            </xsl:when>
            
            <xsl:when test="$restrictions='R1R2' and matches(porter2:R1($thisword),$suffix) and matches(porter2:R2($thisword),$suffix)">
                <xsl:value-of select="replace($thisword,$suffix,$replace/@with)"/>
            </xsl:when>
            
            <xsl:when test="$restrictions='PrecededBy' and matches($thisword,$precededsuffix)">
                <xsl:value-of select="replace($thisword,$suffix,$replace/@with)"/>
            </xsl:when>
            
            <xsl:when test="$restrictions='R1PrecededBy' and matches($thisword,$precededsuffix) and matches(porter2:R1($thisword),$suffix)">
                <xsl:value-of select="replace($thisword,$suffix,$replace/@with)"/>
            </xsl:when>
            
            <xsl:when test="$restrictions='R2PrecededBy' and matches($thisword,$precededsuffix) and matches(porter2:R2($thisword),$suffix)">
                <xsl:value-of select="replace($thisword,$suffix,$replace/@with)"/>
            </xsl:when>
            
            <!-- complex rules -->
            
            <xsl:when test="$restrictions='ComplexRule_s1a'">
                <xsl:choose>
                    <xsl:when test="matches($thisword,concat('..',$suffix))">
                        <xsl:value-of select="replace($thisword,$suffix,'i')"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="replace($thisword,$suffix,'ie')"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            
            <xsl:when test="$restrictions='PrecededByComplexRule_s1b' and matches($thisword,$precededsuffix)">
                <xsl:choose>
                    <xsl:when test="matches($thisword,concat('(at|bl|iz)',$suffix))">
                        <xsl:value-of select="replace($thisword,$suffix,'e')"/>
                    </xsl:when>
                    <xsl:when test="matches($thisword,concat('(bb|dd|ff|gg|mm|nn|pp|rr|tt)',$suffix))">
                        <xsl:value-of select="replace($thisword,concat('.',$suffix),'')"/>
                    </xsl:when>
                    <xsl:when test="porter2:isShort(replace($thisword,$suffix,''))">
                        <xsl:value-of select="replace($thisword,$suffix,'e')"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="replace($thisword,$suffix,'')"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            
            <xsl:when test="$restrictions='ComplexRule_s5' and matches(porter2:R2($thisword),$suffix)">
                <xsl:value-of select="replace($thisword,$suffix,'')"/>
            </xsl:when>
            
            <xsl:when test="$restrictions='ComplexRule_s5' and matches(porter2:R1($thisword),$suffix) and not(porter2:endsWithShortSyllable(replace($thisword,$suffix,'')))">                 
                <xsl:value-of select="replace($thisword,$suffix,'')"/>
            </xsl:when>
            
            <xsl:otherwise>
                <xsl:value-of select="$thisword"/>
            </xsl:otherwise>
        </xsl:choose>
        
    </xsl:template>
    
</xsl:stylesheet>