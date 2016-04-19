class Move < ActiveRecord::Base
	has_many :pokemon_moves
	has_many :pokemon, through: :pokemon_moves
	
	enum type_1: ElementalType.elemental_types
	
	enum category: { physical: 0, special: 1, status: 2, god: 3 }
	
	enum status_effect: StatusEffect.status_effects
	enum stat_type: StatType.stat_types
	
	attr_accessor :temporary_power
	attr_accessor :true_status_effect_chance
	attr_accessor :average_damage
	
	def temporary_power
		@temporary_power ||= self.power
	end
	
	def true_status_effect_chance
		@true_status_effect_chance ||= 0
	end
	
	def true_status_effect_chance=(value)
		@true_status_effect_chance = value
	end
	
	def average_damage
		@average_damage ||= 0
	end
	
	def average_damage=(value)
		@average_damage = value
	end
end
