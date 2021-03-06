class JiraTeamMetrics::ReportBuilder
  attr_reader :board
  attr_reader :sync_history_id
  attr_reader :report_key
  attr_reader :fragment_keys

  def initialize(board, sync_history_id, report_key, fragment_keys)
    @board = board
    @sync_history_id = sync_history_id
    @report_key = report_key
    @fragment_keys = fragment_keys
  end

  def build
    fragment_keys.each do |fragment_key|
      build_fragment(fragment_key)
    end
  end

  def build_fragment(fragment_key)
    fragment = JiraTeamMetrics::ReportFragment.create(sync_history_id: sync_history_id, report_key: report_key, fragment_key: fragment_key)
    fragment.contents = fragment_data_for(fragment_key)
    fragment.save
  end

  def fragment_data_for(fragment_key)
    raise "Unimplemented report fragment: #{fragment_key}"
  end
end
