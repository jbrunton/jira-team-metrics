
class DomainConfig
  attr_reader :config_hash

  def initialize(config_hash)
    @config_hash = config_hash
  end

  def fields
    config_hash['fields'] || []
  end

  def validate
    rx = Rx.new({ :load_core => true })
    schema = rx.make_schema(YAML.load(SCHEMA))
    schema.check!(config_hash)
  end

  SCHEMA = <<~END
    type: "//rec"
    optional:
      fields:
        type: "//arr"
        contents: "//str"
      link_types:
        type: "//arr"
        contents: "//str"
      increments:
        type: "//arr"
        contents:
          type: "//rec"
          required:
            issue_type: "//str"
            inward_link_type: "//str"
  END
end