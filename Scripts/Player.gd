extends CharacterBody2D


var input = 0.0

#jump related variables
var jump_count = 0
@export var max_jump = 2
@export var jump_force = 400

@export var speed = 100.0
@export var gravity = 10

#WallJump Variables
@onready var wall = $wall_ray

#State Machine information

#dashing Variable 
@export var dash_force = 600

#State Machine for the Player
var current_state = player_states.MOVE
enum player_states {MOVE, ATTACK, DEAD, DASH}


func _ready():
	$Sword/Attack_collider.disabled = true

func _physics_process(delta):
	#triggers state
	match current_state:
		player_states.MOVE:
			movement(delta)
		player_states.ATTACK:
			Attack(delta)
		player_states.DASH:
			dashing()
	
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
			$Sword.position.x = -12
			wall.scale.x = 1
			$Anim.play("Run")
		if input < 0:
			velocity.x -= speed * delta
			velocity.x = clamp(-speed, 100.0, -speed)
			#controls the animations and fliping of the character
			$AnimatedSprite2D.scale.x = -1
			$Sword.position.x = -36
			wall.scale.x = -1
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
			$Anim.play("Jump")
		#will be replaced with "fall" insted of a second jump
		if velocity.y > 0:
			$Anim.play("Jump")

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
		current_state = player_states.ATTACK
		
		
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
		
func dashing():
	if velocity.x > 0:
		velocity.x += dash_force
		await get_tree().create_timer(0.1).timeout
		current_state = player_states.MOVE
	elif velocity.x < 0:
		velocity.x -= dash_force
		await get_tree().create_timer(0.1).timeout
		current_state = player_states.MOVE
	else:
		if $AnimatedSprite2D.scale.x == 1:
			velocity.x += dash_force
			await get_tree().create_timer(0.1).timeout
			current_state = player_states.MOVE
		if $AnimatedSprite2D.scale.x == -1:
			velocity.x -= dash_force
			await get_tree().create_timer(0.1).timeout
			current_state = player_states.MOVE
	move_and_slide()
		
		
func Attack(delta):
	$Anim.play("Attack")
	input_movement(delta)
	
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
