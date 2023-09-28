# RServer Image Proxy

## Table of Contents

1. [Description](#description)
1. [Setup - The basics of getting started with Rserver Image Proxy](#setup)
    * [What Rserver Image Proxy affects](#what-rserver-image-proxy-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with Rserver Image Proxy](#beginning-with-rserver-image-proxy)

## Description

This module creates a Python module dynamically from hieradata to proxy singularity
images that contain RStudio Server with JupyterHub.

## Setup

### What Rserver Image Proxy affects

The module is created in /tmp/ and installed under /opt/jupyterhub.

### Setup Requirements

Should also have puppet-jupyterhub module installed.

### Beginning with Rserver Image Proxy

Specify the RServer image names with the `rserver_image_proxy::images` variable
and path at which the images are installed with the `rserver_image_proxy::image_path`
variable and ensure that `puppet-jupyterhub` is installed.
