class Deployment
  def self.run
    puts "\x1b[0m\x1b[34m"
    print "Starting deployment of #{CONFIG.branch} to #{CONFIG.target} ..."
      CONFIG.sudo CONFIG.prescript if CONFIG.prescript?
      CONFIG.sudo %Q(
        cd #{CONFIG.target}/current
        unset GIT_DIR
        git pull origin #{CONFIG.branch}
      )
      CONFIG.sudo CONFIG.postscript if CONFIG.postscript?

      CONFIG.sudo %Q(
        cd #{CONFIG.target}/current
        git tag #{CONFIG.tag}
        git push --tags
    ) if CONFIG.tag?

    puts ' done'
  ensure
    puts "\x1b[0m"
  end
end

