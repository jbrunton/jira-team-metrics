module JiraTeamMetrics::OrderingHelper
  def issues_in_epic(epic)
    all_issues = epic
      .issues(recursive: false)
      .group_by{ |issue| issue.status_category }

    (all_issues['In Progress'] || []).sort_by{ |issue| issue.global_rank } +
      (all_issues['To Do'] || []).sort_by{ |issue| issue.global_rank } +
      (all_issues['Done'] || []).sort_by{ |issue| [issue.started_time || DateTime.now, issue.completed_time ] }
  end
end
