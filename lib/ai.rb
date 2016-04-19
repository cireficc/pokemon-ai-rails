require_relative 'battle.rb'

all_pokemon = Pokemon.all

# Magikarp is literally useless. So is Ditto!
all_pokemon = all_pokemon.reject {|p| p.name == "Magikarp" || p.name == "Ditto" }

effective = Array.new
not_type_weak = Array.new

print "Enter a Pokemon's name of the first 150 Pokemon (Gen I): "

name = gets.chomp
enemy = Pokemon.find_by(name: name)

while (!enemy)
    print "Invalid Pokemon name. Enter the name of one of the first 150 Pokemon: "
    name = gets.chomp
    enemy = Pokemon.find_by(name: name)
end

# Select as a candidate any Pokemon whose STAB-type attacks would be super effective
    # or quadruple effective against the enemy. This greatly increases damage potential.
all_pokemon.each do |source|
    effectiveness = type_effectiveness(source, enemy)
    #puts "Effectiveness #{source.name} vs #{enemy.name}: #{effectiveness}"
    if effectiveness >= 1
        #puts "#{p.name} || Effectiveness #{effectiveness} against #{target.name}"
        effective.push(source)
    end
end

super_effective = effective.select { |p| type_effectiveness(p, enemy) >= 2 }

puts "No super effective Pokemon against #{enemy.name}" if super_effective.empty?

# For any Pokemon that is super effective against the target, only keep Pokemon that
# take half damage or less from STAB-type attacks from the enemy. This greatly increases
# survivability of potential Pokemon.
if super_effective.any?
    super_effective.each do |p|
        weakness = type_effectiveness(enemy, p)
        #puts "#{p.name} || Weakness #{weakness} against #{enemy.name}"
        if weakness <= 1
            #puts "#{p.name} || Weakness #{weakness} against #{enemy.name}"
            not_type_weak.push(p)
        end
    end
end

resistant = not_type_weak.select { |p| type_effectiveness(enemy, p) <= 0.5 }

#puts "No resistant Pokemon against #{enemy.name}. Using not_type_weak" if resistant.empty?

candidates = resistant.any? ? resistant : not_type_weak
puts "Candidates: #{candidates.length} -- these Pokemon can (most likely) kick #{enemy.name}'s ass in a fight\n\n"

