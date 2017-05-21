class KnownIssue < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection
  # why is this included here? FIXME?
  include HtmlCleaner

  validates_presence_of :title
  validates_length_of :title,
    :minimum => Configurable.TITLE_MIN,
    :too_short=> ts("must be at least %{min} letters long.", :min => Configurable.TITLE_MIN)

  validates_length_of :title,
    :maximum => Configurable.TITLE_MAX,
    :too_long=> ts("must be less than %{max} letters long.", :max => Configurable.TITLE_MAX)

  validates_presence_of :content
  validates_length_of :content, :minimum => Configurable.CONTENT_MIN,
    :too_short => ts("must be at least %{min} letters long.", :min => Configurable.CONTENT_MIN)

  validates_length_of :content, :maximum => Configurable.CONTENT_MAX,
    :too_long => ts("cannot be more than %{max} characters long.", :max => Configurable.CONTENT_MAX)

end
