class_name AStarAP
extends AStar2D

var grid : Grid

static func ids_to_positions(ids: PoolIntArray)-> PoolVector2Array:
	var points : PoolVector2Array = []
	for i in ids.size():
		var point = Vector2.ZERO
		point.y = ids[i] % int(MainCombatDemo.map_size.y)
		point.x = floor(ids[i] / MainCombatDemo.map_size.y)
		points.append(point)
	return points

static func ids_to_world_coordinates(ids: PoolIntArray)-> PoolVector2Array:
	var points : PoolVector2Array = []
	for i in ids.size():
		var point = Vector2.ZERO
		point.y = ids[i] % int(MainCombatDemo.map_size.y)
		point.x = floor(ids[i] / MainCombatDemo.map_size.y)
		point *= MainCombatDemo.cell_size
		point += MainCombatDemo.half_cell
		points.append(point)
	return points
func get_point_id(vector: Vector2)->int:
	return vector.y + vector.x * MainCombatDemo.map_size.y


func calculate_id_path(start: Vector2, end: Vector2) -> PoolIntArray:
	if start.x < 0 || start.y < 0 || end.x < 0 || end.y < 0:
		return PoolIntArray()
		
	var start_index: int = get_point_id(start)
	var end_index: int = get_point_id(end)
	if has_point(start_index) and has_point(end_index):
		return get_id_path(start_index, end_index)
	else:
		return PoolIntArray()

func add_and_connect_points() -> void:
# First, we register all our points in the AStar graph.
	for i in grid.width:
		for j in grid.height:
			var point = Vector2(i,j)
			add_point(get_point_id(point), point)
	update_graph()

func update_graph(cells = []) -> void:
	var start_x= 0
	var start_y= 0
	var end_x = grid.width
	var end_y = grid.height
	
	if cells:
		var left_cell = cells[0]
		var right_cell = cells[0]
		var bottom_cell = cells[0]
		var top_cell = cells[0]
		
		for cell in cells:
			if cell.x < left_cell.x: left_cell = cell
			if cell.x > right_cell.x: right_cell = cell
			if cell.y < top_cell.y: top_cell = cell
			if cell.y > left_cell.y: bottom_cell = cell
		
		start_x = left_cell.x
		start_y = top_cell.y
		end_x = right_cell.x + 1
		end_y = bottom_cell.y + 1
	
	
	disconect_all_points(start_x, start_y, end_x, end_y)
	
#	for i in range(start_x, end_x):
#		for j in range(start_y, end_y):
	for i in grid.width:
		for j in grid.height:
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
			
			if validate_point(point):
				for p in neighbouring_points:
					var upper_threshold = p.x < grid.width && p.y < grid.height
					var lower_threshold = p.x >= 0 && p.y >= 0
					if upper_threshold && lower_threshold:
						if validate_point(p):
							connect_points(get_point_id(point), get_point_id(p))

func disconect_all_points(start_x, start_y, end_x, end_y)->void:
#	for i in grid.width:
#		for j in grid.height:
	for i in range(start_x, end_x):
		for j in range(start_y, end_y):
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
			for p in neighbouring_points:
				var upper_threshold = p.x < grid.width && p.y < grid.height
				var lower_threshold = p.x >= 0 && p.y >= 0
				if upper_threshold && lower_threshold:
					disconnect_points(get_point_id(point), get_point_id(p))
#gotta make that one virtual
func validate_point(point:Vector2)->bool:
	var cell_is_valid = !grid.cells[point.x][point.y].is_magma
	if cell_is_valid:
		for piece in grid.cells[point.x][point.y].pieces:
			if piece is GridObject:
				cell_is_valid = false
	if grid.cells[point.x][point.y] == grid.current_cell:
		cell_is_valid = true
	return cell_is_valid

func get_unreachable_points():
	var unreachable_points = []
	for i in grid.width:
		for j in grid.height:
			var point_is_reachable = false
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
			for p in neighbouring_points:
				var upper_threshold = p.x < grid.width && p.y < grid.height
				var lower_threshold = p.x >= 0 && p.y >= 0
				if upper_threshold && lower_threshold:
					if (are_points_connected (get_point_id(point), get_point_id(p))):
						point_is_reachable = true
			if not point_is_reachable:
				unreachable_points.append(point)
	return unreachable_points
func get_path_data (start_point: Vector2, destination_point: Vector2, ap_limit: int)->PathData:

	var new_data = PathData.new()
	var all_cells = calculate_id_path(start_point,destination_point)
	var reachable_cells = []
	var unreachable_cells = []
	var ap_counter = 0
	var ap_counter_total = 0
	
	for i in all_cells.size():
		var ap_cost = get_point_weight_scale(all_cells[i])
		if i != 0:
			if ap_counter + ap_cost > ap_limit:
				unreachable_cells.append(all_cells[i])
				ap_counter_total += ap_cost
			else:
				reachable_cells.append(all_cells[i])
				ap_counter += ap_cost
				ap_counter_total += ap_cost
#		else:
#			reachable_cells.append(all_cells[i])
				
	new_data.all_points = all_cells
	new_data.reachable_points = reachable_cells
	new_data.unreachable_points = unreachable_cells
	new_data.total_cost = ap_counter_total
	new_data.last_reachable_cost = ap_counter
	new_data.last_reachable = reachable_cells[-1] if reachable_cells else -1
	if  start_point == destination_point:
		new_data.last_reachable = all_cells[0]
	if unreachable_cells:
		new_data.last_reachable = all_cells[0]
	return new_data

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
