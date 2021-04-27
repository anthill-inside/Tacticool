extends UnitState



var path : PoolVector2Array
var path_index := 0
var velocity := Vector2.ZERO

var unit : Unit


func handle_input(_event: InputEvent) -> void:
	pass

func update(_delta: float) -> void:
	if state_machine.state_queue:
		state_machine.transition_next()
	pass
	
func physics_update(_delta: float) -> void:
	pass

func enter(_msg := {}) -> void:
	unit = state_machine.unit
	unit.animation_state.travel("Idle")

func exit() -> void:
	
	
	pass
