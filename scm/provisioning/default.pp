# default.php
hiera_include('classes','')

node 'db.home' {}

node 'odb.home' { }

node 'osb.home' { Class['jrockit::usergroup'] -> Class['jrockit::install'] -> Class['weblogic::installer'] -> Class['osb'] -> Class['osb::createdomain'] }

node 'cisrvr.home' {}

node 'wls12c.home' {}

node 'jssrvr.home' {}

node 'mysql.home' {}