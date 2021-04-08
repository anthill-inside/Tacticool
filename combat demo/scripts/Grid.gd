class_name Grid
#cells contains array of coordinates of the changed cells
signal CellsChanged(cells)
var height
var width
var cells = []

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
	cells[cell.x][cell.y].selected = false
	emit_signal("CellsChanged",[cell])
	
func EnterCell(cell, obj):
	cells[cell.x][cell.y].pieces.append(obj)
	if obj.is_active:
		cells[cell.x][cell.y].selected = true
	emit_signal("CellsChanged",[cell])

func set_cell_active(cell:Vector2, value := true)->void:
	cells[cell.x][cell.y].selected = value
	emit_signal("CellsChanged",[cell])
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
