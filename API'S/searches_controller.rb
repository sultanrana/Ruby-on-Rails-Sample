class Api::V1::SearchesController < ApplicationController
  
  def search_artist
    @aritst =  User.where("user_type = ? and lower(first_name) LIKE ?", 'artist', "%#{params[:q].downcase}%")
  end
  
  def search_fan
    @fan =  User.where("user_type = ? and (lower(first_name) LIKE ? or lower(last_name) LIKE ?)", 'fan',"%#{params[:q].downcase}%", "%#{params[:q].downcase}%" )
  end
  
end
