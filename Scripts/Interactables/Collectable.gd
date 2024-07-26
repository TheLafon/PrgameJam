extends Area2D

func _ready():
	$Anim.play("Active")


func _on_body_entered(body):
	if body.name == "Player":
		#animation would go here
		#followed by an await
		player_data.collectable += 1
		#then another Animation to remove it
		queue_free()
