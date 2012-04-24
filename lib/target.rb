class Target
  def self.setup
    puts "Setting up your deployment target in #{CONFIG.target}"
    puts CONFIG.user ? " as user #{CONFIG.user}" : ''
    CONFIG.sudo %Q(
      mkdir -p #{CONFIG.target}
      set -x
      cd #{CONFIG.target}
      git clone #{CONFIG.repo} -b #{CONFIG.branch} current
      cd #{CONFIG.target}
      mkdir -p shared
      mkdir -p scripts
      echo "#!/bin/bash\\necho \\\$0\\n" > scripts/predeploy.sample
      echo "#!/bin/bash\\necho \\\$0\\n" > scripts/postdeploy.sample
      chmod 755 scripts/*
    )
    puts "The deploy will run #{CONFIG.prescript} before the update if it exists" if CONFIG.prescript?
    puts "The deploy will run #{CONFIG.postscript} after the update if it exists" if CONFIG.postscript?
  end

  def self.cold?
    !Dir.exist?(CONFIG.target)
  end

  def initialize
  end

  def sudo
  end

  def ssh
  end

  def local
  end
end

