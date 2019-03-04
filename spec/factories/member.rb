FactoryBot.define do
 factory :member do
   name         { FFaker::Lorem.word }
   email        { FFaker::Internet.email }
   token        { FFaker::Lorem.characters }
   campaign
 end
end
