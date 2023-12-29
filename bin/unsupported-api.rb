#! /usr/bin/env ruby

require_relative 'setup'

CSVDatabase.read './data/photos.csv', Photo

id = "AFYxATE8JhgFp9bD2Ds9FlxnGxS6pKesNs3trPU4Yv9_t6T_CxMnQnp03IyJHEWooXCKhxLC77xVeLg7V9Eh3B4T6k9DWgk0kw"
photo = Photo.find_by_id id

uri = URI("#{GoogleAPI::API_BASE_URL}/mediaItems/#{photo.id}")
uri.query = URI.encode_www_form({
  updateMask: 'description'
})

http = Net::HTTP.new(uri.host, uri.port)
http.use_ssl = true

request = Net::HTTP::Patch.new(uri)
request['Content-type'] = 'application/json'
request['Authorization'] = GoogleAPI::Write.authorization_header
request.body = { description: "new description from ruby!" }.to_json

response = http.request(request)
json = JSON.parse(response.body)
raise StandardError.new(json) if response.code != "200"
