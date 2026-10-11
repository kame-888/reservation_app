# spec/system/reservations_spec.rb
require 'rails_helper'

RSpec.describe "予約の流れ", type: :system do
  let(:user) { create(:user) }
  let!(:room) { create(:room, name: "渋谷ホテル", price: 1000) }

  let(:checkin)  { Date.current + 1.day }
  let(:checkout) { Date.current + 3.days }

  def fill_reservation_form(guests: 2)
    fill_in "reservation_checkin_at",  with: checkin.iso8601
    fill_in "reservation_checkout_at", with: checkout.iso8601
    fill_in "reservation_guest_count", with: guests
  end

  context "ログインしているとき" do
    before { login_as user }

    it "施設を選んで予約を完了できること" do
      visit room_path(room)
      expect(page).to have_content "渋谷ホテル"

      fill_reservation_form(guests: 2)
      click_button "確認画面へ"

      # 確認画面
      expect(page).to have_content "この内容で予約しますか？"
      expect(page).to have_content "人数: 2名"
      # 2人 × 1000円 × 2泊 = 4000円
      expect(page).to have_content "金額: 4,000円"

      expect {
        click_button "予約を確定する"
      }.to change(Reservation, :count).by(1)

      # 予約一覧
      expect(page).to have_current_path(reservations_path)
      expect(page).to have_content "予約済み一覧"
      expect(page).to have_content "渋谷ホテル"
    end

    it "確認画面から戻るボタンで入力画面に戻れること" do
      visit room_path(room)
      fill_reservation_form(guests: 2)
      click_button "確認画面へ"

      expect {
        click_button "戻る"
      }.not_to change(Reservation, :count)

      expect(page).to have_button "確認画面へ"
    end

    it "入力が不正なら確認画面に進めずエラーが表示されること" do
      visit room_path(room)

      fill_reservation_form(guests: 0)
      click_button "確認画面へ"

      expect(page).to have_css "ul.errors li"
      expect(page).not_to have_content "この内容で予約しますか？"
      expect(Reservation.count).to eq 0
    end
  end

  context "ログインしていないとき" do
    it "確認画面へ進もうとするとログイン画面に移動すること" do
      visit room_path(room)

      fill_reservation_form
      click_button "確認画面へ"

      expect(page).to have_current_path(new_user_session_path)
    end
  end
end