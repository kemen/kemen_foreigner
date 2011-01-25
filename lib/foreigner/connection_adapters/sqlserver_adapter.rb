module Foreigner
  module ConnectionAdapters
    module SqlserverAdapter
      include Foreigner::ConnectionAdapters::Sql2003

      def remove_foreign_key(table, options)
        if Hash === options
          foreign_key_name = foreign_key_name(table, options[:column], options)
        else
          foreign_key_name = foreign_key_name(table, "#{options.to_s.singularize}_id")
        end
        execute "IF EXISTS (SELECT 1 from sys.objects where name = '#{foreign_key_name}') ALTER TABLE #{table} DROP CONSTRAINT #{foreign_key_name}"
      end

      def add_primary_key(table,options)
        constraint_name = "pk_#{table}_#{options[:column]}"
        execute "alter table #{table} add constraint #{constraint_name} primary key (#{options[:column]})"
      end

      def remove_primary_key(table, column)
        constraint_name = "pk_#{table}_#{options[:column]}"
        execute "alter table #{table} drop constraint #{constraint_name}"
      end


      def pk(table_name)
        pk_info = select_all %{
          select 	c.COLUMN_NAME as 'pk'
            from 	INFORMATION_SCHEMA.TABLE_CONSTRAINTS pk ,
            INFORMATION_SCHEMA.KEY_COLUMN_USAGE c
          where 	pk.TABLE_NAME = '#{table_name}'
            and	CONSTRAINT_TYPE = 'PRIMARY KEY'
            and	c.TABLE_NAME = pk.TABLE_NAME
            and	c.CONSTRAINT_NAME = pk.CONSTRAINT_NAME
        }
        pk_info.map do |row|
          options = {:pk => row['pk']}
          options
        end
      end

      def foreign_keys(table_name)
        fk_info = select_all %{
          SELECT
              'column' = CU.COLUMN_NAME,
              to_table  = PK.TABLE_NAME,
              primary_key = PT.COLUMN_NAME,
              'name' = C.CONSTRAINT_NAME
          FROM
              INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS C
              INNER JOIN
              INFORMATION_SCHEMA.TABLE_CONSTRAINTS FK
                  ON C.CONSTRAINT_NAME = FK.CONSTRAINT_NAME
              INNER JOIN
              INFORMATION_SCHEMA.TABLE_CONSTRAINTS PK
                  ON C.UNIQUE_CONSTRAINT_NAME = PK.CONSTRAINT_NAME
              INNER JOIN
              INFORMATION_SCHEMA.KEY_COLUMN_USAGE CU
                  ON C.CONSTRAINT_NAME = CU.CONSTRAINT_NAME
              INNER JOIN
              (
                  SELECT
                      i1.TABLE_NAME, i2.COLUMN_NAME
                  FROM
                      INFORMATION_SCHEMA.TABLE_CONSTRAINTS i1
                      INNER JOIN
                      INFORMATION_SCHEMA.KEY_COLUMN_USAGE i2
                      ON i1.CONSTRAINT_NAME = i2.CONSTRAINT_NAME
                      WHERE i1.CONSTRAINT_TYPE = 'PRIMARY KEY'
              ) PT ON PT.TABLE_NAME = PK.TABLE_NAME
              WHERE FK.TABLE_NAME= '#{table_name}'
        }

        fk_info.map do |row|
          options = {:column => row['column'], :name => row['name'], :primary_key => row['primary_key']}
          ForeignKeyDefinition.new(table_name, row['to_table'], options)
        end
      end
    end
  end
end

[:SQLServerAdapter].each do |adapter|
  begin
    ActiveRecord::ConnectionAdapters.const_get(adapter).class_eval do
      include Foreigner::ConnectionAdapters::SqlserverAdapter
    end
  rescue
  end
end