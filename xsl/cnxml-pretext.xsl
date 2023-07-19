<?xml version='1.0'?>

<!--********************************************************************
Copyright 2014-2016 Robert A. Beezer

This file is part of MathBook XML.

MathBook XML is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 2 or version 3 of the
License (at your option).

MathBook XML is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with MathBook XML.  If not, see <http://www.gnu.org/licenses/>.
*********************************************************************-->

<!-- This stylesheet does nothing but traverse the tree         -->
<!-- Possible restricting to a subtree based on xml:id          -->
<!-- An importing stylesheet can concentrate on a specific task -->
<!-- It does define a "scratch" directory for placing output    -->
<!-- to presumably be process further by external program       -->

<!-- Define a namespace for the default CNXML elements, -->
<!-- and use it in subsequent match expressions (cn)    -->
<!-- See http://www.tek-tips.com/faqs.cfm?fid=1188      -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
                xmlns:xi="http://www.w3.org/2001/XInclude"
                xmlns:cnx="http://cnx.rice.edu/cnxml"
                xmlns:col="http://cnx.rice.edu/collxml"
                xmlns:md="http://cnx.rice.edu/mdml"
                xmlns:m="http://www.w3.org/1998/Math/MathML"
                xmlns:exsl="http://exslt.org/common"
                extension-element-prefixes="exsl"
    >

<!-- <xsl:import href="/home/rob/mathbook/local/openstax-convert/mathml/mmltex.xsl"/> -->

<xsl:output method="xml" encoding="UTF-8" />

<xsl:strip-space elements="col:content" />

<!-- Templates matching elements of collection.xml -->

<!-- A collection is like an entire book -->
<xsl:template match="col:collection">
    <exsl:document href="index.xml" method="html" indent="yes" encoding="UTF-8">
        <pretext>
            <!-- PTX "objectives" will work like CNXML "summary" -->
            <docinfo>
                <rename element="objectives" lang="en-US">Summary</rename>
                <rename element="question" lang="en-US">Be Prepared!</rename>
            </docinfo>
            <book>
                <frontmatter>
                    <titlepage>
                    </titlepage>
                </frontmatter>
                <xsl:apply-templates select="col:metadata/md:title" />
                <xsl:apply-templates select="col:content" />
            </book>
        </pretext>
    </exsl:document>
</xsl:template>

<!-- A subcollection is like a chapter    -->
<!-- Its divisions are modules, see below -->
<xsl:template match="col:subcollection">
    <xsl:comment>
        <xsl:apply-templates select="md:title" />
    </xsl:comment>
    <xsl:text>&#xa;</xsl:text>
    <chapter>
        <xsl:text>&#xa;</xsl:text>
        <xsl:apply-templates select="md:title" />
        <xsl:text>&#xa;</xsl:text>
        <xsl:apply-templates select="col:content" />
    </chapter>
    <xsl:text>&#xa;</xsl:text>
</xsl:template>

<xsl:template match="md:title">
    <title>
        <xsl:apply-templates />
    </title>
</xsl:template>

<xsl:template match="col:content">
    <xsl:apply-templates />
</xsl:template>

