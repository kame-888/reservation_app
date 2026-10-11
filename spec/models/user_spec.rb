# spec/models/user_spec.rb
require 'rails_helper'

RSpec.describe User, type: :model do
  describe "ファクトリ" do
    it "有効なファクトリを持つこと" do
      expect(build(:user)).to be_valid
    end
  end

  describe "バリデーション" do
    it "email がなければ無効であること" do
      user = build(:user, email: nil)
      expect(user).not_to be_valid
      expect(user.errors[:email]).to be_present
    end

    it "email が重複していれば無効であること" do
      create(:user, email: "test@example.com")
      user = build(:user, email: "test@example.com")
      expect(user).not_to be_valid
    end

    it "email の形式が不正なら無効であること" do
      user = build(:user, email: "invalid")
      expect(user).not_to be_valid
    end

    it "password がなければ無効であること" do
      user = build(:user, password: nil)
      expect(user).not_to be_valid
    end

    it "password が短すぎると無効であること" do
      user = build(:user, password: "abc12")
      expect(user).not_to be_valid
    end

    # first_name / family_name に presence バリデーションがある場合のみ
    it "first_name がなければ無効であること" do
      user = build(:user, first_name: nil)
      expect(user).not_to be_valid
    end

    it "family_name がなければ無効であること" do
      user = build(:user, family_name: nil)
      expect(user).not_to be_valid
    end
  end

  describe "関連付け" do
    it "複数の rooms を持つこと" do
      expect(User.reflect_on_association(:rooms).macro).to eq :has_many
    end

    it "複数の reservations を持つこと" do
      expect(User.reflect_on_association(:reservations).macro).to eq :has_many
    end
  end
end