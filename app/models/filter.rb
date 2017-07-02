class Filter < ApplicationRecord
  belongs_to :board
  enum filter_type: [:query_filter, :config_filter]

  def exclusions
    exclusions_string = issue_keys
    exclusions_string ||= ''
    exclusions_string.split
  end
end
