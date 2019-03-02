class JiraTeamMetrics::ConfigArray
  include Enumerable

  def initialize(config_arr, schema)
    @config_arr = config_arr
    @schema = schema
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
        @values[index] = JiraTeamMetrics::ConfigValues.new(config_value_hash, @schema['contents'], nil)
      elsif schema_contents.is_a?(Hash) && schema_contents['type'] == '//arr'
        config_value_arr = @config_arr[index] || []
        @values[index] = JiraTeamMetrics::ConfigArray.new(config_value_arr, @schema['contents'])
      else
        @values[index] = @config_arr[index]
      end
    end
  end
end
