class CreatePokemonMoves < ActiveRecord::Migration
	def change
		create_table :pokemon_moves do |t|
			t.belongs_to :pokemon, index: true
			t.belongs_to :move, index: true
		end
	end
end
