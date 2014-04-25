# Introduction

The goal of SIL2LinuxMP is to qualify GNU/Linux RTOS and its support
environment (e.g. development tools) for Safety Integrity Level 2 (SIL2)
according to IEC 61508 Ed2 (2010).
IncludeText: sil2linuxmp_go.jpg --filter pandoc1_filter_md --inline_image
Text:
The key technology for this project is the GNU/Linux RTOS as the OS for a
multi-core platform. While GNU/Linux has demonstrated good security
capabilities over the past decades - most notably in the server market -
the development of real-time capabilities in the mainline Linux kernel is
still an on-going effort and safety qualifications have been achieved in 
the context of specific industrial projects [?], [?]. To enable GNU/Linux
RTOS for the general safety related systems domain the key point is assessment
of current procedures and where necessary, development of suitable amendments
or additional processes and procedures along with the suitable methods.

#: The topics common to the user, SIL2LinuxMP, and contributing projects
SubTopic: DAA/DAA

#: The user project topics
IncludeSubTopic: UserProject

#: SIL2LinuxMP topics
IncludeText: separator01.png --filter pandoc1_filter_md --inline_image
IncludeRequirements: full
SubTopic: S2LX/SAST/SAST
SubTopic: S2LX/STDRS/STDRS
SubTopic: S2LX/RMP/RMP


#: Contributing project topics
IncludeText: separator01.png --filter pandoc1_filter_md --inline_image


#: The topics common to the user, SIL2LinuxMP, and contributing projects
#: Gathering information from all above or provid guidance
IncludeText: separator01.png --filter pandoc1_filter_md --inline_image
SubTopic: RMG/RMG
SubTopic: SCI/SCI

