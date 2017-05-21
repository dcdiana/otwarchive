class Rating < Tag

  NAME = Configurable.RATING_CATEGORY_NAME
  index_name Tag.index_name

  # Gives us the default ratings as Not Rated + low to high
  def self.defaults_by_severity
    ratings = [Configurable.RATING_DEFAULT_TAG_NAME,
               Configurable.RATING_GENERAL_TAG_NAME,
               Configurable.RATING_TEEN_TAG_NAME,
               Configurable.RATING_MATURE_TAG_NAME,
               Configurable.RATING_EXPLICIT_TAG_NAME]
    ratings_by_id = Rating.where(name: ratings).inject({}) do |result, rating|
      result[rating.name] = rating
      result
    end
    ratings.map { |id| ratings_by_id[id] }
  end

end
