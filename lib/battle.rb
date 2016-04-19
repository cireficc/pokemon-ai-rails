#require 'random'

def pokemon_battle(source, target, source_assigned_moves, target_assigned_moves)
	
	$battle_stats = {
		source_damage_done: 0,
		target_damage_done: 0,
		winner: nil
	}
	
	# Clone the original Pokemon into "current" Pokemon used throughout the battle, so as not to modify the original
	source_current = source.deep_clone include: :moves
	target_current = target.deep_clone include: :moves
	$turn_count = 0
	
	# Get 4 moves randomly from all the moves the Pokemon can know; these will be used in the battle
	# Enough 1v1 iterations should give a decent spread of data on the utility of different moves vs
	# particular enemy Pokemon
	source_current.moves = (source_assigned_moves) ? source_assigned_moves : source_current.moves.sample(4)
	target_current.moves = (target_assigned_moves) ? target_assigned_moves : target_current.moves.sample(4)
	source_current.moves.each_with_index do |move, i|
		#puts "(#{source_current.name}) assigned [#{i}] #{move.name}"
	end
	target_current.moves.each_with_index do |move, i|
		#puts "(#{target_current.name}) assigned [#{i}] #{move.name}"
	end
	
	#puts "#{source_current.name} (#{source_current.current_hp}) vs #{target_current.name} (#{target_current.current_hp})"
	
	while (source_current.current_hp > 0 && target_current.current_hp > 0) do
		if $turn_count % 2 == 0
			#puts "Turn #{$turn_count}: #{source_current.name} (#{source_current.status_effect}) hp: #{source_current.current_hp} || #{target_current.name} (#{target_current.status_effect}) hp: #{target_current.current_hp}"
			take_turn(source_current, target_current)
		else
			#puts "Turn #{$turn_count}: #{target_current.name} (#{target_current.status_effect}) hp: #{target_current.current_hp} || #{source_current.name} (#{source_current.status_effect}) hp: #{source_current.current_hp}"
			take_turn(target_current, source_current)
		end
		
		$turn_count += 1
	end
	
	if source_current.current_hp < 0
		#puts "#{source_current.name} fainted! Battle over!"
		$battle_stats[:winner] = "target"
	else
		#puts "#{target_current.name} fainted! Battle over!"
		$battle_stats[:winner] = "source"
	end
	
	return $battle_stats
end

