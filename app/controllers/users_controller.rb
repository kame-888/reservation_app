class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user_id

  #before_actionでidを先に取得
  def show
  end

  def edit
  end

  def update
    if @user.update(user_params)
      redirect_to user_path(@user), notice: "更新しました"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_user_id
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:first_name, :family_name, :avatar)
  end
end
