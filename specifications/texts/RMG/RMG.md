# Requirements 

## Requirements Definition

Requirement aspects shall be organized by requirement attributes.

Requirements must be testable.
Requirements must be positive; negative requirements can mostly not
tested.

### Requirements vs. Design Decisions



### Requirements vs. Constraints


### Use of Terms


### Requirement Structure/ Grammar



## Requirement Attributes

A requirement attribute is a key\:value pair that defines a certain
aspect of the requirement.

The following attributes shall be used to define a requirement:

-------------------------------------------------------------------
Key                 Value                                        
--------------- --- -----------------------------------------------
Name\:           M  The value of this key is a short headline 
                    for the requirement. It is used as a section
                    headline in the output document.

Type\:           M  This value can be one of *master requirement*
                    , *requirement* and *design decision*.
                    There can only be one *master requirement* in
                    the whole set of requirements of a project.
                    This is the requirement (product, artefact)
                    the whole project is about. The name of the
                    master requirement is typically the project 
                    title.

Description\:    M  The description is the formulation of the
                    requirement. There must be one of the words
                    *must* or *shall* used. The words *may*,
                    *possible*, *might*, *and*, and *or* are
                    not allowed.

Rationale\:      R  The rationale gives a hint and some more
                    details about the requirement. Typically
                    some background information is given here.

Note\:           O  The note is an additional comment for the
                    requirement.

Solved by\:      R  Each requirement which is *solved* by other
                    requirements must have one or more children.
                    The *Solved by* attribute contains a list of
                    these children. The children requirements are
                    given by their *requirements ID* and 
                    separated *,*. The children shall either be 
                    set or the *Solved by* attribute omitted.

Topic\:          M  This is the topic the requirement belongs to.
                    The topic is given by it's *topic ID*.
-------------------------------------------------------------------

## User vs. SIL2LinuxMP vs. Contributing Project Requirements {#rmg-rmg-topic-user-sil2linuxmp-contributing-project-topics}

