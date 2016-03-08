require 'securerandom'

class User < ActiveRecord::Base
  include BCrypt  
  has_many :pantry_items
  has_many :recipes
  has_many :pantry_items_user_logs

  has_secure_password

  validates_presence_of :email
  validates_uniqueness_of :email
  validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, :on => :create

  after_create :get_token

  def get_token
    # TODO REMOVE THIS DON'T FORGET
    unless self.email == 'rick@tinyrick.com'
      token = 'pantry' + SecureRandom.urlsafe_base64
      self.api_token = token
      self.save
    end
  end

  def personal_pantry
    self.pantry_items.where('quantity >= 0')
  end

  def public_pantry
    self.pantry_items.where('show_public = ? AND quantity >= ?', true, 0)
  end

  def private_pantry
    self.pantry_items.where('show_public = ? AND quantity >= ?', false, 0)
  end

  def consumed_pantry
    # TODO make this a thing
  end

  def self.send_expiration_emails
    ses = AWS::SES::Base.new(
      :access_key_id => ENV['AWS_KEY'],
      :secret_access_key => ENV['AWS_SECRET'],
      :server => 'email.us-west-2.amazonaws.com'
    )
    self.where(exp_notif: true).each do |user|
      exp_soon = PantryItemsUser.expiring_soon(user.id)
      exp_html = ""
      if exp_soon.length > 0
        exp_soon.each do |exp_item|
          item = exp_item.pantry_item
          exp_html += "#{item.name} is expiring soon. <br>"
        end
        ses.send_email(
          :to        => user.email,
          :source    => '"Pocket Pantry" <riley.r.spicer@gmail.com>',
          :subject   => "You have items expiring soon!",
          :html_body => exp_html
        )
      end
    end
  end

  def self.cron_test
    ses = AWS::SES::Base.new(
      :access_key_id => ENV['AWS_KEY'],
      :secret_access_key => ENV['AWS_SECRET'],
      :server => 'email.us-west-2.amazonaws.com'
    )
    ses.send_email(
      :to        => 'riley.r.spicer@gmail.com',
      :source    => '"Pocket Pantry" <riley.r.spicer@gmail.com>',
      :subject   => "It's working on EB",
      :html_body => "Cron test."
    )
  end

end