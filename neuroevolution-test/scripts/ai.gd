class_name AI
extends RefCounted

var player: ColorRect
var dist_from_target: Vector2 = Vector2(0, 0)
var reached_target: int = 0
var nn: NeuralNetwork
var fitness: float = 0.0

func _init(parent: Node2D):
	player = ColorRect.new()
	player.size = Vector2(30, 30)
	player.color = Color.BLUE
	player.position = Vector2(100, 250)
	parent.add_child(player)
	nn = NeuralNetwork.new(4, 6, 4)
	
func make_decision(target: ColorRect, speed: float, delta: float):
	dist_from_target = target.position - player.position

	var target_left = 0.0
	var target_right = 0.0
	var target_up = 0.0
	var target_down = 0.0

	if dist_from_target.x < 0:
		target_left = 1.0
	else:
		target_right = 1.0

	if dist_from_target.y < 0:
		target_up = 1.0
	else:
		target_down = 1.0

	var inputs: Array[float] = [
		target_left,
		target_right,
		target_up,
		target_down
	]

	var outputs = nn.predict(inputs)
	var strongest = 0

	for i in range(1, outputs.size()):
		if outputs[i] > outputs[strongest]:
			strongest = i

	if strongest == 0:
		player.position.x -= speed * delta
	elif strongest == 1:
		player.position.x += speed * delta
	elif strongest == 2:
		player.position.y -= speed * delta
	elif strongest == 3:
		player.position.y += speed * delta
		
	dist_from_target = target.position - player.position
