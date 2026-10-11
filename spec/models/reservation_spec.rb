# spec/models/reservation_spec.rb
require 'rails_helper'

RSpec.describe Reservation, type: :model do
  describe "ファクトリ" do
    it "有効なファクトリを持つこと" do
      expect(build(:reservation)).to be_valid
    end
  end

  describe "関連付け" do
    it "user に属していること" do
      expect(Reservation.reflect_on_association(:user).macro).to eq :belongs_to
    end

    it "room に属していること" do
      expect(Reservation.reflect_on_association(:room).macro).to eq :belongs_to
    end

    it "user がなければ無効であること" do
      reservation = build(:reservation, user: nil)
      expect(reservation).not_to be_valid
      expect(reservation.errors[:user]).to be_present
    end

    it "room がなければ無効であること" do
      reservation = build(:reservation, room: nil)
      expect(reservation).not_to be_valid
      expect(reservation.errors[:room]).to be_present
    end
  end

  describe "checkin_at のバリデーション" do
    it "なければ無効であること" do
      reservation = build(:reservation, checkin_at: nil)
      expect(reservation).not_to be_valid
      expect(reservation.errors[:checkin_at]).to be_present
    end

    it "昨日だと無効であること" do
      reservation = build(:reservation,
                          checkin_at: Time.zone.today - 1.day,
                          checkout_at: Time.zone.today + 2.days)
      expect(reservation).not_to be_valid
      expect(reservation.errors[:checkin_at]).to be_present
    end

    it "今日なら有効であること（境界値）" do
      reservation = build(:reservation,
                          checkin_at: Time.zone.today,
                          checkout_at: Time.zone.today + 2.days)
      expect(reservation).to be_valid
    end
  end

  describe "checkout_at のバリデーション" do
    it "なければ無効であること" do
      reservation = build(:reservation, checkout_at: nil)
      expect(reservation).not_to be_valid
      expect(reservation.errors[:checkout_at]).to be_present
    end

    it "checkin_at と同じ日だと無効であること（greater_than なので境界は NG）" do
      date = Time.zone.today + 1.day
      reservation = build(:reservation, checkin_at: date, checkout_at: date)
      expect(reservation).not_to be_valid
      expect(reservation.errors[:checkout_at]).to be_present
    end

    it "checkin_at より前だと無効であること" do
      reservation = build(:reservation,
                          checkin_at: Time.zone.today + 3.days,
                          checkout_at: Time.zone.today + 1.day)
      expect(reservation).not_to be_valid
    end

    it "checkin_at の翌日なら有効であること（境界値）" do
      reservation = build(:reservation,
                          checkin_at: Time.zone.today + 1.day,
                          checkout_at: Time.zone.today + 2.days)
      expect(reservation).to be_valid
    end
  end

  describe "guest_count のバリデーション" do
    it "なければ無効であること" do
      reservation = build(:reservation, guest_count: nil)
      expect(reservation).not_to be_valid
      expect(reservation.errors[:guest_count]).to be_present
    end

    it "0 だと無効であること" do
      reservation = build(:reservation, guest_count: 0)
      expect(reservation).not_to be_valid
    end

    it "負の数だと無効であること" do
      reservation = build(:reservation, guest_count: -1)
      expect(reservation).not_to be_valid
    end

    it "1 なら有効であること（境界値）" do
      reservation = build(:reservation, guest_count: 1)
      expect(reservation).to be_valid
    end
  end

  describe "#nights" do
    it "宿泊日数を返すこと" do
      reservation = build(:reservation,
                          checkin_at: Time.zone.today + 1.day,
                          checkout_at: Time.zone.today + 4.days)
      expect(reservation.nights).to eq 3
    end

    it "checkin_at が nil なら 0 を返すこと" do
      reservation = build(:reservation, checkin_at: nil)
      expect(reservation.nights).to eq 0
    end

    it "checkout_at が nil なら 0 を返すこと" do
      reservation = build(:reservation, checkout_at: nil)
      expect(reservation.nights).to eq 0
    end
  end

  describe "#total" do
    it "人数 × 部屋の料金 × 宿泊数を返すこと" do
      room = build(:room, price: 1000)
      reservation = build(:reservation,
                          room: room,
                          guest_count: 2,
                          checkin_at: Time.zone.today + 1.day,
                          checkout_at: Time.zone.today + 4.days)
      # 2人 × 1000円 × 3泊
      expect(reservation.total).to eq 6000
    end

    it "room がなければ 0 を返すこと" do
      reservation = build(:reservation, room: nil)
      expect(reservation.total).to eq 0
    end

    it "guest_count がなければ 0 を返すこと" do
      reservation = build(:reservation, guest_count: nil)
      expect(reservation.total).to eq 0
    end
  end
end