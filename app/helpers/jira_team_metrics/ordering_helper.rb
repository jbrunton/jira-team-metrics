module JiraTeamMetrics::OrderingHelper
  def issues_in_epic(epic)
    all_issues = epic
      .issues(recursive: false)
      .sort_by{ |issue| issue.global_rank }
      .group_by{ |issue| issue.status_category }

    (all_issues['In Progress'] || []) +
      (all_issues['To Do'] || []) +
      (all_issues['Done'] || [])
  end
end