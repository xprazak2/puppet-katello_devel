# Handles initialization and setup of the Rails app
class katello_devel::setup {

  if $::katello_devel::use_rvm or $::katello_devel::manage_bundler {

    $pidfile = "${::katello_devel::foreman_dir}/tmp/pids/server.pid"

    $seed_env = [
      "SEED_ORGANIZATION=${::katello_devel::initial_organization}",
      "SEED_LOCATION=${::katello_devel::initial_location}",
      "SEED_ADMIN_PASSWORD=${::katello_devel::admin_password}",
    ]

    katello_devel::bundle { 'install --without mysql:mysql2 --retry 3 --jobs 3': } ->
    exec { 'npm install':
      cwd       => $::katello_devel::foreman_dir,
      user      => $::katello_devel::user,
      logoutput => 'on_failure',
      path      => "/home/${::katello_devel::user}/.rvm/bin:/usr/bin:/bin",
    } ->
    katello_devel::bundle { 'exec rake webpack:compile': } ->
    katello_devel::bundle { 'exec rake db:migrate': } ->
    katello_devel::bundle { 'exec rake db:seed':
      environment => $seed_env,
    } ~>
    katello_devel::bundle { 'exec rails s -d':
      unless => "/usr/bin/pgrep --pidfile ${pidfile}",
    } ->
    Class['foreman_proxy::register'] ->
    exec { 'destroy rails server':
      command   => "/usr/bin/pkill -9 --pidfile ${pidfile}",
      logoutput => 'on_failure',
      timeout   => '600',
    }
  }

}
