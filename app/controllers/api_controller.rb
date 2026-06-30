class ApiController < ApplicationController
  private

  # Authentication concern の request_authentication を上書き。
  # API用なので、未認証時はHTMLログイン画面へのリダイレクトではなく 401 JSON を返す。
  def request_authentication
    render json: { error: "認証が必要です" }, status: :unauthorized
  end
end
