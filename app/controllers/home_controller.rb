class HomeController < ApplicationController
  def index
  end

  def search
    @rooms = Room.search(params[:keyword]).with_attached_image
  end

end
