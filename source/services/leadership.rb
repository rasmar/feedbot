# frozen_string_literal: true

module Services
  class Leadership
    def validate_leadership(channel, requester, target)
      return true if valid_leadership?(requester, target)

      send_invalid_leadership_message(channel, target)
      false
    end

    def valid_leadership?(requester, target)
      target_profile = Repos::Slack::ProfileGet.new(target).call
      leader = target_profile.dig("profile", "fields", Settings.slack_leader_label_id, "value")
      leader == requester
    end

    def send_invalid_leadership_message(channel, target)
      Repos::Slack::InvalidLeadershipMessage.new(channel, target).call
    end
  end
end
