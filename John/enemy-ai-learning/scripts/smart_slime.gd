extends CharacterBody2D


const SPEED = 50.0
const JUMP_VELOCITY = -250.0
var is_chasing = false
var player = null
var time_since_jump = 0.0

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if is_chasing:
		if is_on_floor():
			if time_since_jump > 0.5:
				$AnimatedSprite2D.play("jump")
				velocity.y = JUMP_VELOCITY
				time_since_jump = 0.0
			else:
				$AnimatedSprite2D.play("stand")
				time_since_jump += delta
			velocity.x = 0.0
		elif velocity.x == 0.0:
			if position.x - player.position.x > 0:
				velocity.x = -SPEED
				$AnimatedSprite2D.flip_h = true
			else:
				velocity.x = SPEED
				$AnimatedSprite2D.flip_h = false
					
	
	move_and_slide()


func _on_detection_area_body_entered(_body: Node2D) -> void:
		$AnimatedSprite2D.play("wake")

func _on_detection_area_body_exited(_body: Node2D) -> void:
		$AnimatedSprite2D.play_backwards("wake")


func _on_attack_area_body_entered(body: Node2D) -> void:
	player = body
	is_chasing = true


func _on_attack_area_body_exited(_body: Node2D) -> void:
	player = null
	is_chasing = false
