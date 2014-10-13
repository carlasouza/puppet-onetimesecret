# == Class: ontimesecret
#
# Include this class on your node to have onetimesecret running with default configuration
#
# === Examples
#
#  include ontimesecret
#
# === Authors
#
# Carla Souza <contact@carlasouza.com>
#
# === Copyright
#
# Copyright 2014 Carla Souza
#
class ontimesecret {

  user { 'ots':
    ensure => present,
    home   => '/var/lib/onetime'
  }

  # Dependencies
  package { [ 'redis-server', 'ntp', 'build-essential', 'libyaml-dev', 'libevent-dev',
              'zlib1g', 'zlib1g-dev', 'openssl', 'libssl-dev', 'libxml2', 'wget' ]:
    ensure => installed
  }

  # Ruby requirements
  package { [ 'ruby1.9.1', 'ruby1.9.1-dev', 'bundler' ]:
    ensure => installed
  }

  # Using foreman as process manager
  package {'installforeman':
    name     => 'foreman',
    ensure   => 'installed',
    provider => 'gem'
  }

  exec {'download-latest-onetime':
    unless  => '/usr/bin/test -f /etc/onetime/config',
    command => '/usr/bin/wget -q -O /tmp/onetime.zip https://github.com/onetimesecret/onetimesecret/archive/master.zip',
    creates => '/tmp/onetime.zip',
    notify  => Exec['unpack']
  }

  exec { 'unpack':
    command     => '/usr/bin/unzip /tmp/onetime.zip -d /var/lib/onetime/ && /bin/mv /var/lib/onetime/onetimesecret-master/* /var/lib/onetime/',
    require     => File['/var/lib/onetime'],
    notify      => Exec['bundle'],
    user        => 'ots',
    refreshonly => true
  }

  exec { 'bundle':
    require     => Package['bundler'],
    cwd         => '/var/lib/onetime',
    command     => '/usr/bin/bundle install --deployment --frozen --without=dev --gemfile /var/lib/onetime/Gemfile',
    user        => 'ots',
    refreshonly => true
  }

  File {
    require => User['ots'],
    owner   => 'ots',
    mode    => 0600,
  }

  #TODO replace some of these file resources with templates
  file {
    [ '/etc/onetime', '/var/log/onetime', '/var/run/onetime', '/var/lib/onetime']:
      ensure  => directory;
    '/etc/onetime/redis.conf':
      require => File['/etc/onetime'],
      source  => 'puppet:///modules/onetimesecret/redis.conf';
    '/etc/onetime/config':
      require => File['/etc/onetime'],
      source  => 'puppet:///modules/onetimesecret/config';
    '/etc/onetime/fortune':
      require => File['/etc/onetime'],
      source  => 'puppet:///modules/onetimesecret/fortune';
    '/var/lib/onetime/Procfile.production':
      require => File['/var/lib/onetime'],
      source  => 'puppet:///modules/onetimesecret/Procfile.production',
  }

  # Start foreman to boot up processes
  exec { 'foreman':
    require => [ Package['installforeman'], File['/var/lib/onetime/Procfile.production'] ],
    command => '/usr/local/bin/foreman start -f /var/lib/onetime/Procfile.production &',
    cwd     => '/var/lib/onetime',
    user    => 'ots',
  }
}