<!-- Track relationships between CNXML input    -->
<!-- source and PTX output source by the module -->
<!-- identifier used in CNXML directories and   -->
<!-- thus in PTX modular files                  -->
<xsl:template match="col:module">
    <!-- mXXXXX is the id of a module -->
    <xsl:variable name="module-id" select="@document" />
    <xsl:variable name="ptxsectionfilename" select="concat(module-id, '.xml')" />
    <!-- First create an include for the module file -->
    <xi:include href="{ptxsectionfilename}" />
    <xsl:text>&#xa;</xsl:text>
    <!-- Now create the file itself -->
    <!-- NB: the second argument is simply a node, it causes -->
    <!-- osmodulefilename to be interpreted relative to the -->
    <!-- location of the *current XML file* (collection.xml) -->
    <!-- rather than the location of the *stylesheet*.       -->
    <!-- The actual node does not seem so critical.          -->
    <!-- This places the entire module file into a variable  -->
    <!-- so we can apply-templates on its contents           -->
    <xsl:variable name="osmodulefilename" select="concat(module-id, '/index.cnxml')" />
    <xsl:variable name="module" select="document(osmodulefilename, .)" />
    <!-- The module variable has a root, then   -->
    <!-- below that is the CNXML "document" node -->
    <!-- We write the processed module file into -->
    <!-- the same file as the target of the      -->
    <!-- previous xi:include                     -->
    <exsl:document href="{ptxsectionfilename}" method="html" indent="yes" encoding="UTF-8">
        <xsl:apply-templates select="module/cnx:document" />
    </exsl:document>
</xsl:template>

<!-- CNXML module file, mXXXXX/index.cnxml -->
<!-- Analouge of a PTX "section"           -->

<!-- A module that is titled "Introduction" is a lead-in   -->
<!-- to a chapter, preceding other module files that will  -->
<!-- become PTX sections. Purposely, we skip the title     -->
<!-- CNXML does not number them, so use PTX "introduction" -->
<xsl:template match="cnx:document[cnx:title = 'Introduction']">
    <introduction>
        <!-- Each introduction is a module file and has a document number. -->
        <!-- We use this as the @xml:id since cross-references use this.   -->
        <xsl:attribute name="xml:id">
            <xsl:apply-templates select="cnx:metadata/md:content-id/text()" />
        </xsl:attribute>
        <xsl:apply-templates select="cnx:content" />
        <!-- footer with license terms here? -->
    </introduction>
</xsl:template>

<!-- A module file is a PTX section, its outermost element is   -->
<!-- "document", so this is the entry template for the majority -->
<!-- of CNXML files.  We use a script to pipe output, though    -->
<!-- we could get the content-id and use exsl:document          -->
<xsl:template match="cnx:document">
    <!-- Licensing info varies by module file       -->
    <!-- We save off various bits here in variables -->
    <!-- for reuse in Attribution footer            -->
    <!-- eg, http://cnx.org/content/col11966/1.2    -->
    <xsl:variable name="content-url" select="cnx:metadata/md:content-url/text()" />
    <!-- eg, <md:license url="http://creativecommons.org/licenses/by-nc-sa/4.0/">       -->
    <!-- Creative Commons Attribution-NonCommercial-ShareAlike License 4.0</md:license> -->
    <xsl:variable name="license-url" select="cnx:metadata/md:license/@url" />
    <xsl:variable name="license-text" select="cnx:metadata/md:license/text()" />

    <section>
        <!-- Each section is a module file and has a document number.    -->
        <!-- We use this as the @xml:id since cross-references use this. -->
        <xsl:attribute name="xml:id">
            <xsl:apply-templates select="cnx:metadata/md:content-id/text()" />
        </xsl:attribute>
        <xsl:apply-templates select="cnx:title" />
        <!-- get objectives here from metadata/abstract -->
        <xsl:apply-templates select="cnx:content" />
        <!-- move to some named template? -->
        <conclusion>
            <xsl:variable name="new-terms">
                <xsl:text>Modifications made for the derivative </xsl:text>
                <pretext />
                <xsl:text> version are </xsl:text>
                <copyright />
                <xsl:text> 2018 Robert A. Beezer</xsl:text>
                <!-- respect ShareAlike clause, or not -->
                <xsl:if test="contains(license-text, 'ShareAlike')">
                    <xsl:text>, and distributed with a </xsl:text>
                    <xsl:value-of select="license-text" />
                    <xsl:text> license</xsl:text>
                </xsl:if>
                <xsl:text>.</xsl:text>
            </xsl:variable>

            <!-- required attribution -->
            <p>Original OpenStax book is available for free at <c><xsl:value-of select="content-url" /></c>, and is distributed with a <xsl:value-of select="license-text" /> license.</p>
            <!-- variable new terms -->
            <p>
                <xsl:copy-of select="new-terms" />
            </p>
        </conclusion>
    </section>
