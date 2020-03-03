
# arc6

This module is meant to configure a Nordugrid ARC6 CE.

 **This module is not finished :** 
 - **work is in progress**
 - **it is not officialy supported**


#### Table of Contents

1. [Description](#description)
2. [Setup - The basics of getting started with arc6](#setup)
    * [Setup requirements](#setup-requirements)
    * [Beginning with arc6](#beginning-with-arc6)
3. [Usage - Configuration options and additional functionality](#usage)
4. [Limitations - OS compatibility, etc.](#limitations)
5. [Development - Guide for contributing to the module](#development)

## Description

This module is used on a grid site : default module options are therefore (for now ?) oriented towards grid support, and especially atlas/cms/alice

## Setup

### Setup Requirements

Outside of this module, you must :
- deploy a host certificate
- deploy voms configuration
- have a running ARGUS server

arctl voms deployment capabilities are not tested with this module. And should not as state would not be reproductible.

setup without ARGUS is untested, and probably not working. If you know of a clean way to correctly configure lcas/lcmaps and its gridmap/groupmap files, please drop a mail... ideally, this should be a module of its own. 

### Beginning with arc6

## Usage

Please see examples/condor.pp for an example of how to use this module.

## Development

Fork in a feature branch, commit, pull request.

## What's tested, what's not 

Tested :
- arc + condor + apel parser
- rtes

Not tested:
- jura direct publishing
- any setup without ARGUS
- anything other than CentOS7. Reason is : we run that in prod, and there are no apel repos for instance for el8. Many grid things are RHEL limited :/
- the umd::repos class : because I use my own, snapshotted, mirros.

