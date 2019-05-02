class Tatto < ApplicationRecord
 
  self.per_page = 30
  
  has_attached_file :avatar, styles: {large: "1200x512" ,medium: "812x512!", thumb: "360x360" }, default_url: ""
  validates_attachment_content_type :avatar, content_type: /\Aimage\/.*\z/
  belongs_to :user
  
  has_many :likes
  has_many :bookmarks
  has_many :comments
  
  def upload_image(params)
    
    if !params.blank?
      decoded_data = Base64.decode64(params)
      @data = StringIO.new(decoded_data)
      self.update(avatar: @data)
    end
    
  end
  
  # Start: Is liked tattos
  def is_liked(user)
    like =  self.likes.where(user_id: user.try(:id), is_like: true)
    if like.blank?
      is_like = false
    else
      is_like = true
    end
    return  is_like
  end
  # End  : Is liked tattos
  
  # Start: Is bookmarked tattos
  def is_bookmarked(user)
    bookmark = self.bookmarks.where(user_id: user.try(:id), is_book_mark: true)
    if bookmark.blank?
      is_bookmark = false
    else
      is_bookmark = true
    end
    return is_bookmark 
  end
  # End  : Is bookmarked tattos
  
end