</xsl:template>


<!-- module file (a PTX section of a chapter) has:   -->
<!--   * summary/objectives in leading metadata      -->
<!--   * "content" with                              -->
<!--     - some unstructured introductory paragraphs -->
<!--     - "section", with final full of exercises   -->
<!--     - a "section" being a PTX "subsection"      -->
<!--   * glossary                                    -->
<xsl:template match="cnx:content[cnx:section]">
    <!-- summary/objectives is buried in preceding metadata as list items -->
    <xsl:apply-templates select="preceding-sibling::cnx:metadata/md:abstract/cnx:list" />
    <introduction>
        <xsl:apply-templates select="cnx:section[1]/preceding-sibling::*" />
    </introduction>
    <!-- re-order: (titled) sections, glossary section, exercises section -->
    <!-- glossary sits outside and below "content" (context here)         -->
    <xsl:apply-templates select="cnx:section[not(@class='section-exercises')]"/>
    <xsl:apply-templates select="following-sibling::cnx:glossary"/>
    <xsl:apply-templates select="cnx:section[@class='section-exercises']"/>
</xsl:template>

<!-- A module file that is not structured by "section" is really  -->
<!-- an introduction to the module (which is a PTX-section)       -->
<xsl:template match="cnx:content[not(cnx:section)]">
    <xsl:apply-templates />
</xsl:template>

<!-- Summary (in metadata) becomes titled "Objectives" -->
<!-- Perhaps a "rename" is in order, or not            -->
<xsl:template match="md:abstract/cnx:list">
    <objectives>
        <!-- Title comes via "rename" element and squashes "Objectives" -->
        <!-- <title>Summary</title> -->
        <ul>
            <xsl:apply-templates select="cnx:item" />
        </ul>
    </objectives>
</xsl:template>

<!-- CNXML section is a PTX subsection -->
<xsl:template match="cnx:section">
    <subsection>
        <xsl:apply-templates select="." mode="id-attribute" />
        <xsl:apply-templates select="cnx:title" />
        <xsl:apply-templates select="*[not(self::cnx:title)]" />
    </subsection>
</xsl:template>

<!-- CNXML section with class indicator is our "exercises"         -->
<!-- There is no title, since it is implicit in both CNXML and PTX -->
<xsl:template match="cnx:section[@class='section-exercises']">
    <exercises>
        <xsl:apply-templates select="." mode="id-attribute" />
        <xsl:apply-templates />
    </exercises>
</xsl:template>

<!-- Glossary -->

<!-- Make a PTX subsection that holds a description list. -->
<xsl:template match="cnx:glossary">
    <subsection>
        <title>Glossary</title>
        <dl>
            <xsl:apply-templates select="cnx:definition" />
        </dl>
    </subsection>
</xsl:template>

<!-- CNXML just lists "definition" elements inside  -->
<!-- the glssary element, which we convert to list  -->
<!-- items of the description list                  -->
<xsl:template match="cnx:glossary/cnx:definition">
    <li>
        <xsl:apply-templates select="." mode="id-attribute" />
        <xsl:apply-templates select="cnx:term" />
        <xsl:apply-templates select="cnx:meaning" />
    </li>
</xsl:template>

<!-- term is used elsewhere generically, -->
<!-- so we need an override              -->
<xsl:template match="cnx:definition/cnx:term">
    <title>
        <xsl:apply-templates select="*|text()" />
    </title>
</xsl:template>

<!-- meaning should become the "stuff" of  -->
<!-- a PTX list item of a description list -->
<xsl:template match="cnx:definition/cnx:meaning">
    <p>
        <xsl:apply-templates select="." mode="id-attribute" />
        <xsl:apply-templates select="*|text()" />
    </p>
