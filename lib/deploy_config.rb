class DeployConfig

  attr_reader :target, :user, :prescript, :postscript, :ref, :old, :new, :repo, :branch

  def initialize(argv)
    @ref = argv[0]
    @old = argv[1]
    @new = argv[2]
    @repo = argv[3]
    @branch = @ref.split('/')[-1]
    @options = {}
    %x(
      cd #{@repo}
      /usr/bin/git config --get-regexp 'deploy.#{@branch}'
    ).split("\n").each do |config_line|
      config_line.match(/(\w*) (.*)$/)
      instance_variable_set("@#{$1}".to_sym, $2)
    end
  end

  def deployable?
    !@target.nil?
  end

  def fresh?
    !Dir.exist?(@target)
  end

  def prescript
    @prescript || "#{@target}/scripts/predeploy"
  end

  def postscript
    @postscript || "#{@target}/scripts/postdeploy"
  end

  def prescript?
    prescript && File.exist?(prescript) && File.executable?(prescript)
  end

  def postscript?
    postscript && File.exist?(postscript) && File.executable?(postscript)
  end

  def remote_run(cmds)
    cmds.gsub!(/^\W*/, '').gsub!("\n", ' ; ').gsub!(/([<>|])/, "\\1")
    cmds = "sudo -u #{@user} #{cmds}"if @user
    puts "\nI will execute:\n#{cmds}\n"
    %x(#{cmds})
  end

  def tag?
    @tag && @tag.downcase != 'false'
  end

  def tag
    "deploy_#{branch}_#{Time.now.strftime('%Y%m%d_%H%M%S')}"
  end
end

