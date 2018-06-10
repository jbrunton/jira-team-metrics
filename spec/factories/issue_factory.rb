FactoryBot.define do
  factory :issue, class: JiraTeamMetrics::Issue do
    sequence(:key) { |k| "ISSUE-#{k + 100}" }
    summary "Some Issue"
    board
    fields { {} }
    transitions []
    status 'Done'

    transient do
      started_time nil
      completed_time nil
    end

    factory :epic do
      issue_type 'Epic'
    end

    after(:create) do |issue, evaluator|
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
    end
  end
end