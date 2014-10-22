class ShortenedUrl
  include DataMapper::Resource

  property :id, Serial
  property :url, Text
  property :myurl, String
  property :username, Text
end

#class User
#  include DataMapper::Resource
#  property :id, Serial
#  property :username, Text
#end