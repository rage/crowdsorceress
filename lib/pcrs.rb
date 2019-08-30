require 'net/http'
require 'net/https'
require 'json'
require 'pcrs_client'

class PCRS

  def initialize(exercise, test_output)
    @exercise = exercise
    @test_output = test_output
    @client = PCRSClient.new()
  end

  def send_results
    # request parameters
    params = {'username' => get_username, 'csId' => get_assignment_id, 'score' => get_score}
    # request headers
    headers = {'Content-Type' => 'application/json', 'Authorization' => 'Token ' + @client.get_auth_token}
    # make post request
    @client.post(@client.get_submission_uri, params, headers)
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

end  
