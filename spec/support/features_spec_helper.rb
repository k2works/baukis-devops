module FeaturesSpecHelper
  def switch_namespace(namespace)
    config = Rails.application.config.baukis
    Capybara.app_host = 'http://' + config[namespace][:host]
  end

  def login_as_staff_member(staff_memeber, password = 'pw')
    visit staff_login_path
    within('#login-form') do
      fill_in 'メールアドレス', with: staff_memeber.email
      fill_in 'パスワード', with: password
      click_button 'ログイン'
    end
  end

  def login_as_customer(customer, password = 'pw')
    visit customer_login_path
    within('#login-form') do
      fill_in 'メールアドレス', with: customer.email
      fill_in 'パスワード', with: password
      click_button 'ログイン'
    end
  end
end