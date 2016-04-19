class CreateMoves < ActiveRecord::Migration
	def change
		create_table :moves do |t|
			t.string :name
			t.string :description
			t.integer :type_1
			t.integer :category
			t.integer :power
			t.integer :accuracy
			t.integer :power_points
			t.integer :status_effect
			t.integer :status_effect_chance
			t.integer :stat_type
			t.integer :stage_change
			t.integer :stat_change_chance
		end
	end
end
