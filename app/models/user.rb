class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :books, dependent: :destroy
  # いいね機能
  has_many :favorites, dependent: :destroy
  # グループ機能
  has_many :group_users
  has_many :groups, through: :group_users
  has_one_attached :profile_image

  validates :name, length: { minimum: 2, maximum: 20 }, uniqueness: true
  validates :introduction, length: { maximum: 50 }

  # DM機能
  has_many :user_rooms, dependent: :destroy
  has_many :chats, dependent: :destroy

  # フォローをした、されたの関係
  has_many :relationships, class_name: "Relationship", foreign_key: "follower_id", dependent: :destroy
  has_many :reverse_of_relationships, class_name: "Relationship", foreign_key: "followed_id", dependent: :destroy

  # 一覧画面で使う
  has_many :followings, through: :relationships, source: :followed
  has_many :followers, through: :reverse_of_relationships, source: :follower

  # フォローしたときの処理
  # current_user（インスタンス）はmodel内で省略できる
  def follow(user_id)
    relationships.create(followed_id: user_id)
  end

  # フォローを外すときの処理
  def unfollow(user_id)
    # selfに紐ずくrelationships自分がフォローしている人たち
    relationships.find_by(followed_id: user_id).destroy
  end

  # フォローしているか判定
  def following?(user)
    followings.include?(user)
  end

  def get_profile_image
    profile_image.attached? ? profile_image : 'no_image.jpg'
  end

  # 検索方法分岐
  def self.looks(search, word)
    if search == "perfect_match"
      @user = User.where("name LIKE?", "#{word}")
    elsif search == "forward_match"
      @user = User.where("name LIKE?", "#{word}%")
    elsif search == "backward_match"
      @user = User.where("name LIKE?", "%#{word}")
    elsif search == "partial_match"
      @user = User.where("name LIKE?", "%#{word}%")
    else
      @user = User.all
    end
  end

  def self.guest
    find_or_create_by!(name: 'guestuser', email: 'guest@example.com') do |user|
      user.password = SecureRandom.urlsafe_base64
      user.name = "guestuser"
    end
  end
end
