# @summary This module manages prometheus node graphite_exporter
# @param arch
#  Architecture (amd64 or i386)
# @param bin_dir
#  Directory where binaries are located
# @param download_extension
#  Extension for the release binary archive
# @param download_url
#  Complete URL corresponding to the where the release binary archive can be downloaded
# @param download_url_base
#  Base URL for the binary archive
# @param options
#  Options added to the startup command
# @param group
#  Group under which the binary is running
# @param init_style
#  Service startup scripts style (e.g. rc, upstart or systemd)
# @param install_method
#  Installation method: url or package (only url is supported currently)
# @param manage_group
#  Whether to create a group for or rely on external code for that
# @param manage_service
#  Should puppet manage the service? (default true)
# @param manage_user
#  Whether to create user or rely on external code for that
# @param os
#  Operating system (linux is the only one supported)
# @param package_ensure
#  If package, then use this for package ensure default 'latest'
# @param package_name
#  The binary package name - not available yet
# @param purge_config_dir
#  Purge config files no longer generated by Puppet
# @param restart_on_change
#  Should puppet restart the service on configuration change? (default true)
# @param service_enable
#  Whether to enable the service from puppet (default true)
# @param service_ensure
#  State ensured for the service (default 'running')
# @param service_name
#  Name of the graphite exporter service (default 'graphite_exporter')
# @param user
#  User which runs the service
# @param version
#  The binary release version
class prometheus::graphite_exporter (
  String $download_extension,
  Prometheus::Uri $download_url_base,
  String[1] $group,
  String[1] $package_ensure,
  String[1] $package_name,
  String[1] $service_name,
  String[1] $user,
  String[1] $version,
  String $options,
  String[1] $os                           = downcase($facts['kernel']),
  Prometheus::Initstyle $init_style       = $facts['service_provider'],
  Prometheus::Install $install_method     = $prometheus::install_method,
  Optional[Prometheus::Uri] $download_url = undef,
  String[1] $arch                         = $prometheus::real_arch,
  Stdlib::Absolutepath $bin_dir           = $prometheus::bin_dir,
  Boolean $export_scrape_job              = false,
  Optional[Stdlib::Host] $scrape_host     = undef,
  Stdlib::Port $scrape_port               = 9108,
  String[1] $scrape_job_name              = 'graphite',
  Optional[Hash] $scrape_job_labels       = undef,
  Boolean $service_enable                 = true,
  Boolean $manage_service                 = true,
  Stdlib::Ensure::Service $service_ensure = 'running',
  Boolean $restart_on_change              = true,
  Boolean $purge_config_dir               = true,
  Boolean $manage_user                    = true,
  Boolean $manage_group                   = true,
) inherits prometheus {
  $real_download_url = pick($download_url,"${download_url_base}/download/v${version}/${package_name}-${version}.${os}-${arch}.${download_extension}")

  $notify_service = $restart_on_change ? {
    true    => Service[$service_name],
    default => undef,
  }

  prometheus::daemon { 'graphite_exporter':
    install_method     => $install_method,
    version            => $version,
    download_extension => $download_extension,
    os                 => $os,
    arch               => $arch,
    real_download_url  => $real_download_url,
    bin_dir            => $bin_dir,
    notify_service     => $notify_service,
    package_name       => $package_name,
    package_ensure     => $package_ensure,
    manage_user        => $manage_user,
    user               => $user,
    group              => $group,
    manage_group       => $manage_group,
    purge              => $purge_config_dir,
    options            => $options,
    init_style         => $init_style,
    service_ensure     => $service_ensure,
    service_enable     => $service_enable,
    manage_service     => $manage_service,
    export_scrape_job  => $export_scrape_job,
    scrape_host        => $scrape_host,
    scrape_port        => $scrape_port,
    scrape_job_name    => $scrape_job_name,
    scrape_job_labels  => $scrape_job_labels,
  }
}
