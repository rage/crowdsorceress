require 'net/http'
require 'net/https'
require 'json'

class PCRSClient

  def get_auth_token
    Rails.application.secrets.PCRS_REST_TOKEN
  end

  def get_submission_uri
    Rails.application.secrets.PCRS_SUBMISSION_URL
  end

  def get_user_info_uri
    Rails.application.secrets.PCRS_USER_INFO_URL
  end

  # Performs a post request and returns the results
  # +uri_str+:: uri string where the post request will execute
  # +params+:: a hash representing the post request parameters
  # +headers+:: a hash representing the post request headers
  def post(uri_str, params, headers) 
    # creating uri object (parses uri into different sections)
    uri = URI(uri_str)
    # creating http object
    https = Net::HTTP.new(uri.host, uri.port)
    https.use_ssl = true
    # creating request object (type: POST))
    req = Net::HTTP::Post.new(uri.path)
    # set request parameters
    req.body = params.to_json
    # set request headers
    req = set_headers(req, headers)
    # making the request
    res = https.request(req)
    # return the response object
    res
  end

  private 

  # Iterates over headers hash, setting each request header
  # +request+:: an http request object
  # +headers+:: a hash representing the request headers
  def set_headers(request, headers)
    # iterate over headers has
    headers.each do | key, value |
      request[key] = value
    end
    # return the request
    request
  end

end
