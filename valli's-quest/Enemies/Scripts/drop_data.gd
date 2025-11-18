class_name DropData
extends Resource

@export var item: ItemData

# Probability as normalized 0.0–1.0 instead of 0–100 percentage
@export_range(0.0, 1.0, 0.01) 
var dropProbability: float = 1.0

# Custom discrete distribution of possible drop counts (e.g. [0,0,1,2,3] means weights)
@export var dropCountDistribution: Array[int] = [1]

func getDropCount() -> int:
	# Roll to see if drop happens
	if randf() > dropProbability:
		return 0
	
	return _sampleDistribution(dropCountDistribution)


func _sampleDistribution(dist: Array[int]) -> int:
	# Simple weighted random pick from distribution array
	# Each element is an item count; frequency = weight
	if dist.is_empty():
		return 1  # fallback
	
	# For example: dist = [1,1,1,2,2,3] means 3x1s, 2x2s, 1x3
	# We pick randomly an index
	var index = randi() % dist.size()
	return dist[index]
