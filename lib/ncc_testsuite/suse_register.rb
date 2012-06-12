class NccTestsuite::SuseRegister
  require 'rubygems'
  require 'inifile'
  require 'fileutils'
  require 'shellwords'

  require 'ncc_testsuite/config'

  SUSE_REGISTER_CONF = '/etc/zypp/credentials.d/NCCcredentials'
  DEFAULT_CONFIG_FILE = '/etc/ncc_registration.conf'
  LOG_FILE = '/var/log/suse_register'
  DEFAULT_LOCALE = 'en_US'

  def self.register
    email = "-a email=" + Shellwords::escape($config["Global"]["email"])
    regcodes = $config["RegCodes"].collect{|key, value|
      "-a " + Shellwords::escape(key) + "=" + Shellwords::escape(value)
    }.join(" ")
    cmd = "suse_register --restore-repos --force-registration #{email} #{regcodes} --log #{Shellwords::escape(LOG_FILE)} --locale=#{DEFAULT_LOCALE}"
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