# On a Pokemon's turn, it will choose a random move (out of its 4-move pool) and use it
def take_turn(source, target)
	
	skip_turn = false
	
	if (source.status_effect == "s_sleeping")
		#puts "SLEEP: #{source.name}"
		if source.status_effect_duration > 0
			#puts "#{source.name} is still sleeping for #{source.status_effect_duration} more turns\n\n"
			skip_turn = true
		else
			#puts "#{source.name} woke up!"
			source.has_status_effect = false
			source.status_effect = nil
		end
		source.status_effect_duration = source.status_effect_duration - 1
	end
	
	if (source.confused)
		#puts "CONFUSION: #{source.name}"
		if source.confused_duration > 0
			#puts "#{source.name} is still confused for #{source.confused_duration} more turns"
			# Calculate chance to hit self and end turn
			rolled = Random.rand(0..100)
			#puts "Rolled: #{rolled}, >= 50 means hurt self"
			if (rolled >= 50 && source.status_effect != "s_sleeping")
				damage = confusion_damage(source)
				#puts "#{source.name} did #{damage} damage to itself in confusion\n\n"
				source.current_hp = source.current_hp - damage
			end
		else
			#puts "#{source.name} snapped out of confusion!"
			source.confused = false
		end
		source.confused_duration = source.confused_duration - 1
	end
	
	if (source.status_effect == "s_frozen")
		#puts "FROZEN: #{source.name}"
		rolled = Random.rand(0..100)
		#puts "Rolled: #{rolled}, > 20 means still frozen"
		if (rolled > 20)
			#puts "#{source.name} is still frozen!\n\n"
			skip_turn = true
		else
			#puts "#{source.name} unfroze!"
			source.has_status_effect = false
			source.status_effect = nil
		end
	end
	
	if (source.status_effect == "s_paralyzed")
		#puts "PARALYSIS: #{source.name}"
		rolled = Random.rand(0..100)
		#puts "Rolled: #{rolled}, > 25 means paralyzed for this turn (cannot use move)"
		if (rolled > 25)
			#puts "#{source.name} is paralyzed, it cannot move!\n\n"
			skip_turn = true
		else
			#puts "#{source.name} is paralyzed, but is able to attack!"
		end
	end
	
	if source.flinched
		#puts "#{source.name} flinched!\n\n"
		source.flinched = false
		skip_turn = true
	end
	
	if source.recharge > 0
		source.recharge = source.recharge - 1
		source.using_move = nil
		#puts "#{source.name} is recharging for #{source.recharge} more turns\n\n"
		apply_status_effect_damage(source)
		skip_turn = true
	else
		if source.using_move
			move = source.using_move
		else
			return if skip_turn
			# Get a random move
			#move = source.moves.sample
			move = choose_move(source, target)
			
			#puts "#{source.name} chose to use #{move.name}"
			
			if ["Dig", "Fly", "Razor Wind", "Skull Bash", "Sky Attack", "Solar Beam"].include? move.name
				#puts "Charge move: #{move.name}"
				source.using_move = move
				source.charge = 1
			end
		end
	end
	
	if (source.charge > 0)
		source.charge = source.charge - 1
		#puts "#{source.name} is charging for #{source.charge} more turns\n\n"
		apply_status_effect_damage(source)
		skip_turn = true
	else
		source.using_move = nil
	end
	
	return if skip_turn
	
	# A move will miss if the accuracy check failed or the enemy Pokemon is using Fly/Dig
	# and the source pokemon did not use a move that could hit a Fly/Dig Pokemon
	dig_miss = (target.using_move && target.using_move.name == "Dig" && move.name != "Earthquake")
	fly_miss = (target.using_move && target.using_move.name == "Fly" && (move.name != "Thunder" && move.name != "Gust"))
	if (!move_hit?(move) || fly_miss || dig_miss)
		#puts "Attack missed!\n\n"
		if ["High Jump Kick", "Jump Kick"].include? move.name
			source.current_hp = source.current_hp - (source.hp / 2.0).round
		end
		return
	end
	
	if move.name == "Dream Eater"
		if !(target.has_status_effect && target.s_sleeping?)
			#puts "#{target.name} is not asleep. Attack missed!"
		end
	end
	
	if ["Recover", "SoftBoiled"].include? move.name
		healed = (source.hp / 2.0).round
		source.current_hp = source.current_hp + healed
		#puts "#{source.name} healed #{healed} hp"
		return
	end
	
	if move.name == "Super Fang"
		damage = (target.current_hp / 2.0).round
		target.current_hp = target.current_hp - damage
		#puts "#{source.name} did #{damage} damage to #{target.name}\n\n"
		return
	end
	
	if move.name == "Haze"
		#puts "Haze used, resetting all stat stages\n\n"
		haze(source, target)
		return
	end
	
	damage = 0
	
	# These moves all hit 2-5 times, so calculate the damage that many times.
	if ["Barrage", "Comet Punch", "Double Slap", "Fury Attack", "Fury Swipes", "Pin Missle", "Spike Cannon"].include? move.name
		hits = Random.rand(2..5)
		#puts "Hitting #{hits} times"
		hits.times do |i|
			hit_damage = calculate_damage(source, target, move)
			damage = damage + hit_damage
		end
	# These moves all hit exactly twice
	elsif ["Bonemerang", "Double Kick", "Twineedle"].include? move.name
		2.times do |i|
			hit_damage = calculate_damage(source, target, move)
			damage = damage + hit_damage
		end
	# The rest of the moves only hit once
	else
		damage = calculate_damage(source, target, move)
	end
	
	# If the move can affect a Pokemon's stats, do the calculation now
	if move.stat_type?
		
		# If the stage_change is positive, it affects the source Pokemon. Negative affects the target Pokemon
		#puts "Stage Change: #{move.stage_change}"
		if move.stage_change > 0
			changed = true
			stat_target = source
			#puts "STAT CHANGE: (CHANGED) #{changed}"
		else
			stat_change_max = 100
			rolled = Random.rand(stat_change_max)
			changed = (rolled >= (stat_change_max - move.stat_change_chance))
			stat_target = target
			#puts "STAT CHANGE: (NEED) #{stat_change_max - move.stat_change_chance} || (ROLL) #{rolled} || (CHANGED) #{changed}"
		end
		
		#puts "Stages (BEFORE): #{stat_target.attack_stage} || #{stat_target.defense_stage} || #{stat_target.special_attack_stage} || #{stat_target.special_defense_stage} || #{stat_target.speed_stage}"
		
		if changed
			case move.stat_type
				when "attack"
					stat_target.attack_stage = stat_target.attack_stage + move.stage_change
				when "defense"
					stat_target.defense_stage = stat_target.defense_stage + move.stage_change
				when "special_attack"
					stat_target.special_attack_stage = stat_target.special_attack_stage + move.stage_change
				when "special_defense"
					stat_target.special_defense_stage = stat_target.special_defense_stage + move.stage_change
				when "speed"
					stat_target.speed_stage = stat_target.speed_stage + move.stage_change
			end
		end
		
		#puts "Stages (AFTER): #{stat_target.attack_stage} || #{stat_target.defense_stage} || #{stat_target.special_attack_stage} || #{stat_target.special_defense_stage} || #{stat_target.speed_stage}"
		
		#puts "#{stat_target.name} #{move.stat_type.upcase} #{(move.stage_change > 0) ? 'rose' : 'fell'} by #{move.stage_change.abs} stage(s)" if changed
	end
	
	apply_status_effect = apply_status_effect?(source, target, move)
	#puts "Apply status effect? #{apply_status_effect} --> #{move.status_effect}"
	
	if !target.has_status_effect && apply_status_effect && move.status_effect != "s_confused"
		target.has_status_effect = true
		target.status_effect = move.status_effect
		#puts "#{target.name} now has status effect: #{target.status_effect}" if target.has_status_effect
		
		if (target.status_effect == "s_sleeping")
			for_turns = Random.rand(1..3)
			#puts "#{target.name} sleeping for #{for_turns} turns"
			target.status_effect_duration = for_turns
		end
	end
	
	if !target.confused && move.status_effect == "s_confused"
		target.confused = true
		for_turns = Random.rand(1..4)
		#puts "#{target.name} confused for #{for_turns} turns"
		target.confused_duration = for_turns
	end
	
	if $turn_count % 2 == 0
		$battle_stats[:source_damage_done] = $battle_stats[:source_damage_done] + damage
	else
		$battle_stats[:target_damage_done] = $battle_stats[:target_damage_done] + damage
	end
	
	target.current_hp = target.current_hp - damage
	#puts "#{source.name} did #{damage} damage to #{target.name}\n\n"
	
	# If the Pokemon just used Hyper Beam, give them a 1-turn cooldown, but we don't care about keeping track of the move
	if move.name == "Hyper Beam"
		source.using_move = move
		source.recharge = 1
	end
	
	if move_caused_flinch?(source, move)
		target.flinched = true
	end
	
	# Healing self
	if ["Absorb", "Dream Eater", "Leech Life", "Mega Drain"].include? move.name
		healed = (damage / 2.0).round
		source.current_hp = source.current_hp + healed
		#puts "#{source.name} healed #{healed} hp"
	end
	
	# Recoil self damage (1/4)
	if ["Submission", "Take Down"].include? move.name
		recoil = (damage / 4).round
		source.current_hp = source.current_hp - recoil
		#puts "#{source.name} took #{recoil} recoil damage"
	end
	
	# Recoil self damage (1/3)
	if move.name == "Double-Edge"
		recoil = (damage / 3).round
		source.current_hp = source.current_hp - recoil
		#puts "#{source.name} took #{recoil} recoil damage"
	end
	
	# Burn or poison damage taken
	apply_status_effect_damage(source)
