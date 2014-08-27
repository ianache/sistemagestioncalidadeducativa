# == Class:  hudson
#
# Hudson
#
# == Authors
#
# Ilver Anache <ilver.anache@gmail.com>
class hudson ($hudson_version = hiera('hudson_version','3.1.2')) {
	$tomcat_version = hiera('tomcat_version')
	
	exec { "install_hudson":
		command => "cp /vagrant_data/installers/hudson/${hudson_version}/hudson.war .",
		path	=>	'/usr/bin:/usr/sbin:/bin:/sbin',
		cwd		=> "/u01/app/apache/apache-tomcat-${tomcat_version}/webapps/",
		creates => "/u01/app/apache/apache-tomcat-${tomcat_version}/webapps/"
	}	
}