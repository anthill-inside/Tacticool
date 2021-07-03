extends GridObject
class_name Unit

onready var animation_state_machine = $AnimationTree.get("parameters/playback")




onready var animation_tree = $AnimationTree
onready var animation_player = $AnimationPlayer
onready var state_machine = $StateMachine
onready var animation_state = animation_tree.get("parameters/playback")
var health_bar 
var action_bar 

func _ready():
	health_bar = $HealthBar
	health_bar.max_value = max_health
	health_bar.value = current_health
	action_bar = $ActionBar
	action_bar.max_value = max_ap
	action_bar.value = current_ap



var is_active = false
signal EndTurn
signal StartTurn
signal StoppedMoving(grid_coordinates, obj)
signal StartedMoving(grid_coordinates, obj)
signal Dead(grid_coordinates, obj)



var move_speed = 100
var path: PoolVector2Array
var path_index = 0
var velocity = Vector2.ZERO

#direction unit faces
var direction = Vector2.DOWN


export var max_ap := 5
export var current_ap := 5
export var max_health := 3
export var current_health :=3

var attack = {"damage": 2, "cost": 2}

func _process(delta):	
	action_bar.value = current_ap

func get_damage(damage):
	current_health -= damage
	if current_health <= 0:
		die()
	else:
		health_bar.value = current_health

func die():
	state_machine.clear_state_queue()
	state_machine.push_state("Dead", {})
	health_bar.hide()
	action_bar.hide()


func change_direction(new_direction):
	animation_tree.set("parameters/Walk/blend_position", new_direction)
	animation_tree.set("parameters/Idle/blend_position", new_direction)
	animation_tree.set("parameters/Attack/blend_position", new_direction)
	


func end_turn():
	deselect()
	is_active = false

func start_turn():	
	select()
	is_active = true



