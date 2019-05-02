class Api::V1::SessionsController < Devise::SessionsController
  # POST /users/authenticate
  
  def create
    params[:user][:email] = params[:user][:email].downcase
    @user = User.find_by_email(params[:user][:email])
    if !@user.blank?
      if @user.valid_password?(params[:user][:password])
         @user.generate_token
         sign_in :user, @user
      else
        render :json => {
          :error => "Invalid email/password."
        }, :status => 400
      end
    else
      render :json => {
        :error => "Invalid email/password."
      }, :status => 400
    end
  end
  
  # POST /users/logout
  def destroy

  end
  
  private
  
  def render_error_responses
    render Response.failed_user_authentication_response if @user.nil?
  end
  
end
