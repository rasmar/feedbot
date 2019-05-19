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

  def slack_bot_token
    @slack_bot_token ||= ENV["SLACK_BOT_TOKEN"]
  end

  def slack_oauth_token
    @slack_oauth_token ||= ENV["SLACK_OAUTH_TOKEN"]
  end

  def slack_leader_label_id
    @slack_leader_label_id ||= ENV["SLACK_LEADER_LABEL_ID"]
  end
end
