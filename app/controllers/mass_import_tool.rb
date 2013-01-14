class MassImportTool
  require "mysql"

  def initialize()
    #Import Class Version Number
    @Version = 1

    #import config filename
    #@config = OTW.Settings.INIFile.new("config.ini") #'

    #temporary table prefix
    @temptableprefix = "temp321"

    # Boolean Options #If true, send invites unconditionaly,
    # if false add them to the que to be sent when it gets to it, could be delayed.
    @bypassInviteQueForImported = true

    #Create collection for imported works?
    @create_collection = true

    #Match Existing Authors by Email-Address
    @matchExistingAuthors = true

    #Import Job Name
    @import_name = "New Import"

    #Import Archive ID
    @import_archive_id = 100

    #Import categories as categories or use ao3 cats
    @useProperCategories = false

    #Create record for imported archive
    @CreateImportArchiveRecord = false

    #Import reviews t/f
    @import_reviews = true

    #If using ao3 cats, sort or skip
    @SortForAo3Categories = true

    #New Collection Name
    @new_collection_name = "New Collection"

    #New Collection Description
    @new_collection_description = "Something here"

    #Send notification email with invitation to archive to imported users
    @notify_imported_users = true

    #Send message for each work imported? (or 1 message for all works)
    @send_individual_messages = false

    #Message to send existing authors
    @existing_notification_message = ""

    #message to be sent to users with no ao3 account
    @new_notification_message = ""

    #ID Of the newly created collection, filled with value automatically if create collection is true
    @new_collection_id = -1

    #Owner for created collection
    @new_collection_owner = "Stephanie"

    #Destination otwarchive Ratings (1 being NR if NR Is conservative, 5 if not)
    #NR
    @target_rating_1 = 9

    #general audiences
    @target_rating_2 = 10

    #teen
    @target_rating_3 = 11

    #Mature
    @target_rating_4 = 12

    #Explicit
    @target_rating_5 = 13
    #
    #target db connection string
    @target_database_connection = "'localhost','stephanies','password','stepahanies_development'"

    #Source Variables
    ##################

    #Source DB Connection
    #"localhost","stephanies","Trustno1","stephanies_development" = "\"thepotionsmaster.net\",\"sltest\",\"test1\",\"password\""

    #Source Archive Type
    @source_archive_type = 4

    #If archivetype being imported is efiction 3 >  then specify what class holds warning information
    @source_warning_class_id = 1

    #Holds Value for source table prefix
    @source_table_prefix = "sl18_"

    #Source Ratings Table
    @source_ratings_table = ""

    #Source Users Table
    @source_users_table = ""

    #Source Stories Table
    @source_stories_table = ""

    #Source Reviews Table
    @source_reviews_table = ""

    #Source Chapters Table
    @source_chapters_table = ""

    #Source Characters Table
    @source_characters_table = ""

    #Source Subcategories Table
    @source_subcatagories_table = ""

    @debug_update_source_tags = true

    #Source Categories Table
    @source_categories_table = ""

    #string holder
    @get_author_from_source_query = ""

    #Skip Rating Transformation (ie if import in progress or testing)
    @skip_rating_transform = false
  end



