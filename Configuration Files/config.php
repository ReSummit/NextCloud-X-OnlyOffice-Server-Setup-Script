<?php
$CONFIG = array (

  # Don't forget to add your domain to the list of trusted domains! Should look like this:

  'trusted_domains' =>
  array (
    0 => 'localhost:7887',
    1 => '(Your domain)',
  )

  # Other code ending with 'version'
  
  # Add this section of the configuration file into the configuration file that is mentioned in the script
  'overwritehost' => '(Your domain name)',
  'overwriteprotocol' => 'https',
  'overwritewebroot' => '/nextcloud',
  'overwrite.cli.url' => 'https://(Your domain name)/nextcloud',
  'htaccess.RewriteBase' => '/nextcloud',

  # Other code below starting with 'dbname'
);
