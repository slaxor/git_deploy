#!/usr/bin/env ruby
Dir[File.join(File.dirname(__FILE__), '..', 'lib', '**', '*.rb')].each do |file|
  require file
end

CONFIG = DeployConfig.new(ARGV)

exit(0) unless CONFIG.deployable?
post_update = File.join(CONFIG.repo, 'hooks', 'post-update')
if File.exist?(post_update)
  File.open(post_update, File::APPEND|File::WRONLY) do |f|
    f.puts("#{File.dirname(File.absolute_path(__FILE__))}/deploy.rb #{CONFIG.ref} #{CONFIG.old} #{CONFIG.new} #{CONFIG.repo}")
    f.puts("sed -i '/#{CONFIG.old} #{CONFIG.new}/d' #{post_update}")
  end
else
  File.open(post_update, File::CREAT|File::WRONLY) do |f|
    f.puts('#!/bin/bash')
    f.puts("#{File.dirname(File.absolute_path(__FILE__))}/deploy.rb #{CONFIG.ref} #{CONFIG.old} #{CONFIG.new} #{CONFIG.repo}")
    f.puts('rm $0')
  end
  File.chmod(0755, post_update)
end


