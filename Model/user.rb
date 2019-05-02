class User < ApplicationRecord
  rolify
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
    :recoverable, :rememberable, :trackable, :validatable
       
  has_attached_file :avatar, styles: { medium: "300x300>", thumb: "100x100>" }, default_url: "/images/:style/missing.png"
  validates_attachment_content_type :avatar, content_type: /\Aimage\/.*\z/

  has_attached_file :banner_image, styles: { medium: "300x300>", thumb: "100x100>" }, default_url: "/images/:style/missing.png"
  validates_attachment_content_type :banner_image, content_type: /\Aimage\/.*\z/  
   
  validates_uniqueness_of :username
  
  self.per_page = 10
  
  has_many :tattos ,  dependent: :destroy
  has_many :followings ,  dependent: :destroy
  has_many :followers , dependent: :destroy
  has_many :likes   , dependent: :destroy
  has_many :bookmarks , dependent: :destroy
  has_many :comments  , dependent: :destroy
  has_one  :shop , dependent: :destroy
  
  before_create :generate_token
  
  def generate_token
    self.token = loop do
      random_token = SecureRandom.urlsafe_base64(nil, false)
      break random_token unless User.exists?(token: random_token)
    end
  end
  
  def name
    if !self.last_name.blank? && !self.first_name.blank?
      name = self.first_name.capitalize + " " + self.last_name.capitalize
    else
      if !self.last_name.blank?
        name = self.first_name.capitalize
      else
        name = ""
      end
    end
    return name
  end
  
  def user_image(params)
    if params
      decoded_data = Base64.decode64(params)
      @data = StringIO.new(decoded_data)
      self.update(avatar: @data)
    end
  end
  
  def add_banner_image(params)
    if params
      decoded_data = Base64.decode64(params)
      @data = StringIO.new(decoded_data)
      self.update(banner_image: @data)
    end
  end
  
  # Start: Is follow other users
  def is_follows(user, current_user)
    if !current_user.blank?
      @following = Follower.find_by_user_id_and_follower_id(user.try(:id), current_user.try(:id))
      if !@following.blank?
        is_follow = true
      else
        is_follow = false
      end
    else
      is_follow = false
    end
    return  is_follow
  end
  # End: Is follow other users
  
  # Start: Getting follower count
  def followers_count
    @follower_ids = self.followers.collect(&:follower_id)
    return User.where(id: @follower_ids).count
  end
  # End  : Getting follower count
  
  # Start: Getting following count
  def followings_count
    @follower_ids = self.followings.collect(&:following_id)
    return User.where(id: @follower_ids).count
  end
  # End : Getting followung count
  
  def is_follow_user(user, current_user)
    @followers=  Follower.where(user_id: user.try(:id), follower_id: current_user.try(:id))
    if @followers.blank?
      a = false
    else
      a = true
    end
    return a
    
  end
   
end
