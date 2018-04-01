class Filter < ApplicationRecord
  belongs_to :board
  enum filter_type: [:query_filter, :config_filter]

  def include?(issue)
    @issue_keys ||= begin
      (issue_keys || '').split
    end
    @issue_keys.include?(issue.key)
  end

  def add_issue(issue)
    raise "Cannot add issues to filters of type #{filter_type}" unless config_filter?

    self.issue_keys += " #{issue.key}"
    save
  end

  def remove_issue(issue)
    raise "Cannot remove issues from filters of type #{filter_type}" unless config_filter?

    self.issue_keys = (issue_keys || '').split
      .select{ |key| key != issue.key }
      .join(' ')
    save
  end
end
