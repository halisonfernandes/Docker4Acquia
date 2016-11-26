<?php

$databases = array (
  'default' =>
  array (
    'default' =>
    array (
      'database' => 'test',
      'username' => 'test',
      'password' => 'test',
      'host' => 'subscription-example-percona',
      'port' => '',
      'driver' => 'mysql',
      'prefix' => '',
    ),
  ),
);

$conf['memcache_servers'] = array('subscription-example-memcached:11211' => 'default');