end

def choose_move(source, target)
	
	#puts "Choosing best move to use"
	
	move_to_use = nil
	
	# Give the enemy a status effect asap
	if (!target.has_status_effect)
		status_moves = source.moves.select {|m| m.status_effect }
		if status_moves.any?
			move_to_use = status_moves.sample
			return move_to_use
		end
	end
	
	# Get a STAB move
	same_type_damage_moves = source.moves.select { |m| ((source.type_1 == m.type_1 || source.type_2 == m.type_1) && m.power) }
	
	if same_type_damage_moves.any?
		move_to_use = same_type_damage_moves.sample
		return move_to_use
	end
	
	# Otherwise just get a random move
	return source.moves.sample
end

def apply_status_effect_damage(source)
	
	if (source.status_effect == "s_burned" || source.status_effect == "s_poisoned")
		status_damage = (source.hp / 8.0).round
		#puts "#{source.name} took #{status_damage} #{source.status_effect} damage\n\n"
		source.current_hp = source.current_hp - status_damage
	end
end

# Dice roll for move hitting or not (accuracy check)
def move_hit?(move)
	
	accuracy_max = 100
	
	# If the move doesn't have an accuracy, it means that it always hits
	return true if move.accuracy.nil?
	
	rolled = Random.rand(accuracy_max)
	
	#puts "(CHANCE) #{move.accuracy} || (NEED) #{accuracy_max - move.accuracy} || (ROLL) #{rolled}"
	
	return (rolled >= (accuracy_max - move.accuracy))
