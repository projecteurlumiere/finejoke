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

  def render_errors(object, field_name)
    # return unless object.errors.any?

    tag.div class: "field-errors" do 
      object.errors.messages[field_name].join(", ") if object.errors.messages[field_name].present?
    end.html_safe
  end 
end
