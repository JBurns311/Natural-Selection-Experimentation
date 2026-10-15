extends Node2D

@onready var target = $Target

var generation_size = 100     # how many squares per generation
var num_generations = 50      # how many generations to run
var num_winners = 10          # best squares that get to be parents
var num_copies = 2            # best squares copied into the next generation
var num_random = 5            # new random squares each generation

var speed = 1000.0
var starting_seconds = 2.5
var seconds_left = starting_seconds

var generation_count = 1
var generation: Array[AI] = []

var info_label: Label
var last_best_fitness = 0.0
var last_reached_count = 0


func _ready():
	# Progress label on the screen
	info_label = Label.new()
	info_label.position = Vector2(10, 10)
	add_child(info_label)

	# Create first generation of player squares
	for i in range(generation_size):
		generation.append(AI.new(self))

	move_target()
	update_label()


func _process(delta):
	if generation_count > num_generations:
		return

	for ai in generation:
		if ai.reached_target == 0:
			ai.make_decision(target, speed, delta)
			if ai.dist_from_target.length() <= 30:
				ai.reached_target = 1
				ai.fitness = seconds_left

	seconds_left -= delta
	if seconds_left <= 0:
		end_generation()


func end_generation():
	# Score the squares depending on how close they were to the target
	last_reached_count = 0
	for ai in generation:
		if ai.reached_target == 0:
			ai.fitness = -1 * ai.dist_from_target.length()
		else:
			last_reached_count += 1

	# Rank squares from best to worst
	var ranked = generation.duplicate()
	ranked.sort_custom(func(a, b): return a.fitness > b.fitness)

	# Find the top squares (winners)
	var winners = ranked.slice(0, num_winners)
	last_best_fitness = winners[0].fitness
	print("Generation %d | best fitness: %.2f | reached target: %d/%d" % [
		generation_count, last_best_fitness, last_reached_count, generation_size])

	# Collect winners from the current generation
	var new_winners: Array[NeuralNetwork] = []

	# Copy the top winners into the array
	for i in range(num_copies):
		new_winners.append(NeuralNetwork.copy(winners[i].nn))

	# Add random instants to keep some variety
	for i in range(num_random):
		new_winners.append(NeuralNetwork.new(4, 6, 4))

	# Create children from winners
	while new_winners.size() < generation_size:
		new_winners.append(make_child(winners))

	# Remove the old squares and create the new generation
	for ai in generation:
		ai.player.queue_free()
	generation.clear()

	for i in range(generation_size):
		var ai = AI.new(self)
		# Color the top winners gold to see them easier
		if i < num_copies:
			ai.set_color(Color.GOLD)
		generation.append(ai)

	# Set up for next round
	move_target()
	seconds_left = starting_seconds
	generation_count += 1
	update_label()


# Breed winners and mutate child
func make_child(winners: Array) -> NeuralNetwork:
	var mom = winners.pick_random()
	var dad = winners.pick_random()
	while dad == mom and winners.size() > 1:
		dad = winners.pick_random()

	var child = NeuralNetwork.reproduce(mom.nn, dad.nn)
	return NeuralNetwork.mutate(child)

# Put the target somewhere random
func move_target():
	target.position = Vector2(
		randf_range(50, 750),
		randf_range(50, 450)
	)

# Update label on screen
func update_label():
	if generation_count > num_generations:
		info_label.text = "%d generations complete.\nLast best fitness: %.2f" % [
			num_generations, last_best_fitness]
		return
	info_label.text = "Generation %d/%d\nLast gen: %d/%d reached the target\nLast best fitness: %.2f" % [
		generation_count, num_generations, last_reached_count,
		generation_size, last_best_fitness]
