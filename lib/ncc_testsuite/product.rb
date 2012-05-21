class NccTestsuite::Product
  require 'rubygems'
  require 'fileutils'

  PRODUCTS_DIR = '/etc/products.d/'

  def self.list_installed_product_rpms
    cmd = 'rpm -qa | grep release | grep -v release-notes'
    out = run cmd
    out.split "\n"
  end

  def self.uninstall_rpm rpm
    cmd = "rpm -e --nodeps '#{rpm}'"
    run cmd
  end

  # Removes all installed product packages
  # Some products might still remain 'installed' if they were not deployed
  # by installing RPMs
  def self.uninstall_all_product_rpms
    list_installed_product_rpms.each do |rpm|
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

  def self.cleanup
    uninstall_all_product_rpms
    remove_all_installed_products
  end

  private

  def self.run command
    cmd = `#{command}`
  end
end
