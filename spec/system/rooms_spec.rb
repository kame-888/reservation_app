# spec/system/rooms_spec.rb
require 'rails_helper'

RSpec.describe "施設の管理と検索", type: :system do
  let(:owner) { create(:user) }

  it "ログインして施設を登録できること" do
    login_as owner
    visit new_room_path

    fill_in "room_name",        with: "新宿ホテル"
    fill_in "room_description", with: "駅から徒歩1分"
    fill_in "room_price",       with: 5000
    fill_in "room_address",     with: "東京都新宿区"

    expect {
      click_button "登録"            # ← 実際のボタン文言に合わせる
    }.to change(Room, :count).by(1)

    expect(page).to have_content "宿泊施設情報を作成しました"
    expect(page).to have_content "新宿ホテル"
  end

  it "住所で施設を検索できること" do
    create(:room, name: "渋谷ホテル", address: "東京都渋谷区")
    create(:room, name: "梅田ホテル", address: "大阪府大阪市")

    visit home_search_path(keyword: "東京")

    expect(page).to have_content "渋谷ホテル"
    expect(page).not_to have_content "梅田ホテル"
  end
end
