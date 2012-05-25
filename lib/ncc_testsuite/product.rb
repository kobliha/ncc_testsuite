class NccTestsuite::Product
  require 'rubygems'
  require 'fileutils'
  require 'shellwords'

  PRODUCTS_DIR = '/etc/products.d/'
  DATA_DIR = File.join(File.dirname(__FILE__),"../../data/products/")
  PRODUCT_DATA_SUFFIX = '.tgz'
  PRODUCT_SUFFIX = '.prod'
  BASE_PRODUCT = 'baseproduct'
  BASEPRODUCT_FILE = File.join(PRODUCTS_DIR, BASE_PRODUCT)

  def self.installed_product_rpms
    cmd = 'rpm -qa | grep release | grep -v release-notes'
    out = run cmd
    out.split "\n"
  end

  def self.uninstall_rpm rpm
    cmd = "rpm -e --nodeps " + Shellwords::escape(rpm)
    run cmd
  end

  # Removes all installed product packages
  # Some products might still remain 'installed' if they were not deployed
  # by installing RPMs
  def self.uninstall_all_product_rpms
    installed_product_rpms.each do |rpm|
      puts "Uninstalling product RPM #{rpm}"
      uninstall_rpm rpm
    end
  end

  # Removes all installed products (files)
  def self.remove_all_installed_products
    Dir["#{PRODUCTS_DIR}/*"].each do |file|
      begin
        FileUtils.rm_rf file
      rescue => e
        raise "Unable to remove file  #{file}: #{e.message}"
      end
    end
  end

  # List all product available for installation
  def self.available_products
    Dir["#{DATA_DIR}/*#{PRODUCT_DATA_SUFFIX}"].collect{|product| File.basename(product, PRODUCT_DATA_SUFFIX)}
  end

  # Returns whether a given product is available
  def self.is_available? product
    available_products.include?(product)
  end

  # Installs a given product into libzypp products directory
  def self.install product
    raise "Product #{product} is not available for installation" unless is_available?(product)

    puts "Installing product #{product}"
    cmd = "tar --directory=/ -xvzf #{DATA_DIR}/#{product}#{PRODUCT_DATA_SUFFIX}"
    run cmd
  end

  def self.baseproduct_exists?
    File.exists? BASEPRODUCT_FILE
  end

  # Creates a base-product symlink
  def self.set_baseproduct product
    begin
      if baseproduct_exists?
        puts "Removing old baseproduct file #{BASEPRODUCT_FILE}"
        File.rm_rf BASEPRODUCT_FILE
      end
    rescue => e
      raise "Unable to remove file  #{BASEPRODUCT_FILE}: #{e.message}"
    end

    product_file = File.join(PRODUCTS_DIR, "#{product}#{PRODUCT_SUFFIX}")

    unless File.exists? product_file
      raise "Product file #{product_file} does not exist, cannot create baseproduct"
    end

    begin
      File.symlink(product_file, BASEPRODUCT_FILE)
    rescue => e
      raise "Cannot create base product file #{BASEPRODUCT_FILE} from #{product_file}: #{e.message}"
    end
  end

  # Does the hard job:
  #   * Removes all installed product RPMs
  #   * Removes all other product files from libzypp products directory
  #
  # This might break your system!
  def self.cleanup
    uninstall_all_product_rpms
    remove_all_installed_products
  end

  private

  def self.run command
    cmd = `#{command}`
  end
end
