extends GridObject
class_name Unit

onready var animation_state_machine = $AnimationTree.get("parameters/playback")

enum unit_states {
	idle,
	walk
}


onready var animation_tree = $AnimationTree
onready var animation_player = $AnimationPlayer
onready var animation_state = animation_tree.get("parameters/playback")

var state = unit_states.idle

var is_active = false
signal EndTurn
signal StartTurn
signal StoppedWalking



var move_speed = 100
var path: PoolVector2Array
var path_index = 0
var velocity = Vector2.ZERO

#direction unit faces
var direction = Vector2.DOWN



func _physics_process(delta):
	if state == unit_states.walk:
		_walk(delta)



func start_walking(new_path: PoolVector2Array)->void:
	state = unit_states.walk
	path_index = 0
	velocity = Vector2.ZERO
	path = new_path
	
	animation_state.travel("Walk")
	
func _walk(delta):
	if !path:
		return
	var target = path[path_index]
	if position.distance_to(target) < velocity.length() :
		path_index += 1
		if path_index == path.size():
			_stop_walking()
			return
		target = path[path_index]
	velocity = (target - position).normalized() * move_speed * delta
	var animation_direction = velocity.normalized()
	animation_direction.y *= -1
	animation_tree.set("parameters/Walk/blend_position", animation_direction)
#	if velocity.length() > position.distance_to(target):
#		position = target.position
	position += velocity

func _stop_walking()->void:
	state = unit_states.idle
	path_index = 0
	velocity = Vector2.ZERO
	emit_signal("StoppedWalking")
	print("stop")
	
	animation_state.travel("Idle")


func end_turn():
	deselect()
	is_active = false

func start_turn():	
	select()
	is_active = true



