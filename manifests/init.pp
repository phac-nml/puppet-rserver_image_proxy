# Proxy RStudio Server images for JupyterHub by creating and installing a python module
class rserver_image_proxy(
  String $image_path,
  Array $images = [],
  Integer $python_minor_version = 9 # only tested on python 3, so major version is not variable
) {
  # The following file declarations define the structure for a new dynamically created python module.
  # This is necessary because jupyterhub proxies are defined at install time for python modules as
  # they are defined in the setup.py file. This module is created in the /tmp directory and then
  # installed by the python installation inside of /opt/jupyterhub which is where the puppet-jupyterhub
  # class installs jupyterhub and therefore, where the proxy must be installed.

  # Create the base directory of the python module
  file { '/tmp/rserver_image_proxy':
    ensure => 'directory',
    path   => '/tmp/rserver_image_proxy',
    mode   => '0644',
  }

  # Define the setup.py file which is used to install the package. Furthermore, it defines the entry points
  # to the module which jupyterhub needs to use the proxies. Each entry point is added to the template from
  # the $images variable.
  file { '/tmp/rserver_image_proxy/setup.py':
    ensure  => 'file',
    path    => '/tmp/rserver_image_proxy/setup.py',
    mode    => '0644',
    content => epp("${module_name}/rserver_image_proxy/setup.py.epp", {'rserver_images'=>$images}),
    require => File['/tmp/rserver_image_proxy'],
  }

  # Create the directory containing the content of the package
  file { '/tmp/rserver_image_proxy/rserver_image_proxy':
    ensure => 'directory',
    path   => '/tmp/rserver_image_proxy/rserver_image_proxy',
    mode   => '0644',
  }

  # Define the __init__.py file which is what the proxy actually runs. Each image in $images has its own
  # function defined which calls a common function which defines a basic proxy where the name of the image
  # is based in as a parameter.
  file { '/tmp/rserver_image_proxy/rserver_image_proxy/__init__.py':
    ensure  => 'file',
    path    => '/tmp/rserver_image_proxy/rserver_image_proxy/__init__.py',
    mode    => '0644',
    content => epp("${module_name}/rserver_image_proxy/rserver_image_proxy/__init__.py.epp", {'rserver_images'=>$images}),
    require => File['/tmp/rserver_image_proxy/rserver_image_proxy'],
  }

  # Define a search command which will trigger a reinstall of the package if it does not return 0.
  # Map each image into a grep command which searches for the string "setup_rserver_${image}" in the
  # installed __init__.py file where ${image} is the name of the image. The -q flag is used for grep
  # to suppress output. Each grep is joined together with && which gives a bash command containing a
  # series of searches such that if one fails, the whole command fails. This command is then used as
  # an unless parameter for the installation so that the install does not happen if each search passes.
  $search = $images
    .map |$image| { "grep -q 'setup_rserver_${image}()' /opt/jupyterhub/lib64/python3.${python_minor_version}/site-packages/rserver_image_proxy/__init__.py"}
    .join(' && ')

  # Install the proxy package that was defined in /tmp. Don't install if /opt/jupyterhub does not exist
  # or if the search defined earlier passes.
  exec { 'install rserver_image_proxy':
    command  => '/opt/jupyterhub/bin/pip3 install /tmp/rserver_image_proxy',
    require  => [File['/tmp/rserver_image_proxy/rserver_image_proxy/__init__.py'],File['/tmp/rserver_image_proxy/setup.py']],
    provider => 'shell',
    unless   => $search,
    onlyif   => 'test -d /opt/jupyterhub'
  }

  # Create executables for each image to launch rstudio server
  $images.each |String $image| {
    file { "/usr/local/bin/${image}-rserver":
      ensure  => 'file',
      path    => "/usr/local/bin/${image}-rserver",
      mode    => '0755',
      content => epp("${module_name}/rserver.epp", {'path'=>$image_path, 'image'=>$image})
    }
  }
}
