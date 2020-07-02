# frozen_string_literal: true

module YMLConfigReader
  def self.fetch(filepath, env_name)
    complete = YAML.load(ERB.new(File.read(filepath)).result)
    current = complete[env_name] || complete['default']
    current.symbolize_keys
  end
end
