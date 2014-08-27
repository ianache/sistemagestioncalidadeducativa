# == Class:  tomcat
#
# Configure Apache Tomcat
#
# == Authors
#
# Ilver Anache <ilver.anache@gmail.com>
#
class tomcat (
	$tomcat_version = hiera('tomcat_version','8.0.8'),
	$install_group=hiera('tomcat_install_group','tomcat'),
	$install_user=hiera('tomcat_install_user', 'tomcat')) {
	
	$tomcat_admin = hiera('tomcat_admin')
	$tomcat_pwd = hiera('tomcat_pwd')
	$tomcat_http_port = hiera('tomcat_http_port')
	$tomcat_https_port = hiera('tomcat_https_port')
	
	$catalina_home = '/u01/app/apache/apache-tomcat'
	
	group { $install_group:
		ensure	=>	'present',
	}
	
	user { $install_user:
		gid	=>	'tomcat',
		name		=> $install_user,
		comment		=> '"Tomcat User"',
		home		=> "/home/${install_user}",
		managehome	=> true,
		shell		=>	'/sbin/nologin',
		ensure		=>	'present',
		require		=>	Group[$install_group],
	}
	
	file { "/u01/app/apache":
		ensure 	=> "directory",
		group	=>	$install_group,
		owner	=>	$install_user,
		require => User[$install_user]
	}
	
	exec { "tar xvfz /vagrant_data/installers/tomcat/${tomcat_version}/apache-tomcat.tar.gz":
		path	=>	'/usr/bin:/usr/sbin:/bin:/sbin',
		group	=>	$install_group,
		user	=>	$install_user,
		cwd		=> '/u01/app/apache',
		require => File['/u01/app/apache']
	}
	
	file { "${catalina_home}/conf/tomcat-users.xml":
		content => template('tomcat/tomcat-users.erb'),
		require => Exec["tar xvfz /vagrant_data/installers/tomcat/${tomcat_version}/apache-tomcat.tar.gz"]
	}
	
	file { "${catalina_home}/conf/server.xml":
		content => template('tomcat/server.erb'),
		require => Exec["tar xvfz /vagrant_data/installers/tomcat/${tomcat_version}/apache-tomcat.tar.gz"]
	}
	
	file { "/etc/init.d/tomcat":
		content => template('tomcat/tomcat.erb'),
		mode 	=> "+x",
		require => [File["${catalina_home}/conf/server.xml"],
					File["${catalina_home}/conf/tomcat-users.xml"]]
	}
	
	exec { 'sudo chkconfig --add tomcat':
		path	=>	'/usr/bin:/usr/sbin:/bin:/sbin',
		require => File["/etc/init.d/tomcat"]
	}
	
	firewall { '100 allow http and https access':
		port   	=> [$tomcat_http_port, $tomcat_https_port],
		proto  	=> tcp,
		action 	=> accept,
	}
	
	file { '/etc/rc5.d/S71tomcat':
		ensure 	=> 'link',
		target 	=> '/etc/init.d/tomcat',
		require => File['/etc/init.d/tomcat']
	}

	service { 'tomcat':
		ensure 	=> running,
		enable 	=> true,
		require => File['/etc/rc5.d/S71tomcat']
	}
}