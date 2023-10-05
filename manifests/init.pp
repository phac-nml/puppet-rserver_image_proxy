# Proxy RStudio Server images for JupyterHub by creating and installing a python module
class rserver_image_proxy(
  String $image_path,
  Array $images = [],
  Number $python_minor_version = 9 # only tested on python 3, so major version is not variable
) {
  file { '/tmp/rserver_image_proxy':
    ensure => 'directory',
    path   => '/tmp/rserver_image_proxy',
    mode   => '0644',
  }

  file { '/tmp/rserver_image_proxy/setup.py':
    ensure  => 'file',
    path    => '/tmp/rserver_image_proxy/setup.py',
    mode    => '0644',
    content => epp("${module_name}/rserver_image_proxy/setup.py.epp", {'rserver_images'=>$images}),
    require => File['/tmp/rserver_image_proxy'],
  }

  file { '/tmp/rserver_image_proxy/rserver_image_proxy':
    ensure => 'directory',
    path   => '/tmp/rserver_image_proxy/rserver_image_proxy',
    mode   => '0644',
  }

  file { '/tmp/rserver_image_proxy/rserver_image_proxy/__init__.py':
    ensure  => 'file',
    path    => '/tmp/rserver_image_proxy/rserver_image_proxy/__init__.py',
    mode    => '0644',
    content => epp("${module_name}/rserver_image_proxy/rserver_image_proxy/__init__.py.epp", {'rserver_images'=>$images}),
    require => File['/tmp/rserver_image_proxy/rserver_image_proxy'],
  }

  $search = $images
    .map |$image| { "grep -q 'setup_rserver_${image}()' /opt/jupyterhub/lib64/python3${python_minor_version}/site-packages/rserver_image_proxy/__init__.py"}
    .join(' && ')

  # TODO remove this
  notify{"string of greps is: ${search}":}

  # only install the proxy if jupyterhub is installed
  exec { 'install rserver_image_proxy':
    command  => '/opt/jupyterhub/bin/pip3 install /tmp/rserver_image_proxy',
    require  => [File['/tmp/rserver_image_proxy/rserver_image_proxy/__init__.py'],File['/tmp/rserver_image_proxy/setup.py']],
    provider => 'shell',
    unless   => $search,
    onlyif   => 'test -d /opt/jupyterhub'
  }

  $images.each |String $image| {
    file { "/usr/local/bin/${image}-rserver":
      ensure  => 'file',
      path    => "/usr/local/bin/${image}-rserver",
      mode    => '0755',
      content => epp("${module_name}/rserver.epp", {'path'=>$image_path, 'image'=>$image})
    }
  }
}
