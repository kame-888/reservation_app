# spec/system/reservation_destroy_spec.rb
require 'rails_helper'

RSpec.describe "予約の削除", type: :system, js: true do
  let(:user) { create(:user) }
  let!(:room) { create(:room, name: "渋谷ホテル") }
  let!(:reservation) { create(:reservation, user: user, room: room) }

  before { login_as user }

  it "確認ダイアログを承認すると予約を削除できること" do
    visit reservations_path
    expect(page).to have_content "渋谷ホテル"

    expect {
      accept_confirm("予約を削除しますか？") do
        click_link "削除"
      end
      expect(page).not_to have_content "渋谷ホテル"
    }.to change(Reservation, :count).by(-1)
  end

  it "確認ダイアログをキャンセルすると削除されないこと" do
    visit reservations_path

    dismiss_confirm do
      click_link "削除"
    end

    expect(page).to have_content "渋谷ホテル"
    expect(Reservation.count).to eq 1
  end
end