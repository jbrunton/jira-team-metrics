class JiraTeamMetrics::TagsService
  def initialize(board, notifier)
    @board = board
    @notifier = notifier
  end

  def apply_tags
    @notifier.notify_status('tagging issues')
    tags = @board.domain.config.tags.map { |tag| Tag.new(tag.name, tag.path) }
    @board.issues.reload.each do |issue|
      issue.tags = tags
        .select { |tag| tag.json_path.on(issue.json).any? }
        .map{ |tag| tag.name }
      issue.save
    end
  end

  Tag = Struct.new(:name, :path) do
    def json_path
      @json_path ||= JsonPath.new(path)
    end
  end
end
