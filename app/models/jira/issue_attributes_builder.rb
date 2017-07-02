
class IssueAttributesBuilder
  def initialize(json, statuses)
    @json = json
    @statuses = statuses
  end

  def build
    {
      'key' => key,
      'summary' => summary,
      'issue_type' => issue_type,
      'transitions' => transitions
    }
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
        transition = history['items'].find{ |x| x['field'] == 'status' }
        toStatus = transition['toString']
        fromStatus = transition['fromString']
        {
          'date' => history['created'],
          'fromStatus' => fromStatus,
          'fromStatusCategory' => @statuses[fromStatus],
          'toStatus' => toStatus,
          'toStatusCategory' => @statuses[toStatus]
        }
      end
    end
  end
end
