class SessionsController < ApplicationController

  def destroy
    sessions[:user_id] = nil
    redirect_to root_path, notice: 'Signed out!'
  end

end
