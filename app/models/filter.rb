class Filter < ApplicationRecord
  belongs_to :board
  enum filter_type: [:query_filter, :config_filter, :issue_type_filter]

  def include?(issue)
    @issue_keys ||= begin
      if config_filter?
        board.exclusions
      else
        (issue_keys || '').split
      end
    end
    @issue_keys.include?(issue.key)
  end
end
