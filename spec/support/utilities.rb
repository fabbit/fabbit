include DropboxHelper

# TODO: Use factories and test user
def db_test_email
  'dev.fabbit@gmail.com'
end

def db_test_password
  'fabbit development'
end

def db_test_name
  'Dev Fabbit'
end

def dropbox_sign_in
  Capybara.current_driver = :selenium
  visit new_dropbox_path
  if page.has_field? "Email"
    fill_in "Email", with: db_test_email
    fill_in "Password", with: db_test_password
    click_button "Sign in"
  end
  click_button "Allow"
end

# Generates a random set of directories and a path for them
def random_directory
  directories = Faker::Lorem.words(Random.rand(1..10))
  path = File::SEPARATOR + File.join(directories)

  { dirs: directories, path: path }
end
