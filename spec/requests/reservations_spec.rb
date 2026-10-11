# spec/requests/reservations_spec.rb
require 'rails_helper'

RSpec.describe "Reservations", type: :request do
  let(:user) { create(:user) }
  let(:room) { create(:room) }
  let(:valid_params) { { reservation: attributes_for(:reservation) } }
  let(:invalid_params) { { reservation: attributes_for(:reservation, guest_count: 0) } }

  describe "POST /rooms/:room_id/reservations/confirm" do
    context "ログインしていないとき" do
      it "ログイン画面にリダイレクトされること" do
        post confirm_room_reservations_path(room), params: valid_params
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "ログインしているとき" do
      before { sign_in user }

      it "有効なパラメータなら確認画面が表示されること" do
        post confirm_room_reservations_path(room), params: valid_params
        expect(response).to have_http_status(:ok)
      end

      it "確認画面では予約が保存されないこと" do
        expect {
          post confirm_room_reservations_path(room), params: valid_params
        }.not_to change(Reservation, :count)
      end

      it "無効なパラメータなら 422 になること" do
        post confirm_room_reservations_path(room), params: invalid_params
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe "POST /rooms/:room_id/reservations" do
    context "ログインしていないとき" do
      it "ログイン画面にリダイレクトされること" do
        post room_reservations_path(room), params: valid_params
        expect(response).to redirect_to(new_user_session_path)
      end

      it "予約が作成されないこと" do
        expect {
          post room_reservations_path(room), params: valid_params
        }.not_to change(Reservation, :count)
      end
    end

    context "ログインしているとき" do
      before { sign_in user }

      it "予約が作成されること" do
        expect {
          post room_reservations_path(room), params: valid_params
        }.to change(Reservation, :count).by(1)
      end

      it "ログインユーザーと対象の部屋に紐づくこと" do
        post room_reservations_path(room), params: valid_params
        reservation = Reservation.last
        expect(reservation.user).to eq user
        expect(reservation.room).to eq room
      end

      it "予約一覧にリダイレクトされること" do
        post room_reservations_path(room), params: valid_params
        expect(response).to redirect_to(reservations_path)
      end

      it "無効なパラメータなら作成されず 422 になること" do
        expect {
          post room_reservations_path(room), params: invalid_params
        }.not_to change(Reservation, :count)
        expect(response).to have_http_status(:unprocessable_content)
      end

      it "back パラメータがあれば作成されず 422 で入力画面に戻ること" do
        expect {
          post room_reservations_path(room), params: valid_params.merge(back: "1")
        }.not_to change(Reservation, :count)
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe "GET /reservations" do
    context "ログインしていないとき" do
      it "ログイン画面にリダイレクトされること" do
        get reservations_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "ログインしているとき" do
      before { sign_in user }

      it "200 が返ること" do
        get reservations_path
        expect(response).to have_http_status(:ok)
      end

      it "自分の予約だけが表示されること" do
        my_room    = create(:room, name: "自分の予約ホテル")
        other_room = create(:room, name: "他人の予約ホテル")
        create(:reservation, user: user, room: my_room)
        create(:reservation, user: create(:user), room: other_room)

        get reservations_path
        expect(response.body).to include("自分の予約ホテル")
        expect(response.body).not_to include("他人の予約ホテル")
      end
    end
  end

  describe "DELETE /reservations/:id" do
    let!(:reservation) { create(:reservation, user: user, room: room) }

    context "ログインしていないとき" do
      it "ログイン画面にリダイレクトされ、削除されないこと" do
        expect {
          delete reservation_path(reservation)
        }.not_to change(Reservation, :count)
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "ログインしているとき" do
      before { sign_in user }

      it "自分の予約を削除できること" do
        expect {
          delete reservation_path(reservation)
        }.to change(Reservation, :count).by(-1)
      end

      it "予約一覧に 303 でリダイレクトされること" do
        delete reservation_path(reservation)
        expect(response).to redirect_to(reservations_path)
        expect(response).to have_http_status(:see_other)
      end

      it "他人の予約は削除できないこと" do
        others = create(:reservation, user: create(:user), room: room)
        expect {
          delete reservation_path(others)
        }.not_to change(Reservation, :count)
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end