extends GridObject
class_name Unit

var is_active = false
signal EndTurn

func _input(event):
	if is_active:
		if event.is_action_pressed("EndTurn"):
			emit_signal("EndTurn")
