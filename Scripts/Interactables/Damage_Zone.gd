extends Area2D


func _on_body_entered(body):
	if body.name == "Player":
		player_data.health -= 1
	
