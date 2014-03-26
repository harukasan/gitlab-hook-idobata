require 'sinatra'
require 'json'
require 'idobata'
require 'slim'

Idobata.hook_url = ENV['HOOK_URL']

class App < Sinatra::Base
  post '/push.json' do
    data = JSON.parse request.body.read

    Thread.new do
      if ENV['BRANCH'] == 'all' || data["ref"].match(/#{ENV['BRANCH']}/)
        message = Slim::Template.new("templates/push.slim").render(self, data: data)
        Idobata::Message.create source: message, format: :html if message
      end
    end

    { status: "ok" }.to_json
  end
end

