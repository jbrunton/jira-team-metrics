class JiraTeamMetrics::Config
  attr_reader :config_hash

  def initialize(config_hash, schema = nil, parent = nil)
    @config_hash = config_hash
    @schema = schema
    @parent = parent
    @config_value = ConfigValues.new(config_hash, schema, @parent)
  end

  def validate
    rx = Rx.new({ :load_core => true })
    rx.add_prefix('metrics', 'jira-team-metrics/')
    reports_schema_path = File.join(__dir__, 'schemas/types', 'reports_config.yml')
    rx.learn_type('jira-team-metrics/reports-config', YAML.load_file(reports_schema_path))
    schema = rx.make_schema(@schema)
    schema.check!(config_hash)
  end

  def get(key, default = nil)
    @config_hash.dig(*key.split('.')) || @parent.try(:get, key) || default
  end

  # def project_type
  #   get('project_type')
  # end

  def self.for(object)
    if object.class == JiraTeamMetrics::Domain
      schema_path = File.join(__dir__, 'schemas', 'domain_config.yml')
      parent = nil
    elsif object.class == JiraTeamMetrics::Board
      schema_path = File.join(__dir__, 'schemas', 'board_config.yml')
      parent = JiraTeamMetrics::Config.for(object.domain)
    else
      raise "Unexpected class: #{object.class}"
    end
    schema = YAML.load_file(schema_path)
    JiraTeamMetrics::Config.new(object.config_hash, schema, parent)
  end

  def self.domain_config(config_hash)
    JiraTeamMetrics::Config.new(config_hash, 'board_config')
  end

  def method_missing(method, *args)
    @config_value.method_missing(method, *args)
  end

  def has_key?(key)
    @config_value.has_key?(key)
  end

  class ConfigValues
    def initialize(config_hash, schema, parent)
      @config_hash = config_hash
      @schema = schema
      @parent = parent

      @fields = (@schema['required'] || {}).merge(@schema['optional'] || {})
      @field_types = @fields.map{ |field, field_type| [field, field_type.class == String ? field_type : field_type['type']] }.to_h
      @values = {}
    end

    def has_key?(key)
      @field_types.keys.include?(key)
    end

    def method_missing(method, *args)
      method_name = method.to_s
      value = @values.fetch(method) do
        if @field_types.keys.include?(method_name)
          field_type = @field_types[method_name]
          if field_type == '//rec'
            config_value_hash = @config_hash[method_name] || {}
            @values[method] = ConfigValues.new(config_value_hash, @fields[method_name], parent_for(method_name))
          elsif field_type == '//arr'
            config_value_arr = @config_hash[method_name] || []
            @values[method] = ConfigArray.new(config_value_arr, @fields[method_name], parent_for(method_name))
          elsif field_type == '/metrics/reports-config'
            config_value_hash = @config_hash[method_name] || {}
            schema = YAML.load_file(File.join(__dir__, 'schemas', 'types', 'reports_config.yml'))
            @values[method] = JiraTeamMetrics::Config.new(config_value_hash, schema, parent_for(method_name))
          else
            @values[method] = @config_hash[method_name]
          end
        else
          raise "Unknown key: #{method}"
        end
      end
      if value.nil?
        if @parent.nil?
          args[0]
        else
          @parent.method_missing(method, *args)
        end
      else
        value
      end
    end

    private
    def schema_for(key)
      field = (@schema['required'][key] || @schema['optional'][key])
      field.class == String ? field : field['type']
    end

    def parent_for(key)
      unless @parent.nil?
        if @parent.has_key?(key)
          @parent.method_missing(key.to_sym)
        end
      end
    end
  end

  class ConfigArray
    include Enumerable

    def initialize(config_arr, schema, parent)
      @config_arr = config_arr
      @schema = schema
      @parent = parent
      @values = {}
    end

    def each(&block)
      @config_arr.count.times do |index|
        block.call(self[index])
      end
    end

    def [](index)
      @values.fetch(index) do
        schema_contents = @schema['contents']
        if schema_contents.is_a?(Hash) && schema_contents['type'] == '//rec'
          config_value_hash = @config_arr[index] || {}
          @values[index] = ConfigValues.new(config_value_hash, @schema['contents'], nil)
        elsif schema_contents.is_a?(Hash) && schema_contents['type'] == '//arr'
          config_value_arr = @config_arr[index] || []
          @values[index] = ConfigArray.new(config_value_arr, @schema['contents'], nil)
        else
          @values[index] = @config_arr[index]
        end
      end
    end
  end
end
