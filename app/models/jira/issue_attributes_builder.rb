
class IssueAttributesBuilder
  def initialize(json, statuses, field_definitions)
    @json = json
    @statuses = statuses
    @field_definitions = field_definitions
  end

  def build
    {
      'key' => key,
      'summary' => summary,
      'issue_type' => issue_type,
      'transitions' => transitions,
      'fields' => fields,
      'labels' => labels
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

  def labels
    @json['fields']['labels']
  end

  def fields
    @fields ||= begin
      fields = {}
      @field_definitions.each do |field|
        field_id = field['id']
        field_value = @json['fields'][field_id]
        fields[field['name']] =
          case field['type']
            when 'string'
              field_value
            when 'array'
              field_value.map{ |x| x['value'] }
            when 'user'
              field_value['name']
            else
              nil
          end unless field_value.nil?
      end
      fields
    end
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
