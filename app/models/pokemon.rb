class Pokemon < ActiveRecord::Base
	has_many :pokemon_moves
	has_many :moves, through: :pokemon_moves
	
	enum type_1: ElementalType.elemental_types, _prefix: true
	enum type_2: ElementalType.elemental_types, _prefix: true
	
	attr_accessor :current_hp
	attr_accessor :has_status_effect
	enum status_effect: StatusEffect.status_effects
	attr_accessor :status_effect_duration
	attr_accessor :confused
	attr_accessor :confused_duration
	attr_accessor :using_move
	attr_accessor :charge
	attr_accessor :recharge
	attr_accessor :flinched
	
	# Crit chance is based on crit stage, which is modified by moves
	attr_accessor :crit_stage
	
	CRIT_STAGES = [6.25, 12.50, 25, 33.33, 50]
	
	# A Pokemon can have its stats in many stages throughout the battle
	# A Pokemon will multiply its base by the stage index during damage caluculation for a move
	# The default value will be 6, which is the normal multiplier
	attr_accessor :attack_stage
	attr_accessor :defense_stage
	attr_accessor :special_attack_stage
	attr_accessor :special_defense_stage
	attr_accessor :speed_stage
	
	attr_accessor :total_wins
	attr_accessor :win_ratio
	attr_accessor :average_damage_done
	attr_accessor :average_damage_taken
	
	attr_accessor :best_moves
	
	STAGE_MULTIPLIERS = [0.25, 0.28, 0.33, 0.40, 0.50, 0.66, 1, 1.50, 2, 2.50, 3, 3.50, 4]
	
	
	def current_hp
    	@current_hp ||= self.hp
	end
	
	def current_hp=(value)
    	@current_hp = value
    	@current_hp = self.hp if @current_hp > self.hp
    end
	
	def has_status_effect
    	@has_status_effect ||= false
	end
	
	def status_effect
		@status_effect
	end
	
	def status_effect=(value)
		@status_effect = value
	end
	
	def status_effect_duration
		@status_effect_duration ||= 0
	end
	
	def status_effect_duration=(value)
		@status_effect_duration = value
	end
	
	def confused
    	@confused ||= false
    end
    
    def confused=(value)
		@confused = value
	end
	
	def confused_duration
		@confused_duration ||= 0
	end
	
	def confused_duration=(value)
		@confused_duration = value
	end
	
	def charge
    	@charge ||= 0
	end
	
	def recharge
    	@recharge ||= 0
	end
	
	def flinched
    	@flinched ||= false
	end
    
    def crit_stage
    	@crit_stage ||= 0
    end
    
    def crit_stage=(value)
    	@crit_stage = value
    	@crit_stage = 4 if @crit_stage > 4
    end
    
    def attack_stage
    	@attack_stage ||= 6
    end
    
    def attack_stage=(value)
    	@attack_stage = value
    	@attack_stage = 12 if @attack_stage > 12
    	@attack_stage = 0 if @attack_stage < 0
    end
    
    def defense_stage
    	@defense_stage ||= 6
    end
    
    def defense_stage=(value)
    	@defense_stage = value
    	@defense_stage = 12 if @defense_stage > 12
    	@defense_stage = 0 if @defense_stage < 0
    end
    
    def special_attack_stage
    	@special_attack_stage ||= 6
    end
    
    def special_attack_stage=(value)
    	@special_attack_stage = value
    	@special_attack_stage = 12 if @special_attack_stage > 12
    	@special_attack_stage = 0 if @special_attack_stage < 0
    end
    
    def special_defense_stage
    	@special_defense_stage ||= 6
    end
    
    def special_defense_stage=(value)
    	@special_defense_stage = value
    	@special_defense_stage = 12 if @special_defense_stage > 12
    	@special_defense_stage = 0 if @special_defense_stage < 0
    end
    
    def speed_stage
    	@speed_stage ||= 6
    end
    
    def speed_stage=(value)
    	@speed_stage = value
    	@speed_stage = 12 if @speed_stage > 12
    	@speed_stage = 0 if @speed_stage < 0
    end
    
    def total_wins
    	@total_wins ||= 0
    end
    
    def total_wins=(value)
    	@total_wins = value
    end
    
    def win_ratio
    	@win_ratio ||= 0
    end
    
    def win_ratio=(value)
    	@win_ratio = value
    end
    
    def average_damage_done
    	@average_damage_done ||= 0
    end
    
    def average_damage_done=(value)
    	@average_damage_done = value
    end
    
    def average_damage_taken
    	@average_damage_taken ||= 0
    end
    
    def average_damage_taken=(value)
    	@average_damage_taken = value
    end
    
    def best_moves
    	@best_moves ||= []
    end
    
    def best_moves=(value)
    	@best_moves = value
    end
end
