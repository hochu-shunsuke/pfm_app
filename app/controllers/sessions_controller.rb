class SessionsController < ApplicationController
  allow_unauthenticated_access only: %i[ new create ]
  skip_forgery_protection only: %i[ create destroy ] # SPA(Next)からのJSONログイン/ログアウト用
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_session_path, alert: "Try again later." }

  def new
  end

  def create
    if user = User.authenticate_by(params.permit(:email_address, :password))
      start_new_session_for user
      respond_to do |format|
        format.html { redirect_to after_authentication_url }
        format.json { render json: { ok: true }, status: :ok }
      end
    else
      respond_to do |format|
        format.html { redirect_to new_session_path, alert: "Try another email address or password." }
        format.json { render json: { error: "メールアドレスかパスワードが違います" }, status: :unauthorized }
      end
    end
  end

  def destroy
    terminate_session
    respond_to do |format|
      format.html { redirect_to new_session_path, status: :see_other }
      format.json { render json: { ok: true } }
    end
  end
end
