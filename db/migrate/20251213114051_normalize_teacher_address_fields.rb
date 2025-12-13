class NormalizeTeacherAddressFields < ActiveRecord::Migration[8.0]
  def up
    # Add new normalized address fields
    add_column :teachers, :address, :string
    add_column :teachers, :zip_code, :string
    add_column :teachers, :city, :string

    # Migrate existing data
    execute <<-SQL
      UPDATE teachers
      SET city = base_city,
          zip_code = base_zip_code
      WHERE base_city IS NOT NULL OR base_zip_code IS NOT NULL
    SQL

    # Remove old fields
    remove_column :teachers, :base_city, :string
    remove_column :teachers, :base_zip_code, :string
  end

  def down
    # Add back old fields
    add_column :teachers, :base_city, :string
    add_column :teachers, :base_zip_code, :string

    # Migrate data back
    execute <<-SQL
      UPDATE teachers
      SET base_city = city,
          base_zip_code = zip_code
      WHERE city IS NOT NULL OR zip_code IS NOT NULL
    SQL

    # Remove new fields
    remove_column :teachers, :address, :string
    remove_column :teachers, :zip_code, :string
    remove_column :teachers, :city, :string
  end
end