=begin
  def ReadConfigValues()
    @ImportArchiveID = @config.GetValue("General", "ImportArchiveID", 0)
    @CollectionOwner = @config.GetValue("General", "CollectionOwner", "")
    @_tgtRating1 = @config.GetValue("General", "_tgtRating1", "")
    @_tgtRating2 = @config.GetValue("General", "_tgtRating2", "")
    @_tgtRating3 = @config.GetValue("General", "_tgtRating3", "")
    @_tgtRating4 = @config.GetValue("General", "_tgtRating4", "")
    @_tgtRating5 = @config.GetValue("General", "_tgtRating5", "")
    @useProperCategories = @config.GetValue("General", "useProperCategories", "")
    @existingAuthorMessage = @config.GetValue("General", "existingAuthorMessage", "")
    @newCollectionID = @config.GetValue("General", "newCollectionID", "")
    @NotificationMessage = @config.GetValue("General", "NotificationMessage", "")
    @CreateImportArchiveRecord = @config.GetValue("General", "CreateImportArchiveRecord", "")
    @bypassInviteQueForImported = @config.GetValue("General", "bypassInviteQueForImported", "")
    @NotifyImportedUsers = @config.GetValue("General", "NotifyImportedUsers", "")
    @srcArchiveType = @config.GetValue("General", "srcArchiveType", "")
    @srcWarningClassTypeID = @config.GetValue("General", "srcWarningClassTypeID", "")
    @source_table_prefix = @config.GetValue("General", "srcTablePrefix", "")
    @dbgSkipRatingTransform = @config.GetValue("General", "dbgSkipRatingTransform", "")
    @targetDBhost = "localhost"
  end
=end

  def DisplayStartupInfo()
    puts "AO3 Importer Starting "
    puts "Version #{@Version}"
    puts "Running: #{@import_name}"
  end




