class Target
  def self.setup
    puts "\x1b[0m\x1b[33m"
    puts "Setting up your deployment target in #{CONFIG.target}"
    puts CONFIG.user ? " as user #{CONFIG.user}" : ''
    CONFIG.remote_run %Q(
      mkdir -p #{CONFIG.target}
      cd #{CONFIG.target}
      git clone #{CONFIG.repo} -b #{CONFIG.branch} current
      mkdir -p shared
      mkdir -p scripts
      echo "#!/bin/bash\\necho \\\$0\\n" > scripts/predeploy.sample
      echo "#!/bin/bash\\necho \\\$0\\n" > scripts/postdeploy.sample
      chmod 755 scripts/*
    )
    puts "The deploy will run #{CONFIG.prescript} before the update if it exists" if CONFIG.prescript?
    puts "The deploy will run #{CONFIG.postscript} after the update if it exists" if CONFIG.postscript?
    puts "\x1b[0m"
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

