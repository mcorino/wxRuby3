
require 'uri'
require 'net/https'
require 'json'

$GITHUB_TOKEN = ENV['GITHUB_TOKEN'] || ''
if $GITHUB_TOKEN.empty?
  $stderr.puts 'Please provide GitHub access token via GITHUB_TOKEN environment variable!'
  exit(1)
end

$CIRRUS_RELEASE = ENV['CIRRUS_RELEASE'] || ''
if $CIRRUS_RELEASE.empty?
  uri = URI('https://api.github.com/repos/mcorino/wxruby3/releases/latest')
  headers = {
    'Accept' => 'application/vnd.github+json',
    'X-GitHub-Api-Version' => '2022-11-28',
    'Authorization' => "Bearer #{ENV['GITHUB_TOKEN']}"
  }
  rest_response = Net::HTTP.get_response(uri, headers)
  if rest_response.code.to_i == 200
    data = JSON.parse!(rest_response.body)
    $CIRRUS_RELEASE = data['id']
  else
    $stderr.puts "Cannot determine latest release [#{rest_response}]!"
    exit(1)
  end
end

file_content_type="application/octet-stream"
Dir.glob(File.join('pkg', '*.pkg')).each do |fpath|
  name = File.basename(fpath)
  url_to_upload = "https://uploads.github.com/repos/mcorino/wxruby3/releases/#{$CIRRUS_RELEASE}/assets?name=#{name}"
  puts "Uploading #{fpath} for release #{$CIRRUS_RELEASE} to #{url_to_upload}..."
  cmd = "curl -L -X POST -H \"Accept: application/vnd.github+json\" " +
                          "-H \"Authorization: token #{$GITHUB_TOKEN}\" " +
                          "-H \"X-GitHub-Api-Version: 2022-11-28\" " +
                          "-H \"Content-Type: #{file_content_type}\" " +
                          "#{url_to_upload} --data-binary @#{fpath}"
  result = `#{cmd}`
  rc = $?.success? && JSON.parse!(result)['browser_download_url']
  if rc
    name = File.basename(name, '.*')+'.sha'
    fpath = File.join(File.dirname(fpath), name)
    url_to_upload = "https://uploads.github.com/repos/mcorino/wxruby3/releases/#{$CIRRUS_RELEASE}/assets?name=#{name}"
    puts "Uploading #{fpath} for release #{$CIRRUS_RELEASE} to #{url_to_upload}..."
    cmd = "curl -L -X POST -H \"Accept: application/vnd.github+json\" " +
      "-H \"Authorization: token #{$GITHUB_TOKEN}\" " +
      "-H \"X-GitHub-Api-Version: 2022-11-28\" " +
      "-H \"Content-Type: #{file_content_type}\" " +
      "#{url_to_upload} --data-binary @#{fpath}"
    result = `#{cmd}`
    rc = $?.success? && JSON.parse!(result)['browser_download_url']
  end
  unless rc
    $stderr.puts "Failed to upload release asset!"
    exit(1)
  end
end
