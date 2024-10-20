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

  def cache_with_lock(name = {}, options = {}, &block)
    cache_key = cache_fragment_name(name)
    lock_key = "#{name.instance_of?(String) ? name : name.cache_key}:lock"

    20.times do
      if Rails.cache.exist?(lock_key)
        logger.info "Cache is locked. Waiting."
        sleep 0.1
      else 
        unless controller.fragment_exist?(cache_key)
          logger.info "Locking cache"
          Rails.cache.write(lock_key, true) 
        end
        cache(name, options, &block)
        
        if Rails.cache.exist?(lock_key)
          logger.info "Unlocking cache"
          Rails.cache.delete(lock_key)
        end

        return
      end

      logger.info "Retrying cache lock"
    end

    logger.warn "Failed to obtain cache locked - proceeding to render"
    cache(name, options, &block)
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

  # see application#set_title_key
  def set_title
    return t(:".title") if @title_key.blank?
    "#{t(@title_key, **(@title_vars || {}))} | #{t :".title"}"
  end

  SEO_EXPOSED_ACTIONS = [
    { controller: :registrations, action: :new },
    { controller: :sessions, action: :new },
    { controller: :passwords, action: :new }
  ].freeze

  def seo_exposed_page?
    controller = controller_name.to_sym
    action = action_name.to_sym

    SEO_EXPOSED_ACTIONS.any? do |args|
      controller == args[:controller] && action == args[:action]
    end
  end

  def seo_meta_tags
    return unless seo_exposed_page?

    default_locale_path = strip_params(request.original_url)
    canonical_path = params[:locale] ? replace_query_param(default_locale_path, "locale", I18n.locale) : default_locale_path

    canonical = <<~HTML
      <link rel="canonical" href="#{canonical_path}">
    HTML

    default_locale_link = <<~HTML
      <link rel="alternate" hreflang="x-default" href="#{default_locale_path}">
    HTML

    locale_links = I18n.available_locales.map do |l|
      <<~HTML
        <link rel="alternate" hreflang="#{l}" href="#{replace_query_param(default_locale_path, "locale", l)}">
      HTML
     end

    [canonical, default_locale_link, *locale_links].join(" ").html_safe
  end

  def seo_no_index_tag
    <<~HTML.html_safe
      <meta name="robots" content="noindex">
    HTML
  end

  EMAILS = {
    en: "haha@finejoke.lol",
    ru: "xaxa@finejoke.lol",
    fr: "hihi@finejoke.lol",
    es: "jaja@finejoke.lol"
  }.freeze

  def contact_email_tag_for(locale)
    link_to EMAILS[locale], "mailto:#{EMAILS[locale]}"
  end
end
