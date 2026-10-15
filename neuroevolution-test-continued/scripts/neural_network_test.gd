extends Node

var nn: NeuralNetwork


func _ready():
	nn = NeuralNetwork.new(2, 4, 1)

	print("BEFORE TRAINING")
	print(nn.predict([0.0, 0.0]))
	print(nn.predict([0.0, 1.0]))
	print(nn.predict([1.0, 0.0]))
	print(nn.predict([1.0, 1.0]))

	for epoch in range(10000):
		nn.train([0.0, 0.0], [0.0])
		nn.train([0.0, 1.0], [1.0])
		nn.train([1.0, 0.0], [1.0])
		nn.train([1.0, 1.0], [0.0])

	print("AFTER TRAINING")
	print(nn.predict([0.0, 0.0]))
	print(nn.predict([0.0, 1.0]))
	print(nn.predict([1.0, 0.0]))
	print(nn.predict([1.0, 1.0]))
