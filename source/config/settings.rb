# frozen_string_literal: true

module Settings
  extend self

  def database_url
    @database_url ||= ENV["DATABASE_URL"]
  end

  def salesforce_client_key
    @salesforce_client_key ||= ENV["SALESFORCE_CLIENT_KEY"]
  end

  def salesforce_client_secret
    @salesforce_client_secret ||= ENV["SALESFORCE_CLIENT_SECRET"]
  end

  def slack_token
    @slack_token ||= ENV["SLACK_ACCESS_TOKEN"]
  end
end
