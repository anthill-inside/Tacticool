extends Node2D
class_name GridObject

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export var selection_material = "res://combat demo/resources/Selected_Shader.tres"

var  my_cell : Vector2

func select():
	$Sprite.material = load(selection_material)
	
func deselect():
	$Sprite.material = null

func update_zindex():
	pass

func snap_to_grid():
	var n_cells : Vector2 = position/ MainCombatDemo.cell_size
	n_cells = n_cells.floor()
	my_cell = n_cells
	position =  n_cells * MainCombatDemo.cell_size + MainCombatDemo.half_cell
	

# Called when the node enters the scene tree for the first time.
func _ready():
	snap_to_grid()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
