class NccTestsuite::Chroot
  require 'rubygems'
  require 'fileutils'
  require 'shellwords'

  require 'ncc_testsuite/zypper'

  def self.prepare(chroot_dir, repositories)
    check_dir chroot_dir
    create_chroot_dir chroot_dir
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

end