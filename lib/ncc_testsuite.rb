class NccTestsuite
  require 'fileutils'
  require 'shellwords'

  # For running the library from git checkout
  unless $LOAD_PATH.include? File.dirname(__FILE__)
    $LOAD_PATH << File.dirname(__FILE__)
  end

  DEFAULT_ROOT_DIR = '/'

  @@root_directory = DEFAULT_ROOT_DIR

  def self.root_directory=(root_dir)
    if (root_dir == nil || root_dir == "")
      root_dir = DEFAULT_ROOT_DIR
    else
      puts "Using changed root dir #{root_dir}"
    end


    unless File.exists? root_dir
      raise "Directory #{root_dir} doesn't exist"
    end

    unless File.directory? root_dir
      raise "Path #{root_dir} is not a directory"
    end

    @@root_directory = root_dir
  end

  def self.root_directory
    @@root_directory
  end

  def self.run_chrooted?
    (root_directory != DEFAULT_ROOT_DIR)
  end

  def self.escaped_root_directory
    Shellwords::escape(root_directory)
  end
end
