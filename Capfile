# frozen_string_literal: true

%w[setup deploy scm/git pending bundler rails passenger]
  .each { |r| require "capistrano/#{r}" }
install_plugin Capistrano::SCM::Git

Dir.glob('lib/capistrano/tasks/*.rake').each { |r| import r }
