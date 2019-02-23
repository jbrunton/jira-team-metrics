# class JiraTeamMetrics::DomainConfig < JiraTeamMetrics::BaseConfig
#   BoardDetails = Struct.new(:board_id, :config_file)
#
#   TeamDetails = Struct.new(:name, :short_name)
#
#   ProjectType = Struct.new(:issue_type, :outward_link_type, :inward_link_type)
#
#   def initialize(config_hash)
#     super(config_hash, 'domain_config')
#   end
#
#   def url
#     config_hash['url'] || '<Unconfigured Domain>'
#   end
#
#   def name
#     config_hash['name'] || url
#   end
#
#   # TODO: add Epic Link to this
#   def fields
#     config_hash['fields'] || []
#   end
#
#   def project_type
#     project_hash = config_hash['projects']
#     return nil if project_hash.nil?
#     ProjectType.new(project_hash['issue_type'], project_hash['outward_link_type'], project_hash['inward_link_type'])
#   end
#
#   def link_missing_epics?
#     config_hash.dig('epics', 'link_missing')
#   end
#
#   def epic_counting_strategy
#     config_hash.dig('epics', 'counting_strategy')
#   end
#
#   def boards
#     (config_hash['boards'] || []).map do |config_hash|
#       BoardDetails.new(config_hash['board_id'], config_hash['config_file'])
#     end
#   end
#
#   def teams
#     (config_hash['teams'] || []).map do |team_hash|
#       TeamDetails.new(team_hash['name'], team_hash['short_name'])
#     end
#   end
#
#   def epics_report_options
#     report_options_for('epics') || ReportOptions.new([])
#   end
#
#   def projects_report_options
#     report_options_for('projects') || ReportOptions.new([])
#   end
#
#   def status_category_overrides
#     @status_category_overrides ||= begin
#       (config_hash['status_category_overrides'] || []).map do |override_hash|
#         [override_hash['map'], override_hash['to_category']]
#       end.to_h
#     end
#   end
#
#   def scatterplot_default_query
#     report_property_for('scatterplot', 'default_query')
#   end
#
#   def throughput_default_query
#     report_property_for('throughput', 'default_query')
#   end
#
#
#   def aging_wip_completed_query
#     report_property_for('aging_wip', 'completed_query')
#   end
# end
#
