# Run a bundle command, possibly under RVM
define katello_devel::bundle(
  Array[String] $environment = [],
  $unless = undef,
  $use_rvm = $::katello_devel::use_rvm,
) {

  if $use_rvm {
    include ::katello_devel::rvm
    Class['katello_devel::rvm'] -> Exec["bundle-${title}"]
    $command = "rvm ${katello_devel::rvm_ruby} do bundle ${title}"
    $path = "/home/${::katello_devel::user}/.rvm/bin:/usr/bin:/bin:/usr/bin/env"
  } else {
    $command = "bundle ${title}"
    $path = '/usr/bin:/bin:/usr/bin/env'
  }

  exec { "bundle-${title}":
    command     => $command,
    environment => $environment + ["HOME=/home/${::katello_devel::user}"],
    cwd         => $::katello_devel::foreman_dir,
    user        => $::katello_devel::user,
    logoutput   => 'on_failure',
    timeout     => '600',
    path        => $path,
    unless      => $unless,
  }
}
