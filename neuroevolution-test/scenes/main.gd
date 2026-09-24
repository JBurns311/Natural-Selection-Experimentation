extends Node2D

@onready var target = $Target

var generation_size = 100
var num_generations = 10

var speed = 1000.0
var starting_seconds = 2.5
var seconds_left = starting_seconds

var generation: Array[AI] = []

func _ready():
	
	# Create first generation of player squares
	for i in range(generation_size):
		var ai = AI.new(self)
		generation.append(ai)

	# Put the target somewhere random.
	target.position = Vector2(
		randf_range(50, 750),
		randf_range(50, 450)
	)

func _process(delta):
	if num_generations <= 0: 
		return
	for ai in generation:
		if ai.reached_target == 0:
			ai.make_decision(target, speed, delta)
			if ai.dist_from_target.length() <= 30:
				ai.reached_target = 1
				ai.fitness = seconds_left
	seconds_left -= delta
	if seconds_left <= 0:
		for ai in generation:
			if ai.reached_target == 0:
				ai.fitness = -1 * ai.dist_from_target.length()
			print(ai.fitness)
		
		# Find the AI with the highest score
		var highest_score = generation[0].fitness
		var highest_score_index = 0
		for i in range(generation_size):
			if generation[i].fitness > highest_score:
				highest_score = generation[i].fitness
				highest_score_index = i
		
		# Create a new mutated generation
		var best_nn = generation[highest_score_index].nn
		for i in range(generation_size):
			generation[i].player.queue_free()
			generation[i] = AI.new(self)
			generation[i].nn = NeuralNetwork.mutate(best_nn)
			
		# Set up for next round
		seconds_left = starting_seconds
		num_generations -= 1
