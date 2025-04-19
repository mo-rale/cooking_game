extends RigidBody3D

enum FoodState { RAW, COOKED }
var state: FoodState = FoodState.RAW

func cook():
	if state == FoodState.RAW:
		state = FoodState.COOKED
		remove_from_group("fry_food")
		print("remove frome grill group")
		add_to_group("fries") 
		print("add to fries group")
		$Raw.mesh = $cooked# Change to cooked mesh
		print("Food is cooked!")

func _ready():
	add_to_group("fry_food")  # Add the food to the "food" group for easy detection
