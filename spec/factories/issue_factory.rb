FactoryBot.define do
  factory :issue, class: JiraTeamMetrics::Issue do
    sequence(:key) { |k| "ISSUE-#{k + 100}" }
    summary "Some Issue"
    board
    issue_type 'Story'
    fields { {} }
    transitions []
    links []
    labels []
    status 'To Do'
    sequence(:global_rank) { |k| (k+200).to_s }

    transient do
      started_time nil
      completed_time nil
      epic nil
      project nil
    end

    factory :epic do
      issue_type 'Epic'
    end

    factory :project do
      issue_type 'Project'
    end

    before(:create) do |issue, evaluator|
      if evaluator.started_time
        issue.transitions << {
          'fromStatusCategory' => 'To Do',
          'toStatusCategory' => 'In Progress',
          'date' => evaluator.started_time.strftime('%Y-%m-%dT%H:%M:%S.%L%z')
        }
        issue.issue_created = evaluator.started_time - 1 unless issue.issue_created
      end

      if evaluator.completed_time
        issue.transitions << {
          'fromStatusCategory' => 'In Progress',
          'toStatusCategory' => 'Done',
          'date' => evaluator.completed_time.strftime('%Y-%m-%dT%H:%M:%S.%L%z')
        }
      end

      assign_project = lambda do |issue, project, add_links|
        if add_links
          issue.links << {
            'inward_link_type' => 'is included in',
            'issue' => {
              'issue_type' => project.issue_type,
              'key' => project.key,
              'summary' => project.summary
            }
          }
          issue.parent_key = project.key
          issue.parent = project
        end
        issue.project_key = project.key
        issue.project = project
        issue.board = project.board
      end

      if evaluator.project
        assign_project.call(issue, evaluator.project, true)
      end

      if evaluator.epic
        issue.fields['Epic Link'] = evaluator.epic.key
        issue.board = evaluator.epic.board
        issue.epic_key = evaluator.epic.key
        issue.epic = evaluator.epic

        if issue.project.nil? && evaluator.epic.project
          assign_project.call(issue, evaluator.epic.project, false)
        end
      end
    end
  end
end