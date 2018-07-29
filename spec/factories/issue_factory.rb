FactoryBot.define do
  factory :issue, class: JiraTeamMetrics::Issue do
    sequence(:key) { |k| "ISSUE-#{k + 100}" }
    summary "Some Issue"
    board
    issue_type 'Story'
    fields { {} }
    transitions []
    links []
    status 'Done'

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
      end

      if evaluator.completed_time
        issue.transitions << {
          'fromStatusCategory' => 'In Progress',
          'toStatusCategory' => 'Done',
          'date' => evaluator.completed_time.strftime('%Y-%m-%dT%H:%M:%S.%L%z')
        }
      end

      if evaluator.project
        issue.links << {
          'inward_link_type' => 'is included in',
          'issue' => {
            'issue_type' => evaluator.project.issue_type,
            'key' => evaluator.project.key,
            'summary' => evaluator.project.summary
          }
        }
        issue.project_key = evaluator.project.key
        issue.project = evaluator.project
      end

      if evaluator.epic
        issue.fields['Epic Link'] = evaluator.epic.key
        issue.board = evaluator.epic.board
        issue.epic_key = evaluator.epic.key
        issue.epic = evaluator.epic
      end
    end
  end
end