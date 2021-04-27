extends UnitState



var path : PoolVector2Array
var path_index := 0
var velocity := Vector2.ZERO

var unit : Unit


func handle_input(_event: InputEvent) -> void:
	pass

func update(_delta: float) -> void:
	pass
	
func physics_update(_delta: float) -> void:
	pass

func enter(_msg := {}) -> void:
	unit = state_machine.unit
	unit.emit_signal("Dead", unit.grid_coordinates, unit)
	unit = state_machine.unit 
	unit.animation_state.travel("Dead")
	unit.z_index -= 1

func exit() -> void:
	
	
	pass
