extends RigidBody3D

enum FoodState { RAW, COOKED }
var state: FoodState = FoodState.RAW

func cook():
	if state == FoodState.RAW:
		state = FoodState.COOKED
		$patty.disabled = true
		$cooked.disabled = false
		remove_from_group("grill_food")
		print("remove frome grill group")
		add_to_group("burger") 
		print("add to burger group")
		$Raw.visible = false
		$Cooked.visible = true # Change to cooked mesh
		print("Food is cooked!")

func _ready():
	add_to_group("grill_food")  # Add the food to the "food" group for easy detection
	$Cooked.visible = false
	$cooked.disabled = true
