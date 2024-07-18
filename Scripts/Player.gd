extends CharacterBody2D


var input
var jump_count = 0
@export var max_jump = 2
@export var jump_force = 400
@export var speed = 100.0
@export var gravity = 10




func _ready():
	pass

func _process(delta):
	movement(delta)
	
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
			$Anim.play("Run")
		if input < 0:
			velocity.x -= speed * delta
			velocity.x = clamp(-speed, 100.0, -speed)
			#controls the animations and fliping of the character
			$AnimatedSprite2D.scale.x = -1
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
	if Input.is_action_pressed("Jump") && is_on_floor() && jump_count < max_jump:
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
		
	gravity_force()
	move_and_slide()


func gravity_force():
	velocity.y += gravity
