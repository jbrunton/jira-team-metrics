class JiraTeamMetrics::SyncHistory < ApplicationRecord
  belongs_to :domain
  belongs_to :board

  def self.log(target)
    started_time = DateTime.now
    yield
    completed_time = DateTime.now

    if target.class == JiraTeamMetrics::Domain
      board, domain = nil, target
    elsif target.class == JiraTeamMetrics::Board
      board, domain = target, target.domain
    end

    history = JiraTeamMetrics::SyncHistory.create(
      domain: domain,
      board: board,
      issues_count: target.issues.count,
      started_time: started_time,
      completed_time: completed_time
    )
    binding.pry
  end
end
