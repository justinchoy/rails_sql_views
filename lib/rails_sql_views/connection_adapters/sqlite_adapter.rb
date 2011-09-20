module RailsSqlViews
  module ConnectionAdapters
    module SQLiteAdapter
      def supports_views?
        true
      end

      def supports_drop_table_cascade?
        return false 
      end
      
      def tables(name = nil) #:nodoc:
        sql = <<-SQL
          SELECT name
          FROM sqlite_master
          WHERE (type = 'table' OR type = 'view') AND NOT name = 'sqlite_sequence'
        SQL

        execute(sql, name).map do |row|
          row[0]
        end
      end

      def base_tables(name = nil)
        sql = <<-SQL
          SELECT name
          FROM sqlite_master
          WHERE (type = 'table') AND NOT name = 'sqlite_sequence'
        SQL

        execute(sql, name).map do |row|
          row[0]
        end        
      end
      alias nonview_tables base_tables
      
      def views(name = nil)
        sql = <<-SQL
          SELECT name
          FROM sqlite_master
          WHERE type = 'view' AND NOT name = 'sqlite_sequence'
        SQL

        execute(sql, name).map do |row|
          row[0]
        end
      end
      
      # Get the view select statement for the specified table.
      def view_select_statement(view, name = nil)
        sql = <<-SQL
          SELECT sql
          FROM sqlite_master
          WHERE name = '#{view}' AND NOT name = 'sqlite_sequence'
        SQL
        
        view_def = select_value(sql, name)
        
        if view_def
          return convert_statement(view_def)
        else
          raise "No view called #{view} found"
        end
      end
      
      def supports_view_columns_definition?
        false
      end
      
      private
      def convert_statement(s)
        s.sub(/^CREATE.* AS (SELECT .*)/i, '\1')
      end
      
    end
  end
end