</xsl:template>

<!-- Frequent Components -->

<!-- modal template to get CNXML "id" and make a PTX xml:id -->
<!-- prefix with document id, since the @id                 -->
<!-- is only unique within a module file                    -->
<xsl:template match="*" mode="id-attribute">
    <xsl:attribute name="xml:id">
        <xsl:value-of select="ancestor::cnx:document/cnx:metadata/md:content-id/text()" />
        <xsl:text>-</xsl:text>
        <xsl:value-of select="@id" />
    </xsl:attribute>
</xsl:template>

<xsl:template match="cnx:title">
    <title>
        <xsl:apply-templates />
    </title>
</xsl:template>

<!-- ###### -->
<!-- Blocks -->
<!-- ###### -->

<xsl:template match="cnx:para">
    <p>
        <xsl:apply-templates />
    </p>
</xsl:template>


<!-- Notes -->
<!-- various purposes, based on attributes (or titles)                 -->
<!-- classes, as discovered:  Calculus 3, Intermediate Algebra         -->
<!-- class = (null), a note (IA)                                       -->
<!-- class = checkpoint, inline exercise (Calc3)                       -->
<!-- class = try, inline exercise (IA)                                 -->
<!-- class = theorem, obvious (proofs odd) (Calc3)                     -->
<!-- class = project, obvious (Calc3)                                  -->
<!-- class = problem-solving, to remark (could adjust titling) (Calc3) -->
<!-- class = media, media-2, to a real note (could rename) (IA, Calc3) -->
<!-- class = howto, to a real note (could rename) (IA)                 -->
<!-- title = Definition, obvious (Calc3)                               -->
<!-- title starts with "Rule:", these are results, theorems (Calc3)    -->

<!-- A generic no-class CNXML "note" becomes a PTX "note" -->
<xsl:template match="cnx:note[not(@class)]">
    <note>
        <xsl:apply-templates select="." mode="id-attribute" />
        <xsl:apply-templates />
    </note>
</xsl:template>

<xsl:template match="cnx:note[(@class = 'checkpoint') or (@class = 'try')]">
    <!-- make an exercise, which is normally inline? -->
    <!-- the CNXML "solution" will be a PTX "answer" -->
    <xsl:apply-templates select="cnx:exercise" />
</xsl:template>

<xsl:template match="cnx:note[@class = 'theorem']">
    <theorem>
        <xsl:apply-templates select="." mode="id-attribute" />
        <xsl:apply-templates />
    </theorem>
</xsl:template>

<xsl:template match="cnx:note[@class = 'project']">
    <project>
        <xsl:apply-templates select="." mode="id-attribute" />
        <xsl:apply-templates />
    </project>
</xsl:template>

<xsl:template match="cnx:note[@class = 'problem-solving']">
    <remark>
        <xsl:apply-templates select="." mode="id-attribute" />
        <xsl:apply-templates />
    </remark>
</xsl:template>

<!-- Just a short paragraph pointing to media somewhere else -->
<!-- Or a "howto" showing how to solve a problem            -->
<xsl:template match="cnx:note[(@class = 'media') or (@class = 'media-2') or (@class = 'howto')]">
    <note>
        <xsl:apply-templates select="." mode="id-attribute" />
        <xsl:apply-templates />
    </note>
</xsl:template>

<!-- Readieness Quizzes as "question" to rename -->
<xsl:template match="cnx:note[@class = 'be-prepared']">
    <question>
        <xsl:apply-templates select="." mode="id-attribute" />
        <xsl:apply-templates />
    </question>
</xsl:template>

<xsl:template match="cnx:note[cnx:title = 'Definition']">
    <definition>
        <xsl:apply-templates select="." mode="id-attribute" />
        <xsl:apply-templates select="*[not(self::cnx:title)]"/>
    </definition>
</xsl:template>

