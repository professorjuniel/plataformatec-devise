class Notifier < ::ActionMailer::Base
  cattr_accessor :sender

  # Deliver confirmation instructions when the user is created or confirmation
  # is manually requested
  #
  def confirmation_instructions(record)
    subject translate(:confirmation_instructions, :default => 'Confirmation instructions')
    setup_mail(record)
  end

  # Deliver reset password instructions when manually requested
  #
  def reset_password_instructions(record)
    subject translate(:reset_password_instructions, :default => 'Reset password instructions')
    setup_mail(record)
  end

  private

    def setup_mail(record)
      from         self.class.sender
      recipients   record.email
      sent_on      Time.now
      content_type 'text/html'
      body         record.class.name.downcase.to_sym => record, :resource => record
    end

    def translate(key, options={})
      I18n.t(key, {:scope => [:devise, :notifier]}.merge(options))
    end
end
