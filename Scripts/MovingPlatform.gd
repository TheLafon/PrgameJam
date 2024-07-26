extends AnimatableBody2D


@export var speed : float = 255.0
@export var dir : Vector2


var startpos : Vector2
var targetpos : Vector2


# Called when the node enters the scene tree for the first time.
func _ready():
	startpos = global_position
	targetpos = startpos + dir 

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	global_position = global_position.move_toward(targetpos, speed * delta)
	if global_position == targetpos:
		if global_position == startpos:
			targetpos = startpos + dir
		else: 
			targetpos = startpos
