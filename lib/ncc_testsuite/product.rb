class NccTestsuite::Product
  require 'rubygems'

  def self.list_installed_product_rpms
    cmd = 'rpm -qa | grep release | grep -v release-notes'
    out = run cmd
    out.split "\n"
  end

  def self.uninstall_rpm rpm
    cmd = "rpm -e --nodeps '#{rpm}'"
    run cmd
  end

  def self.uninstall_all_product_rpms
    list_installed_product_rpms.each do |rpm|
      puts "Uninstalling product RPM #{rpm}"
      uninstall_rpm rpm
    end
  end

  private

  def self.run command
    cmd = `#{command}`
  end
end
