
require 'uri'
require 'net/https'
require 'json'

$CIRRUS_TOKEN = ENV['CIRRUS_TOKEN'] || ''

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
      branch: "v0.9.7",
      clientMutationId: "wxRuby3"
    }
  }
  $response = Net::HTTP.post($cirrus_uri, { query:  $mutation, variables: vars }.to_json, $headers)
  if Net::HTTPOK === $response
    $build_id = JSON.parse($response.body)['data']['createBuild']['build']['id']
    puts "Started release build [#{$build_id}]"
  else
    $stderr.puts "Failed to start release build."
    exit(1)
  end
else
  $stderr.puts "Failed to retrieve repository id."
  exit(1)
end
