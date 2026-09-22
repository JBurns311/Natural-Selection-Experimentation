extends CharacterBody2D


const SPEED = 100.0
const JUMP_VELOCITY = -300.0
var has_jumped = false

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if is_on_floor():
		has_jumped = false
		if Input.is_action_just_pressed("jump"):
			velocity.y = JUMP_VELOCITY
			has_jumped = true
			animated_sprite_2d.play("jump")

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("move_left", "move_right")
	
	# Flip the sprite
	if direction > 0:
		animated_sprite_2d.flip_h = false
	elif direction < 0:
		animated_sprite_2d.flip_h = true
		
	if not has_jumped:
		if direction == 0:
			animated_sprite_2d.play("idle")
		else:
			animated_sprite_2d.play("run")
	
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
