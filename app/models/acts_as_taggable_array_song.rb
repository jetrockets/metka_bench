class ActsAsTaggableArraySong < ApplicationRecord
  acts_as_taggable_array_on :genres
end
