module JiraTeamMetrics::HtmlHelper
  def form_input(object, method, options = {})
    input_tag = form_input_tag(object, method, options)
    label_tag = form_label_tag(object, method)
    field_classes = 'field'
    field_classes += ' error' if object.errors[method].any?
    if object.errors[method].any?
      error_tag = content_tag(:div, object.errors[method][0], :class => 'ui pointing red basic label')
    else
      error_tag = ""
    end
    content_tag(:div, [label_tag, input_tag, error_tag].join.html_safe, :class => field_classes)
  end

  def form_input_tag(object, method, options)
    object_name = object_name_for(object)
    classes = 'ui'
    classes += ' error' if object.errors[method].any?
    opts = {
      :id => input_id_for(object, method),
      :name =>  "#{object_name}[#{method}]",
      :class => classes
    }
    opts.merge!(:readonly => 'readonly') if options[:readonly]
    input_value = object.send(method)
    if options[:type] == :textarea
      content_tag(:textarea, input_value, opts)
    else
      opts.merge!({
        :value => input_value,
        :type => options[:type] || 'text',
      })
      tag(:input, opts)
    end
  end

  def form_label_tag(object, method)
    value = object.send(method)
    attributes = { :for => input_id_for(object, method) }
    #attributes.merge!('data-error' => object.errors[method][0]) if object.errors[method].any?
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
    if field_value.nil?
      if issue.epic.nil?
        ""
      else
        issue_field(issue.epic, field_name)
      end
    elsif field_value.is_a?(Array)
      field_value.map{ |v| content_tag(:div, v, class: 'chip') }.join.html_safe
    else
      field_value
    end
  end
end