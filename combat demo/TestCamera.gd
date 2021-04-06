extends Camera2D


export var speed := 10

func _input(event):
	if event.is_action_pressed("zoom_in"):
		zoom *= 1.1
	if event.is_action_pressed("zoom_out"):
		zoom *= 0.9
# Called when the node enters the scene tree for the first time.
func _process(delta):
	var velocity = Vector2.ZERO
	if Input.is_action_pressed("Down"):
		velocity.y += speed
	elif Input.is_action_pressed("Up"):
		velocity.y -= speed
	elif Input.is_action_pressed("Right"):
		velocity.x += speed
	elif Input.is_action_pressed("Left"):
		velocity.x -= speed
	global_position += velocity * delta
