extends UnitState

var projectile = preload("res://combat demo/objects/Projectile.tscn")
enum ATTACK_TYPES {melee,ranged_projectyle, ranged_instant}
var attack_type = ATTACK_TYPES.ranged_projectyle

var target

var unit : Unit
var damage : int

var animation_length
var timer = 0.0

func handle_input(_event: InputEvent) -> void:
	pass

func update(_delta: float) -> void:
	timer += _delta
	if timer >= animation_length:
		state_machine.transition_next()
	
func physics_update(_delta: float) -> void:
	pass

func enter(_msg := {}) -> void:
	
	
	target = _msg.target
	damage = _msg.damage
	
	unit = state_machine.unit
	var new_direction = (target.position - unit.position).normalized()
	new_direction.y *= -1
	unit.change_direction(new_direction)
	unit.animation_state.travel("Attack")
	
	#unit.emit_signal("StartedMoving", unit.grid_coordinates, unit)
	unit.current_ap = unit.current_ap - _msg.cost
	
	
	animation_length = 0.6
	# can't get data from animation tree because of the bug known for years
	#motherfuckers
	timer = 0.0
	

func exit() -> void:
	if attack_type != ATTACK_TYPES.ranged_projectyle:
		target.get_damage(damage)
	else:
		var projectileInstance = projectile. instance()
		projectileInstance. position = state_machine.unit.position
		add_child(projectileInstance)
#	
#	yield(get_tree().create_timer(1), "timeout")
	
	#unit.emit_signal("StoppedMoving", unit.grid_coordinates, unit)
	
	
	pass
