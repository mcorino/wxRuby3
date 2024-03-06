
require 'uri'
require 'net/https'
require 'json'
require 'yaml'

$CIRRUS_TOKEN = ENV['CIRRUS_TOKEN'] || ''

$release = false # actual release or manual test run
$refname = 'master'
$task_cfg = File.join(__dir__, 'cirrus-release.yml')
until ARGV.empty?
  arg = ARGV.shift
  case arg
  when '--release'
    $release = true
  when '--config'
    $task_cfg = ARGV.shift || ''
  else
    $refname = arg
  end
end

# for an actual release use the master branch and get the actual sha for the release tag
if $release
  $branch = 'master'
  $sha = `git rev-list -1 #{$refname}`
else
  $branch = $refname # run the test off the given branch
end

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
      configOverride: File.read($task_cfg),
      clientMutationId: "wxRuby3"
    }
  }
  vars[:input][:sha] = $sha if $release
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
