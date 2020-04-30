class MetkaSong < ApplicationRecord
  include Metka::Model(column: 'genres')
end
