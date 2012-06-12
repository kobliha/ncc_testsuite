class NccTestsuite::SuseRegister
  require 'rubygems'
  require 'inifile'
  require 'fileutils'
  require 'shellwords'

  SUSE_REGISTER_CONF = '/etc/zypp/credentials.d/NCCcredentials'
  DEFAULT_CONFIG_FILE = '/etc/ncc_registration.conf'

  def initialize(config_file = nil)
    # The default config file is used always if exists on a system
    if File.exists?(DEFAULT_CONFIG_FILE)
      config_file = DEFAULT_CONFIG_FILE
    end

    unless File.exist? config_file
      raise IOError, "Cannot load #{config_file} config file: File does not exist"
    end

    begin
      puts "Loading configuration from #{config_file}"
      config = IniFile.load(config_file)
    rescue RuntimeError => e
      raise "Unable to read and parse configuration file #{config_file}: #{e.message}"
    end

    @config = {}

    config.each do |section, key, value|
      @config[section] ||= {}
      @config[section].merge!(config[section])
    end
  end

  def register
    email = "-a email=" + Shellwords::escape(@config["Global"]["email"])
    regcodes = @config["RegCodes"].collect{|key, value|
      "-a " + Shellwords::escape(key) + "=" + Shellwords::escape(value)
    }.join(" ")
    cmd = "suse_register --restore-repos --force-registration #{email} #{regcodes}"
    puts "Registering system..."
    puts NccTestsuite::SuseRegister::run(cmd)
  end

  def self.config_file
    File.join(NccTestsuite::root_directory, SUSE_REGISTER_CONF)
  end

  def self.cleanup
    if File.exists?(config_file)
      puts "Removing #{config_file}"
      FileUtils.rm config_file
    end
  end

  private

  def self.make_chrooted cmd
    if NccTestsuite::run_chrooted?
      "chroot #{NccTestsuite::escaped_root_directory} #{cmd}"
    else
      cmd
    end
  end

  def self.run command
    begin
        command = make_chrooted(command)
        cmd = `#{command}`
    rescue Exception => e
      raise "Cannot chroot to #{NccTestsuite::root_directory}: #{e.message}"
    end
  end
end
