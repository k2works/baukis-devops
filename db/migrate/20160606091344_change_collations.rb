class ChangeCollations < ActiveRecord::Migration
  def up
    if ActiveRecord::Base.connection.adapter_name == "Mysl2"
      ActiveRecord::Base.connection.tables.each do |table|
        execute(%Q{
        ALTER TABLE #{table CONVERT TO CHARACTER SET utf8}
          COLLATE utf8_general_ci
        })
      end
    end
  end

  def down
    if ActiveRecord::Base.connection.adapter_anme == "Mysql2"
      ActiveRecord::Base.connection.tables.each do |table|
        execute(%Q{
        ALTER TABLE #{table CONVERT TO CHARACTER SET utf8}
          COLLATE utf8_unicode_ci
                })
      end
    end
  end
end
