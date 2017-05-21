class CollectionProfile < ActiveRecord::Base
  belongs_to :collection

  validates_length_of :intro,
                      :allow_blank => true,
                      :maximum => Configurable.INFO_MAX, :too_long => ts("must be less than %{max} letters long.", :max => Configurable.INFO_MAX)

  validates_length_of :faq,
                      :allow_blank => true,
                      :maximum => Configurable.INFO_MAX, :too_long => ts("must be less than %{max} letters long.", :max => Configurable.INFO_MAX)

  validates_length_of :rules,
                      :allow_blank => true,
                      :maximum => Configurable.INFO_MAX, :too_long => ts("must be less than %{max} letters long.", :max => Configurable.INFO_MAX)

  validates_length_of :assignment_notification,
                      :allow_blank => true,
                      :maximum => Configurable.SUMMARY_MAX, :too_long => ts("must be less than %{max} letters long.", :max => Configurable.SUMMARY_MAX)

  validates_length_of :gift_notification,
                      :allow_blank => true,
                      :maximum => Configurable.SUMMARY_MAX, :too_long => ts("must be less than %{max} letters long.", :max => Configurable.SUMMARY_MAX)

end
