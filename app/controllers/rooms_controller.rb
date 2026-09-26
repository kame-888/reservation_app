class RoomsController < ApplicationController
  before_action :authenticate_user!, only: [:new, :create, :edit, :update, :destroy]
  before_action :set_room, only: [:show, :edit, :update, :destroy]
  before_action :authorize_owner!, only: [:edit, :update, :destroy]

  def new
    @room = Room.new
  end

  def create
    @room = current_user.rooms.build(room_params)

    if @room.save
      redirect_to @room, notice: "宿泊施設情報を作成しました"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def index
    @rooms = Room.order(created_at: :desc)
  end

  # before_actionでセット済み
  def show 
  end
  def edit
  end

  def update
    if @room.update(room_params)
      redirect_to room_path(@room), notice: "更新しました", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    redirect_to rooms_path, notice: "宿泊施設情報を削除しました"
  end

  private

  def set_room_id
    @room = Room.find(params[:id])
  end

  def room_params
    params.require(:room).permit(:name, :description, :price, :address, :image)
  end

  def authorize_owner!
    redirect_to root_path, alert: "権限がありません" unless @room.user_id == current_user.id
  end
end
