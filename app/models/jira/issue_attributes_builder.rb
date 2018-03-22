
class IssueAttributesBuilder
  def initialize(json, domain)
    @json = json
    @statuses = domain.statuses
    @field_definitions = domain.fields || []
    @link_types = domain.link_types || []
  end

  def build
    {
      'key' => key,
      'summary' => summary,
      'issue_type' => issue_type,
      'transitions' => transitions,
      'fields' => fields,
      'issue_created' => issue_created,
      'labels' => labels,
      'links' => links
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

  def issue_created
    @json['fields']['created']
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
            when 'string', 'any'
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

  def links
    @links ||= begin
      issue_links = @json['fields']['issuelinks'].map do |link|
        if link['inwardIssue'].nil?
          nil
        else
          {
            inward_link_type: link['type']['inward'],
            issue: {
              key: link['inwardIssue']['key'],
              issue_type: link['inwardIssue']['fields']['issuetype']['name'],
              summary: link['inwardIssue']['fields']['summary']
            }
          }
        end
      end
      issue_links
        .compact
        .select{ |link| @link_types.include?(link[:inward_link_type]) }
    end
  end
end
