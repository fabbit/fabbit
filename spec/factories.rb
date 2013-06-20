FactoryGirl.define do
  factory :member do
    dropbox_uid { Random.rand(100) }
    name { Faker::Name.name }
  end

  factory :model_file do
    path { [Faker::Lorem.characters(10), ".stl"].join }
    cached_revision { Faker::Lorem.characters(9) }
    member
  end

  factory :version do
    revision_number { Faker::Lorem.characters(9) }
    revision_date { DateTime.now }
    details { Faker::Lorem.sentence(10) }
    model_file
  end

  factory :project_type do
    name { Faker::Lorem.words(1) }
  end

  factory :project do
    name { Faker::Lorem.words(4) }
    project_type
  end

end
