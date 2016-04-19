class StatusEffect < ActiveRecord::Base
	self.abstract_class = true
	
	# Status effects applied by moves to Pokemon
	enum status_effect: {
		s_burned: 0,
		s_confused: 1,
		s_frozen: 2,
		s_paralyzed: 3,
		s_poisoned: 4,
		s_sleeping: 5
	}
end