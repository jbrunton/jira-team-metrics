module LinkHelper
  def link_type(link)
    link['inward_link_type'] || link['outward_link_type']
  end

  def link_summary(link, board)
    issue_key = link['issue']['key']
    issue = board.object.issues.find_by(key: issue_key)
    if issue.nil?
      "#{issue_key} – #{link['issue']['summary']}".html_safe
    else
      "<a href='#{url_for(issue)}'>#{issue_key}</a> – #{link['issue']['summary']}".html_safe
    end
  end

  def issue_summary(issue)
    "<a href='#{url_for(issue)}'>#{issue.key}</a> – #{issue.summary}".html_safe
  end

  def external_link_url(link, domain)
    "#{domain.config.url}/browse/#{link['issue']['key']}"
  end
end