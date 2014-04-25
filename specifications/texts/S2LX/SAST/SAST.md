# Aims and Scope
GNU/Linux has demonstrated good security capabilities over the past
decades - most notably in the server market - the development of real-time capabilities in
the mainline Linux kernel is still an on-going effort and safety qualifications have been
achieved in the context of specific industrial projects.

To enable GNU/Linux RTOS for the general safety related systems domain the key point is 
assessment of current procedures and where necessary, development of suitable amendments
or additional processes and procedures along with the suitable methods.

SIL2LinuxMP aims to provide a Certification Package to enable the users of this package to
gain safety certification when using the GNU/ Linux RTOS in a safety context.

The safety strategy applies to SIL2LinuxMP for all life cycle phases.

# SIL2LinuxMP Safety Policy

**The key safety policy is to demonstrate that the GNU/ Linux RTOS complies to the requirements
of the software safety standards IEC 61508-3:2010 SIL 2, EN 50128:2011 SIL 2, 
and ISO 26262-6:2011 ASIL D.**

IEC 61508 is a widely accepted base standard. Sector specific standards like EN 50128 or ISO 26262
are derived from it. Therefore achieving compliance to IEC 61508-3 requirements is chosen as the primary step 
in creating safety evidence for the GNU/ Linux RTOS. Compliance evidence to EN 50128 and ISO 26262 is
provided based on the compliance to IEC 61508.

IEC 61508-3 defines three possible routes to demonstrate compliance. Only Route 3S is regarded viable
for the GNU/ Linux RTOS as this route specifically targets non-compliant (to the standard development
process) developments. The GNU/ Linux RTOS development processes are not based on any standard's 
requirements but have been elaborated to achieve high quality and suitable functionality. This is
the fundament to show compliance to the standard's requirements by a non-compliant process. Additional
measures, methods and processes are implemented to gain full compliance by Route 3S.

EN 50128 accepts the use of pre-existing software with some restrictions. Pre-existing software includes
open source software. The restrictions are basically covered by IEC 61508-3 Route 3S. Additional
measures, methods and processes are implemented in case gaps with respect to IEC 61508-3 are discovered.

ISO 26262-8 clause 12 defines requirements for re-use of qualified software components even from outside
of the automotive domain. Additional measures, methods and processes are implemented on top of
IEC 61508 Route 3S to fulfil the IEC 26262-8 requirements for qualified software from a different
industrial domain.

Implementation of measures, methods and processes is done by:

 *  Re-use of measures, methods and processes already available in GNU/ Linux RTOS with additional
    documentation and arguments for standards and safety compliance.
 *  Creation of new measures, methods and processes including documentation and arguments for 
    standards and safety compliance. 

# SIL2LinuxMP Project

The SIL2LinuxMP project creates the SIL2LinuxMP Certification Package adhering to
the SIL2LinuxMP Safety Policy. 

## Involved Parties

**User**

The user of SIL2LinuxMP uses the Certification Package provided by SIL2LinuxMP to gain certification or
homologation of the incorporating safety product.

**Contributors**

Contributors provide artefacts that become part of the SIL2LinuxMP Certification Package. Contribution may be
passive (e.g. Linux kernel) or active (e.g. patches to SIL2LinuxMP).

**SIl2LinuxMP Organisation**

The SIL2LinuxMP Organisation is responsible for the safety and quality of the SIL2LinuxMP Certification
Package. The SIL2LinuxMP Organisation monitors and controls the development and maintenance of the
SIL2LinuxMP Certification Package. The Organisation assures that contributions to the Certification Package
sustain or improve the safety and quality of GNU/ Linux RTOS.

**Certification Authority**

The certification authority certifies the SIL2LinuxMP Certification Package to be suitable for to implement
software safety functions in a safety product and to provide safety evidence compliant to the standard's
requirements.

## Technical Background

Sil2LinuxMP consists of the base components of an embedded GNU/Linux RTOS running on a multi-core
industrial COTS computer board and the accompanying safety evidence documentation.

Base components are boot loader, root file system, Linux kernel with a well defined subset of
drivers and the C library bindings (glibc using NPTL) to access the Linux kernel. With
the exception of a minimal set of utilities (to inspect the system, manage files and start
test procedures), user space applications are not included.

# Safety Management Approach

## Organisational Structure

### SIL2LinuxMP Organisation

The SIL2LinuxMP Organisation consists of the OSADL SIL2LinuxMP partners. The coordination of the 
partners work flow is in the hands of OSADL Safety Critical Linux Working Group and infrastructure
wise located at OSADL in Heidelberg.

The safety management process will be primarily the responsibility of OSADL with contributions
from all partners.

At the technical level the roles are more differentiated with
full partners contributing domain know-how for their specific Use-Cases and reviewing
partners (as the name indicates) providing a first level of semi-independent review. Specific tasks,
be it analytical, the development/tailoring of tools or generation of suitable
evidence data will be the main contribution of our academic partners as well as of
OSADL staff.



