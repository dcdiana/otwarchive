=begin
class A
  def add_chapters(new_work, old_work_id, first, ac_mode)
    chapter_array = []
    if new_work.chapters
      #chapter_array = new_work.chapters
    else
      chapter_array = []
    end


    old_chapter_count = get_single_value_target("SELECT COUNT(sid) AS chapters FROM " + @source_chapters_table + " where sid = #{old_work_id}")
    @ac_mode = ac_mode
    begin
      case @source_archive_type
        when 4 #Storyline
          puts "1121 == Select * from #{@source_chapters_table} where csid = #{old_work_id}"
          r = @connection.query("Select * from #{@source_chapters_table} where csid = #{old_work_id}")
          puts "333"
          ix = 1
          r.each do |rr|
            c = new_work.chapters.build
            c.title = rr[1]
            c.created_at = rr[4]
            #c.updated_at = rr[4]
            c.content = rr[3]
            c.position = ix
            c.summary = ""
            c.posted = 1
            #ns.chapters << c
            ix = ix + 1
            #self.post_chapters(c, @source_archive_type)
          end
        when 3 #efiction 3
          if first
            query = "Select chapid,title,inorder,notes,storytext,endnotes,sid,uid from  #{@source_chapters_table} where sid = #{old_work_id} order by inorder asc Limit 1"
          else
            first_chapter_index = get_single_value_target("Select inorder from  #{@source_chapters_table} where sid = #{old_work_id} order by inorder asc Limit 1")
            query = "Select chapid,title,inorder,notes,storytext,endnotes,sid,uid from  #{@source_chapters_table} where sid = #{old_work_id} AND inorder  > 1 order by inorder asc"
            puts query
          end
          r = @connection.query(query)
          puts " chaptercount #{get_row_count(r)} "
          position_holder = 2
          r.each do |rr|
            if @ac_mode == 1
              ic = ImportChapter.new

              if first

                ic.position = 1
              else
                #c = new_work.chapters.new
                #c.work_id = new_work.id
                #ic.authors = new_work.authors
                ic.position = rr[2]


              end
              ic.title = rr[1]
              #c.created_at  = rr[4]
              #c.updated_at = rr[4]
              my_iconv = Iconv.new('UTF-8//IGNORE', 'UTF-8')
              valid_string = my_iconv.iconv(rr[4] + ' ')[0..-2]
              ic.body = valid_string
              ic.summary = rr[3]

              ic.published_at = Date.today
              ic.created_at = Date.today
              #unless first
              #  c.save!
              # new_work.save
              ## get reviews for all chapters but chapter 1, all chapter 1 reviews done in separate step post work import
              ## due to the chapter not having an id until the work gets saved for the first time
              #  import_chapter_reviews(rr[0], c.id)
              #end
              chapter_array << ic


            else
=begin

              if first
                c = new_work.chapters.build()
                c.position = 1
              else
                c = new_work.chapters.new
                c.work_id = new_work.id
                c.authors = new_work.authors
                c.position = position_holder
              end
              c.title = rr[1]
              #c.created_at  = rr[4]
              #c.updated_at = rr[4]
              ic = Iconv.new('UTF-8//IGNORE', 'UTF-8')
              valid_string = ic.iconv(rr[4] + ' ')[0..-2]
              c.content = valid_string
              c.summary = rr[3]
              c.posted = 1
              c.published_at = Date.today
              c.created_at = Date.today
              unless first
                c.save!
                new_work.save
                ## get reviews for all chapters but chapter 1, all chapter 1 reviews done in separate step post work import
                ## due to the chapter not having an id until the work gets saved for the first time
                import_chapter_reviews(rr[0], c.id)
              end

=end
            end
            if new_work.chapters
              new_work.chapters = new_work.chapters + chapter_array
            else
              new_work.chapters = chapter_array
            end


          end
          binding.pry
          if old_chapter_count.to_i > 1
            if new_work.chapters.length != old_chapter_count
              return add_chapters(new_work, old_work_id, false, 1)
            else
              return new_work
            end

          else

          end

        else
          puts "Error: (add_chapters): Invalid source archive type"
      end

      return new_work
    rescue Exception => ex
      puts "error in add chapters : #{ex}"
    end

    endend=end
