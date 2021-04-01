extends Node2D

var units := []
var current_unit
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
func new_current_unit(number:int):
	if current_unit:
		current_unit.deselect()
		current_unit.is_active = false
	current_unit = units[number]
	current_unit.select()
	current_unit.is_active = true
	
	
func end_turn():
	var unit_number : = units.find(current_unit)
	if unit_number > -1:
		if not (current_unit == units[-1]):
			new_current_unit(unit_number + 1)
		else:
			new_current_unit(0)
	else:
		new_current_unit(0)
		
	unit_number = units.find(current_unit)
	print(unit_number)
	


func _ready():
	for candidate in $stuff/units.get_children():
		if candidate is Unit:
			units.append(candidate)
			candidate.connect("EndTurn", self, "end_turn")
	new_current_unit(0)
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
