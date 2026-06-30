require "rails_helper"

RSpec.describe Organization, type: :model do
  it "nameが無いと無効" do
    expect(Organization.new(name: nil)).not_to be_valid
  end

  it "nameがあれば有効" do
    expect(Organization.new(name: "会社A")).to be_valid
  end
end
