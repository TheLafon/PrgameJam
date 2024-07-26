extends CharacterBody2D
class_name Player

var input = 0.0

#jump related variables
var jump_count = 0
@export var max_jump = 2
@export var jump_force = 400

@export var speed = 100.0
@export var gravity = 8

#WallJump Variables
@onready var wall = $wall_ray

#State Machine information

#dashing Variable 
@onready var sprite = $AnimatedSprite2D
@export var dash_duration = 0.1 
@export var is_dashing = false 
@export var dash_start_pos = Vector2.ZERO
@export var dash_distance = 50  

#State Machine for the Player
var current_state = player_states.MOVE
enum player_states {MOVE, ATTACK, DEAD, DASH}


func _ready():
	pass
	#$Sword/Attack_collider.disabled = true


func _physics_process(delta):
	#Triggers Death State
	if player_data.health <= 0:
		current_state = player_states.DEAD
		
	#triggers basic states
	match current_state:
		player_states.MOVE:
			movement(delta)
#		player_states.ATTACK:
#			Attack(delta)
		player_states.DASH:
			dashing(delta)
		player_states.DEAD:
			dead()
	
	
func movement(delta):
	#handles left and right directionals
	input = Input.get_action_strength("Right") - Input.get_action_strength("Left")
	#controlls the speed at which the character moves left and right with a fixed value
	
	if input != 0: 
		if input > 0:
			velocity.x += speed * delta
			velocity.x = clamp(speed, 100.0, speed)
			#controls the animations and fliping of the character
			$AnimatedSprite2D.scale.x = 1
			#$Sword.position.x = -12
			wall.scale.x = 4
			$Anim.play("Run")
		if input < 0:
			velocity.x -= speed * delta
			velocity.x = clamp(-speed, 100.0, -speed)
			#controls the animations and fliping of the character
			$AnimatedSprite2D.scale.x = -1
			#$Sword.position.x = -36
			wall.scale.x = -4
			$Anim.play("Run")
	if input == 0:
		velocity.x = 0
		$Anim.play("Idle")
		
		#handles jump
	if is_on_floor():
		jump_count = 0
	
	
	if !is_on_floor():
		#afirms that the player is not on the floor
		if velocity.y < 0:
			$AnimatedSprite2D.play("Jump")
		#will be replaced with "fall" insted of a second jump
		if velocity.y >= 0:
			$AnimatedSprite2D.play("Fall")

		#counts the jump value and counts if the player is on the floor and
		#if the jump count is less then the max jumps allowed
	if Input.is_action_just_pressed("Jump") && is_on_floor() && jump_count < max_jump:
		jump_count += 1
		velocity.y -= jump_force
		velocity.x = input

		#if the player is not on the floor and the jump is pressed allows you
		#the extra jump and adds it to the jump counter that maxes at 2
	if !is_on_floor() && Input.is_action_just_pressed("Jump") && jump_count < max_jump:
		jump_count += 1
		#height of the second jump
		velocity.y -= jump_force * 1.1
		velocity.x = input
		#sets gravity and speed for second jump
	if !is_on_floor() && Input.is_action_just_released("Jump") && jump_count < max_jump:
		velocity.y = gravity
		velocity.x = input
		
	else:
		gravity_force()
		
		
	if wall_collide() && Input.is_action_just_pressed("Jump"):
		if velocity.x > 0:
			velocity = Vector2(-800, -350)
		elif velocity.x < 0:
			velocity = Vector2(800, -350)
		
		
			#handles attack trigger
	if Input.is_action_just_pressed("Primary_Attack"):
		current_state = player_states.DASH
		
		
	if Input.is_action_just_pressed("Dash"):
		current_state = player_states.DASH
		
	gravity_force()
	move_and_slide()


func wall_collide():
	return wall.is_colliding()


func gravity_force():
	if !is_on_wall():
		velocity.y += gravity
	elif is_on_wall() && velocity.y > 0:
		velocity.y += .5
	else:
		velocity.y += gravity
		
		
func dashing(delta):
	is_dashing = true
	dash_start_pos = position
	var dash_direction = Vector2.RIGHT if sprite.scale.x == 1 else Vector2.LEFT
	var dash_end_pos = dash_start_pos + dash_distance * dash_direction
	var dash_time = dash_duration
	var dash_step = dash_distance / dash_duration  
	
	while dash_time > 0:
		$Anim.play("Dash")
		var progress = 1 - (dash_time / dash_duration)
		var current_pos = dash_start_pos + (dash_end_pos - dash_start_pos) * progress
		if wall_collide():
			current_pos = position  
			break
		position = current_pos
		await(get_tree().create_timer(0.01).timeout)
		dash_time -= 0.01
		
		
	current_state = player_states.MOVE
	is_dashing = false
	move_and_slide()
	gravity_force()
		
		
func boarDash(delta):
	is_dashing = true
	dash_start_pos = position
	var dash_direction = Vector2.RIGHT if sprite.scale.x == 1 else Vector2.LEFT
	var dash_end_pos = dash_start_pos + dash_distance * dash_direction
	var dash_time = dash_duration
	var dash_step = dash_distance / dash_duration  
	
	while dash_time > 0:
		$Anim.play("Attack")
		var progress = 1 - (dash_time / dash_duration)
		var current_pos = dash_start_pos + (dash_end_pos - dash_start_pos) * progress
		if wall_collide():
			current_pos = position  
			break
		position = current_pos
		await(get_tree().create_timer(0.01).timeout)
		dash_time -= 0.01
		
		
	current_state = player_states.MOVE
	is_dashing = false
	move_and_slide()
	gravity_force()
	
	
	
func dead():
	$Anim.play("Death")
	#stops the player from moving
	velocity.x = 0
	#returns the player to the ground incase they die in the air
	gravity_force()
	move_and_slide()
	await $Anim.animation_finished
	player_data.health = 4
	player_data.collectable = 0
	#checks if the tree is in the scene allowing the reload cause godot is funky
	if get_tree():
		get_tree().reload_current_scene()
	
	
func input_movement(delta):
	input = Input.get_action_strength("Right") - Input.get_action_strength("Left")
	#controlls the speed at which the character moves left and right with a fixed value
	
	if input != 0: 
		if input > 0:
			velocity.x += speed * delta
			velocity.x = clamp(speed, 100.0, speed)
			$AnimatedSprite2D.scale.x = 1
		if input < 0:
			velocity.x -= speed * delta
			velocity.x = clamp(-speed, 100.0, -speed)
			$AnimatedSprite2D.scale.x = -1
	if input == 0:
		velocity.x = 0 
	gravity_force()
	move_and_slide()


#returns the player to the move state and is set inside the Anim node under the Player function track
func reset_state():
	current_state = player_states.MOVE
