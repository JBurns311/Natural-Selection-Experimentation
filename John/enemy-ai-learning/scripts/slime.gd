extends Node2D

@onready var ray_cast_right: RayCast2D = $RayCastRight
@onready var ray_cast_left: RayCast2D = $RayCastLeft
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var health_bar: ProgressBar = $ProgressBar

var health = 100.0
var damage_cooldown_active = false

const SPEED = 24
var direction = 1
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if ray_cast_right.is_colliding():
		direction = -1
		animated_sprite_2d.flip_h = true
	if ray_cast_left.is_colliding():
		direction = 1
		animated_sprite_2d.flip_h = false
		
	position.x += direction * SPEED * delta
	
	if health_bar.get_health() <= 0:
		self.queue_free()

func take_player_attack():
	health_bar.subtract_portion(0.1)
	damage_cooldown_active = true
	$damage_cooldown.start()

func _on_damage_cooldown_timeout():
	damage_cooldown_active = false

# Marks this as a script for an enemy
func enemy():
	pass
