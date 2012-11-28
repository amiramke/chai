# Our YelpHelper module to do all things Yelp related

require 'oauth'
require 'json'

module YelpHelper
  #Ferdi:
  CONSUMER_KEY = 's3OFJZeLxXg4Zpyik4-Qng'
  CONSUMER_SECRET = 'CEoKVSBOfl7I_GBsH_5McAqyv0U'
  TOKEN = 'I0EhDz5uRcD44f5QrL38Bl6vdwSpitlR'
  TOKEN_SECRET = 'UPrz5Tf3_L_DswN3zu2nCeJ2c4c'

  #Ami:
  # CONSUMER_KEY = 'oQp4rtg9Br5pqsu56T_f-Q'
  # CONSUMER_SECRET = 'QdxcWLugM2MP7vXsyzZsAO1e9z8'
  # TOKEN = 'mtAJKfk5KNHQ1HHfvhFq4pRfp70iWy6v'
  # TOKEN_SECRET = 'TlAyQHs-JmhXGNyUlbXRDKz77Lk'

  def self.api_host
    'api.yelp.com'
  end

  def self.api_search_path
    '/v2/search'
  end

# wraps all our Yelp api related information in a handy function
  def self.consumer
    @consumer ||= OAuth::Consumer.new(CONSUMER_KEY, CONSUMER_SECRET, {:site => "http://#{api_host}"})
  end

# wraps all our Yelp api related authentification information in a handy function
  def self.access_token
    @access_token ||= OAuth::AccessToken.new(consumer, TOKEN, TOKEN_SECRET)
  end


# our Search function which takes in a location
# if no location is found it's using a default long lat
# it gets specifically the business and region information

  def self.search(location)
    location ||= "37.788022,-122.399797"
    { businesses: get_businesses(location), region: get_region(location) }
  end


# function that sanitizes the coffeeshop information
# in order to not have a huge amount of useless information
# but instead get information that we want

  def self.get_businesses(location)
    businesses(location).collect do |coffee|
      [
        coffee['name'],
        coffee['distance'],
        coffee['rating'],
        coffee['review_count'],
        coffee['image_url'],
        coffee['url'],
        coffee['location']['coordinate']['latitude'],
        coffee['location']['coordinate']['longitude'],
      ]
    end
  end

# function that gets all the region related information
# and packaging that in an array
  def self.get_region(location)
    info = region(location)
      [
        info['span']['latitude_delta'],
        info['span']['longitude_delta'],
        info['center']['latitude'],
        info['center']['longitude'],
      ]
  end

  def self.query(location)
    access_token.get(path(location)).body

  end

  def self.path(location)
    "#{api_search_path}?term=coffee&ll=#{location}"
  end

  def self.region(location)
    JSON.parse(query(location))["region"] || []
  end

  def self.businesses(location)
    JSON.parse(query(location))["businesses"] || []
  end
end