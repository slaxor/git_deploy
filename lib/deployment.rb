class Deployment
  def self.run
    print "Starting deployment of #{CONFIG.branch} to #{CONFIG.target} ..."
      CONFIG.sudo CONFIG.prescript if CONFIG.prescript?
      CONFIG.sudo %Q(
        cd #{CONFIG.target}/current
        git pull origin #{CONFIG.branch}
      )
      CONFIG.sudo CONFIG.postscript if CONFIG.postscript?

      CONFIG.sudo %Q(
        cd #{CONFIG.target}/current
        git tag #{CONFIG.tag}
        git push --tags
    ) if CONFIG.tag?

    puts ' done'
  end
end

