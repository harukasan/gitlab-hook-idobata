require 'sinatra'
require 'json'
require 'idobata'
require 'slim'

Idobata.hook_url = "https://idobata.io/hook/f89ab32a-93f1-47e4-b6e8-c8b68b3e9943"

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

