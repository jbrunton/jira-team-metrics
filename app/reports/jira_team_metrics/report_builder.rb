class JiraTeamMetrics::ReportBuilder
  attr_reader :board
  attr_reader :report_key
  attr_reader :fragment_keys

  def initialize(board, report_key, fragment_keys)
    @board = board
    @report_key = report_key
    @fragment_keys = fragment_keys
  end

  def build
    if board.training_projects.any?
      Rails.logger.info "Training data available for #{board.name}, building reports."
      fragment_keys.each do |fragment_key|
        build_fragment(fragment_key)
      end
    else
      Rails.logger.info "No training data available for #{board.name}, skipping reports."
    end
  end

  def build_fragment(fragment_key)
    fragment = board.report_fragments.find_or_create_by(report_key: report_key, fragment_key: fragment_key)
    fragment.contents = fragment_data_for(fragment_key)
    fragment.save
  end

  def fragment_data_for(fragment_key)
    raise "Unimplemented report fragment: #{fragment_key}"
  end
end