# Convert Source DB Ratings to those of target archive in advance
  def transform_source_ratings()
    puts "transform source ratings"
    case @source_archive_type
      when 4
        self.update_record_source("update #{@source_stories_table} set srating= #{@target_rating_1} where srating = 1;")
        self.update_record_source("update #{@source_stories_table} set srating= #{@target_rating_2} where srating = 2;")
        self.update_record_source("update #{@source_stories_table} set srating= #{@target_rating_3} where srating = 3;")
        self.update_record_source("update #{@source_stories_table} set srating= #{@target_rating_4} where srating = 4;")
        self.update_record_source("update #{@source_stories_table} set srating= #{@target_rating_5} where srating = 5;")

      when 3
        self.update_record_source("update #{@source_stories_table} set rid= #{@target_rating_1} where rid=1;")
        self.update_record_source("update #{@source_stories_table} set rid= #{@target_rating_2} where rid=2;")
        self.update_record_source("update #{@source_stories_table} set rid= #{@target_rating_3} where rid=3;")
        self.update_record_source("update #{@source_stories_table} set rid= #{@target_rating_4} where rid=4;")
        self.update_record_source("update #{@source_stories_table} set rid= #{@target_rating_5} where rid=5;")
      when ArchiveType.efiction2
    end
  end

  def fill_tag_list(tl)
    i = 0
    while i <= tl.length - 1
      temptag = tl[i]
      connection =Mysql.new('localhost','stephanies','Trustno1','stephanies_development')

      query = "Select id from tags where name = '#{temptag.tag}'; "
      r = connection.query(query)
      if r.num_rows == 0 then
        # '' self.update_record_target("Insert into tags (name, type) values ('#{temptag.tag}','#{temptag.tag_type}');")
        temp_new_tag = Tag.new()
        temp_new_tag.type = "#{temptag.tag_type}"
        temp_new_tag.name = "#{temptag.tag}"
        temp_new_tag.save

        temptag.new_id = temp_new_tag.id
      else
        r.each do |r|
          temptag.new_id = r[0]
        end
      end
      connection.close()
      tl[i] = temptag
      i = i + 1
    end
    return tl
  end

  def get_tag_list(tl, at)
    taglist = tl
    connection = Mysql.new("localhost","stephanies","Trustno1","stephanies_development")
    case at
      when 4
        query = "Select caid, caname from #{@source_table_prefix}category; " #
        r = connection.query(query)
        r.each do |r|
          nt = ImportTag.new()
          nt.tag_type = 1
          nt.old_id = r[0]
          nt.tag = r[1]
          taglist.push(nt)
        end

        query2 = "Select subid, subname from #{@source_table_prefix}subcategory; "
        rr = connection.query(query2)
        unless rr.num_rows.nil? || rr.num_rows == 0
          rr.each do |rr|
            nt = ImportTag.new()
            nt.tag_type = 99
            nt.old_id = rr[0]
            nt.tag = rr[1]
            taglist.push(nt)
          end
        end

      when 3
        query = "Select class_id, class_type, class_name from #{@source_table_prefix}classes; " #
        r = connection.query(query)
        r.each do |r|
          nt = ImportTag.new()
          if r[1] == @srcWarningClassTypeID
            nt.tag_type = 6
          else
            nt.tag_type = 3
          end
          nt.old_id = r[0]
          nt.tag = r[2]
          taglist.push(nt)
        end
        query2 = "Select catid, category from #{@source_table_prefix}categories; "
        rr = connection.query(query2)
        rr.each do |rr|
          nt = ImportTag.new()
          nt.tag_type = 1
          nt.old_id = rr[0]
          nt.tag = rr[1]
          taglist.push(nt)

        end
        query3 = "Select charid, charname from #{@source_table_prefix}characters; "
        rrr = connection.query(query3)
        rrr.each do |rrr|
          nt = ImportTag.new()
          nt.tag_type = 2
          nt.old_id = rrr[0]
          nt.tag = rrr[1]
          taglist.push(nt)
        end
      when ArchiveType.efiction2
    end
    connection.close()
    return taglist
  end



  def update_source_tags(tl)
    case @source_archive_type
      when 4
        #{'}"Console.WriteLine(" Updating tags in source database for Archive Type 'StoryLine' ")
        puts "updating source tags"
        i = 0
        while i <= tl.length - 1
          current_tag = tl[i]
          if current_tag.tag_type == 1
            self.update_record_source("update #{@source_stories_table} set scid = #{current_tag.new_id} where scid = #{current_tag.old_id}")
          end
          if current_tag.tag_type == 99
            self.update_record_source("update #{@source_stories_table} set ssubid = #{current_tag.new_id}  where ssubid = #{current_tag.old_id}")
          end
          i = i + 1
        end
      when 3
    end
  end



  # <summary> # Main Worker Sub # </summary> # <remarks></remarks>
  def import_data()
    puts " Setting Import Values "
    self.set_import_strings()
    query = " SELECT * FROM #{@source_stories_table} ;"
    connection = Mysql.new("localhost","stephanies","Trustno1","stephanies_development")

    if @skip_rating_transform == false
      puts " Tranforming source ratings "
      self.transform_source_ratings()
    else
      puts " Skipping source rating transformation per config "
    end

    #Update Tags and get Taglist
    puts (" Updating Tags ")
    tag_list = Array.new()
    #tag_list2 = self.get_tag_list(tag_list, @source_archive_type)
    tag_list = self.fill_tag_list(tag_list)
    if @debug_update_source_tags == true
      self.update_source_tags(tag_list)
    end

    r = connection.query(query)

    puts (" Importing Stories ")
    i = 0
    while i <= r.num_rows
      puts " Importing Story #{i}"
      ns = ImportWork.new()
      a = ImportUser.new()
      #Create Taglisit for this story
      my_tag_list = Array.new()
      begin
        case srcArchiveType
          when 4
            ns.old_story_id = r[0]
            ns.title = r[1]
            ns.summary = r[2]
            ns.old_user_id = r[3]
            ns.rating_integer = r[4]
            rating_tag = ImportTag.new()
            rating_tag.tag_type = 7
            rating_tag.new_id = ns.rating_integer
            my_tag_list.Add(rating_tag)

            ns.published =  r[5]

            cattag = ImportTag.new()
            if useProperCategories == true
              cattag.tag_type = 1
            else
              cattag.tag_type = 3
            end
            cattag.new_id = r[6]
            my_tag_list.Add(cattag)
            subcattag = ImportTag.new()
            if useProperCategories == true
              subcattag.tag_type = 1
            else
              subcattag.tag_type = 3
            end
            subcattag.new_id =r[11]
            myTagList.Add(subcattag)
            ns.updated = r[9]
            ns.completed = r[12]
            ns.hits = r[10]
          when 3
            ns.old_story_id = r[0]
            ns.title = r[1]
            ns.summary = r[2]
            ns.old_user_id = r[10]
            ns.rating_integer = r[4]
            rating_tag = ImportTag.new()
            rating_tag.tag_type =7
            rating_tag.new_id = ns.rating_integer
            tag_list.Add(rating_tag)

            ns.published = r[8]

            ns.updated = r[9]
            ns.completed = r[12]
            ns.hits = r[10]

        end
        ns.new_author_id = self.getauthorIDbyOld(ns.old_user_id, ns.source_archive, ArchiveType.OTW)
        if ns.new_author_id == 0
          a = self.getAuthorObjectFromSRC(ns.old_user_id)
          new_a = self.add_user(a)
          ns.new_user_id = new_a.default_pseud
          ns.author = new_a.penname
        end
        self.update_record_target("Insert into works (title, summary, authors_to_sort_on, title_to_sort_on, revised_at, created_at, srcArchive, srcID) values ('" + ns.title + "', '" + ns.summary + "', '" + ns.Author + "', '" + ns.title + "', '" + ns.Updated + "', '" + ns.Published + "', " + ImportArchiveID + ", " + ns.OldSid + "); ")

        tgtConnection = Mysql.new(@target_database_connection)

        rr=tgtconnection.Query("select id from works where srcid = #{ns.OldSid} and srcArchive = #{@import_archive_id}")
        ns.NewSid = rr[0] #create creatorship
        self.update_record_target("Insert into creatorships(creation_id, pseud_id, creation_type) values (" + ns.NewSid + ", " + ns.NewAuthId + ", 'work') ") #ADD CHAPTERS
        tgtConnection.close()

        connection.close()
        self.AddChaptersOTW(ns)
      rescue Exception => ex
        puts " Error : " + ex.Message
        connection.close()
      ensure
      end
      i = i + 1
    end
    connection.close()
  end
