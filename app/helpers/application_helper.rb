module ApplicationHelper
  def app_nav_link(label, path, active_controllers)
    controllers = Array(active_controllers).map(&:to_s)
    classes = [ "nav-link" ]
    classes << "active" if controllers.include?(controller_name)

    link_to label, path, class: classes.join(" ")
  end

  def status_badge(record)
    value = record.status.to_s
    label = record.respond_to?(:status_label) ? record.status_label : value.humanize

    content_tag(:span, label, class: [ "badge", "badge-#{value.dasherize}" ].join(" "))
  end

  def priority_badge(task)
    value = task.priority.to_s
    content_tag(:span, task.priority_label, class: [ "badge", "badge-priority-#{value.dasherize}" ].join(" "))
  end

  def user_initial(user)
    source = user.name.presence || user.email_address
    source.to_s.first.to_s.upcase.presence || "U"
  end
end
