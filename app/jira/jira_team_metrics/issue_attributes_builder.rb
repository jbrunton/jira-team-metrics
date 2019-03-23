class JiraTeamMetrics::IssueAttributesBuilder
  def initialize(json, domain)
    @json = json
    @domain = domain
  end

  def build
    {
      'key' => key,
      'summary' => summary,
      'issue_type' => issue_type,
      'issue_type_icon' => issue_type_icon,
      'transitions' => transitions,
      'fields' => fields,
      'issue_created' => issue_created,
      'labels' => labels,
      'links' => links,
      'status' => status,
      'global_rank' => global_rank,
      'resolution' => resolution,
      'json' => @json
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

  def issue_type_icon
    @json['fields']['issuetype']['iconUrl']
  end

  def issue_created
    @json['fields']['created']
  end

  def status
    @json['fields']['status']['name']
  end

  def labels
    @json['fields']['labels']
  end

  def global_rank
    fields['Global Rank']
  end

  def resolution
    @json['fields']['resolution'].try(:[], 'name')
  end

  def fields
    @fields ||= begin
      fields = {}
      (@domain.fields + ['Global Rank']).each do |field|
        field_id = field['id']
        field_value = @json['fields'][field_id]
        fields[field['name']] =
          case field['type']
            when 'string', 'any', 'date'
              field_value
            when 'array'
              field_value.map do |x|
                x['value'] ||
                  x['name'] # for fix versions
              end
            when 'user', 'resolution'
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
          'fromStatusCategory' => @domain.status_category_for(fromStatus),
          'toStatus' => toStatus,
          'toStatusCategory' => @domain.status_category_for(toStatus)
        }
      end
    end
  end

  def links
    @links ||= begin
      issue_links = @json['fields']['issuelinks'].map do |link|
        if link['inwardIssue']
          {
            inward_link_type: link['type']['inward'],
            issue: link_hash_for(link['inwardIssue'])
          }
        elsif link['outwardIssue']
          {
            outward_link_type: link['type']['outward'],
            issue: link_hash_for(link['outwardIssue'])
          }
        end
      end
      issue_links.compact
    end
  end

  def link_hash_for(issue_hash)
    {
      key: issue_hash['key'],
      issue_type: issue_hash['fields']['issuetype']['name'],
      summary: issue_hash['fields']['summary']
    }
  end
end

