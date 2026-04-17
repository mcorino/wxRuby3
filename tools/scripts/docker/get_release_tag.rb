
require 'uri'
require 'net/https'
require 'json'

$GITHUB_TOKEN = ENV['GITHUB_TOKEN'] || ''
if $GITHUB_TOKEN.empty?
  $stdout.puts 'ERROR: GitHub access token missing!'
  exit(1)
end

uri = URI('https://api.github.com/repos/mcorino/wxruby3/releases/latest')
headers = {
  'Accept' => 'application/vnd.github+json',
  'X-GitHub-Api-Version' => '2022-11-28',
  'Authorization' => "Bearer #{ENV['GITHUB_TOKEN']}"
}
rest_response = if RUBY_VERSION < '3.0.0'
                  Net::HTTP.start(uri.hostname, uri.port, :use_ssl => uri.scheme == 'https') do |http|
                    http.request_get(uri, headers)
                  end
                else
                  Net::HTTP.get_response(uri, headers)
                end
if rest_response.code.to_i == 200
  data = JSON.parse!(rest_response.body)
  $stdout.puts data['tag_name']
else
  $stdout.puts "ERROR: Cannot determine latest release [#{rest_response}]!"
  exit(1)
end
