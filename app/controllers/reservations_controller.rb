class ReservationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_room

  def confirm
    @reservation = build_reservation
    render "rooms/show", status: :unprocessable_entity if @reservation.invalid?
  end

  def create
    @reservation = build_reservation

    return render "rooms/show" if params[:back]

    if @reservation.save
      redirect_to room_path(@room), notice: "予約が完了しました"
    else
      render "rooms/show", status: :unprocessable_entity
    end
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