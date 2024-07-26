extends Node2D

@export var speed = 160.0
var current_speed = 0.0


func _on_hitbox_area_entered(area):
	if area.get_parent() is Player:
		area.get_parent().die()


func _on_player_detection_area_entered(area):
	pass # Replace with function body.
