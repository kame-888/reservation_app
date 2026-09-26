class RoomsController < ApplicationController
  before_action :set_room_id, only: [ :show, :edit, :update, :destroy ]

  def new
    @room = Room.new
  end

  def create
    @room = Room.new(room_params)

    if @room.save
      redirect_to @room, notice: "宿泊施設情報を作成しました"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def index
    @Rooms = Room.order(created_at: :desc)
  end

  # before_actionで同一のアクションを定義
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
    if @room.destroy
      redirect_to rooms_path, notice: "スケジュールを削除しました"
    else
      render :show, status: :unprocessable_entity
    end
  end

  private

  def set_room_id
    @room = Room.find(params[:id])
  end

  def room_params
    params.require(:room).permit(:name, :description, :price, :address, :image)
  end
end
