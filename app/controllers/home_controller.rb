class HomeController < ApplicationController
  def index
  end

  def search
    @rooms = Room.all.with_attached_image

    if params[:keyword].present?
      kw = "%#{Room.sanitize_sql_like(params[:keyword])}%"
      @rooms = @rooms.where("address LIKE ?", kw).with_attached_image
    end

    if params[:free_word].present?
      fw = "%#{Room.sanitize_sql_like(params[:free_word])}%"
      @rooms = @rooms.where("name LIKE :fw OR description LIKE :fw", fw: fw).with_attached_image
    end
  end

end
