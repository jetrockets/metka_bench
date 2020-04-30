class TagColumnsSong < ApplicationRecord
  include TagColumns
  tag_columns :genres
end
