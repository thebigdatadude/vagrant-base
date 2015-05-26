# This is the Hadoop default puppet manifest

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
		name => 'hortonworkshdp22',
		baseurl => 'http://public-repo-1.hortonworks.com/HDP/centos6/2.x/GA/2.2.0.0',
		gpgkey => 'http://public-repo-1.hortonworks.com/HDP/centos6/2.x/GA/2.2.0.0/RPM-GPG-KEY/RPM-GPG-KEY-Jenkins',
		enabled => 1,
		gpgcheck => 1,
		require => Yumrepo [ 'yumepel' ]  
	}
	yumrepo { 'yumhortonworksutils17':
		name => 'hortonworksutils17',
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
		content => "127.0.0.1   ${::fqdn} ${::hostname} localhost localhost.localdomain localhost4 localhost4.localdomain4\n::1         localhost localhost.localdomain localhost6 localhost6.localdomain6\n192.168.32.10	ambari.sandbox.thebigdatadude.com ambari\n192.168.32.20	master.sandbox.thebigdatadude.com master\n192.168.32.31	node001.sandbox.thebigdatadude.com node001\n192.168.32.32	node002.sandbox.thebigdatadude.com node002\n192.168.32.33	node003.sandbox.thebigdatadude.com node003"
	}

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

	# Install some base tools
	$cmdtools = [ "screen", "vim-enhanced", "htop" ]
	package { $cmdtools:
		ensure => 'installed',
		require => Yumrepo[ 'yumepel' ]
	}
}

# Ambari Server needs to have Ambari installed
node "ambari" {
	class { 'hwhdp' : }

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
}

# Single master node only to be used in dev scenarios
node "master" {
	class { 'hwhdp' : }
}

node "node001", "node002", "node003" {
	class { 'hwhdp' : }
}
