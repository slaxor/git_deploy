#!/usr/bin/env ruby
# use it as a git update hook like so
#   ${HOME}/githooks/deploy.rb $* $0
# so it gets called with
#   /home/slash/githooks/deploy.rb refs/heads/staging b5df4496d86841594b140679fa73565e8dc48df7 b0ef9647534a10fffac9ca61b3afd2e9e80e4285 /home/slash/gitrepos/gitplay.git
# you should tell your git what to do with each branch using git config
#   git config deploy.staging.target /tmp/gitplay
#   git config deploy.staging.user slash
#   git config deploy.staging.prescript /tmp/gitplay/predeploy
#   git config deploy.staging.postscript /tmp/gitplay/postdeploy
#   git config deploy.staging.tag true
# only the first is mandatory and if you configure a user you need to make sure it is
# allowed to run the commands as that user without being asked for a password
#
Dir[File.join(File.dirname(__FILE__), '..', 'lib', '**', '*.rb')].each do |file|
  require file
end

CONFIG = DeployConfig.new(ARGV)

exit(0) unless CONFIG.deployable?

Target.setup if Target.cold?

Deployment.run

