# == Class consul_template::config
#
# This class is called from consul_template for service config.
#
class consul_template::config (
  $config_hash = {},
  $purge       = true,
) {
  # Using our parent module's pretty_config & pretty_config_indent just because
  $content_full = consul_sorted_json($config_hash, $consul::pretty_config, $consul::pretty_config_indent)
  # remove the closing } and it's surrounding newlines
  $content = $content_full

  $concat_name = 'consul-template/config.json'
  concat::fragment { 'consul-service-pre':
    target  => $concat_name,
    # add the opening template array so that we can insert watch fragments
    content => "${content}",
    order   => '1',
  }

  file { [$consul_template::config_dir, "${consul_template::config_dir}/config"]:
    ensure  => 'directory',
    purge   => $purge,
    recurse => $purge,
    owner   => $consul_template::user,
    group   => $consul_template::group,
    mode    => '0755',
  } ->
  concat { $concat_name:
    path   => "${consul_template::config_dir}/config/config.json",
    owner  => $consul_template::user,
    group  => $consul_template::group,
    mode   => $consul_template::config_mode,
    notify => Service['consul-template'],
  }

}
