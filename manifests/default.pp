# This is the Hadoop default puppet manifest

$use_proxy=true
$proxy_host = "proxy.uni-linz.ac.at"
$proxy_port = "3128"
# $proxy_host = "secureproxy.a1.net"
# $proxy_port = "8080"

class yumproxyserver {

	
	# Use the following exec statement to add a proxy configuation for your organisation
	# Use of a Proxy server is highly recommended especially when rolling out a high number of nodes
	if $use_proxy {
		exec { 'proxy-server':
			command => '/bin/echo proxy=http://proxy.uni-linz.ac.at:3128 >> /etc/yum.conf'
		}
	}
}

# Base configuration for all HDP2.2 nodes
class hwhdp {

	# Set message of the day with a little bit advertisement ;)
	file { 'motd':
                name => '/etc/motd',
                mode => '0664',
                owner   => 'root',
                group   => 'root',
                content => "\n\nWelcome to ${::fqdn} - this node is controlled by puppet and vagrant\nThis machine configuration was created by https://thebigdatadude.com/\n\n\n"
        }

	# Make sure that the machine is en_EN.UTF-8
	file { 'i18n':
		name => '/etc/sysconfig/i18n',
		mode => '0664',
		owner => 'root',
		group => 'root',
		content => "LANG=\"en_US.UTF-8\"\nSYSFONT=\"latarcyrheb-sun16\""
	}

	# Disable SELinux -> permissive
	augeas { 'selinuxpermissive':
		context => '/etc/selinux/config',
		changes => [
			"set SELINUX permissive"
		]
	}
	exec { 'selinuxpermissive-tmp':
		command => '/usr/sbin/setenforce Permissive',
		returns => [ 0, 1]
	}

	# Disable iptables firewalls
	exec { 'disable-iptables':
		command => '/sbin/service iptables save && /sbin/service iptables stop && /sbin/chkconfig iptables off'	
	}

	# Install EPEL repository
	yumrepo { 'yumepel':
		name => 'epel',
		baseurl => 'http://download.fedoraproject.org/pub/epel/6/$basearch',
		gpgkey => 'https://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-6',
		enabled => 1,
		gpgcheck => 1
	}

	# Add the Hortonworks repo
	yumrepo { 'yumhortonworkshdp22':
		name => 'hdp',
		baseurl => 'http://public-repo-1.hortonworks.com/HDP/centos6/2.x/GA/2.2.0.0',
		gpgkey => 'http://public-repo-1.hortonworks.com/HDP/centos6/2.x/GA/2.2.0.0/RPM-GPG-KEY/RPM-GPG-KEY-Jenkins',
		enabled => 1,
		gpgcheck => 1,
		require => Yumrepo [ 'yumepel' ]  
	}
	yumrepo { 'yumhortonworksutils17':
		name => 'hdputils',
		baseurl => 'http://public-repo-1.hortonworks.com/HDP-UTILS-1.1.0.20/repos/centos6',
		gpgkey => 'http://public-repo-1.hortonworks.com/HDP/centos6/2.x/GA/2.2.0.0/RPM-GPG-KEY/RPM-GPG-KEY-Jenkins',
		enabled => 1,
		gpgcheck => 1,
		require => Yumrepo [ 'yumhortonworkshdp22' ]  
	}
	yumrepo { 'yumhortonworksambari20':
		name => 'ambari',
		baseurl => 'http://public-repo-1.hortonworks.com/ambari/centos6/2.x/updates/2.0.0',
		gpgkey => 'http://public-repo-1.hortonworks.com/ambari/centos6/RPM-GPG-KEY/RPM-GPG-KEY-Jenkins',
		enabled => 1,
		gpgcheck => 1,
		require => Yumrepo [ 'yumhortonworksutils17' ]
	}

