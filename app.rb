require 'sinatra'
require 'json'
require 'idobata'
require 'slim'

Idobata.hook_url = ENV['HOOK_URL']

Gitlab.configure do |c|
  c.endpoint = ENV['GITLAB_API_ENDPOINT']
  c.private_token = ENV['GITLAB_API_PRIVATE_TOKEN']
end


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

  post '/merge_request.json' do
    data = JSON.parse request.body.read
    project = Gitlab.project(data["object_attributes"]["target_project_id"]).to_hash
    mr = Gitlab.merge_request(data["object_attributes"]["target_project_id"], data["object_attributes"]["id"]).to_hash

    message = Slim::Template.new("templates/merge_request.slim").render(self, data: data, project: project, mr: mr)
    Idobata::Message.create source: message, format: :html if message

    { status: "ok" }.to_json
  end
end

