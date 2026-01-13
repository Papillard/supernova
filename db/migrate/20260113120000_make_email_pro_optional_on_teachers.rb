class MakeEmailProOptionalOnTeachers < ActiveRecord::Migration[8.0]
  def change
    change_column_null :teachers, :email_pro, true
  end
end
