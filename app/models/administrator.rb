class Administrator < ActiveRecord::Base
  include EmailHolder
  include PasswordHolder

  def active?
    !suspended?
  end
end
