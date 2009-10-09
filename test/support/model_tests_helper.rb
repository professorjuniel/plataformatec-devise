class ActiveSupport::TestCase
  def setup_mailer
    ActionMailer::Base.deliveries = []
  end

  # Helpers for creating new users
  #
  def generate_unique_email
    @@email_count ||= 0
    @@email_count += 1
    "test#{@@email_count}@email.com"
  end

  def valid_attributes(attributes={})
    { :email => generate_unique_email,
      :password => '123456',
      :password_confirmation => '123456' }.update(attributes)
  end

  def new_user(attributes={})
    User.new(valid_attributes(attributes))
  end

  def create_user(attributes={})
    User.create!(valid_attributes(attributes))
  end

  def field_accessible?(field)
    new_user(field => 'test').send(field) == 'test'
  end
end
