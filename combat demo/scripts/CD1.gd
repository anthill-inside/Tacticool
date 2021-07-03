extends Node2D


var grid = Grid.new()
var units := []
var current_unit : Unit
onready var magma = $PathBlocked
onready var path = $Path
onready var camera = $TestCamera
var astar := AStarAP.new()

onready var UI = $UI

var control_blocked = false

func block_control():
	control_blocked = true
func allow_control():
	control_blocked = false


func _input(event):
		if event.is_action_pressed("EndTurn") && !current_unit.state_machine.state_queue && current_unit.state_machine.state.name == "Idle":
			end_turn()
		if event.is_action_pressed("ReloadLevel"):
			get_tree().reload_current_scene()

func _unhandled_input(event):
	if event.is_action_pressed("LMB") and  !control_blocked :
		var click_coordinates = get_global_mouse_position()
		var start_point  = current_unit.grid_coordinates
		var destination_point  = (click_coordinates/ MainCombatDemo.cell_size).floor()
		
		var target_cell = grid.cells[destination_point.x][destination_point.y]
		var target  = null
		
		for piece in target_cell.pieces:
			if not piece.get("current_health") == null:
				target = piece
				if target == current_unit:
					return
				
				var path_data = approach_point(start_point, destination_point)
				
				var ap_left = current_unit.current_ap - path_data.total_cost
				if ap_left >= current_unit.attack.cost:
					current_unit.state_machine.push_state("Attack", {
						"damage": current_unit.attack.damage, 
						"cost": current_unit.attack.cost,
						"target": target})
				
				return
		move_to_point(start_point, destination_point)

#builds path to a closest cell adjacent to a destination point if there is any
func approach_point(start_point: Vector2, destination_point: Vector2):
	var path_data = get_path_data_to_closest_adjacent_point(start_point, destination_point)
	if path_data:
		path_to_state_queue(path_data)
	return path_data
	
func move_to_point(start_point: Vector2, destination_point: Vector2):
	
	
	var path_data := astar.get_path_data(start_point, destination_point, current_unit.current_ap)
	path_to_state_queue(path_data)
	return path_data
	
func path_to_state_queue(path_data:PathData):
	if path_data.last_reachable >= 0:
		var way_points = AStarAP.ids_to_world_coordinates(path_data.reachable_points)
		if current_unit.state_machine.state_queue:
			current_unit.state_machine.clear_state_queue()
		for point in way_points:
			current_unit.state_machine.push_state("Walk", {"path": [point]})



func new_current_unit(number:int):
	if current_unit:
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
		
	current_unit.current_ap = current_unit.max_ap

func kill_unit(grid_coordinates, obj):
	units.erase(obj)
	grid.remove_object(grid_coordinates, obj)

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
			candidate.connect("Dead", self, "kill_unit")
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
	draw_path()
	highlight_current()
	var up = astar.get_unreachable_points()
	for p in up:
		path.set_cellv(p, 3)
	
	UI.ap.text = str(current_unit.current_ap)
	
func highlight_current():
	for column in grid.cells:
		path.set_cellv(grid.current_cell.coordinates, 2)


func draw_path():
	var start_point  = current_unit.grid_coordinates
	var destination_point  = (get_global_mouse_position()/ MainCombatDemo.cell_size).floor()
	
	if grid.validate_point(destination_point):
		var target_cell = grid.cells[destination_point.x][destination_point.y]
		var target  = null
		
		for piece in target_cell.pieces:
			if not piece.get("current_health") == null:
				target = piece
				if target == current_unit:
					return
				var path_data = get_path_data_to_closest_adjacent_point(start_point, destination_point)
				if path_data:
					var reachable_cells = path_data.reachable_points
					var unreachable_cells = path_data.unreachable_points
					if current_unit.current_ap - path_data.last_reachable_cost >= current_unit.attack.cost:
						id_draw_attack_path(reachable_cells, unreachable_cells, path_data.last_reachable, destination_point)
					else:
						id_draw_path(reachable_cells, unreachable_cells)
					return
				
		
		
		
		var path_data := astar.get_path_data(start_point, destination_point, current_unit.current_ap)
		var reachable_cells = path_data.reachable_points
		var unreachable_cells = path_data.unreachable_points
		id_draw_path(reachable_cells, unreachable_cells)
	
#func draw_path(points):
#	path.clear()
#
##	for point in points:
##		path.set_cellv(point,0)
#
#	var line_points = points
#	var l2d = path.get_node("Line2D")
#
#	for i in line_points.size():
#		line_points[i] = line_points[i] * MainCombatDemo.cell_size + MainCombatDemo.half_cell
#	l2d.points = line_points
	
func id_draw_path(ids, unreachable = null):
	path.clear()
	
	for id in ids:
		var coordinates = astar.get_point_position(id)
		path.set_cellv(coordinates,0)
	
	if unreachable:
		for id in unreachable:
			var coordinates = astar.get_point_position(id)
			path.set_cellv(coordinates,1)

func id_draw_attack_path(ids, unreachable = null, last_reachable = 0, target = Vector2(0,0)):
	path.clear()
	var eop = astar.get_point_position(last_reachable)
	if ids:
		for id in ids:
			var coordinates = astar.get_point_position(id)
			if id  == ids[-1]:
				eop = coordinates
			path.set_cellv(coordinates,0)
		
	var tile_shift = 0
	if unreachable:
		tile_shift = 8
		for id in unreachable:
			var coordinates = astar.get_point_position(id)
			
			if id  == unreachable[-1]:
				eop = coordinates
			path.set_cellv(coordinates,1)
			
	
	match (target - eop) * Vector2(-1,1):
		Vector2.RIGHT:
			path.set_cellv(eop,9 + tile_shift)
		Vector2.UP:
			path.set_cellv(eop,8 + tile_shift)
		Vector2.DOWN:
			path.set_cellv(eop,10 + tile_shift)
		Vector2.LEFT:
			path.set_cellv(eop,11 + tile_shift)
		Vector2.UP + Vector2.LEFT:
			path.set_cellv(eop,7 + tile_shift)
		Vector2.UP + Vector2.RIGHT:
			path.set_cellv(eop,4 + tile_shift)
		Vector2.DOWN + Vector2.LEFT:
			path.set_cellv(eop,6 + tile_shift)
		Vector2.DOWN + Vector2.RIGHT:
			path.set_cellv(eop,5 + tile_shift)
	




func get_path_data_to_closest_adjacent_point(start_point: Vector2, destination_point: Vector2):
	var neighbour_points = [
				destination_point + Vector2.UP,
				destination_point + Vector2.DOWN,
				destination_point + Vector2.LEFT,
				destination_point + Vector2.RIGHT,
				
				destination_point + Vector2.UP + Vector2.LEFT,
				destination_point + Vector2.UP + Vector2.RIGHT,
				destination_point + Vector2.DOWN + Vector2.LEFT,
				destination_point + Vector2.DOWN + Vector2.RIGHT,
				]
	var target_cell = grid.cells[destination_point.x][destination_point.y]
	#if target_cell:# probably don't need that line
	var paths = []
	for point in neighbour_points:
		paths.append(astar.get_path_data(start_point, point, current_unit.current_ap))
		
	var valid_paths = []
	for p in paths:
		if p.last_reachable >= 0:
			valid_paths.append(p)
	var old_paths = paths
	paths = valid_paths
	if !paths:
		return
		
	var min_distance = paths[0].total_cost
	var index = 0
	for i in paths.size() :
		var tc = paths[i].total_cost
		if tc < min_distance:
			min_distance = paths[i].total_cost
			index = i
	var path_data = paths[index]
	
	return path_data







# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