	# Inject a custom hosts file which contains names for our cluster
	file { 'etc-hosts':
		path => '/etc/hosts',
		content => "127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4\n::1         localhost localhost.localdomain localhost6 localhost6.localdomain6\n\n192.168.32.10	ambari.sandbox.thebigdatadude.com ambari\n192.168.32.31	node001.sandbox.thebigdatadude.com node001\n192.168.32.32	node002.sandbox.thebigdatadude.com node002\n192.168.32.33	node003.sandbox.thebigdatadude.com node003\n192.168.32.34	node004.sandbox.thebigdatadude.com node004"
	}
	# removed from 127.0.0.1 ${::fqdn} ${::hostname} ... seems that the namenode does not bind correctly

	# Inject root SSH keys
	file { 'root-ssh-dir':
		path => '/root/.ssh',
		ensure => 'directory',
		owner => 'root',
		group => 'root',
		mode => '700'
	}
	file { 'root-ssh-private-key':
		path => '/root/.ssh/id_rsa',
		owner => 'root',
		group => 'root',
		mode => '600',
		source => '/vagrant/files/ssh_keys/root.key',
		require => File[ 'root-ssh-dir' ]
	}
	file { 'root-ssh-public-key':
		path => '/root/.ssh/authorized_keys',
		owner => 'root',
		group => 'root',
		mode => '600',
		source => '/vagrant/files/ssh_keys/root.key.pub',
		require => File[ 'root-ssh-dir' ]
	}

	# NTP service
	package { 'ntp':
		name   => "ntp",
		ensure => present
	}
 	service { 'ntp-services':
		name   => "ntpd",
		ensure => running,
		require => Package[ntp] 
	}

	# Install some base tools
	$cmdtools = [ "screen", "vim-enhanced", "htop" ]
	package { $cmdtools:
		ensure => 'installed',
		require => Yumrepo[ 'yumepel' ]
	}
}

# Ambari Server needs to have Ambari installed
node "ambari" {

	class { 'yumproxyserver' : }
	class { 'hwhdp' : }

	if $use_proxy {
		file { 'ambari-proxy': 
			path => '/var/lib/ambari-server/ambari-env.sh',
			content => "AMBARI_PASSHPHRASE=\"DEV\"\nexport AMBARI_JVM_ARGS=\$AMBARI_JVM_ARGS' -Xms512m -Xmx2048m -Djava.security.auth.login.config=/etc/ambari-server/conf/krb5JAASLogin.conf -Djava.security.krb5.conf=/etc/krb5.conf -Djavax.security.auth.useSubjectCredsOnly=false -Dhttp.proxyHost=proxy.uni-linz.ac.at -Dhttp.proxyPort=3128'\nexport PATH=\$PATH:/var/lib/ambari-agent",
			before => Exec [ 'ambari-server-setup' ],
			require => Package [ 'ambari-server' ]
		}
	}

	# Install the ambari package
	package { "ambari-server":
		ensure => 'installed',
		require => Yumrepo[ 'yumhortonworksambari20' ]
	}

	# Configure ambari server
	exec { "ambari-server-setup":
		command => '/usr/sbin/ambari-server setup -s',
		require => Package[ 'ambari-server' ],
		timeout => 0
	}

	# Ensure the ambari-server is running
	service { "ambari-server-service":
		name => "ambari-server",
		ensure => "running",
		require => Exec[ 'ambari-server-setup' ]
	}

	# Sometimes the above service is not working so do it manually
	exec { "ambari-server-service-fallback":
		command => "/etc/init.d/ambari-server start",
		require => Service[ 'ambari-server-service' ]
	}

	exec { "ambari-server-service-register":
		command => "/sbin/chkconfig --add ambari-server",
		returns => [ 0, 1],
		require => Exec [ 'ambari-server-setup' ]
	}
}

# Node definitions
node /^node\d+$/ {
	class { 'yumproxyserver' : }
	class { 'hwhdp' : }

	# Disable Transparent Huge Pages on the worker nodes
	exec { 'disalble-transparent-huge-pages':
		command => "/bin/echo never > /sys/kernel/mm/redhat_transparent_hugepage/enabled"
	}
}
