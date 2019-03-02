class JiraTeamMetrics::ConfigValues
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
    puts "ConfigValues::method_missing(#{method}, #{args.join})"
    method_name = method.to_s
    value = @values.fetch(method) do
      puts "ConfigValues::method_missing - cache miss"
      if @field_types.keys.include?(method_name)
        field_type = @field_types[method_name]
        if field_type == '//rec'
          config_value_hash = @config_hash[method_name] || {}
          @values[method] = JiraTeamMetrics::ConfigValues.new(config_value_hash, @fields[method_name], parent_for(method_name))
        elsif field_type == '//arr'
          config_value_arr = @config_hash[method_name] || []
          @values[method] = JiraTeamMetrics::ConfigArray.new(config_value_arr, @fields[method_name], parent_for(method_name))
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

