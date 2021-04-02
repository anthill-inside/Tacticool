extends GridObject
class_name Unit

var is_active = false
signal EndTurn
signal StartTurn

func end_turn():
	deselect()
	is_active = false

func start_turn():	
	select()
	is_active = true



