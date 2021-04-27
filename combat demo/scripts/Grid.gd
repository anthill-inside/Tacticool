class_name Grid
#cells contains array of coordinates of the changed cells
signal CellsChanged(cells)
var height
var width
var cells = []

#cell of the selected unit
var current_cell : Cell


# Called when the node enters the scene tree for the first time.
func _init():
	height = MainCombatDemo.map_size.y
	width = MainCombatDemo.map_size.x
	for x in range(width):
		cells.append([])
		for y in range(height):
			var cell = Cell.new()
			cell.coordinates = Vector2(x, y)
			cells[x].append(cell)
			
			
func  ObjectMoved(start_cell,new_cell, obj):
	print("1")
	cells[start_cell.x][start_cell.y].pieces.erase(obj)
	cells[new_cell.x][new_cell.y].pieces.append(obj)
	emit_signal("CellsChanged",[start_cell,new_cell])

func LeaveCell(cell, obj):
	cells[cell.x][cell.y].pieces.erase(obj)
	emit_signal("CellsChanged",[cell])
	
func EnterCell(cell, obj):
	cells[cell.x][cell.y].pieces.append(obj)
	if obj.is_active:
		set_cell_active(cell)
#		if obj is Unit:
#			obj.current_ap -= 1
	emit_signal("CellsChanged",[cell])

func remove_object(cell, obj):
	cells[cell.x][cell.y].pieces.erase(obj)
	emit_signal("CellsChanged",[cell])

func set_cell_active(cell:Vector2)->void:
	var cell_array := [cell]
	if current_cell:
		cell_array.append(current_cell.coordinates)
	current_cell = cells[cell.x][cell.y]
	
	emit_signal("CellsChanged",cell_array)
func print_cells_with_pieces():
	for column in cells:
		for cell in column:
			if cell.pieces:
				print("cell [" + str(cells.find(column)) + "]"
				+ "[" + str(column.find(cell)) + "]"
				+ str(cell.pieces)
				)
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
