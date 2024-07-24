module ApplicationHelper
  
  def inline_svg(path)
    File.open("app/assets/images/#{path}", "rb", encoding: "UTF-8") do |file|
      raw file.read
    end
  end
end
