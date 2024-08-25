module Simpler
  module DatabaseInitialization
    def create_tables_if_not_exists
      unless @db.table_exists?(:categories)
        @db.create_table(:categories) do
          primary_key :id
          String :title, null: false
        end
      end

      unless @db.table_exists?(:tests)
        @db.create_table(:tests) do
          primary_key :id
          String :title, null: false
          Integer :level, default: 0
          foreign_key :category_id, :categories, on_delete: :cascade
        end
      end
    end

    def seed_data_if_needed
      return if Test.count > 0

      create_category('Backend')
      create_category('Frontend')
      create_category('DevOps')

      create_test('Ruby Basics', 1, 'Backend')
      create_test('Ruby Advanced', 2, 'Backend')
      create_test('JavaScript Basics', 1, 'Frontend')
      create_test('JavaScript Advanced', 2, 'Frontend')
      create_test('Docker Basics', 1, 'DevOps')
      create_test('Kubernetes Advanced', 2, 'DevOps')

      # Устанавливаем ID = 101 для одного из тестов по заданию
      test = Test.find(title: 'Ruby Basics')
      if test
        @db.run("UPDATE tests SET id = 101 WHERE title = 'Ruby Basics'")
      end
    end

    private

    def create_category(title)
      Category.find_or_create(title: title)
    rescue Sequel::ValidationFailed => e
      puts "Category creation failed: #{e.message}"
    end

    def create_test(title, level, category_title)
      category = Category.find(title: category_title)
      unless category
        puts "Category with title '#{category_title}' not found."
        return
      end
      Test.find_or_create(title: title, level: level, category: category)
    rescue Sequel::ValidationFailed => e
      puts "Test creation failed: #{e.message}"
    end
  end
end