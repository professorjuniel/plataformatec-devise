require 'test_helper'

class ConfirmationsTest < ActionController::IntegrationTest

  test 'authenticated user should not be able to visit confirmation page' do
    sign_in

    get new_confirmation_path

    assert_response :redirect
    assert_redirected_to root_path
    assert warden.authenticated?
  end

  test 'not authenticated user should be able to request a new confirmation' do
    user = create_user

    visit '/session/new'
    click_link 'Didn\'t receive confirmation instructions?'

    fill_in 'email', :with => user.email
    click_button 'Resend confirmation instructions'

#    assert_response :redirect
#    assert_redirected_to root_path
    assert_template 'sessions/new'
    assert_contain 'You will receive an email with instructions about how to confirm your account in a few minutes'
  end

  test 'not authenticated user with invalid perishable token should not be able to confirm an account' do
    visit confirmation_path(:perishable_token => 'invalid_perishable')

    assert_response :success
    assert_template 'confirmations/new'
    assert_have_selector '#errorExplanation'
    assert_contain 'invalid confirmation'
  end

  test 'not authenticated user with valid perishable token should be able to confirm an account' do
    user = create_user(:confirm => false)
    assert_not user.confirmed?

    visit confirmation_path(:perishable_token => user.perishable_token)

#    assert_response :redirect
    assert_template 'sessions/new'
    assert_contain 'Your account was successfully confirmed!'

    assert user.reload.confirmed?
  end

  test 'already confirmed user should not be able to confirm the account again' do
    user = create_user
    visit confirmation_path(:perishable_token => user.perishable_token)

    assert_template 'confirmations/new'
    assert_have_selector '#errorExplanation'
    assert_contain 'already confirmed'
  end
end
