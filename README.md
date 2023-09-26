# RServer Image Proxy

## Table of Contents

1. [Description](#description)
1. [Setup - The basics of getting started with rserver_image_proxy](#setup)
    * [What rserver_image_proxy affects](#what-rserver_image_proxy-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with rserver_image_proxy](#beginning-with-rserver_image_proxy)
1. [Usage - Configuration options and additional functionality](#usage)
1. [Limitations - OS compatibility, etc.](#limitations)
1. [Development - Guide for contributing to the module](#development)

## Description

This module creates a Python module dynamically from hieradata to proxy images
that contain RStudio Server with JupyterHub.

## Setup

### What rserver_image_proxy affects

The module is created in /tmp/ and installed under /opt/jupyterhub.

### Setup Requirements

Should also have puppet-jupyterhub module installed.

### Beginning with rserver_image_proxy

Specify the RServer image names with the `rserver_image_proxy::rserver_images`
variable and ensure that `puppet-jupyterhub` is installed.
