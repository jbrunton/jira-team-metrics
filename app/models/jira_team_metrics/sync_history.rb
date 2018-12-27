module JiraTeamMetrics
  class SyncHistory < ApplicationRecord
    belongs_to :domain
    belongs_to :board
  end
end
