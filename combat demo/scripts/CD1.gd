extends Node2D


var grid = Grid.new()
var units := []
var current_unit : Unit
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
	var start_point  = current_unit.grid_coordinates
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
			yield(current_unit,"StoppedMoving")
#			var cell_coordinates = astar.get_point_position(path_data.last_reachable) * MainCombatDemo.cell_size
#			current_unit.move_object(cell_coordinates)
		

func new_current_unit(number:int):
	if current_unit:
		grid.set_cell_active(current_unit.grid_coordinates, false)
		current_unit.end_turn()
	current_unit = units[number]
	grid.set_cell_active(current_unit.grid_coordinates)
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
	var height = grid.height
	var width = grid.width
	
	for x in range(width):
		for y in range(height):
			var is_magma
			if magma.get_cell(x,y) != -1:
				is_magma = true
			else:
				is_magma = false
			grid.cells[x][y].is_magma = is_magma
			
	for candidate in $stuff.get_children():
		if candidate is Unit:
			units.append(candidate)
			candidate.connect("EndTurn", self, "end_turn")
			candidate.connect("StoppedMoving", grid, "EnterCell")
			candidate.connect("StartedMoving", grid, "LeaveCell")
		if candidate is GridObject:	
			var cell = candidate.grid_coordinates
			grid.cells[cell.x][cell.y].pieces.append(candidate)
			candidate.connect("ObjectMoved", grid, "ObjectMoved")
	
	new_current_unit(0)
	astar.grid = grid
	astar.add_and_connect_points()
	grid.connect("CellsChanged", astar, "update_graph")
	
	
func _process(delta):
	highlight_current()
	var up = astar.get_unreachable_points()
	for p in up:
		path.set_cellv(p, 3)
	
	
func highlight_current():
	for column in grid.cells:
		for cell in column:
			if cell.selected:
				path.set_cellv(cell.coordinates, 2)





# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
