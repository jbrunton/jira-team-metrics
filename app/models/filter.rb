class Filter < ApplicationRecord
  belongs_to :board
  enum filter_type: [:query_filter, :config_filter, :issue_type_filter]

  def include?(issue)
    @issue_keys ||= begin
      (issue_keys || '').split
    end
    @issue_keys.include?(issue.key)
  end

  def exclusions
    exclusions_string = issue_keys
    exclusions_string ||= ''
    exclusions_string.split
  end
end
