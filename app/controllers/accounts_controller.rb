class AccountsController < ApiController
  # GET /accounts
  # 「今ログインしている人の組織」の口座だけを返す。
  # Account.all と書くと全組織が混ざる＝情報漏洩。必ず組織経由で辿る（認可境界）。
  def index
    accounts = Current.user.organization.accounts.order(:id)
    balances = Account.balances_for(accounts) # 全口座の残高を1クエリでまとめて算出(N+1回避)
    render json: accounts.map { |account| account_json(account, balances[account.id] || 0) }
  end

  # POST /accounts
  # 組織はログインユーザーから導出して .accounts.new する。
  # クライアントから organization_id を受け取らない＝他組織への作成を防ぐ。
  def create
    account = Current.user.organization.accounts.new(account_params)
    if account.save
      render json: account, status: :created
    else
      render json: { errors: account.errors.full_messages }, status: :unprocessable_content
    end
  end

  private

  # strong parameters: 受け取って良いキーだけ許可。
  # name/category のみ許可し、organization_id は意図的に除外（セッションから導出するため）。
  def account_params
    params.require(:account).permit(:name, :category)
  end

  # レスポンス整形。必要な項目だけ返し、残高(balance: 1/100円単位の整数)を加える。
  # balanceは呼び出し側でバッチ算出した値を受け取る(N+1回避)。
  def account_json(account, balance)
    account.as_json(only: [:id, :name, :category]).merge(balance: balance)
  end
end
