class AccountsController < ApplicationController
  # GET /accounts
  # 「今ログインしている人の組織」の口座だけを返す。
  # Account.all と書くと全組織が混ざる＝情報漏洩。必ず組織経由で辿る（認可境界）。
  def index
    accounts = Current.user.organization.accounts
    render json: accounts
  end
end
