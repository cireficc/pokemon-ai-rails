class StatType < ActiveRecord::Base
	self.abstract_class = true
	
	# Pokemon stat categories
	enum stat_type: {
		hp: 0,
		attack: 1,
		defense: 2,
		special_attack: 3,
		special_defense: 4,
		speed: 5,
		crit: 6
	}
end