class User < ActiveRecord::Base
  has_many :posts
  has_secure_password
  validates_presence_of :username, :email

  def slug
    self.username.downcase.gsub(" ", "-")
  end

  def self.find_by_slug(slug)
    self.all.detect { |instance| instance.username.downcase == slug.gsub("-", " ")}
  end
end
