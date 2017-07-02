class Filter < ApplicationRecord
  belongs_to :board

  def exclusions
    exclusions_string = issue_keys
    exclusions_string ||= ''
    exclusions_string.split
  end
end
