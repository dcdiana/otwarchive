#!/usr/bin/env script/rails runner
# shebang not current working
# see
# https://rails.lighthouseapp.com/projects/8994/tickets/4249-rails-runner-cant-be-used-in-shebang-lines

# run instead as:
# rails runner script/ensure_required_tags.rb
# or 
# rails runner -e production script/ensure_required_tags.rb

Warning.create_canonical(Configurable.WARNING_DEFAULT_TAG_NAME)
Warning.create_canonical(Configurable.WARNING_NONE_TAG_NAME)
Warning.create_canonical(Configurable.WARNING_VIOLENCE_TAG_NAME)
Warning.create_canonical(Configurable.WARNING_DEATH_TAG_NAME)
Warning.create_canonical(Configurable.WARNING_NONCON_TAG_NAME)
Warning.create_canonical(Configurable.WARNING_CHAN_TAG_NAME)
Rating.create_canonical(Configurable.RATING_DEFAULT_TAG_NAME, true)
Rating.create_canonical(Configurable.RATING_EXPLICIT_TAG_NAME, true)
Rating.create_canonical(Configurable.RATING_MATURE_TAG_NAME, true)
Rating.create_canonical(Configurable.RATING_TEEN_TAG_NAME, false)
Rating.create_canonical(Configurable.RATING_GENERAL_TAG_NAME, false)
Category.create_canonical(Configurable.CATEGORY_HET_TAG_NAME)
Category.create_canonical(Configurable.CATEGORY_SLASH_TAG_NAME)
Category.create_canonical(Configurable.CATEGORY_FEMSLASH_TAG_NAME)
Category.create_canonical(Configurable.CATEGORY_GEN_TAG_NAME)
Category.create_canonical(Configurable.CATEGORY_MULTI_TAG_NAME)
Category.create_canonical(Configurable.CATEGORY_OTHER_TAG_NAME)
Media.create_canonical(Configurable.MEDIA_UNCATEGORIZED_NAME)
Media.create_canonical(Configurable.MEDIA_NO_TAG_NAME)
Fandom.create_canonical(Configurable.FANDOM_NO_TAG_NAME)