=begin
    #Check For Author
    def AddChaptersOTW(ns)
      connection = MySqlConnection.new()
      connection.ConnectionString = srcDBCON
      chapCmd = MySqlCommand.new()
      chapCmd.Connection = connection
      chapCmd.CommandText = " Select * from " + srcTablePrefix + " chapters where csid = " + ns.OldSid
      chapDT = DataTable.new()
      connection.Open()
      reader = chapCmd.ExecuteReader
      chapDT.Load(reader)
      ixxi = 0
      ixxi = 0
      while ixxi <= chapDT.Rows.Count - 1
        c = Chapter.new()
        c.newSid = ns.NewSid
        c.newUserId = ns.NewAuthId
        c.title = chapDT.Rows(ixxi).Item(1)
        c.dateposted = chapDT.Rows(ixxi).Item(4)
        c.body = chapDT.Rows(ixxi).Item(3)
        self.PostChapterOTW(c, srcArchiveType)
        ixxi = ixxi + 1
      end
      connection.Close()
      reader.Close()
    end

    def post_chapters(c, sourceType)
      case sourceType
        when 4
          self.update_record_target("Insert into Chapters (content, work_id, created_at, updated_at, posted, title, published_at) values ('" + c.body + "', '" + c.dateposted.ToString + "', '" + c.dateposted.ToString + "', 1, '" + c.title + "', '" + c.dateposted.ToString + "') ")
          self.update_record_target("Insert into creatorships(creation_id, pseud_id, creation_type) values (" + c.newSid + ", " + c.newUserId + ", 'chapter') ")


      end
    end
