class NccTestsuite::Chroot
  require 'rubygems'
  require 'fileutils'
  require 'shellwords'
  require 'ftools'

  require 'ncc_testsuite/zypper'
  require 'ncc_testsuite/config'

  RPM_DB = '/var/lib/rpm/Packages'

  def self.create chroot_dir
    check_dir chroot_dir
    create_chroot_dir chroot_dir
  end

  def self.prepare(chroot_dir, repositories)
    add_repositories repositories
    import_gpg_keys
    mount_directories
    install_required_packages
    rebuild_rpm_database
    polish
    puts "Done"
  end

  private

  def self.check_dir chroot_dir
    if chroot_dir == nil || chroot_dir == ""
      raise "Chroot directory has to be set"
    end
  end

  def self.create_chroot_dir chroot_dir
    if File.exists? chroot_dir
      raise "Directory #{chroot_dir} already exists, cannot be reused"
    end

    begin
      puts "Creating directory #{chroot_dir}"
      Dir.mkdir chroot_dir
    rescue Exception => e
      raise "Cannot create directory #{chroot_dir}: #{e.message}"
    end
  end

  def self.add_repositories repositories
    repositories.each do |repo_alias|
      unless $config['Repos'][repo_alias]
        raise "Unknown repository #{repo_alias}, check your config file"
      end

      puts "Adding repository #{repo_alias}"
      NccTestsuite::Zypper::add_repository $config['Repos'][repo_alias], repo_alias
    end
  end

  def self.import_gpg_keys
    puts "Refreshing and importing all keys..."
    NccTestsuite::Zypper::auto_import_keys
  end

   def self.mount_directories
     ['/proc', '/dev', '/sys'].each do |directory|
       bind_mount directory, File.join(NccTestsuite::root_directory, directory)
     end
   end

  def self.bind_mount original_dir, new_dir
    unless File.exists? new_dir
      puts "Creating directory #{new_dir}"
      Dir.mkdir new_dir
    end

    puts "Mounting #{original_dir} as #{new_dir}"
    cmd "mount --bind #{Shellwords::escape(original_dir)} #{Shellwords::escape(new_dir)}"
  end

  def self.install_required_packages
    required_packages = $config['Global']['required_packages'] || ""
    unless required_packages
      raise "No required packages are defined"
    end

    puts "Installing required packages: #{required_packages}"
    NccTestsuite::Zypper::install_packages required_packages.split
  end

  def self.polish
    ['/etc/resolv.conf'].each do |file|
      hardlink_file = File.join(NccTestsuite::root_directory, file)

      begin
        File.unlink hardlink_file if File.exists? hardlink_file
        File.link file, hardlink_file
      rescue Exception => e
        # Cannot hardlink, let's copy the file
        puts "Cannot hardlink #{file} -> #{hardlink_file}: #{e.message}"
        copy file, hardlink_file
      end
    end
  end

  def self.copy from, to
    begin
      cmd "cp #{Shellwords::escape(from)} #{Shellwords::escape(to)}"
    rescue Exception => e
      raise "Cannot copy #{from} to #{to}: #{e.message}"
    end
  end

  def self.rebuild_rpm_database
    rpm_db_file = File.join(NccTestsuite::root_directory, RPM_DB)

    begin
      File.unlink rpm_db_file if File.exists? rpm_db_file
    rescue Exception => e
      raise "Cannot remove file #{rpm_db_file}: #{e.message}"
    end

    cmd "chroot #{NccTestsuite::escaped_root_directory} rpm --rebuilddb"
  end

  def self.cmd command
    `#{command}`
  end

end
