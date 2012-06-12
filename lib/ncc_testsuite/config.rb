class NccTestsuite::Config
  require 'rubygems'
  require 'inifile'
  require 'fileutils'

  DEFAULT_CONFIG_FILE = '/etc/ncc_registration.conf'

    unless File.exist? DEFAULT_CONFIG_FILE
      raise IOError, "Cannot load #{DEFAULT_CONFIG_FILE} config file: File does not exist"
    end

    begin
      puts "Loading configuration from #{DEFAULT_CONFIG_FILE}"
      config = IniFile.load(DEFAULT_CONFIG_FILE)
    rescue RuntimeError => e
      raise "Unable to read and parse configuration file #{DEFAULT_CONFIG_FILE}: #{e.message}"
    end

    $config = {}

    config.each do |section, key, value|
      $config[section] ||= {}
      $config[section].merge!(config[section])
    end

end
