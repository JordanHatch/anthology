FactoryGirl.define do
  factory :loan do
    user
    copy
    state "on_loan"
    sequence(:loan_date) {|n|
      Date.parse('2000-01-01') + n.week
    }
    return_date nil

    trait :returned do
      state :returned
      sequence(:return_date) {|n|
        Date.parse('2001-01-01') + n.week
      }
    end

    factory :returned_loan, traits: [:returned]
  end
end
