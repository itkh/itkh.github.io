---
title: "Kubernetes concepts"
excerpt: "A basic of Kubernetes concepts, architecture, and components"
pagination:
  enabled: true
categories:
  - kubernetes  
tags:
  - Kubernetes
  - concepts
  - architecture
toc: true
toc_sticky: true
toc_label: "Kubernetes"
sidebar:
  title: "Kubernetes"
  nav: kubernetes
lang: en
khmer_url: "/khmer/cloud/kubernetes/2019-12-06-kubernetes-concepts.km"
---
> [Read Official Documentation](https://kubernetes.io/){:target="\_blank"}


## What is Kubernetes?
Kubernetes (K8s), created by Google in 2014, is an open-source system for automating deployment, scaling, and management of containerized applications. It is a portable, extensible platform for managing containerized workloads and services, that facilitates both declarative configuration and automation.  

> - What is containerized application?  
  **An application/software that run on container.**
> - What is container?  
  **A standard unit of software that packages up code and all its dependencies, so an application can run quickly, uniformly, and reliably on any computing environment.**
> - what is container runtime?  
  **A software that executes and manages containers like Docker, rkt, containerd, and lxd.**

## Why Kubernetes?

### Evolution of Application Deployment
[![app-evol](/assets/images/kubernetes/Going-back-in-time.png)](/assets/images/kubernetes/Going-back-in-time.png)

- **Traditional Deployment era:**  
  All applications are running on physical server. One application would take up most of the resources. As a result, the other applications would underperform.
  A solution is to run each application on different server, but this did not scale as resources were underutilized, and physical server is too expensive.
- **Virtualized Deployment era:**  
  Virtualization allows you to run multiple VMs on a single physical server. So your applications can be run separately on different VM. Each VM is a full machine running all the components, including its own operating system which taking up so much disk space.
  > - What is virtual machine (VM)?  
    **An emulation of a computer system, an abstraction of physical hardware turning one server into many servers. Each VM includes a full copy of an operating system, the application, necessary binaries and libraries.**
  > - What is Hypervisor?  
    **A software, Virtual Machine Monitor, that creates, runs and manages virtual machines. It allows one host computer to support multiple guest VMs by virtually sharing its resources like CPU, memory, storage, etc...**

- **Container Deployment era:**  
  Containers are considered lightweight compared to VMs because they share operating system (OS) among the applications. Similar to Vm, a container has its own file system, CPU, memory, process space, and more. They are portable across clouds and OS distributions.

### What Kubernetes can do?
Containerized application is easy to edit, deploy, and update on fly. But managing applications across more than one machine is complicated very quickly. As a solution, Kubernetes was introduced. Kubernetes can easily manage application deployment for your system with almost zero downtime. It provides you with:
  - **Service discovery and load balancing**  
    Kubernetes can expose a container using the DNS name or using their own IP address. If traffic to a container is high, Kubernetes is able to load balance and distribute the network traffic so that the deployment is stable.
  - **Storage orchestration**  
    Kubernetes allows you to automatically mount a storage system of your choice, such as local storage, public cloud providers, and more.
  - **Automated rollouts and rollbacks**  
    You can automate Kubernetes to create new containers for your deployment, remove existing containers and adopt all their resources to the new container.
  - **Automatic bin packing**  
    You can tell Kubernetes how much CPU and memory (RAM) each container needs. Kubernetes can fit containers onto your nodes to make the best use of your resources.
  - **Self-healing**  
    Kubernetes restarts containers that fail, replaces containers, kills containers that don’t respond to your user-defined health check, and doesn’t advertise them to clients until they are ready to serve.
  - **Secret and configuration management**  
    Kubernetes lets you store and manage sensitive information, such as passwords, OAuth tokens, and SSH keys.

## Kubernetes Architecture
When you deploy Kubernetes, you get a cluster which consists of master and worker node(s) interact to each other through network connection.
[![k8s-arch](/assets/images/kubernetes/k8s_architecture.png)](/assets/images/kubernetes/k8s_architecture.png)

## Kubernetes components
- **User**  
A person or administrator who wish to manage the Kubernetes cluster.
  - **UI (Dashboard)** is a web-based Kubernetes user interface. You can use Dashboard to deploy containerized applications, troubleshoot, and manage the cluster itself.
  - **CLI (Kubectl)** is command line interface for Kubernetes used to interact with control plane node through API server. It uses REST API to send request to create, delete, update, and manage Kubernetes resources.

- **Control Plane (Master)**  
The control plane's components make global decisions about the cluster.
  - **API Server** is the front end API for Kubernetes control plane, handling internal and external requests. It provides APIs to support request from user, and also acts as gateway to the cluster, so other component can interact to another through API server.
  - **etcd** a simple consistent and highly-available distributed key-value store used as database to store all cluster data.
  - **Controller** (kube-controller-manager) is a daemon that runs the core control loops, watches the state of the cluster, and makes changes to drive status toward the desired state. It contains several controller functions which compiled into a single binary and run in a single process.    
  - **Scheduler** is responsible for the scheduling of containers across the nodes in the cluster. It watches newly created POD with no assigned node, considers the resource needs of a POD such as CPU, memory, along with the health of the cluster and schedules the POD to an appropriate worker node.

- **Node (worker)**  
Node components run on every node, maintaining running pods and providing the Kubernetes runtime environment.
  - **kubelet** is an agent runs on each node and reads the container manifests which ensures that containers are running and healthy. It communicates with master node, which execute any action that master node needs to happen in a worker node.
  - **kube-proxy** is a network proxy and loadbalancer that runs on each node, maintaining network rules on node, which allows network communication to PODs from inside or outside of the cluster.
  - **Container Runtime** is a software that is responsible for running containers

## References
- <https://kubernetes.io/docs/concepts/overview/what-is-kubernetes/>
- <https://www.docker.com/resources/what-container>
- <https://www.redhat.com/en/topics/virtualization/what-is-a-virtual-machine>
- <https://www.youtube.com/watch?v=IMOZCDhH7do>
