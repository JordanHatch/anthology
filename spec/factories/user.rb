FactoryGirl.define do
  factory :user do
    sequence(:name) {|n|
      "User#{n}"
    }
    sequence(:email) {|n|
      "user#{n}@example.org"
    }
    provider 'google'
    sequence(:provider_uid)
    sequence(:image_url) {|n|
      "http://example.org/users/#{n}.jpg"
    }
  end
end
