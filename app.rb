require 'sinatra'
require 'json'
require 'idobata'
require 'slim'

Idobata.hook_url = ENV['HOOK_URL']

class App < Sinatra::Base
  post '/push.json' do
    data = JSON.parse request.body.read

    Thread.new do
      message = Slim::Template.new("templates/push.slim").render(self, data: data)
      Idobata::Message.create source: message, format: :html if message
    end

    { status: "ok" }.to_json
  end
end