end

# Dice roll for move critting or not. Takes into account moves that have high crit chance
def move_crit?(source, move)
	
	max = 100
	rolled = Random.rand(max)
	
	# If you roll less than 50% (which is the max crit chance you can have), then return early to save CPU cycles
	return false if (rolled < 50)
	
	stage = source.crit_stage
	
	# Special case calculation for all moves that have high crit chance, listed explicity here
	if ["Crabhammer", "Karate Chop", "Razor Leaf", "Razor Wind", "Slash"].include? move.name
		stage = stage + 2	
	end
	
	#puts "Crit stage: #{stage}"
	
	chance = Pokemon::CRIT_STAGES[stage]
	
	#puts "(CHANCE) #{chance} || (NEED) #{max - chance} || (ROLL) #{rolled}"
	
	return (rolled >= (max - chance))
end

def move_caused_flinch?(source, move)
	return false if !["Bite", "Bone Club", "Headbutt", "Hyper Fang", "Rock Slide", "Rolling Kick", "Sky Attack", "Stomp", "Waterfall"].include? move.name
	
	flinch_max = 100
	
	rolled = Random.rand(flinch_max)
	
	# All of the above moves have a 15% chance to cause flinching
	return (rolled >= (flinch_max - 15))
end

# Calculate the damage done by a move to the source and target Pokemon
# http://bulbapedia.bulbagarden.net/wiki/Damage#Damage_formula
def calculate_damage(source, target, move)
	
	#puts "Calculating damage for #{move.name} against #{target.name}"
	
	# Special static-damage moves that don't have normal damage calculation
	return 40 if move.name == "Dragon Rage" # Always does 40 damage
	# Damage equal to the user's level
	return 100 if (move.name == "Night Shade" || move.name == "Seismic Toss") # Damage equal to the user's level
	return Random.rand(50..150) if move.name == "Psywave" # 50%-150% of the user's level
	return 20 if move.name == "Sonic Boom" # Always does 20 damage
	
	# If the move doesn't have a base power, it will do 0 damage
	if move.power.nil?
		return 0
	end
	
	# Critical hit check (crit increases)
	critical_hit = move_crit?(source, move)
	
	if critical_hit
		#puts "Critical hit!"
	end
	
	attack = move.physical? ? source.attack * Pokemon::STAGE_MULTIPLIERS[source.attack_stage] : source.special_attack * Pokemon::STAGE_MULTIPLIERS[source.special_attack_stage]
	defense = move.physical? ? target.defense * Pokemon::STAGE_MULTIPLIERS[source.defense_stage] : target.special_defense * Pokemon::STAGE_MULTIPLIERS[source.special_defense_stage]
	
	# level_calc = ((2 * pokemon_level) + 10) / 250.0
	# All pokemon are level 100, so the level_calc is always 0.84
	level_calc = 0.84
	stat_calc = attack.to_f / defense.to_f
	base = (source.status_effect == "s_burned" && move.physical?) ? (move.power / 2.0) : (move.power || 0)
	if target.using_move && ((target.using_move.name == "Dig" && move.name == "Earthquake") || (target.using_move.name == "Fly" && (move.name == "Gust" || move.name == "Thunder")))
		#puts "Target using DIG/FLY and source used EARTHQUAKE/GUST/THUNDER. Double base power applied"
		base = base * 2
	end
	damage = (level_calc * stat_calc * base) + 2
	
	
	stab = ((source.type_1 == move.type_1) || (source.type_2 == move.type_1)) ? 1.5 : 1
	type_1_effectiveness = type_1_effectiveness(source, target, move)
	type_2_effectiveness = type_2_effectiveness(source, target, move)
	type_effectiveness = type_1_effectiveness * (type_2_effectiveness || 1)
	crit_multiplier = critical_hit ? 2 : 1
	random = Random.rand(85..100) / 100.0
	modifier = stab * type_effectiveness * crit_multiplier * random
	
	total_damage = damage * modifier
	total_damage_rounded = total_damage.round
	
	#puts "Attack: #{attack}"
	#puts "Defense: #{defense}"
	#puts "Level calc: #{level_calc}"
	#puts "Stat calc: #{stat_calc}"
	#puts "Base: #{base}"
	#puts "Damage (before modifier): #{damage}"
	#puts "STAB: #{stab}"
	#puts "Type_1 effectiveness: #{type_1_effectiveness}"
	#puts "Type_2 effectiveness: #{type_2_effectiveness}"
	#puts "Crit multiplier: #{crit_multiplier}"
	#puts "Random % modifier: #{random}"
	#puts "Modifier: #{modifier}"
	#puts "Total damage: #{total_damage_rounded}"
	
	#puts "Hit for #{total_damage_rounded}"
	
	return total_damage_rounded
