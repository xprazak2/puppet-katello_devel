# Katello Development Install
class katello_devel::install {

  package{ ['libvirt-devel', 'sqlite-devel', 'postgresql-devel', 'libxslt-devel', 'libxml2-devel', 'git', 'npm']:
    ensure => present,
  }

  katello_devel::git_repo { 'foreman':
    source          => 'xprazak2/foreman',
    github_username => $katello_devel::github_username,
    rev => 'xprazak2/install-plugins-debug'
  }

}
