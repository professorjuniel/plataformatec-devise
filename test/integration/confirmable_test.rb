require 'test/test_helper'

class UsersConfirmationTest < ActionController::IntegrationTest

  test 'user should be able to request a new confirmation' do
    user = create_user(:confirm => false)
    ActionMailer::Base.deliveries.clear

    visit new_user_session_path
    click_link 'Didn\'t receive confirmation instructions?'

    fill_in 'email', :with => user.email
    click_button 'Resend confirmation instructions'

    assert_template 'sessions/new'
    assert_contain 'You will receive an email with instructions about how to confirm your account in a few minutes'
    assert_equal 1, ActionMailer::Base.deliveries.size
  end

  test 'user with invalid perishable token should not be able to confirm an account' do
    visit user_confirmation_path(:perishable_token => 'invalid_perishable')

    assert_response :success
    assert_template 'confirmations/new'
    assert_have_selector '#errorExplanation'
    assert_contain 'invalid confirmation'
  end

  test 'user with valid perishable token should be able to confirm an account' do
    user = create_user(:confirm => false)
    assert_not user.confirmed?

    visit user_confirmation_path(:perishable_token => user.perishable_token)

    assert_template 'sessions/new'
    assert_contain 'Your account was successfully confirmed!'

    assert user.reload.confirmed?
  end

  test 'user already confirmed user should not be able to confirm the account again' do
    user = create_user
    visit user_confirmation_path(:perishable_token => user.perishable_token)

    assert_template 'confirmations/new'
    assert_have_selector '#errorExplanation'
    assert_contain 'already confirmed'
  end
end
