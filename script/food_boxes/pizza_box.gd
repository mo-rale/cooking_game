extends StaticBody3D

@export var food_scene: PackedScene  # Assign the food scene in the inspector
@onready var label: Label3D = $Label3D

var pizza_price = 8  # Cost of pizza

func _ready():
	print("✅ Ready executed!")  # Debugging
	add_to_group("food_box")
	label.text = "Pizza_box"
	label.font_size = 20  # Adjust size if needed
	label.visible = true

func spawn_food():
	var game_manager = get_tree().get_first_node_in_group("GameManager")  # Get GameManager
	if game_manager:
		var player_cash = game_manager.cash  # Get player's current cash

		if player_cash < pizza_price:  
			print("❌ Not enough cash to buy pizza!")  
		else:
			if game_manager.subtract_cash(pizza_price):  # Deduct cash if possible
				var food_instance = food_scene.instantiate()
				get_parent().add_child(food_instance)
				food_instance.global_transform.origin = global_transform.origin + Vector3(0, 1, 0)  # Spawn above the box
				print("🍕 Pizza Spawned!")
	else:
		print("❌ GameManager not found!")
