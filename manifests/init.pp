# Proxy RStudio Server images for JupyterHub by creating and installing a python module
class rserver_image_proxy(
  Array $rserver_images = []
) {
  # only create the proxy if jupyterhub is installed
  file { '/tmp/rserver_image_proxy':
    ensure => 'directory',
    path   => '/tmp/rserver_image_proxy',
    mode   => '0644',
    onlyif => 'test -d /opt/jupyterhub',
  }

  file { '/tmp/rserver_image_proxy/setup.py':
    ensure  => 'file',
    path    => '/tmp/rserver_image_proxy/setup.py',
    mode    => '0644',
    content => epp('rserver_image_proxy/setup.py.epp', {'rserver_images'=>$rserver_images}),
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
    content => epp('rserver_image_proxy/rserver_image_proxy/__init__.py.epp', {'rserver_images'=>$rserver_images}),
    require => File['/tmp/rserver_image_proxy/rserver_image_proxy'],
  }

  exec { 'install rserver_image_proxy':
    command  => '/opt/jupyterhub/bin/pip3 install /tmp/rserver_image_proxy',
    require  => [File['/tmp/rserver_image_proxy/rserver_image_proxy/__init__.py'],File['tmp/rserver_image_proxy/setup.py']],
    provider => 'shell',
  }

}
