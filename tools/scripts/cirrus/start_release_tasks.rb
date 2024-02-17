
require 'uri'
require 'net/https'
require 'json'

$CIRRUS_TOKEN = ENV['CIRRUS_TOKEN'] || ''

# for an actual release we can just run the Cirrus tasks off the master branch since
# the release tag has just be created against that
$branch = ARGV.empty? ? 'master' : ARGV[0]

$cirrus_uri = URI('https://api.cirrus-ci.com/graphql')

$query = %q[{ ownerRepository(platform: "github", owner: "mcorino", name: "wxRuby3") { id } }]

$headers = {
  'Authorization' => "Bearer #{$CIRRUS_TOKEN}",
  'Content-Type' => 'application/json'
}
$response = Net::HTTP.post($cirrus_uri, { query:  $query }.to_json, $headers)

if Net::HTTPOK === $response
  $repository_id = JSON.parse($response.body)['data']['ownerRepository']['id']

  $mutation = %Q[mutation StartReleaseBuild( $input: RepositoryCreateBuildInput! ) { createBuild(input: $input) { build { id } } }]
  vars = {
    input: {
      repositoryId: "#{$repository_id}",
      branch: $branch,
      clientMutationId: "wxRuby3"
    }
  }
  $response = Net::HTTP.post($cirrus_uri, { query:  $mutation, variables: vars }.to_json, $headers)
  if Net::HTTPOK === $response
    response_data = JSON.parse($response.body)
    if response_data['errors']
      $stderr.puts "Error starting release build: #{response_data['errors'].collect { |err| err['message'] }.join(',')}"
    else
      $build_id = response_data['data']['createBuild']['build']['id']
      puts "Started release build [#{$build_id}]"
    end
  else
    $stderr.puts "Failed to start release build."
    exit(1)
  end
else
  $stderr.puts "Failed to retrieve repository id."
  exit(1)
end