<xsl:template match="cnx:note[contains(cnx:title, 'Rule:')]">
    <theorem>
        <xsl:apply-templates select="." mode="id-attribute" />
        <xsl:apply-templates />
    </theorem>
</xsl:template>

<!-- if not handled, then make alerts -->
<xsl:template match="cnx:note">
    <xsl:message>Unhandled <xsl:value-of select="name(.)" /></xsl:message>
    <xsl:for-each select="@*">
        <xsl:message>  <xsl:value-of select="name(.)" /> = <xsl:value-of select="." /></xsl:message>
    </xsl:for-each>
    <p>[[NOTE]]</p>
</xsl:template>

<!-- Examples -->

<xsl:template match="cnx:example">
    <example>
        <!-- CNXML "example", "exercise", "problem" all have xml:id,      -->
        <!-- we grab the outermost and hope CNXML "link" sees it the same -->
        <xsl:apply-templates select="." mode="id-attribute" />
        <xsl:apply-templates select="cnx:exercise/cnx:problem/cnx:title" />
        <statement>
            <xsl:apply-templates select="cnx:exercise/cnx:problem/*[not(self::cnx:title)]" />
        </statement>
        <xsl:apply-templates select="cnx:exercise/cnx:solution" />
    </example>
</xsl:template>

<!-- A "solution" looks more like a      -->
<!-- "solution" when it is in an example -->
<xsl:template match="cnx:example/cnx:exercise/cnx:solution">
    <solution>
        <xsl:apply-templates select="." mode="id-attribute" />
        <xsl:apply-templates />
    </solution>
</xsl:template>


<!-- Lists -->

<!-- <list id="fs-id1167794211137" list-type="enumerated" number-style="lower-alpha"> -->

<!-- TODO: respect number-style and bullet-style -->

<xsl:template match="cnx:list">
    <!-- <p>[[LIST]]</p> -->
    <xsl:variable name="list-type-element">
        <xsl:choose>
            <!-- default seems to be bulleted/unordered list -->
            <xsl:when test="not(@list-type)">
                <xsl:text>ul</xsl:text>
            </xsl:when>
            <xsl:when test="@list-type='enumerated'">
                <xsl:text>ol</xsl:text>
            </xsl:when>
            <xsl:when test="@list-type='bulleted'">
                <xsl:text>ul</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:message>CNXML @list-type "<xsl:value-of select="@list-type" />" not recognized</xsl:message>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <!-- CNXML has as peers of paragraphs, PTX requires them to be inside paragraphs -->
    <p>
        <xsl:element name="{$list-type-element}">
            <xsl:apply-templates select="." mode="id-attribute" />
            <xsl:apply-templates select="cnx:item" />
        </xsl:element>
    </p>
</xsl:template>

<xsl:template match="cnx:item">
    <li>
        <p>
            <xsl:apply-templates select="*|text()" />
        </p>
    </li>
</xsl:template>

<!-- Figures -->

<xsl:template match="cnx:figure">
    <figure>
        <!-- CNXML "figure" has an "id" that looks like the -->
        <!-- filename in the @src attribute used below      -->
        <xsl:attribute name="xml:id">
            <xsl:value-of select="@id" />
        </xsl:attribute>
        <caption>
            <xsl:apply-templates select="cnx:caption" />
        </caption>
        <!-- seems graphics are designed for full page width -->
        <image width="100%">
            <!-- an id is on the enclosing media element -->
            <xsl:apply-templates select="parent::cnx:media" mode="id-attribute" />
            <xsl:attribute name="source">
                <xsl:text>../</xsl:text>
                <xsl:value-of select="ancestor::cnx:document/cnx:metadata/md:content-id/text()" />
                <xsl:text>/</xsl:text>
                <xsl:value-of select="cnx:media/cnx:image/@src" />
            </xsl:attribute>
            <description>
                <xsl:apply-templates select="cnx:media/@alt" />
            </description>
        </image>
    </figure>
</xsl:template>

