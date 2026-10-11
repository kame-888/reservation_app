# spec/requests/users_spec.rb
require 'rails_helper'

RSpec.describe "Users", type: :request do
  let(:user)       { create(:user) }
  let(:other_user) { create(:user) }

  describe "GET /users/:id" do
    it "ログインしていなければログイン画面にリダイレクトされること" do
      get user_path(user)
      expect(response).to redirect_to(new_user_session_path)
    end

    it "ログインしていれば 200 が返ること" do
      sign_in user
      get user_path(user)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /users/:id/edit" do
    it "ログインしていなければログイン画面にリダイレクトされること" do
      get edit_user_path(user)
      expect(response).to redirect_to(new_user_session_path)
    end

    it "本人なら 200 が返ること" do
      sign_in user
      get edit_user_path(user)
      expect(response).to have_http_status(:ok)
    end

    # authorize_self! を追加するまでは失敗します
    it "他人の編集画面は開けず、トップにリダイレクトされること" do
      sign_in user
      get edit_user_path(other_user)
      expect(response).to redirect_to(root_path)
    end
  end

  describe "PATCH /users/:id" do
    let(:update_params) { { user: { first_name: "新しい名", family_name: "新しい姓" } } }

    it "ログインしていなければログイン画面にリダイレクトされること" do
      patch user_path(user), params: update_params
      expect(response).to redirect_to(new_user_session_path)
    end

    context "本人のとき" do
      before { sign_in user }

      it "更新できること" do
        patch user_path(user), params: update_params
        user.reload
        expect(user.first_name).to eq "新しい名"
        expect(user.family_name).to eq "新しい姓"
      end

      it "プロフィール画面にリダイレクトされること" do
        patch user_path(user), params: update_params
        expect(response).to redirect_to(user_path(user))
      end

      # User に first_name の presence バリデーションがある場合のみ
      it "無効なパラメータなら 422 になること" do
        patch user_path(user), params: { user: { first_name: "" } }
        expect(response).to have_http_status(:unprocessable_content)
      end
    end

    # authorize_self! を追加するまでは失敗します
    context "他人のとき" do
      before { sign_in user }

      it "更新されず、トップにリダイレクトされること" do
        original_name = other_user.first_name
        patch user_path(other_user), params: update_params
        expect(response).to redirect_to(root_path)
        expect(other_user.reload.first_name).to eq original_name
      end
    end
  end
end