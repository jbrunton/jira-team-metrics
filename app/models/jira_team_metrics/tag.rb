Tag = Struct.new(:name, :path) do
  def json_path
    @json_path ||= JsonPath.new(path)
  end
end
