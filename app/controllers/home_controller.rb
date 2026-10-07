class HomeController < ApplicationController
  def index
  end

  def search
    session[:rooms_index_url] = request.fullpath
    @rooms = Room.search(params[:keyword]).with_attached_image
  end

end