<xsl:template match="cnx:caption">
    <xsl:apply-templates select="*|text()" />
</xsl:template>

<!-- Stray Media (in sectional exercises?) -->

<xsl:template match="cnx:media[cnx:image]">
    <sidebyside width="50%">
        <image>
            <xsl:apply-templates select="." mode="id-attribute" />
            <xsl:attribute name="source">
                <xsl:text>../</xsl:text>
                <xsl:value-of select="ancestor::cnx:document/cnx:metadata/md:content-id/text()" />
                <xsl:text>/</xsl:text>
                <xsl:value-of select="cnx:image/@src" />
            </xsl:attribute>
        </image>
    </sidebyside>
</xsl:template>


<!-- Tables -->

<xsl:template match="cnx:table">
    <!-- should pick up summary for some sort of description -->
    <!-- ignore empty "label" element                        -->
    <table>
        <xsl:apply-templates select="." mode="id-attribute" />
        <caption>[[CAPTION]]</caption>
        <tabular>
            <xsl:apply-templates select="cnx:tgroup" />
        </tabular>
    </table>
</xsl:template>

<xsl:template match="cnx:tgroup">
    <!-- convert colspec to empty col, ignore attributes -->
    <xsl:apply-templates select="cnx:colspec" />
    <!-- push into "thead" and "tbody" to process rows -->
    <xsl:apply-templates select="cnx:thead/cnx:row" />
    <xsl:apply-templates select="cnx:tbody/cnx:row" />
</xsl:template>

<!-- Just drop a "col" so we have the right number -->
<xsl:template match="cnx:colspec">
    <!-- <col></col> -->
</xsl:template>

<!-- CNXML "row" is a PTX "row"                       -->
<!-- ignoring alignment attributes, perhaps redundant -->
<xsl:template match="cnx:row">
    <row>
        <xsl:apply-templates select="cnx:entry" />
    </row>
</xsl:template>

<!-- Adorn last row of "thead" with a border/rule -->
<xsl:template match="cnx:row[parent::cnx:thead and not(following-sibling::cnx:row)]">
    <row bottom="major">
        <xsl:apply-templates select="cnx:entry" />
    </row>
</xsl:template>

<!-- CNXML "entry" is a PTX "cell" -->
<xsl:template match="cnx:entry">
    <cell>
        <xsl:apply-templates select="*|text()" />
    </cell>
</xsl:template>

<!-- CNXML uses tables to layout graphics elements -->
<!-- e.g, <entry valign="top" align="left"><media id="fs-id1167836444935" alt=".">              -->
<!-- <image mime-type="image/jpeg" src="CNX_IntAlg_Figure_06_02_002a_img.jpg"/></media></entry> -->

<xsl:template match="cnx:entry[media]">
    <cell>
        <xsl:text>[[</xsl:text>
        <xsl:value-of select="media/image/@src" />
        <xsl:text>]]</xsl:text>
    </cell>
</xsl:template>




<!-- <xsl:template match="cnx:table">
    <p> should be PTX table
        <xsl:apply-templates select="." mode="id-attribute" />
        <xsl:text>[[TABLE]]</xsl:text>
    </p>
</xsl:template>
 -->

<!-- Exercises -->

<!-- Exercises, not in examples    -->
<!-- (solutions are just answers?) -->
<xsl:template match="cnx:exercise[not(parent::cnx:example)]">
    <exercise>
        <xsl:apply-templates select="." mode="id-attribute" />
        <!-- reorder into PTX order: statement, hint, answer -->
        <xsl:apply-templates select="cnx:problem" />
        <xsl:apply-templates select="cnx:commentary[@type='hint']" />
        <xsl:apply-templates select="cnx:solution" />
    </exercise>
</xsl:template>

<!-- A "problem" is a "statement" -->
<xsl:template match="cnx:exercise[not(parent::cnx:example)]/cnx:problem">
    <statement>
        <xsl:apply-templates select="." mode="id-attribute" />
        <xsl:apply-templates />
    </statement>
