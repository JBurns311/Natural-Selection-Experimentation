extends CharacterBody2D

const SPEED = 100.0
const JUMP_VELOCITY = -300.0
var has_jumped = false

var enemy_in_range = false
var damage_cooldown_active = false
var player_alive = true
#var attack_cooldown_active = false

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var health_bar: ProgressBar = $ProgressBar
@onready var killzone: Area2D = $"../Killzone"
@onready var player_hitbox: Area2D = $player_hitbox
@onready var slime: CharacterBody2D = $"../Enemies/Slime"

var health = 1.0

func get_health():
	return health

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

	if Input.is_action_just_pressed("attack") and enemy_in_range:
		#attack_cooldown_active = true
		#if enemy_in_range:
		slime.take_player_attack()
		

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
	
	if enemy_in_range and damage_cooldown_active == false:
		take_enemy_attack()
		
	if health_bar.get_health() <= 0 and player_alive == true:
		player_alive = false
		killzone.player_death(player_hitbox)
	
func _on_player_hitbox_body_entered(body):
	if (body.has_method("enemy")):
		enemy_in_range = true

func _on_player_hitbox_body_exited(body):
	if (body.has_method("enemy")):
		enemy_in_range = false

func take_enemy_attack():
	health_bar.subtract_portion(0.1)
	damage_cooldown_active = true
	$damage_cooldown.start()

func _on_damage_cooldown_timeout():
	damage_cooldown_active = false

# Marks this as the player script
func player():
	pass
