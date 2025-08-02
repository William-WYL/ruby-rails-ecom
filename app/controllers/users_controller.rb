class UsersController < ApplicationController
  before_action :authenticate_user!

  def index
    @users = User.includes(:address).all
  end

  def show
    @user = User.includes(address: :province).find(params[:id])
  end
end
