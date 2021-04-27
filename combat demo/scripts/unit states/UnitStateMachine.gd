# Generic state machine. Initializes states and delegates engine callbacks
# (_physics_process, _unhandled_input) to the active state.
class_name UnitStateMachine
extends Node

# Emitted when transitioning to a new state.
signal transitioned(state_name)

# Path to the initial active state. We export it to be able to pick the initial state in the inspector.
export var initial_state := NodePath()

# The current active state. At the start of the game, we get the `initial_state`.
onready var state := get_node("Idle")

var unit

var state_queue := []
#every member should look like this:
#{
#	state_name: 
#	params:  {parameters used in enter()} 
#}

func _ready() -> void:
	yield(owner, "ready")
	unit = owner
	# The state machine assigns itself to the State objects' state_machine property.
	for child in get_children():
		child.state_machine = self
	state.enter()


# The state machine subscribes to node callbacks and delegates them to the state objects.
func _unhandled_input(event: InputEvent) -> void:
	state.handle_input(event)


func _process(delta: float) -> void:
	state.update(delta)


func _physics_process(delta: float) -> void:
	state.physics_update(delta)

	
# This function calls the current state's exit() function, then changes the active state,
# and calls its enter function.
# It optionally takes a `msg` dictionary to pass to the next state's enter() function.
func transition_to(target_state_name: String, params: Dictionary = {}) -> void:
	if not has_node(target_state_name):
		return
	state.exit()
	state = get_node(target_state_name)
	state.enter(params)
	emit_signal("transitioned", state.name)




func push_state(state_name: String, params: Dictionary = {}) -> void:
	state_queue.append({"state_name": state_name, "params": params})
	
func push_state_front(state_name: String, params: Dictionary = {}) -> void:
	state_queue.push_front({"state_name": state_name, "params": params})
	
func clear_state_queue()-> void:
	state_queue.clear()
	
func add_states_to_queue(new_states: Array = []) -> void:
	for s in new_states:
		state_queue.push_back(s)
	
func transition_next()-> void:
	var new_state = {"state_name": "Idle", "params": {}}
	var s = state_queue.pop_front()
	if s:
		new_state = s
			
	transition_to(new_state.state_name, new_state.params)
