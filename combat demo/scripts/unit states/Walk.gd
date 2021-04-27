extends UnitState



var path : PoolVector2Array
var path_index := 0
var velocity := Vector2.ZERO

var unit : Unit


func handle_input(_event: InputEvent) -> void:
	pass

func update(_delta: float) -> void:
	if !path:
		return
	var target = path[path_index]
	if unit.position.distance_to(target) < velocity.length() :
		path_index += 1
		if path_index == path.size():
			state_machine.transition_next()
			return
		target = path[path_index]
	velocity = (target - unit.position).normalized() * unit.move_speed * _delta
	var animation_direction = velocity.normalized()
	animation_direction.y *= -1
	unit.change_direction(animation_direction)
#	if velocity.length() > position.distance_to(target):
#		position = target.position
	unit.position += velocity
	
	
	
	var n_cells : Vector2 = target/ MainCombatDemo.cell_size
	unit.grid_coordinates = n_cells.floor()
	#unit.update_grid_coordinates()
	
func physics_update(_delta: float) -> void:
	pass

func enter(_msg := {}) -> void:
	
	
	path_index = 0
	velocity = Vector2.ZERO
	path = _msg.path
	
	unit = state_machine.unit
	
	unit.animation_state.travel("Walk")
	unit.emit_signal("StartedMoving", unit.grid_coordinates, unit)
	unit.current_ap -= 1
	
	

func exit() -> void:
	
	path_index = 0
	velocity = Vector2.ZERO
	
	unit.emit_signal("StoppedMoving", unit.grid_coordinates, unit)
	
	
	pass
