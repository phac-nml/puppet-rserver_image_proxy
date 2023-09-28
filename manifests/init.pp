# Proxy RStudio Server images for JupyterHub by creating and installing a python module
class rserver_image_proxy(
  Array $rserver_images = []
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
    content => epp("${module_name}/rserver_image_proxy/setup.py.epp", {'rserver_images'=>$rserver_images}),
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
    content => epp("${module_name}/rserver_image_proxy/rserver_image_proxy/__init__.py.epp", {'rserver_images'=>$rserver_images}),
    require => File['/tmp/rserver_image_proxy/rserver_image_proxy'],
  }

  # extract major python version (i.e. 3.9) from python --version
  $python_version = inline_template("<%=`/opt/jupyterhub/bin/python3 --version | sed 's/Python //' | sed 's/\.[0-9]*\$//'` %>")

  # only install the proxy if jupyterhub is installed
  exec { 'install rserver_image_proxy':
    command  => '/opt/jupyterhub/bin/pip3 install /tmp/rserver_image_proxy',
    require  => [File['/tmp/rserver_image_proxy/rserver_image_proxy/__init__.py'],File['/tmp/rserver_image_proxy/setup.py']],
    provider => 'shell',
    creates  => "/opt/jupyterhub/lib64/python${python_version}/site-packages/rserver_image_proxy/__init__.py",
    onlyif   => 'test -d /opt/jupyterhub'
  }
}
