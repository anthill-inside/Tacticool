extends Node2D


var grid = []
var units := []
var current_unit
onready var magma = $Terrain/Magma



func _input(event):
		if event.is_action_pressed("EndTurn"):
			end_turn()

func _unhandled_input(event):
	if event.is_action_pressed("LMB"):
		current_unit.move_object(get_viewport().get_mouse_position())
		print_cells_with_pieces()


func new_current_unit(number:int):
	if current_unit:
		current_unit.end_turn()
	current_unit = units[number]
	current_unit.start_turn()


func end_turn():
	var unit_number : = units.find(current_unit)
	if unit_number > -1:
		if not (current_unit == units[-1]):
			new_current_unit(unit_number + 1)
		else:
			new_current_unit(0)
	else:
		new_current_unit(0)


func _ready():
	var height = MainCombatDemo.map_size.y
	var width = MainCombatDemo.map_size.x
	for x in range(width):
		grid.append([])
		for y in range(height):
			var is_magma
			if magma.get_cell(x,y) != -1:
				is_magma = false
			else:
				is_magma = true
			var cell = {
				"is_magma" : is_magma,
				"pieces" : [],
			}
			grid[x].append(cell)
			
	for candidate in $stuff.get_children():
		if candidate is Unit:
			units.append(candidate)
			candidate.connect("EndTurn", self, "end_turn")
		if candidate is GridObject:	
			var cell = candidate.my_cell
			grid[cell.x][cell.y].pieces.append(candidate)
			candidate.connect("ObjectMoved", self, "ObjectMoved")
	
	new_current_unit(0)
	
	print_cells_with_pieces()
	
	
func  ObjectMoved(start_cell,new_cell, obj):
	grid[start_cell.x][start_cell.y].pieces.erase(obj)
	grid[new_cell.x][new_cell.y].pieces.append(obj)
	pass


func print_cells_with_pieces():
	for column in grid:
		for cell in column:
			if cell.pieces:
				print("cell [" + str(grid.find(column)) + "]"
				+ "[" + str(column.find(cell)) + "]"
				+ str(cell.pieces)
				)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
