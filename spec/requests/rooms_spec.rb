# spec/requests/rooms_spec.rb
require 'rails_helper'

RSpec.describe "Rooms", type: :request do
  let(:owner)      { create(:user) }
  let(:other_user) { create(:user) }
  let!(:room)      { create(:room, user: owner) }

  let(:valid_params)   { { room: attributes_for(:room) } }
  let(:invalid_params) { { room: attributes_for(:room, name: "") } }

  describe "GET /rooms" do
    context "ログインしていないとき" do
      it "ログイン画面にリダイレクトされること" do
        get rooms_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "ログインしているとき" do
      before { sign_in owner }

      it "200 が返ること" do
        get rooms_path
        expect(response).to have_http_status(:ok)
      end

      it "自分の施設だけが表示されること" do
        create(:room, user: owner,      name: "自分のホテル")
        create(:room, user: other_user, name: "他人のホテル")

        get rooms_path
        expect(response.body).to include("自分のホテル")
        expect(response.body).not_to include("他人のホテル")
      end
    end
  end

  describe "GET /rooms/:id" do
    it "ログインしていなくても表示できること" do
      get room_path(room)
      expect(response).to have_http_status(:ok)
    end

    it "存在しない ID なら 404 になること" do
      get room_path(id: 0)
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "GET /rooms/new" do
    it "ログインしていなければログイン画面にリダイレクトされること" do
      get new_room_path
      expect(response).to redirect_to(new_user_session_path)
    end

    it "ログインしていれば 200 が返ること" do
      sign_in owner
      get new_room_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /rooms" do
    context "ログインしていないとき" do
      it "ログイン画面にリダイレクトされ、作成されないこと" do
        expect {
          post rooms_path, params: valid_params
        }.not_to change(Room, :count)
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "ログインしているとき" do
      before { sign_in owner }

      it "施設が作成されること" do
        expect {
          post rooms_path, params: valid_params
        }.to change(Room, :count).by(1)
      end

      it "ログインユーザーに紐づくこと" do
        post rooms_path, params: valid_params
        expect(Room.last.user).to eq owner
      end

      it "施設一覧にリダイレクトされること" do
        post rooms_path, params: valid_params
        expect(response).to redirect_to(rooms_path)
      end

      it "無効なパラメータなら作成されず 422 になること" do
        expect {
          post rooms_path, params: invalid_params
        }.not_to change(Room, :count)
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe "GET /rooms/:id/edit" do
    it "ログインしていなければログイン画面にリダイレクトされること" do
      get edit_room_path(room)
      expect(response).to redirect_to(new_user_session_path)
    end

    it "作成者なら 200 が返ること" do
      sign_in owner
      get edit_room_path(room)
      expect(response).to have_http_status(:ok)
    end

    it "作成者以外ならトップにリダイレクトされること" do
      sign_in other_user
      get edit_room_path(room)
      expect(response).to redirect_to(root_path)
    end
  end

  describe "PATCH /rooms/:id" do
    let(:update_params) { { room: { name: "新しい名前" } } }

    context "ログインしていないとき" do
      it "ログイン画面にリダイレクトされ、更新されないこと" do
        patch room_path(room), params: update_params
        expect(response).to redirect_to(new_user_session_path)
        expect(room.reload.name).not_to eq "新しい名前"
      end
    end

    context "作成者のとき" do
      before { sign_in owner }

      it "更新できること" do
        patch room_path(room), params: update_params
        expect(room.reload.name).to eq "新しい名前"
      end

      it "施設一覧に 303 でリダイレクトされること" do
        patch room_path(room), params: update_params
        expect(response).to redirect_to(rooms_path)
        expect(response).to have_http_status(:see_other)
      end

      it "無効なパラメータなら更新されず 422 になること" do
        patch room_path(room), params: { room: { name: "" } }
        expect(response).to have_http_status(:unprocessable_content)
        expect(room.reload.name).not_to eq ""
      end
    end

    context "作成者以外のとき" do
      before { sign_in other_user }

      it "更新されず、トップにリダイレクトされること" do
        patch room_path(room), params: update_params
        expect(response).to redirect_to(root_path)
        expect(room.reload.name).not_to eq "新しい名前"
      end
    end
  end

  describe "DELETE /rooms/:id" do
    context "ログインしていないとき" do
      it "ログイン画面にリダイレクトされ、削除されないこと" do
        expect {
          delete room_path(room)
        }.not_to change(Room, :count)
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "作成者のとき" do
      before { sign_in owner }

      it "削除できること" do
        expect {
          delete room_path(room)
        }.to change(Room, :count).by(-1)
      end

      it "施設一覧に 303 でリダイレクトされること" do
        delete room_path(room)
        expect(response).to redirect_to(rooms_path)
        expect(response).to have_http_status(:see_other)
      end
    end

    context "作成者以外のとき" do
      before { sign_in other_user }

      it "削除されず、トップにリダイレクトされること" do
        expect {
          delete room_path(room)
        }.not_to change(Room, :count)
        expect(response).to redirect_to(root_path)
      end
    end
  end
end
