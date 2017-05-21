begin
  ActiveRecord::Base.connection  # if we have no database fall through to rescue
  if AdminSetting.table_exists? && !AdminSetting.first
    settings = AdminSetting.new(:invite_from_queue_enabled => Configurable.INVITE_FROM_QUEUE_ENABLED,
          :invite_from_queue_number => Configurable.INVITE_FROM_QUEUE_NUMBER,
          :invite_from_queue_frequency => Configurable.INVITE_FROM_QUEUE_FREQUENCY,
          :account_creation_enabled => Configurable.ACCOUNT_CREATION_ENABLED,
          :days_to_purge_unactivated => Configurable.DAYS_TO_PURGE_UNACTIVATED)
    settings.save(:validate => false)
  end
rescue ActiveRecord::ConnectionNotEstablished
end
