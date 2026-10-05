class ReservationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_room, only: [:create, :confirm]

  def confirm
    @reservation = build_reservation
    render "rooms/show", status: :unprocessable_entity if @reservation.invalid?
  end

  def create
    @reservation = build_reservation

    return render "rooms/show", status: :unprocessable_entity if params[:back]

    if @reservation.save
      redirect_to reservations_path, notice: "予約が完了しました"
    else
      render "rooms/show", status: :unprocessable_entity
    end
  end

  def index
    @reservations = current_user.reservations.includes(room: { image_attachment: :blob }).order(created_at: :desc)
  end

  def destroy
    @reservation = current_user.reservations.find(params[:id])
    @reservation.destroy
    redirect_to reservations_path, notice: "予約を削除しました", status: :see_other
  end

  private

  def set_room
    @room = Room.find(params[:room_id])
  end

  def build_reservation
    @room.reservations.build(reservation_params).tap do |r|
      r.user = current_user
    end
  end

  def reservation_params
    params.require(:reservation).permit(:checkin_at, :checkout_at, :guest_count)
  end
end