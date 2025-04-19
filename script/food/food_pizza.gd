extends RigidBody3D

enum FoodState { RAW, COOKED }
var state: FoodState = FoodState.RAW
@onready var area: Area3D = $Area3D

func cook():
	if state == FoodState.RAW:
		state = FoodState.COOKED
		remove_from_group("oven_food")
		add_to_group("pizza") 
		$Cooked.visible = true
		$Raw.mesh = $Cooked# Change to cooked mesh
		print("Food is cooked!")

func _ready():
	add_to_group("oven_food")  # Add the food to the "food" group for easy detection
	$Cooked.visible = false
	
