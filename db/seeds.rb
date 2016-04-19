require 'csv'

pokemon_data_directory = Rails.root.join('db', 'pokemon_data')
pokemon = pokemon_data_directory.join('pokemon.csv')
moves = pokemon_data_directory.join('moves.csv')
pokemon_moves = pokemon_data_directory.join('pokemon_moves.csv')

# Iterate through all of the Pokemon
CSV.foreach(pokemon, col_sep: "|", headers: false).each_with_index do |row, i|
	
	# Format: name	type_1	type_2	hp	attack	defense	special_attack	special_defense	speed
	# e.g. Bulbasaur	4	7	294	216	216	251	251	207
	
	name = row[0]
	type_1 = row[1]
	type_2 = row[2]
	hp = row[3]
	attack = row[4]
	defense = row[5]
	special_attack = row[6]
	special_defense = row[7]
	speed = row[8]

	Pokemon.create(name: name, type_1: type_1, type_2: type_2, hp: hp, attack: attack, defense: defense,
					special_attack: special_attack, special_defense: special_defense, speed: speed)
end

# Iterate through all of the moves
CSV.foreach(moves, col_sep: '|', headers: false).each_with_index do |row, i|
	
	# Format: name|type|category|power|accuracy|power_points|status_effect|status_effect_chance|stat_type|stage_change|stat_change_chance|description
	# e.g. Absorb|grass|special|20|100|25||||||User recovers half the HP inflicted on opponent.
	
	name = row[0]
	type = row[1]
	category = row[2]
	power = row[3]
	accuracy = row[4]
	power_points = row[5]
	status_effect = row[6]
	status_effect_chance = row[7]
	stat_type = row[8]
	stage_change = row[9]
	stat_change_chance = row[10]
	description = row[11]
	
	Move.create(name: name, type_1: type, category: category, power: power, accuracy: accuracy, power_points: power_points,
				status_effect: status_effect, status_effect_chance: status_effect_chance, stat_type: stat_type,
				stage_change: stage_change, stat_change_chance: stat_change_chance, description: description)
end

# Iterate through all of the Pokemon moves
CSV.foreach(pokemon_moves, col_sep: "|", headers: false).each_with_index do |row, i|
	
	# Format: pokemon_id move_id
	# e.g. 1    125
	
	pokemon_id = row[0]
	move_id = row[1]
	
	PokemonMove.create(pokemon_id: pokemon_id, move_id: move_id)
end