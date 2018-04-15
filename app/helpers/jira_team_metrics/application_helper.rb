require 'securerandom'

module JiraTeamMetrics::ApplicationHelper
  include JiraTeamMetrics::FormattingHelper
  include JiraTeamMetrics::LinkHelper
  include JiraTeamMetrics::ChartsHelper

  def readonly?
    !!ENV['READONLY']
  end

  def domain_path
    "#{root_path}domain"
  end

  def domain_metadata_path
    "#{domain_path}/metadata"
  end

  def board_path(board)
    "#{domain_path}/boards/#{board.jira_id}"
  end

  def reports_path(board)
    "#{root_path}reports/boards/#{board.jira_id}"
  end

  def deliveries_report_path(board)
    "#{reports_path(board)}/deliveries"
  end

  def delivery_report_path(board, issue)
    "#{deliveries_report_path(board)}/#{issue.key}"
  end

  def delivery_scope_report_path(board, issue, team)
    "#{delivery_report_path(board, issue)}/scope/#{team}"
  end

  def board_issues_path(board)
    "#{reports_path(board)}/issues"
  end

  def board_components_path(board)
    "#{root_path}components/boards/#{board.jira_id}"
  end

  def board_component_summary_path(board)
    "#{board_components_path(board)}/summary"
  end

  def board_api_path(board)
    "#{root_path}api/boards/#{board.jira_id}"
  end

  def board_control_chart_path(board)
    "#{board_path(board)}/control_chart"
  end

  def issue_path(issue)
    "#{board_path(@board)}/issues/#{issue.key}"
  end

  def path_for(object)
    if object.kind_of?(Issue)
      issue_path(object)
    end
  end

  # TODO: move this
  def render_table_options(object)
    path = path_for(object)
    "<a href='#{path}'>Details</a>".html_safe
  end

  def form_input(object, method, options = {})
    input_tag = form_input_tag(object, method, options)
    label_tag = form_label_tag(object, method)

    [input_tag, label_tag].join.html_safe
  end

  def form_input_tag(object, method, options)
    object_name = object_name_for(object)
    classes = 'validate'
    classes += ' invalid' if object.errors[method].any?
    tag(:input, :id => input_id_for(object, method),
      :name =>  "#{object_name}[#{method}]",
      :type => options[:type] || 'text',
      :class => classes,
      :value => object.send(method))
  end

  def form_label_tag(object, method)
    value = object.send(method)
    attributes = { :for => input_id_for(object, method) }
    attributes.merge!('data-error' => object.errors[method][0]) if object.errors[method].any?
    attributes.merge!('class' => 'active') unless value.blank?
    content_tag(:label, method.capitalize, attributes)
  end

  def input_id_for(object, method)
    object_name = object_name_for(object)
    "#{object_name}_#{method}" # e.g. organization_name
  end

  def object_name_for(object)
    object.class.name.split('::').last.tableize.singularize # e.g. organization
  end

  def issue_field(issue, field_name)
    field_value = issue.fields[field_name]
    if field_value.is_a?(Array)
      field_value.map{ |v| content_tag(:div, v, class: 'chip') }.join.html_safe
    else
      field_value
    end
  end

  def generate_id
    SecureRandom.urlsafe_base64(10)
  end
end