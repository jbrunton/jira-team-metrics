module Jira
  class IssueBuilder
    def initialize(json, statuses)
      @json = json
      @statuses = statuses
    end

    def build
      attrs = {
        'key' => key,
        'summary' => summary,
        'issue_type' => issue_type,
        'transitions' => transitions,
        'started' => compute_started_date,
        'completed' => compute_completed_date
      }

      # unless attrs[:issue_type] == 'Epic'
      #   attrs[:started] = compute_started_date
      #   attrs[:completed] = compute_completed_date
      #   attrs[:epic_key] = epic_key
      # end

      Issue.new(attrs)
    end

  private
    def key
      @json['key']
    end

    def summary
      @json['fields']['summary']
    end

    def issue_type
      @json['fields']['issuetype']['name']
    end

    def transitions
      @transitions ||= begin
        histories = @json['changelog']['histories']
        transitions = histories.select do |history|
          history['items'].any?{ |x| x['field'] == 'status' }
        end
        transitions.map do |history|
          status = history['items'].find{ |x| x['field'] == 'status' }['toString']
          {
            'date' => history['created'],
            'status' => status,
            'statusCategory' => @statuses[status]
          }
        end
      end
    end

    def compute_started_date
      started_transitions = transitions.select{ |t| t['statusCategory'] == 'In Progress' }

      if started_transitions.any?
        started_transitions.first['date']
      else
        nil
      end
    end

    def compute_completed_date
      return nil unless @json['changelog']

      if !transitions.last.nil? && transitions.last['statusCategory'] == 'Done'
        transitions.last['date']
      else
        nil
      end
    end
  end
end
