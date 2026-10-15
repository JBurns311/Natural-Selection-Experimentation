extends ProgressBar

func _ready():
	value = max_value

func get_health():
	return value

func set_health(health: float):
	value = health
	
func subtract_portion(portion: float):
	value -= (portion * max_value)
	print(value)
