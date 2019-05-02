class Api::V1::ArtistsController < ApplicationController
  
  before_filter :get_artist ,  only: [:update, :show, :destroy]
   
  def index
    @artists = User.where(:user_type => 'artist')
  end
  
  def show
    
  end  
  
  def update
    
    @already = User.find_by_atow(true)
    if @already
      if  @already.update(:atow => false)
        @artist.update(:atow => true)
      else
        
      end
    else
      @artist.update(:atow => true)
    end
    
  end
  
  def destroy
    if @artist.destroy
      
    else
      
    end
  end
  
  def active_artist
    @artist = User.find_by_atow(true)
  end
  
  private
  
  def get_artist
    @artist = User.find_by_id(params[:id])
  end
  
end
