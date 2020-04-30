class ActsAsTaggableSong < ApplicationRecord
  acts_as_taggable_on :genres
end
