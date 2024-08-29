# prevents insetions of div.field_with_error wrapping invalid input fields
ActionView::Base.field_error_proc = Proc.new do |html_tag, instance|
  html_tag.html_safe
end