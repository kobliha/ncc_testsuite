class NccTestsuite::Repository
  require 'rubygems'

  # Lists all currently known repositories (aliases)
  def self.all
    $config['Repos'].keys.sort
  end

  # returns URL for a repository alias
  def self.url repo_alias
    url = $config['Repos'][repo_alias]

    if url == nil || url == ""
      raise "Repository URL for #{repo_alias} is not defined"
    end

    url
  end
end
