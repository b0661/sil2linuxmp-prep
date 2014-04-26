# SIL2LinuxMP - Prep

SIL2LinuxMP-Prep is a demonstrator/ test bed/ playground to evaluate
means, methods and tools for the coming SIL2LinuxMP project.

SIL2LinuxMP aims to qualify GNU/Linux RTOS and its support environment
(e.g. development tools) for Safety Integrity Level 2 (SIL2) according 
to IEC 61508 Ed2 (2010) (see <https://www.osadl.org/SIL2LinuxMP.sil2-linux-project.0.html>).

# Status

Implemented features:

  * Build system (using CMake)
  * Requirements management environment (using rmtoo) 
  * SIL2LinuxMP demonstrator project
  * Certification package generator
  * Demo requirements set (using rmtoo - requirements)
  * Demo documentation template(s) (using rmtoo - topics)
  
Additions:

  * rmtoo enhanced to use pandoc markdown

# Installation

Install the following tools:

  * git
  * CMake
  * pandoc >= 1.11
  * texlive xetex
  * dot
  * unflatten
  * python 2.7
  * python argparse
  * python pygraphviz
  
For Ubuntu 13.10 the following will install all of the above:

    sudo apt-get install git cmake pandoc texlive-xetex texlive-fonts-recommended python-all python-pygraphviz 

Get your copy of SIL2LinuxMP - Prep.

    git clone https://github.com/b0661/sil2linuxmp-prep.git

Create a build directory and call the bootstrap script of the SIL2LinuxMP
demonstrator project from inside the build directory.

    mkdir my-build-dir
    cd my-build-dir 
    . <path to>/sil2linuxmp-prep/sil2linuxmp-demonstrator/bootstrap

A configuration file is created in the
build directory. Assure you have internet access
and execute the configuration script.

    . ./configuration

The configuration may take some time. After configuration
you are able to generate the demo certification package.

    make doc

The demo certification package can now be accessed by.

    my-build-dir/certification-package/<name>.html or
    my-build-dir/certification-package/<name>.pdf