The requirements shall be kept in the same directory hierarchy as the topics
they are associated to \(see 
[User vs. SIL2LinuxMP vs. Contributing Project Topics](#rmg-rmg-topic-user-sil2linuxmp-contributing-project-topics)
\)

The user project shall have **one** master requirement. This master requirement
shall be associated to the *Basics/Basics* topic.

A minimal master requirement file might look like:

    Name: <User Project Name>
    Type: master requirement
    Description: The world needs a <User Project Name>.
    Solved by: SIL2LinuxMP
    Topic: Basics/Basics
    Invented on: 20xx-xx-xx
    Invented by: Community
    Ownwer: Authors
    
The master requirement file usually is named after the project name:

    <user-project-name>.req
    
It shall live in the top level requirements directory of the user project:

    <user project>/.../requirements/<user-project-name>.req

## Requirement file (*.req)

# Constraints

Constraints describe (mostly limit) the problem solution space of requirements.
Requirements inherit constraints from dependent requirements.

## Constraint Attributes

A constraint attribute is a key\:value pair that defines a certain
aspect of the constraint.

-------------------------------------------------------------------
Key                 Value                                        
--------------- --- -----------------------------------------------
Name\:           M  The value of this key is a short headline 
                    for the constraint. It is used as a section
                    headline in the output document.

Description\:    M  The description is the formulation of the
                    constraint. There must be one of the words
                    *must* or *shall* used. The words *may*,
                    *possible*, *might*, *and*, and *or* are
                    not allowed.

Note\:           O  The note is an additional comment for the
                    constraint.
                    
CE3\:            O  Definition for the Constraint Execution
                    Environment: contains a formal definition of
                    the constraint which can be automatically
                    evaluated.                   
-------------------------------------------------------------------

## Constraint file (*.ctr)

# Topics

Topics are the way requirements and supporting texts are organized.
They provide the structure of the output document(s).

Topics group requirements into sets with increased cohesion. Requirements
of the same topic will be listed in the same section of the output document.

## Topic Attributes

-------------------------------------------------------------------
Key                 Value
--------------- --- -----------------------------------------------
Name\:           M  The value of this key is the headline 
                    of the topic chapter in the output document.

Text\:           O  Arbitrary text for explanations.

IncludeText\:    0  Text include directive - The include directive
                    is evaluated and the resulting text
                    is included in the output document.

Include          O  full - Include all requirements of the topic.
Requirements\:

SubTopic\:       O  Other topics. The sub topic becomes a sub 
                    chapter of the current topic. The sub topic
                    is identified by the *topic ID*.

Include          O  Other topics. The sub topic is included in
SubTopic\:          the chapter of the current topic. It will
                    **not** become a sub chapter. The sub topic
                    is identified by the *topic ID*.
-------------------------------------------------------------------

### IncludeText\:

The IncludeText\: key allows to define include directives for external content
inclusion. The external content is fetched and optionally processed by a filter
function before it is included in the output document.

The external content may be anything that can be converted to a Pandoc markdown
fragment. The external content may be directly included by the markdown fragment
(like markdown or raw HTML) or linked (like images) or must be converted to an
image and\/ or markdown text.

Filter directives are defined by a shell like command syntax:

**IncludeText\: [options...] \<files...\>**

---------------------------------------------------------------------
Option                Description                                        
--------------------- -----------------------------------------------
\-\-filter \<name\>   The name of the filter to use. Defaults to
                      pandoc1_filter_md.

\-\-caption "CAPTION" Caption in case the file is an image.

\-\-inline_image      Inline the image. The caption will not be
                      visible. 
---------------------------------------------------------------------

The following filters for external content processing are available:

-------------------------------------------------------------------
Filter              Description                                        
------------------- -----------------------------------------------
pandoc1_filter_md   Convert external content using pandoc.
                    Supports markdown, png, jpeg, csv.
-------------------------------------------------------------------

## Topic Content

A topic shall describe the general intention of the topic in the
first TEXT\: attribute following the NAME\: attribute.

With that description, the topic guides in the development of
suitable requirements and supporting texts.

To resemble the classical document view on a project the 
description for a top level topic, which can be seen the equivalent
of a document, shall be of the form:

*Example for a plan:*

    NAME: Development Plan (DP/DP)
    Text:
    The Development Plan (DP/DP):
      * Provides organisational requirements for development.
      * Provides process requirements regarding the general development process.
      * References detailed plans.

Topics below the top level topics may use the same scheme to 
describe their intention.

The topic shall add up the directive to include the topic requirements:

    IncludeRequirements: full

The topic may add up any additional sub topics.

    SubTopic: My/Subtopic_in_a_extra_chapter
    IncludeSubTopic: My/Subtopic_directly_included

## Topic file (*.tic)

## User vs. SIL2LinuxMP vs. Contributing Project Topics {#rmg-rmg-topic-user-sil2linuxmp-contributing-project-topics}

Topics can be associated to different classes:

*Contributing Project Topics*

Topics that belong to a project that contributes passively to
(is used by) SIL2LinuxMP are contributing project topics. These topics
shall be kept in a directory named according to (the abbreviation of)
the contributing project. The following abbreviated directory
names are already defined:
  * KRNL - The Linux kernel.
  * GLIBC - The GNU C library.
  * UBOOT - Das U-Boot boot loader.
 
All topics that will become a top level chapter in the certification
package documentation shall have the (abbreviated) project name and 
the abbreviation of the topic (the topic ID) as a postfix in the
topic name.

E.g.\:

    Name: Software Architecture Specification (KRNL/SAS/SAS)

The topic file is:

    .../topics/KRNL/SAS/SAS.tic

*SIL2LinuxMP Project Topics*

Topics that belong to the SIL2LinuxMP Certification Package but
do not belong to any of the contributing projects. The SIL2LinuxMP
topics shall be kept in the S2LX directory. 

All topics that will become a top level chapter in the certification
package documentation shall have *S2LX* and the abbreviation of the
topic (the topic ID) as a postfix in the topic name.

E.g.\:

    Name: Safety Strategy (S2LX/SAST/SAST)

The topic file is:

    .../topics/S2LX/SAST/SAST.tic

*User Project Topics*

Topics that belong to the user project that uses the SIL2LinuxMP
Certification Package shall be kept in the top level topics
directory.
 
All topics that will become a top level chapter in the certification
package documentation shall have *UP* and the abbreviation of the
topic (the topic ID) as a postfix in the topic name.

E.g.\:

    Name: Safety Plan (UP/SP/SP)

The topic file is:

    .../topics/UP/SP/SP.tic

The master topic of the user project shall be named:

    Name: <user project name>

The master topic file shall be:

    .../topics/UserProject.tic

*Common Topics*

Topics that are common to the user project, SIL2LinuxMP, and the 
contributing project(s). These topics shall be kept in the top level
topics directory. Examples of such kind of topics are abbreviations,
definitions, guidelines, ...

For the naming the same as for the *User Project Topics* shall be 
applied.

E.g.\:

    Name: Definitions, Acronyms and Abbreviations (DAA/DAA)

The topic file is:

    .../topics/DAA/DAA.tic

## Top Level Topic Structure

![Top Level Topic Structure](TopLevelTopicStructure.png)

# Formatting Rules

## Attributes

Attributes shall start with a tag at the beginning of a line. 
The attribute tag shall end with a \:.

Any text after the \: until the next attribute name is regarded attribute
content.

## Comments

To mark a line as a comment in non Text\: type content the attribute key \#
or \#\: shall be used.

To mark a line as a comment in Text: content only the attribute key \#\: 
shall be used. This is to avoid misinterpretation by the markdown scanner.

Any text after the key up until the end of the line is regarded comment
content. Comments may be intermixed with attribute value content. Comment
lines will be removed from the attribute value content.

~~~
 attribute value content
 #: This is a comment until the end of the line
 further attribute value content
~~~

To insert comments into the attribute content (inline comment) the HTML
comment notation shall be used.

~~~
 The quick brown fox <!- a comment -!> jumps over the lazy dog.
~~~

Inline comments shall only be inserted into the attribute value content of 
Text\:, Description\:, Rationale\:, and Note\: attributes. There is no such
restriction for line comments.

## Markdown Syntax

Any attribute content text in a specification file (\*.tic,  \*.req, \*.ctr) shall
adhere to the Pandoc Markdown syntax.

### Headers

Only atx-style headers shall be used.

~~~
 # Header Level 1

 Level 1 text.

 ## Header Level 2

 Level 2 text.
~~~

The header level in an attribute content shall start at one.

The output processor will increase the header level appropriately
on output document generation.

Headers shall only be used in the attribute content of Text\: attributes.

### Special characters {#rmg-rmg-markdown-special-characters}

The special characters \*, \_, \*, \+ shall be written \\\*, \\\_, \\\*, \\\+ to be used literally.

The \: character shall be written \\\: to avoid any confusion with requirement keys. If a \: character is
dictated by the markdown syntax, please check for requirement key confusion.