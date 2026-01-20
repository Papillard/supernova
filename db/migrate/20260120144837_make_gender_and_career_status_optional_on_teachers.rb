class MakeGenderAndCareerStatusOptionalOnTeachers < ActiveRecord::Migration[8.0]
  def change
    change_column_null :teachers, :gender, true
    change_column_null :teachers, :career_status, true
  end
end
