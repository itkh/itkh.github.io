---
title: "oVirt - How to install self-hosted engine"
excerpt: "oVirt self-hosted engine installation is automated by using Ansible."
categories:
  - oVirt
tags:
  - oVirt
  - Virtual Machine
sidebar:
  title: "oVirt"
  nav: ovirt 
lang: en
---
# Self-Hosted Engine Architecture
The oVirt Engine runs as a Virtual machine on self-hosted engine nodes in the same environment it manages. We do not need to separate Engine from the Host, but this requires more administrative overhead to deploy and manage.
[![ovirt-overview](/assets/images/ovirt/self-hosted.png)](/assets/images/ovirt/self-hosted.png)

For more details, you can read more on [self-hosted Engine oVirt](https://ovirt.org/documentation/installing_ovirt_as_a_self-hosted_engine_using_the_cockpit_web_interface/).

[Videos]
  - step 1: Download oVirt Node ISO file (00:07)
  - step 2: Create Bootable USB (00:40)
  - step 3: Install oVirt Node from bootable ISO (01:54)
  - step 4: Check oVirt Node status (03:07)
  - step 5: Prepare Storage (NFS) (04:50)
  - step 6: Install oVirt Engine Appliance (09:36)
  - step 7: Deploy self-hosted Engine using Cockpit (10:13)
  - step 8: Enable the oVirt Engine repositories (15:26)
