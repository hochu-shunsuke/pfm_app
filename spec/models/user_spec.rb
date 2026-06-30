require "rails_helper"

RSpec.describe User, type: :model do
  let(:organization) { Organization.create!(name: "テスト組織") }

  it "正しいパスワードならauthenticateがユーザーを返す" do
    user = User.create!(
      email_address: "a@example.com",
      password: "pw12345",
      password_confirmation: "pw12345",
      organization: organization
    )
    expect(user.authenticate("pw12345")).to eq(user)
  end

  it "間違ったパスワードならauthenticateがfalseを返す" do
    user = User.create!(
      email_address: "b@example.com",
      password: "pw12345",
      password_confirmation: "pw12345",
      organization: organization
    )
    expect(user.authenticate("wrong")).to be_falsey
  end
end
