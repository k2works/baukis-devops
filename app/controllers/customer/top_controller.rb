class Customer::TopController < ApplicationController
  def index
    raise ActiveRecord::RecordNotFound
  end
end
