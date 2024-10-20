class UserMailer < Devise::Mailer
  SENDERS = {
    en: "haha@finejoke.lol",
    ru: "xaxa@finejoke.lol",
    fr: "hihi@finejoke.lol",
    es: "jaja@finejoke.lol"
  }.freeze


  # last from the argument is the options hash devise mailer uses for defining email headers
  # see devise/app/mailers/devise/mailer.rb
  def confirmation_instructions(*args)
    args.last[:from] = set_sender(locale)
    super *args
  end

  def email_changed(*args)
    args.last[:from] = set_sender(locale)
    super *args
  end

  def reset_password_instructions(*args)
    args.last[:from] = set_sender(locale)
    super *args
  end

  def unlock_instructions(*args)
    args.last[:from] = set_sender(locale)
    super *args
  end

  private

  def set_sender(locale)
    "Finejoke <#{SENDERS[locale]}>"
  end
end