</xsl:template>

<!-- A hint is a "commentary" with @type="hint" -->
<!-- and a "title" with content "Hint"          -->
<xsl:template match="cnx:exercise[not(parent::cnx:example)]/cnx:commentary[@type='hint']">
    <hint>
        <xsl:apply-templates select="." mode="id-attribute" />
        <!-- drop redundant title, process remainder -->
        <xsl:apply-templates select="*[not(self::cnx:title)]" />
    </hint>
</xsl:template>

<!-- A "solution" looks more like an answer when -->
<!-- it is in the group of exercises, and does   -->
<!-- not have the "checkpoint" or "try" class    -->
<xsl:template match="cnx:exercise[not(parent::cnx:example)]/cnx:solution">
    <answer>
        <xsl:apply-templates select="." mode="id-attribute" />
        <xsl:apply-templates />
    </answer>
</xsl:template>

<!-- checkpoint exercises are our "inline" exercises -->
<!-- They seem to have only an "answer"              -->
<xsl:template match="cnx:note[(@class='checkpoint') or (@class='try')]/cnx:exercise/cnx:solution">
    <answer>
        <xsl:apply-templates select="." mode="id-attribute" />
        <xsl:apply-templates />
    </answer>
</xsl:template>


<!-- ################ -->
<!-- Cross-References -->
<!-- ################ -->

<!-- Templates: -->
<!-- <link target-id="CNX_Calc_Figure_12_01_002"/>            -->
<!-- <link target-id="fs-id1167836732813"> -->
<!-- <link document="m53874" target-id="fs-id1163723955608"/> -->
<xsl:template match="cnx:link[@target-id]">
    <xref>
        <xsl:attribute name="ref">
            <!-- intra-module reference, not to an image -->
            <!-- (starts-with "fs-id", really)           -->
            <!-- so prefix with present module id        -->
            <xsl:if test="contains(@target-id, 'fs-id')">
                <xsl:value-of select="ancestor::cnx:document/cnx:metadata/md:content-id/text()" />
                <xsl:text>-</xsl:text>
            </xsl:if>
            <xsl:value-of select="@target-id" />
        </xsl:attribute>
    </xref>
</xsl:template>

<!-- An extra-module reference, since @document supplied -->
<xsl:template match="cnx:link[@target-id and @document]">
    <xref>
        <xsl:attribute name="ref">
            <xsl:value-of select="@document" />
            <xsl:text>-</xsl:text>
            <xsl:value-of select="@target-id" />
        </xsl:attribute>
    </xref>
</xsl:template>

<!-- Template: -->
<!-- <link class="target-chapter" document="m53846">Conic Sections</link> -->
<!-- Despite the class name saying chapter, items with -->
<!-- document numbers are module files which are PTX   -->
<!-- sections or chapter introductions                 -->
<xsl:template match="cnx:link[@class = 'target-chapter']">
    <xref>
        <xsl:attribute name="ref">
            <xsl:value-of select="@document" />
        </xsl:attribute>
        <xsl:attribute name="text">
            <xsl:text>title</xsl:text>
        </xsl:attribute>
        <!-- we mimic CNXML and use a hard-coded  -->
        <!-- title name as the content         -->
        <xsl:apply-templates />
    </xref>
</xsl:template>

<!-- Template: -->
<!-- <link url="http://www.openstaxcollege.org/l/20_OsculCircle2">discussion</link> -->
<xsl:template match="cnx:link[@url]">
    <url>
        <xsl:attribute name="href">
            <xsl:value-of select="@url" />
        </xsl:attribute>
        <!-- duplicate content -->
        <xsl:apply-templates select="*|text()" />
    </url>
</xsl:template>


<!-- ############### -->
<!-- Intra-Paragraph -->
<!-- ############### -->

<!-- has a "no-emphasis" option, hmmm -->
<xsl:template match="cnx:term">
    <term>
        <xsl:apply-templates select="*|text()" />
    </term>
