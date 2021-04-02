extends Node2D


var grid = []
var units := []
var current_unit
onready var magma = $PathBlocked
onready var path = $Path
onready var camera = $TestCamera
var astar := AStar2D.new()



func calculate_point_path(start: Vector2, end: Vector2) -> PoolVector2Array:
	# With the AStar algorithm, we have to use the points' indices to get a path. This is why we
	# need a reliable way to calculate an index given some input coordinates.
	# Our Grid.as_index() method does just that.
	if start.x < 0 || start.y < 0 || end.x < 0 || end.y < 0:
		return PoolVector2Array()
	var start_index: int = cell_int_index(start)
	var end_index: int = cell_int_index(end)
	# We just ensure that the AStar graph has both points defined. If not, we return an empty
	# PoolVector2Array() to avoid errors.
	if astar.has_point(start_index) and astar.has_point(end_index):
		# The AStar2D object then finds the best path between the two indices.
		return astar.get_point_path(start_index, end_index)
	else:
		return PoolVector2Array()


func draw_path(points):
	path.clear()
	
#	for point in points:
#		path.set_cellv(point,0)
		
	var line_points = points
	var l2d = path.get_node("Line2D")
	
	for i in line_points.size():
		line_points[i] = line_points[i] * MainCombatDemo.cell_size + MainCombatDemo.half_cell
	l2d.points = line_points

func _input(event):
		if event.is_action_pressed("EndTurn"):
			end_turn()

func _unhandled_input(event):
	var click_coordinates = get_global_mouse_position()
	if event is InputEventMouseMotion:
		var start_point  = (current_unit.position/ MainCombatDemo.cell_size).floor()
		var destination_point  = (click_coordinates/ MainCombatDemo.cell_size).floor()
		var points = calculate_point_path(start_point, destination_point)
		draw_path(points)
		
	if event.is_action_pressed("LMB"):
		pass
		current_unit.move_object(click_coordinates)
		

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

# for use wtith a*
func cell_int_index(vector: Vector2)->int:
	return vector.y + vector.x * grid[0].size()
	
	
func _add_and_connect_points() -> void:
# First, we register all our points in the AStar graph.
	for i in grid.size():
		for j in grid[0].size():
			var point = Vector2(i,j)
			astar.add_point(cell_int_index(point), point)

# Then, we loop over the points again, and we connect points if their cells don't have magma.
	for i in grid.size():
		for j in grid[0].size():
			var point = Vector2(i,j)
			var neighbouring_points = [
				point + Vector2.UP,
				point + Vector2.DOWN,
				point + Vector2.LEFT,
				point + Vector2.RIGHT,
				
				point + Vector2.UP + Vector2.LEFT,
				point + Vector2.UP + Vector2.RIGHT,
				point + Vector2.DOWN + Vector2.LEFT,
				point + Vector2.DOWN + Vector2.RIGHT,
				]
			if !grid[point.x][point.y].is_magma:
				for p in neighbouring_points:
					var upper_threshold = p.x < grid.size() && p.y < grid[0].size()
					var lower_threshold = p.x >= 0 && p.y >= 0
					if upper_threshold && lower_threshold:
						if !grid[p.x][p.y].is_magma:
							astar.connect_points(cell_int_index(point), cell_int_index(p))


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
	
	_add_and_connect_points()
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
