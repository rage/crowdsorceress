require 'net/http'
require 'net/https'
require 'json'

class PCRS

  def initialize(exercise, test_output)
    @exercise = exercise
    @test_output = test_output
  end

  def send_results
    # request parameters
    params = {'username' => get_username, 'csId' => get_assignment_id, 'score' => get_score}
    # request headers
    headers = {'Content-Type' => 'application/json', 'Authorization' => 'Token ' + get_auth_token}
    # make post request
    post(get_submission_uri, params, headers)
  end  

  def get_score
    @test_output['status'] == 'PASSED' ? 1 : 0
  end

  def get_assignment_id
    @exercise.assignment[:id]
  end

  def get_username
    @exercise.user[:username]
  end

  def get_auth_token
    Rails.application.secrets.PCRS_REST_TOKEN
  end

  def get_submission_uri
    Rails.application.secrets.PCRS_SUBMISSION_URL
  end
 
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
end  
