class NccTestsuite::SuseRegister
  require 'rubygems'
  require 'inifile'
  require 'fileutils'

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
    email = "-a email='" + @config["Global"]["email"] + "'"
    regcodes = @config["RegCodes"].collect{|key, value| "-a #{key}='#{value}'"}.join(" ")
    cmd = "suse_register --restore-repos --force-registration #{email} #{regcodes}"
    puts "Registering system..."
    puts NccTestsuite::SuseRegister::run(cmd)
  end

  def self.cleanup
    if File.exists?(SUSE_REGISTER_CONF)
      puts "Removing #{SUSE_REGISTER_CONF}"
      FileUtils.rm SUSE_REGISTER_CONF
    end
  end

  private

  def self.run command
    cmd = `#{command}`
  end
end
