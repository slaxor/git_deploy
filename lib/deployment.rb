class Deployment
  def self.run
    puts "\x1b[0m\x1b[34m"
    print "Starting deployment of #{CONFIG.branch} to #{CONFIG.target} ..."
    CONFIG.remote_run CONFIG.prescript if CONFIG.prescript?

    CONFIG.remote_run %Q(
      cd #{CONFIG.target}/current
      unset GIT_DIR
      git pull origin #{CONFIG.branch}
    )

    CONFIG.remote_run CONFIG.postscript if CONFIG.postscript?

    %x(
      unset GIT_DIR
      cd #{CONFIG.repo}
      git tag #{CONFIG.tag}
    ) if CONFIG.tag?

    puts ' done'
  ensure
    puts "\x1b[0m"
  end
end

