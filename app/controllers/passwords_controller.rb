class PasswordsController < ApplicationController
  before_filter :require_no_authentication

  # GET /password/new
  #
  def new
  end

  # POST /password
  #
  def create
    @password = User.send_reset_password_instructions(params[:password])
    if @password.errors.empty?
      flash[:notice] = I18n.t(:send_instructions, :scope => [:devise, :passwords], :default => 'You will receive an email with instructions about how to reset your password in a few minutes.')
      redirect_to new_session_path
    else
      render :new
    end
  end

  # GET /password/edit?perishable_token=abcdef
  #
  def edit
    @password = User.new
    @password.perishable_token = params[:perishable_token]
  end

  # PUT /password
  #
  def update
    @password = User.reset_password!(params[:password])
    if @password.errors.empty?
      flash[:notice] = I18n.t(:update, :scope => [:devise, :passwords], :default => 'Your password was changed successfully.')
      redirect_to new_session_path
    else
      render :edit
    end
  end
end