=end
  ImportTag = Struct.new(:old_id,:new_id,:tag,:tag_type)

  ImportUser = Struct.new(:old_username, :penname,:realname,:joindate,:source_archive_id,:old_user_id,:bio,:password,
                          :password_salt,:website,:aol,:yahoo,:msn,:icq,:new_user_id,:email,:is_adult)

  ImportChapter = Struct.new(:new_work_id,:old_story_id,:source_archive_id,:title,
                             :summary,:notes,:old_user_id,:body,:position,:date_added)

  ImportWork = Struct.new(:old_story_id,:new_work_id,:author_string,:title,:summary,:classes,:old_user_id,:characters,
                          :hits,:new_author_id,:word_count,:completed,:updated,:source_archive,:generes,:rating,
                          :rating_integer,:warnings,:chapters,:published,:cats)
  class NewOtwTag
    def initialize()
    end
    #Old Tag ID #New Tag ID #Tag
  end #Tag Type

  def get_user_id_from_email(email)
    connection = Mysql.new(@target_database_connection)
    r = connection.query("select user_id from users where email = '#{email}'")
    return r[0]
  end

  def add_user(a)
    new_user = user.create(email:"#{a.email}",login:"#{a.email}",password:"#{a.password}",confiirmpassword:"#{a.password}")
    new_user.create_default_associateds
    a.new_user_id = new_user.id
=begin
        #self.update_record_target("insert into users (email, login) values ('#{a.email}', '#{a.email}'); ")
        #a.new_user_id = self.get_user_id_from_email(a.email)
        #a.newuid = self.getauthorIDbyOld(a.source_archive_id, a.srcuid, ArchiveType.OTW)
        #self.update_record_target("Insert into profiles (user_id, about_me) values ( #{a.newuid},'#{a.bio}'); ")
        #self.update_record_target("Insert into pseuds (user_id, name, description, is_default) values (#{a.newuid}, '#{a.PenName}', 'Imported Pseudonym', 1); ")
        #self.update_record_target("Insert into preferences (user_id) values (#{a.newuid}); ")
        self.update_record_target("Insert into user_imports (user_id,source_user_id,source_archive_id,source_penname) values (#{a.newuid},#{a.source_archive_id},#{a.source_user_id}")
        cmd.CommandText = "Select id from users where source_archive_id = #{@import_archive_id} and srcid = #{a.srcuid}"
        a.newuid = r2.Rows(0).Item(0)
        cmd.CommandText = "Select id from pseuds where user_id = #{a.newuid} and is_default = 1 "
        a.defaultPsuid = r2.Rows(0).Item(0)
        connection.Close()
=end
    return a

  end
  # <summary> # Set Archive Strings and values # </summary> # <remarks></remarks>
  def set_import_strings
    case @source_archive_type
      when 1
        @source_chapters_table = "#{@source_table_prefix}chapters"
        @source_reviews_table = "#{@source_table_prefix}reviews"
        @source_stories_table = "#{@source_table_prefix}stories"
        @source_categories_table = "#{@source_table_prefix}categories"
        @source_users_table = "#{@source_table_prefix}authors"
        @get_author_from_source_query = " "
      when 2
        @source_chapters_table = "#{@source_table_prefix}chapters"
        @source_reviews_table = "#{@source_table_prefix}reviews"
        @source_stories_table = "#{@source_table_prefix}stories"
        @source_users_table = "#{@source_table_prefix}authors"
        @get_author_from_source_query = "Select realname, penname, email, bio, date, pass, website, aol, msn, yahoo, icq, ageconsent from  #{@source_users_table} where uid ="
      when 3
        @source_chapters_table = "#{@source_table_prefix}chapters"
        @source_reviews_table = "#{@source_table_prefix}reviews"
        @source_stories_table = "#{@source_table_prefix}stories"
        @source_users_table = "#{@source_table_prefix} authors"
        @get_author_from_source_query = "Select realname, penname, email, bio, date, pass from #{@source_users_table} where uid ="
      when 5
      when 4
        @source_chapters_table = "#{@source_table_prefix}chapters"
        @source_reviews_table = "#{@source_table_prefix}reviews"
        @source_stories_table = "#{@source_table_prefix}stories"
        @source_users_table = "#{@source_table_prefix}users"
        @source_categories_table = "#{@source_table_prefix}category"
        @source_subcategories_table = "#{@source_table_prefix}subcategory"
        @srcRatingsTable = "" #None
        @get_author_from_source_query = "SELECT urealname, upenname, uemail, ubio, ustart, upass, uurl, uaol, umsn, uicq from #{@source_users_table} where uid ="
    end
  end

  def get_imported_author_from_source(authid)
    a = ImportedAuthor.new()
    connection = Mysql.new("localhost","stephanies","Trustno1","stephanies_development")
    r = my.query("#{qryGetAuthorFromSource} #{authid}")
    r.each_hash do |r|
      a.srcuid = authid
      a.RealName = r["realname"]
      a.source_archive_id = @importArchiveID
      a.PenName = r["penname"]
      a.email = r["email"]
      a.Bio = r[3]
      a.joindate = r[4]
      a.password = r[5]
      if @source_archive_type == ArchiveType.efiction2 || @source_archive_type == ArchiveType.storyline
        a.website = r[6]
        a.aol = r[7]
        a.msn = r[8]
        a.icq = r[9]
        a.Bio = self.build_bio(a).Bio
        a.yahoo = ""
        if srcArchiveType == ArchiveType.efiction2
          a.yahoo = r[10]
          a.isadult = r[11]
        end
      end

    end
    my.free
    return a
  end

