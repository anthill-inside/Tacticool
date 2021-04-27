extends Node2D


var grid = Grid.new()
var units := []
var current_unit : Unit
onready var magma = $PathBlocked
onready var path = $Path
onready var camera = $TestCamera
var astar := AStarAP.new()

onready var UI = $UI


func _input(event):
		if event.is_action_pressed("EndTurn"):
			end_turn()

func _unhandled_input(event):
	if event.is_action_pressed("LMB"):
		var click_coordinates = get_global_mouse_position()
		var start_point  = current_unit.grid_coordinates
		var destination_point  = (click_coordinates/ MainCombatDemo.cell_size).floor()
		
		var target_cell = grid.cells[destination_point.x][destination_point.y]
		var target  = null
		var neighbour_points = [
				target_cell.coordinates + Vector2.UP,
				target_cell.coordinates + Vector2.DOWN,
				target_cell.coordinates + Vector2.LEFT,
				target_cell.coordinates + Vector2.RIGHT,
				
				target_cell.coordinates + Vector2.UP + Vector2.LEFT,
				target_cell.coordinates + Vector2.UP + Vector2.RIGHT,
				target_cell.coordinates + Vector2.DOWN + Vector2.LEFT,
				target_cell.coordinates + Vector2.DOWN + Vector2.RIGHT,
				]
		
		
		if target_cell:
			for piece in target_cell.pieces:
				if not piece.get("current_health") == null:
					target = piece
					var paths = []
					for point in neighbour_points:
						paths.append(astar.get_path_data(start_point, point, current_unit.current_ap))
						
					var valid_paths = []
					for p in paths:
						if p.last_reachable >= 0:
							valid_paths.append(p)
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
					###############
					if path_data.last_reachable >= 0:
						var way_points = AStarAP.ids_to_world_coordinates(path_data.reachable_points)
						if current_unit.state_machine.state_queue:
							current_unit.state_machine.clear_state_queue()
						for point in way_points:
							current_unit.state_machine.push_state("Walk", {"path": [point]})
							
						var ap_left = current_unit.current_ap - path_data.total_cost
						if ap_left >= current_unit.attack.cost:
							current_unit.state_machine.push_state("Attack", {
								"damage": current_unit.attack.damage, 
								"cost": current_unit.attack.cost,
								"target": target})
								
						#current_unit.state_machine.transition_next()
					#################
					
					return
		build_state_queue(start_point, destination_point)


func build_state_queue(start_point: Vector2, destination_point: Vector2):
	var path_data := astar.get_path_data(start_point, destination_point, current_unit.current_ap)
	if path_data.last_reachable >= 0:
		var way_points = AStarAP.ids_to_world_coordinates(path_data.reachable_points)
		if current_unit.state_machine.state_queue:
			current_unit.state_machine.clear_state_queue()
		for point in way_points:
			current_unit.state_machine.push_state("Walk", {"path": [point]})
		#current_unit.state_machine.transition_next()

func new_current_unit(number:int):
	if current_unit:
		current_unit.end_turn()
	current_unit = units[number]
	grid.set_cell_active(current_unit.grid_coordinates)
	current_unit.start_turn()


func end_turn():
	current_unit.current_ap = current_unit.max_ap
	
	var unit_number : = units.find(current_unit)
	if unit_number > -1:
		if not (current_unit == units[-1]):
			new_current_unit(unit_number + 1)
		else:
			new_current_unit(0)
	else:
		new_current_unit(0)

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
	
	if unreachable != null:
		for id in unreachable:
			var coordinates = astar.get_point_position(id)
			path.set_cellv(coordinates,1)




# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
