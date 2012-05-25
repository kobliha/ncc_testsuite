class NccTestsuite::Zypper
  require 'rubygems'
  require 'xmlsimple'

  # Lists all current repositories (XML output)
  def self.list_repositories
    xml_run('repos')["repo-list"][0]["repo"] || []
  end

  # Lists all current services (XML output)
  def self.list_services
    xml_run('services')["service-list"][0]["service"] || []
  end

  # Removes all repositories
  #
  # @returns boolean whether successful 
  def self.remove_all_repositories
    repositories = list_repositories
    return if (repositories.nil? || repositories == [])

    repositories.each {|repo|
      puts "Removing repository '#{repo["alias"]}'"
      run("zypper --non-interactive --quiet removerepo '#{repo["alias"]}'")
    }

    # Check and return whether all repositories have been removed
    repositories = list_repositories
    return (repositories.nil? || repositories == [])
  end

  # Removes all services
  #
  # @returns boolean whether successful
  def self.remove_all_services
    services = list_services
    return if (services.nil? || services == [])

    services.each {|service|
      puts "Removing service '#{service["alias"]}'"
      run("zypper --non-interactive --quiet removeservice '#{service["alias"]}'")
    }

    # Check and return whether all services have been removed
    services = list_services
    return (services.nil? || services == [])
  end

  # Removes all services and repositories
  def self.cleanup
    remove_all_services
    remove_all_repositories
  end

  # Lists all patches according to given filter criteria
  #
  # @param filter criteria, possible keys are catalog, name, version, category and status
  #
  # @example
  #   list_patches('status' => 'Needed')
  #   list_patches('version' => '1887', 'catalog' => 'SLES11-SP1-Update')
  def self.list_patches(params = [])
    out = []
    table_index = 0
    patch = {}

    # Zypper `patches` does not support XML output
    run('zypper --non-interactive --quiet patches').split("\n").each {|line|
      table_index = table_index + 1
      # Skip the first two - table header
      next if table_index < 3
      line.gsub!(/ +/, '')
      patch = line.split "|"

      out.push(
        "catalog"  => patch[0],
        "name"     => patch[1],
        "version"  => patch[2],
        "category" => patch[3],
        "status"   => patch[4]
      )
    }

    params.each {|param_key, param_value|
      out = out.select{|patch| patch[param_key] == param_value}
    }

    out
  end

  def self.xml_run command
    command = "zypper --non-interactive --xmlout #{command}"
    xml = run command
    out = XmlSimple.xml_in(xml)

    if !out["message"].nil?
      errors = out["message"].select{|hash| hash["type"] == "error"}
      error = errors.collect{|hash| hash["content"]}.join(", ")
      raise "Error running command '#{command}': #{error}"
    end

    out
  end

  private

  def self.run command
    cmd = `#{command}`
  end
end
