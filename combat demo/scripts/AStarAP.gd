class_name AStarAP
extends AStar2D


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

func add_and_connect_points(grid) -> void:
# First, we register all our points in the AStar graph.
	for i in grid.size():
		for j in grid[0].size():
			var point = Vector2(i,j)
			add_point(get_point_id(point), point)

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
							connect_points(get_point_id(point), get_point_id(p))




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
	return new_data

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