# Select 4 moves: desired would be 2 STAB-type moves, 1 stat-change move and 1 status-effect move
# If selection of some moves fails (because a Pokemon doesn't have moves in (some) of those categories),
# fill in the rest randomly from the Pokemon's pool.
def select_moves(source, target)
    
    source.moves = source.moves.reject {|m| m.category == "god" }
    
    # puts "Selecting moves for #{source.name} vs #{target.name}"
    
    selected_moves = Array.new
    
    # Select 2 STAB damaging moves as they will do the most damage
    same_type_damage_moves = source.moves.select { |m| ((source.type_1 == m.type_1 || source.type_2 == m.type_1) && m.power) }
    
    if same_type_damage_moves.any?
        
        same_type_damage_moves.each do |m|
            total_damage = 0
            100.times do |i|
                total_damage = total_damage + calculate_damage(source, target, m)
            end
            m.average_damage = ((total_damage / 100.0) * (m.accuracy / 100.0)).round
            #puts "#{source.name} used #{m.name} for an average of #{m.average_damage} damage"
        end
    
        same_type_damage_moves.sort! { |x, y| x.average_damage <=> y.average_damage }
        same_type_damage_moves.reverse!
        
        # same_type_damage_moves.each do |m|
        #     puts "#{m.name} --> avg damage = #{m.average_damage}"
        # end
        
        selected_moves.push(same_type_damage_moves[0]) unless same_type_damage_moves[0].nil?
        selected_moves.push(same_type_damage_moves[1]) unless same_type_damage_moves[1].nil?
    end
    
    # Select 1 stat change move: use the highest stage change value move because
    # it will be the most effective
    stat_change_moves = source.moves.select { |m| m.stage_change && m.stat_type != "speed" }
    
    if stat_change_moves.any?
        stat_change_moves.sort! { |x, y| x.stage_change <=> y.stage_change }
        stat_change_moves.reverse!
    end
    
    # stat_change_moves.each do |m|
    #     puts "#{m.name} --> #{m.stage_change}"
    # end
    
    already_selected = selected_moves.include? stat_change_moves[0]
    selected_moves.push(stat_change_moves[0]) unless stat_change_moves[0].nil? || already_selected
    
    status_effect_moves = source.moves.select { |m| m.status_effect }
    
    if status_effect_moves.any?
        
        status_effect_moves.each do |m|
            true_status_effect_chance = (m.accuracy / 100.0) * (m.status_effect_chance / 100.0)
            m.true_status_effect_chance = true_status_effect_chance
        end
        status_effect_moves.sort! { |x, y| x.true_status_effect_chance <=> y.true_status_effect_chance }
        status_effect_moves.reverse!
    end
    
    # status_effect_moves.each do |m|
    #     puts "#{m.name} --> #{m.status_effect} || #{m.true_status_effect_chance}"
    # end
    
    already_selected = selected_moves.include? status_effect_moves[0]
    selected_moves.push(status_effect_moves[0]) unless status_effect_moves[0].nil? || already_selected
    
    # puts "SELECTED MOVES: #{selected_moves.length}"
    
    while selected_moves.length < 4
        random_move = source.moves.sample
        selected_moves.push(random_move) unless selected_moves.include? random_move
    end
    
    # puts "SELECTED MOVES AFTER RANDOM: #{selected_moves.length}"
    
    # selected_moves.each do |m|
    #     puts "#{source.name} selected: #{m.name}"
    # end
    
    return selected_moves
end

puts "Running simulations..."

candidates.each do |p|
    total_damage_done = 0
    total_damage_taken = 0
    max_difference = 0
    total_wins = 0
    best_moves = []
    selected_moves = select_moves(p, enemy)
    # Simulate 25 battles to get some statistics to use in candidate selection
    iterations = 25
    iterations.times do |i|
        battle_stats = pokemon_battle(p, enemy, selected_moves, nil)
        total_damage_done = total_damage_done + battle_stats[:source_damage_done]
        total_damage_taken = total_damage_taken + battle_stats[:target_damage_done]
        damage_difference = battle_stats[:source_damage_done] - battle_stats[:target_damage_done]
        if (damage_difference > max_difference)
            max_differece = damage_difference
            best_moves = selected_moves
        end
        total_wins = total_wins + 1 if battle_stats[:winner] == "source"
        p.reload
        enemy.reload
    end
    
    p.total_wins = total_wins
    p.win_ratio = p.total_wins / iterations.to_f
    p.average_damage_done = (total_damage_done / iterations.to_f).round
    p.average_damage_taken = (total_damage_taken / iterations.to_f).round
    p.best_moves = best_moves
    
    #puts "#{p.name}: WIN RATIO: #{(p.win_ratio * 100).round(2)} || AVG DMG DONE: #{p.average_damage_done} || AVG DMG TAKEN: #{p.average_damage_taken}"
end

# Sort the candidates by the highest win ratio, then highest average damage done, then lowest average damage taken
candidates.sort_by! { |c| [c.win_ratio, c.average_damage_done, (1000 - c.average_damage_taken)]}
candidates.reverse!

puts "\n\n"
candidates.each do |p|
    puts "#{p.name} vs #{enemy.name}: #{p.name} won #{(p.win_ratio * 100).round(2)}% of battles doing an average of #{p.average_damage_done} damage and taking #{p.average_damage_taken} damage"
end

puts "\n\n#{candidates[0].name} is the best candidate Pokemon to beat #{enemy.name}"
puts "The following moves were the most effective:"
candidates[0].best_moves.each do|m|
    puts "--#{m.name}"
end