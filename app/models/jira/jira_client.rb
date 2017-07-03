require 'net/http'
require 'net/https'
require 'json'

class JiraClient
  MAX_RESULTS = 50

  def initialize(url, credentials)
    @url = url
    @credentials = credentials
  end

  def request(relative_url)
    uri = URI::join(@url, relative_url)
    puts "Issuing request to " + uri.to_s
    request = setup_request(uri)
    response = issue_request(uri, request)
    response.value
    JSON.parse(response.body)
  end

  def search_issues(opts, &block)
    yield(0) if block_given? && opts[:startAt].nil?

    url = generate_url(opts.merge(expand: ['changelog']))
    statuses = opts[:statuses]

    response = request(url)

    issues = response['issues'].map do |raw_issue|
      IssueAttributesBuilder.new(raw_issue, statuses).build
    end

    startAt = response['startAt'] || 0
    progress = compute_progress(issues, startAt, response)
    yield(progress) if block_given?
    if startAt + response['maxResults'] < response['total']
      startAt = startAt + response['maxResults']
      issues = issues + search_issues(opts.merge({:startAt => startAt}), &block)
    end

    issues
  end

  def get_rapid_boards
    url = "/rest/greenhopper/1.0/rapidviews/list"
    response = request(url)
    response['views'].map do |raw_view|
      BoardAttributesBuilder.new(raw_view).build
    end
  end

  def get_rapid_board(id)
    get_rapid_boards.find{ |board| board.id == id }
  end

  def get_fields
    url = "/rest/api/2/field"
    response = request(url)
    response.map do |field|
      field.slice('id', 'name')
    end
  end

  def get_field(name)
    get_fields.find{ |field| field['name'] == name }
  end

  def get_statuses
    url = "/rest/api/2/status"
    response = request(url)
    response.map do |status|
      [status['name'], status['statusCategory']['name']]
    end.to_h
  end

private
  def setup_request(uri)
    request = Net::HTTP::Get.new(uri)
    request.basic_auth @credentials[:username], @credentials[:password]
    request
  end

  def issue_request(uri, request)
    Net::HTTP.start(uri.hostname, uri.port, :use_ssl => true) do |http|
      http.request(request)
    end
  end

  def generate_url(opts)
    max_results = opts[:max_results] || MAX_RESULTS

    url = "rest/api/2/search?"
    url += "&expand=#{opts[:expand].join(',')}" if opts[:expand]
    url += "&jql=#{URI::escape(opts[:query])}" if opts[:query]
    url += "&startAt=#{opts[:startAt]}" if opts[:startAt]
    url += "&maxResults=#{max_results}"

    url
  end

  def compute_progress(issues, startAt, response)
    if response['total'] == 0
      100
    else
      ((startAt + issues.length) * 100.0 / response['total']).to_i
    end
  end
end

