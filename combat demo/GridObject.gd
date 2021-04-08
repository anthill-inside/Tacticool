extends Node2D
class_name GridObject

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export var selection_material = "res://combat demo/resources/Selected_Shader.tres"

var  grid_coordinates : Vector2

signal ObjectMoved(start_cell, new_cell, obj)

func move_object(destination):
	var start_cell = grid_coordinates
	position = destination
	snap_to_grid()
	emit_signal("ObjectMoved", start_cell, grid_coordinates, self)

func select():
	$Sprite.material = load(selection_material)
	
func deselect():
	$Sprite.material = null

func update_zindex():
	pass

func snap_to_grid():
	update_grid_coordinates()
	position =  grid_coordinates * MainCombatDemo.cell_size + MainCombatDemo.half_cell
	

func update_grid_coordinates():
	var n_cells : Vector2 = position/ MainCombatDemo.cell_size
	n_cells = n_cells.floor()
	grid_coordinates = n_cells
	
# Called when the node enters the scene tree for the first time.
func _ready():
	snap_to_grid()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
