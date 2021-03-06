class User < ActiveRecord::Base
  ROLES = %w[dbausr supervisor user banned]
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :roles, :avatar
  # attr_accessible :title, :body

  # This is for the example
  has_many :reminders

  has_attached_file :avatar, styles: {
    small:  '25x25>',
    thumb:  '100x100>',
    medium: '200x200>',
    large:  '300x300>'
  }
  
  # Enable papertrail on this model
  # Ignore fields that are not critical, and do not store s3 information
  has_paper_trail only: [:email, :encrypted_password, :roles_mask],
                  skip: [:avatar_file_name, :avatar_content_type, :avatar_file_size, :avatar_updated_at]

  include Rails.application.routes.url_helpers

  def roles=(roles)
    self.roles_mask = (roles & ROLES).map { |r| 2**ROLES.index(r) }.inject(0, :+)
    self.save
  end

  def roles
    ROLES.reject do |r|
      ((roles_mask || 0) & 2**ROLES.index(r)).zero?
    end
  end

  def is?(role)
    roles.include?(role.to_s)
  end

end