end

# Get the type effectiveness multiplier for a move vs target Pokemon
def type_1_effectiveness(source, target, move)
	ElementalType::TYPE_MULTIPLIERS[ElementalType.elemental_types[move.type_1]][ElementalType.elemental_types[target.type_1]]
end

# Get the type effectiveness multiplier for a move vs target Pokemon
def type_2_effectiveness(source, target, move)
	ElementalType::TYPE_MULTIPLIERS[ElementalType.elemental_types[move.type_1]][ElementalType.elemental_types[target.type_2]] if !target.type_2.nil?
end

# Overall type effectiveness for a Pokemon vs another
def type_effectiveness(source, target)
	
	multiplier = ElementalType::TYPE_MULTIPLIERS
	types = ElementalType.elemental_types

	type_1_v_1 = multiplier[types[source.type_1]][types[target.type_1]]
	type_1_v_2 = (multiplier[types[source.type_1]][types[target.type_2]] unless target.type_2.nil?) || 1
	type_2_v_1 = (multiplier[types[source.type_2]][types[target.type_1]] unless source.type_2.nil?) || 1
	type_2_v_2 = (multiplier[types[source.type_2]][types[target.type_2]] unless (source.type_2.nil? || target.type_2.nil?)) || 1
	
	#puts "#{source.name} (#{source.type_1}, #{source.type_2}) |vs| #{target.name} (#{target.type_1}, #{target.type_2})"
	#puts "#{type_1_v_1} || #{type_1_v_2} || #{type_2_v_1} || #{type_2_v_2}"
	stab_effectiveness = type_1_v_1 * type_1_v_2 * type_2_v_1 * type_2_v_2
end

def confusion_damage(source)
	
	attack = source.attack
	defense = source.defense
	
	level_calc = 0.84
	stat_calc = attack.to_f / defense.to_f
	base = (source.status_effect == "s_burned") ? 20 : 40
	damage = (level_calc * stat_calc * base) + 2
	
	random = Random.rand(85..100) / 100.0
	
	total_damage = (damage * random).round
end

# Calculate any status effect produced by using a move against a target Pokemon
# http://bulbapedia.bulbagarden.net/wiki/Status_move
def apply_status_effect?(source, target, move)
	
	#puts "Target: has status effect? #{target.has_status_effect} || effect: #{target.status_effect} || move: #{move.status_effect}"
	
	# A Pokemon can only have one status effect at a time (except Confusion)
	return false if target.has_status_effect

	# False if the move doesn't have a status effect
	#puts "Move has status effect? #{move.status_effect}"
	return false unless move.status_effect
	
	# Status effect application roll
	chance_max = 100
	rolled = Random.rand(chance_max)
	
	#puts "(CHANCE) #{move.status_effect_chance} || (NEED) #{chance_max - move.status_effect_chance} || (ROLL) #{rolled}"
	
	return (rolled >= (chance_max - move.status_effect_chance))
end

# Haze is a special move that resets all stat stages
def haze(source, target)
	source.attack_stage = 6
	source.defense_stage = 6
	source.special_attack_stage = 6
	source.special_defense_stage = 6
	source.speed_stage = 6
	source.crit_stage = 0
	
	target.attack_stage = 6
	target.defense_stage = 6
	target.special_attack_stage = 6
	target.special_defense_stage = 6
	target.speed_stage = 6
	target.crit_stage = 0
end