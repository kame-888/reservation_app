class HomeController < ApplicationController
  def index
  end

  def search
    @rooms = Room.search(params[:keyword])
  end

end
