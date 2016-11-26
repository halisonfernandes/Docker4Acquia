<?php

$databases = array (
  'default' =>
  array (
    'default' =>
    array (
      'database' => 'subscription-example',
      'username' => 'root',
      'password' => 'root',
      'host' => 'subscription-example-percona',
      'port' => '3306',
      'driver' => 'mysql',
      'prefix' => '',
    ),
  ),
);

$conf['memcache_servers'] = array('subscription-example-memcached:11211' => 'default');
