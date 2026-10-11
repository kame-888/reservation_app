# spec/models/room_spec.rb
require 'rails_helper'

RSpec.describe Room, type: :model do
  describe "ファクトリ" do
    it "有効なファクトリを持つこと" do
      expect(build(:room)).to be_valid
    end
  end

  describe "バリデーション" do
    it "user がなければ無効であること" do
      room = build(:room, user: nil)
      expect(room).not_to be_valid
      expect(room.errors[:user]).to be_present
    end

    it "name がなければ無効であること" do
      room = build(:room, name: nil)
      expect(room).not_to be_valid
      expect(room.errors[:name]).to be_present
    end

    it "description がなければ無効であること" do
      room = build(:room, description: nil)
      expect(room).not_to be_valid
      expect(room.errors[:description]).to be_present
    end

    it "address がなければ無効であること" do
      room = build(:room, address: nil)
      expect(room).not_to be_valid
      expect(room.errors[:address]).to be_present
    end

    it "price がなければ無効であること" do
      room = build(:room, price: nil)
      expect(room).not_to be_valid
      expect(room.errors[:price]).to be_present
    end

    it "price が 0 だと無効であること" do
      room = build(:room, price: 0)
      expect(room).not_to be_valid
    end

    it "price が負の数だと無効であること" do
      room = build(:room, price: -100)
      expect(room).not_to be_valid
    end

    it "price が 1 なら有効であること（境界値）" do
      room = build(:room, price: 1)
      expect(room).to be_valid
    end

    it "price が小数だと無効であること" do
      room = build(:room, price: 1.5)
      expect(room).not_to be_valid
      expect(room.errors[:price]).to be_present
    end
  end

  describe "関連付け" do
    it "user に属していること" do
      expect(Room.reflect_on_association(:user).macro).to eq :belongs_to
    end

    it "複数の reservations を持つこと" do
      expect(Room.reflect_on_association(:reservations).macro).to eq :has_many
    end

    it "room を削除すると関連する reservations も削除されること" do
      room = create(:room)
      create(:reservation, room: room)
      expect { room.destroy }.to change(Reservation, :count).by(-1)
    end
  end

  describe ".search" do
    let!(:tokyo_room) { create(:room, address: "東京都渋谷区") }
    let!(:osaka_room) { create(:room, address: "大阪府大阪市") }

    it "キーワードに一致する住所の room だけ返すこと" do
      expect(Room.search("東京")).to contain_exactly(tokyo_room)
    end

    it "一致する room がなければ空になること" do
      expect(Room.search("北海道")).to be_empty
    end

    it "部分一致で検索できること" do
      expect(Room.search("大阪市")).to contain_exactly(osaka_room)
    end

    it "キーワードが空文字のとき全件返すこと" do
      expect(Room.search("")).to match_array(Room.all)
    end
  end
end
