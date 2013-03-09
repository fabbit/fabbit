include DropboxHelper

def db_test_username
  'wyrven09@gmail.com'
end

def db_test_password
  '318GreCya'
end

def dropbox_sign_in
  Capybara.current_driver = :selenium
  visit new_dropbox_path
  fill_in "Email", with: db_test_username
  fill_in "Password", with: db_test_password
  click_button "Sign in"
  click_button "Allow"
end
