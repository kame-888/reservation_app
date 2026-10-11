# spec/requests/home_spec.rb
require 'rails_helper'

RSpec.describe "Home", type: :request do
  describe "GET /" do
    it "200 が返ること" do
      get root_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /home/search" do
    let!(:tokyo_room) do
      create(:room, name: "渋谷ホテル", description: "駅近で便利", address: "東京都渋谷区")
    end
    let!(:osaka_room) do
      create(:room, name: "梅田ホテル", description: "海が見える", address: "大阪府大阪市")
    end

    it "ログインしていなくても表示できること" do
      get home_search_path
      expect(response).to have_http_status(:ok)
    end

    it "パラメータなしなら全件表示されること" do
      get home_search_path
      expect(response.body).to include("渋谷ホテル", "梅田ホテル")
    end

    it "keyword で住所を絞り込めること" do
      get home_search_path, params: { keyword: "東京" }
      expect(response.body).to include("渋谷ホテル")
      expect(response.body).not_to include("梅田ホテル")
    end

    it "free_word で名前を絞り込めること" do
      get home_search_path, params: { free_word: "梅田" }
      expect(response.body).to include("梅田ホテル")
      expect(response.body).not_to include("渋谷ホテル")
    end

    it "free_word で説明文を絞り込めること" do
      get home_search_path, params: { free_word: "駅近" }
      expect(response.body).to include("渋谷ホテル")
      expect(response.body).not_to include("梅田ホテル")
    end

    it "keyword と free_word を組み合わせて絞り込めること" do
      get home_search_path, params: { keyword: "東京", free_word: "海" }
      expect(response.body).not_to include("渋谷ホテル")
      expect(response.body).not_to include("梅田ホテル")
    end

    it "一致する部屋がなくても 200 が返ること" do
      get home_search_path, params: { keyword: "北海道" }
      expect(response).to have_http_status(:ok)
    end
  end
end