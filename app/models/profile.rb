class Profile < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection
  
  belongs_to :user

  validates_length_of :location, :allow_blank => true, :maximum => ArchiveConfig.PROFILE_LOCATION_MAX,
    :too_long => ts("must be less than %{max} characters long.", :max => ArchiveConfig.PROFILE_LOCATION_MAX)
  validates_length_of :title, :allow_blank => true, :maximum => ArchiveConfig.PROFILE_TITLE_MAX,
    :too_long => ts("must be less than %{max} characters long.", :max => ArchiveConfig.PROFILE_TITLE_MAX)
  validates_length_of :about_me, :allow_blank => true, :maximum => ArchiveConfig.PROFILE_ABOUT_ME_MAX,
    :too_long => ts("must be less than %{max} characters long.", :max => ArchiveConfig.PROFILE_ABOUT_ME_MAX)

  before_update :validate_date_of_birth
  # Checks date of birth when user updates profile
  # blank is okay as they already checked that they were over 13 when registering
  def validate_date_of_birth
    return unless self.date_of_birth
    if self.date_of_birth > 13.years.ago.to_date
      errors.add(:base, "You must be over 13.")
      return false
    end
  end

end
