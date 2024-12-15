require 'puppeteer-ruby'
require 'sinatra'
require 'securerandom'

set :host_authorization, { permitted_hosts: [] }

get '/alive' do
  status 200
  return "Alive!"
end

get '/' do
  begin
    base_image_tmpfile_path = "/tmp/#{SecureRandom.uuid}.png"
    puts "Browsing #{params[:url]}"
    Puppeteer.launch(headless: true) do |browser|
      page = browser.new_page
      page.goto(params[:url])
      page.screenshot(path: base_image_tmpfile_path)
    end
    send_file base_image_tmpfile_path
  ensure
    Thread.new do
      sleep 1
      puts "Removed file"
      FileUtils.rm base_image_tmpfile_path if File.exist?(base_image_tmpfile_path)
    end
    # File.unlink base_image_tmpfile_path if File.exist?(base_image_tmpfile_path)
  end
end