</xsl:template>

<!-- <emphasis> -->
<!--   rare, sometimes ad-hoc formatting -->
<xsl:template match="cnx:emphasis">
    <em>
        <xsl:apply-templates select="*|text()" />
    </em>
</xsl:template>

<!-- <emphasis effect="bold"> -->
<!--   One letter => vector     -->
<!--   Else => regular emphasis -->
<xsl:template match="cnx:emphasis[@effect='bold']">
    <xsl:choose>
        <xsl:when test="string-length(.) = 1">
            <m>
                <xsl:text>\mathbf{</xsl:text>
                <xsl:value-of select="text()" />
                <xsl:text>}</xsl:text>
            </m>
        </xsl:when>
        <xsl:otherwise>
            <em>
                <xsl:apply-templates select="*|text()" />
            </em>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<!-- <emphasis effect="italics"> -->
<!--   Has <sub> => math symbols, eg C<sub>2</sub        -->
<!--   Three or less letters => math symbols, eg xy-axis -->
<!--   Else => regular emphasis -->
<xsl:template match="cnx:emphasis[@effect='italics']">
    <xsl:choose>
        <xsl:when test="sub">
            <m>
                <xsl:value-of select="*|text()" />
            </m>
        </xsl:when>
        <xsl:when test="string-length(.) &lt; 4">
            <m>
                <xsl:value-of select="text()" />
            </m>
        </xsl:when>
        <xsl:otherwise>
            <em>
                <xsl:apply-templates select="*|text()" />
            </em>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<xsl:template match="cnx:emphasis/cnx:sub">
    <xsl:text>_{</xsl:text>
    <xsl:value-of select="text()" />
    <xsl:text>}</xsl:text>
</xsl:template>

<!-- ########### -->
<!-- Mathematics -->
<!-- ########### -->

<xsl:template match="m:math">
    <m>
        <xsl:apply-templates />
    </m>
</xsl:template>

<xsl:template match="cnx:equation">
    <p>
        <men>
            <xsl:apply-templates select="." mode="id-attribute" />
            <xsl:apply-templates select="m:math/m:*" />
        </men>
    </p>
</xsl:template>

<!-- CNXML has fixed spacing, we substitute a single ASCII space,   -->
<!-- and let LaTeX figure it out, since mmltex makes too many rules -->
<xsl:template match="m:mspace">
    <xsl:text> </xsl:text>
</xsl:template>

<!-- CNXML appears to allow stray sub- and super-scripts -->
<!-- Some subscripts are embedded in emphasis/@italics,  -->
<!-- and so help us recognize short mathematical symbols -->
<!-- Here, we just do the best we can with the hand      -->
<!-- we have been dealt                                  -->
<xsl:template match="cnx:sub">
    <m>
        <xsl:text>_{</xsl:text>
        <xsl:value-of select="text()" />
        <xsl:text>}</xsl:text>
    </m>
</xsl:template>

<xsl:template match="cnx:sup">
    <m>
        <xsl:text>^{</xsl:text>
        <xsl:value-of select="text()" />
        <xsl:text>}</xsl:text>
    </m>
</xsl:template>

<!-- ######### -->
<!-- Worthless -->
<!-- ######### -->

<!-- We have no analogue.  Intentionally. -->
<xsl:template match="cnx:newline" />


<!-- <xsl:template match="*">
    <xsl:message>Unhandled <xsl:value-of select="name(.)" /></xsl:message>
    <xsl:for-each select="@*">
        <xsl:message>  <xsl:value-of select="name(.)" /> = <xsl:value-of select="." /></xsl:message>
    </xsl:for-each>
    <xsl:text>&lt;&lt;</xsl:text>
    <xsl:value-of select="name(.)" />
    <xsl:text>&gt;&gt;</xsl:text>
</xsl:template>
 -->
</xsl:stylesheet>
