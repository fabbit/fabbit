FactoryGirl.define do
  factory :user do
    first_name Faker::Name.first_name
    last_name Faker::Name.last_name
    email Faker::Internet.email
    password "foobar"
    password_confirmation "foobar"
  end

  factory :model_file do
    path [Faker::Lorem.characters(10), ".stl"].join
    cached_revision Random.rand(9)
    user Faker::Internet.user_name
  end
end
