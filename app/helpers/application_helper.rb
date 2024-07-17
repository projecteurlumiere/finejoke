module ApplicationHelper
  
  def inline_svg(path)
    File.open("app/assets/images/#{path}", "rb") do |file|
      raw file.read.force_encoding("UTF-8")
    end
  end
end
