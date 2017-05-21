class AbuseReporter < FeedbackReporter
  PROJECT_PATH = "authtoken=#{Configurable.ABUSE_AUTH}&portal=ao3abuse&department=AO3%20Abuse"
  attr_accessor :ip_address

  def template
    "abuse_reports/report"
  end
end
