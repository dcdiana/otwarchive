class Warning < Tag

  NAME = Configurable.WARNING_CATEGORY_NAME
  index_name Tag.index_name

  def self.warning_tags
    Set[Configurable.WARNING_DEFAULT_TAG_NAME,
        Configurable.WARNING_NONE_TAG_NAME,
        Configurable.WARNING_SOME_TAG_NAME,
        Configurable.WARNING_VIOLENCE_TAG_NAME,
        Configurable.WARNING_DEATH_TAG_NAME,
        Configurable.WARNING_NONCON_TAG_NAME,
        Configurable.WARNING_CHAN_TAG_NAME]
  end

  def self.warning?(warning)
    warning_tags.include? warning
  end
end