# Consolidate Author Fields into User About Me String
  def build_bio(a)
    if a.yahoo == nil
      a.yahoo = " "
    end
    if a.aol.Length > 1 | a.yahoo.Length > 1 | a.website.Length > 1 | a.icq.Length > 1 | a.msn.Length > 1
      if a.Bio.Length > 0
        a.Bio << "<br /><br />"
      end
    end
    if a.aol.Length > 1
      a.Bio << " <br /><b>AOL / AIM :</b><br /> #{a.aol} "
    end
    if a.website.Length > 1
      a.Bio << "<br /><b>Website:</ b><br /> #{a.website} "
    end
    if a.yahoo.Length > 1
      a.Bio << "<br /><b>Yahoo :</b><br /> #{a.yahoo} "
    end
    if a.msn.Length > 1
      a.Bio << "<br /><b>Windows Live:</ b><br /> #{a.msn} "
    end
    if a.icq.Length > 1
      a.Bio << "<br /><b>ICQ :</b><br /> #{a.icq} "
    end
    return a
  end
#TODO

# <summary> # Converts d/m/y to m/d/y # </summary> #
  def tppDateFix(dv)
    s = dv.Split("/")
    nd = self.s(1) + "/" + self.s(0) + "/" + self.s(2)
    return nd
  end

  # <summary> # Return new story id given old id and archive #
  def get_new_story_id_from_old_id(source_archive_id, old_story_id) #
    query = " select work_id from work_imports where source_archive_id #{source_archive_id} and old_story_id=#{old_story_id}"
    connection = Mysql.new(@target_database_connection)

    r = Mysql.query(query)
    if r.num_rows > 0
      return r[0]
    else
      return r.num_rows
    end

    connection.Close()

  end

  # Get New Author ID from old User ID & old archive ID
  def get_new_author_id_from_old(old_archive_id, old_user_id)
    begin
      connection = Mysql.new(@target_database_connection)
      query = " Select user_id from user_imports where source_archive_id = #{old_archive_id} and source_user_id = #{old_user_id} "
      r = connection.query(query)
      if r.num_rows == 0
        return 0
      else
        return r[0]
      end
      connection.close()
    rescue Exception => ex
      connection.close()
    ensure
    end
  end

# Update db record takes query as peram #
  def update_record_target(query)
    connection = Mysql.new("localhost","stephanies","Trustno1","stephanies_development")
    begin
      rowsEffected = 0
      rowsEffected = connection.query(query)
      connection.free
      connection.close()
      return rowsEffected
    rescue Exception => ex
      connection.close()
      puts ex.message
    ensure
    end
  end

# Update db record takes query as peram #
  def update_record_source(query)
    connection = Mysql.new("localhost","stephanies","Trustno1","stephanies_development")
    begin
      rowsEffected = 0

      rowsEffected = connection(query)
      connection.close()
      return rowsEffected
    rescue Exception => ex

      connection.close()

      puts ex.message
    end
  end

end