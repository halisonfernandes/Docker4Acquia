<?php

$databases = array (
  'default' =>
  array (
    'default' =>
    array (
      'database' => 'subscription-example',
      'username' => 'root',
      'password' => 'admin',
      'host' => 'subscription-example-percona',
      'port' => '',
      'driver' => 'mysql',
      'prefix' => '',
    ),
  ),
);

$conf['memcache_servers'] = array('subscription-example-memcached:11211' => 'default');
