class JournalEntriesController < ApplicationController
  # POST /journal_entries
  # 仕訳ヘッダ(date/description)＋複数の明細行(lines)を一括で受け取り作成する。
  def create
    entry = Current.user.organization.journal_entries.new(
      date: entry_params[:date],
      description: entry_params[:description]
    )

    entry_params.fetch(:lines, []).each do |line|
      # 明細が指す勘定も必ず「自組織の口座」に限定する。
      # 他組織のaccount_idを送り込まれても、自組織には存在しないので弾く（認可境界）。
      account = Current.user.organization.accounts.find_by(id: line[:account_id])
      if account.nil?
        return render json: { errors: ["指定された勘定が自組織に存在しません"] },
                      status: :unprocessable_content
      end
      entry.journal_lines.build(account: account, side: line[:side], amount: line[:amount])
    end

    if entry.save  # ここで貸借一致(Σ借方==Σ貸方)の検証が走る。全行まとめて1トランザクション。
      render json: entry.as_json(include: :journal_lines), status: :created
    else
      render json: { errors: entry.errors.full_messages }, status: :unprocessable_content
    end
  end

  private

  # ネストしたパラメータの許可: lines は account_id/side/amount を持つハッシュの配列。
  def entry_params
    params.require(:journal_entry).permit(:date, :description, lines: [:account_id, :side, :amount])
  end
end
