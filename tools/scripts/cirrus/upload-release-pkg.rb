
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

$PGP_KEY = ENV['PGP_KEY'] || ''
$PGP_PASSPHRASE = ENV['PGP_PASSPHRASE']
if $PGP_KEY.empty?
  $stderr.puts 'Provide PGP key for release signing via PGP_KEY environment variable!'
  exit(1)
end

# import signing key
unless system(%Q{echo -n "#{$PGP_KEY}" | base64 --decode | gpg --pinentry-mode loopback --batch --passphrase #{$PGP_PASSPHRASE} --import})
  exit(1)
end

file_content_type="application/octet-stream"
Dir.glob(File.join('pkg', '*.pkg')).each do |fpath|

  # sign release
  unless system(%Q{gpg --detach-sign --pinentry-mode loopback --batch --passphrase #{$PGP_PASSPHRASE} --armor #{fpath}})
    $stderr.puts "Failed to sign release asset #{fpath}!"
    exit(1)
  end

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
    cmd = "curl -L -X POST -H \"Accept: application/vnd.github+json\" " +
      "-H \"Authorization: token #{$GITHUB_TOKEN}\" " +
      "-H \"X-GitHub-Api-Version: 2022-11-28\" " +
      "-H \"Content-Type: #{file_content_type}\" " +
      "#{url_to_upload}.asc --data-binary @#{fpath}.asc"
    result = `#{cmd}`
    rc = $?.success? && JSON.parse!(result)['browser_download_url']
  end
  unless rc
    $stderr.puts "Failed to upload release asset!"
    exit(1)
  end
end
