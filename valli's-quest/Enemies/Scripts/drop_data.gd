class_name DropData
extends Resource

@export var item: ItemData

# Probability as normalized 0.0–1.0 instead of 0–100 percentage
@export_range(0.0, 1.0, 0.01) 
var dropProbability: float = 1.0

# Custom discrete distribution of possible drop counts (e.g. [0,0,1,2,3] means weights)
@export var dropCountDistribution: Array[int] = [1]

# Determines the number of items to drop based on probability and distribution.
func getDropCount() -> int:
	if randf() > dropProbability:
		return 0
	
	return _sampleDistribution(dropCountDistribution)

# Samples a weighted random count from the provided distribution array.
func _sampleDistribution(dist: Array[int]) -> int:
	if dist.is_empty():
		return 1
	
	var index = randi() % dist.size()
	return dist[index]
