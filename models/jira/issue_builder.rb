
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
      'transitions' => transitions
    }

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
end
