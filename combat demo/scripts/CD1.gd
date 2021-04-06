extends Node2D


var grid = []
var units := []
var current_unit
onready var magma = $PathBlocked
onready var path = $Path
onready var camera = $TestCamera
var astar := AStarAP.new()





func draw_path(points):
	path.clear()
	
#	for point in points:
#		path.set_cellv(point,0)
		
	var line_points = points
	var l2d = path.get_node("Line2D")
	
	for i in line_points.size():
		line_points[i] = line_points[i] * MainCombatDemo.cell_size + MainCombatDemo.half_cell
	l2d.points = line_points
	
func id_draw_path(ids, unreachable = null):
	path.clear()
	
	for id in ids:
		var coordinates = astar.get_point_position(id)
		path.set_cellv(coordinates,0)
	
	if unreachable != null:
		for id in unreachable:
			var coordinates = astar.get_point_position(id)
			path.set_cellv(coordinates,1)

func _input(event):
		if event.is_action_pressed("EndTurn"):
			end_turn()

func _unhandled_input(event):
	var click_coordinates = get_global_mouse_position()
	var start_point  = (current_unit.position/ MainCombatDemo.cell_size).floor()
	var destination_point  = (click_coordinates/ MainCombatDemo.cell_size).floor()
	var ap_limit = 5
	
	if event is InputEventMouseMotion:
		var path_data := astar.get_path_data(start_point, destination_point, ap_limit)
		var reachable_cells = path_data.reachable_points
		var unreachable_cells = path_data.unreachable_points
		id_draw_path(reachable_cells, unreachable_cells)
	
	if event.is_action_pressed("LMB"):
		var path_data := astar.get_path_data(start_point, destination_point, ap_limit)
		if path_data.last_reachable >= 0:
			var way_points = AStarAP.ids_to_world_coordinates(path_data.reachable_points)
			current_unit.start_walking(way_points)
			yield(current_unit,"StoppedWalking")
#			var cell_coordinates = astar.get_point_position(path_data.last_reachable) * MainCombatDemo.cell_size
#			current_unit.move_object(cell_coordinates)
		

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
				is_magma = true
			else:
				is_magma = false
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
	
	astar.add_and_connect_points(grid)
	new_current_unit(0)
	
	
	
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
