class StaticPagesController < ApplicationController
  
  before_action :authenticate_user!
  
  def index
    @page = Page.last
  end
  
end
