FactoryBot.define do
 factory :campaign do
   title         { FFaker::Lorem.word }
   description   { FFaker::Lorem.sentence }
   status { 0 } 
   user
 end
end
