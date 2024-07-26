extends CanvasLayer

#tells us how much health the player can have total
const HEALTH_ROW_SIZE = 8
#tells us the distance between each Health container
const HEALTH_OFFSET = 16
# Called when the node enters the scene tree for the first time.
func _ready():
	for i in player_data.health:
		var new_health = Sprite2D.new()
		new_health.texture = $Health.texture
		new_health.hframes = $Health.hframes
		$Health.add_child(new_health)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$Collectable_display.text = var_to_str(player_data.collectable)
	health_display()
	
func health_display():
	for health in $Health.get_children():
		var index = health.get_index()
		var x = (index % HEALTH_ROW_SIZE) * HEALTH_OFFSET
		var y = (index / HEALTH_ROW_SIZE) * HEALTH_OFFSET
		health.position = Vector2(x,y)
		
		var last_heart = floor(player_data.health)
		if index > last_heart:
			health.frame = 0
		if index == last_heart:
			health.frame = (player_data.health - last_heart) * 4
		if index < last_heart:
			health.frame = 4
		
		
