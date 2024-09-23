module ApplicationHelper
  def inline_svg(path)
    File.open("app/assets/images/#{path}", "rb", encoding: "UTF-8") do |file|
      raw file.read
    end
  end

  def preload_fonts
    Dir.entries("app/assets/fonts").map do |font_name|
      next unless font_name.end_with?(".woff2")

      preload_link_tag font_name, crossorigin: ""
    end.join(" ").html_safe
  end

  def render_errors(object, field_name, custom_message = nil)
    # return unless object.errors.any?

    tag.div class: "field-errors" do
      error_messages = object.errors.messages[field_name]

      if custom_message && error_messages.present?
         custom_message
      elsif error_messages.present?
        error_messages.join(", ")
      end
    end.html_safe
  end

  def render_date(time)
    [
      time.year, 
      time.month.to_s.rjust(2, "0"),
      time.day.to_s.rjust(2, "0")
    ].join(".")
  end
end
