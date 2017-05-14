class ExternalAuthorName < ActiveRecord::Base

  belongs_to :external_author, :inverse_of => :external_author_names
  has_many :external_creatorships, :inverse_of => :external_author_name
  has_many :works, :through => :external_creatorships, :source => :creation, :source_type => 'Work', :uniq => true  
  
  validates_presence_of :name

  validates_length_of :name, 
    :within => ArchiveConfig.NAME_LENGTH_MIN..ArchiveConfig.NAME_LENGTH_MAX,
    :too_short => ts("is too short (minimum is %{min} characters)", :min => ArchiveConfig.NAME_LENGTH_MIN),
    :too_long => ts("is too long (maximum is %{max} characters)", :max => ArchiveConfig.NAME_LENGTH_MAX)

  validates_uniqueness_of :name, :scope => :external_author_id, :case_sensitive => false  

  validates_format_of :name, 
    :message => ts('can contain letters, numbers, spaces, underscores, @-signs, dots, and dashes.'),
    :with => /\A\w[ \w\-\@\.]*\Z/

  validates_format_of :name, 
    :message => ts('must contain at least one letter or number.'),
    :with => /[a-zA-Z0-9]/

  def to_s
    self.name + ' <' + self.external_author.email + '>'
  end

  def external_work_creatorships
    external_creatorships.where("external_creatorships.creation_type = 'Work'")
  end
  
end
