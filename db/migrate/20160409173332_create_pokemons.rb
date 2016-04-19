class CreatePokemons < ActiveRecord::Migration
	def change
		create_table :pokemons do |t|
			t.string :name
			t.integer :type_1
			t.integer :type_2
			t.integer :hp
			t.integer :attack
			t.integer :defense
			t.integer :special_attack
			t.integer :special_defense
			t.integer :speed
		end
	end
end
