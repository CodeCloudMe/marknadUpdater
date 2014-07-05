class FeedsController < ApplicationController
  
 skip_before_filter :require_login, only: [:index]

  def index
    #redirect_to :controller => 'sessions', :action => 'connect' if !session[:access_token] 

    client = Instagram.client(:access_token => '251365880.1fb234f.451c1a86b42143579928d78f2c612f8d')
    @user = client.user
   # @recent_media_items = client.user_recent_media
   @recent_media_items = Instagram.user_recent_media(1019588938, {access_token: '251365880.1fb234f.451c1a86b42143579928d78f2c612f8d', count: 60}) 
  end
end