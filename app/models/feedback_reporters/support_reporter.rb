class SupportReporter < FeedbackReporter
  PROJECT_PATH = "authtoken=#{Configurable.SUPPORT_AUTH}&portal=ao3support&department=Support"
  attr_accessor :user_agent, :site_revision

  def template
    "feedbacks/report"
  end
end
