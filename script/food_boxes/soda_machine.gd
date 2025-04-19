extends StaticBody3D

@export var food_scene: PackedScene  # Assign the food scene in the inspector
@onready var label: Label3D = $Label3D
@onready var engineSoda: AudioStreamPlayer3D = $machine
var amount = -1
func _ready():
	print("✅ Ready executed!")  # Debugging
	add_to_group("food_box")
	label.text = ("Soda_Machine")
	label.font_size = 40  # Adjust size if needed
	label.visible = true
	engineSoda.play()


func spawn_food():
	if food_scene:
		$kitchenFridgeLarge/AnimationPlayer.play("opening")
		await $kitchenFridgeLarge/AnimationPlayer.animation_finished
		$kitchenFridgeLarge/AnimationPlayer.play("closing")
		var game_manager = get_tree().get_first_node_in_group("GameManager")# Use get_node_or_null
		if game_manager and game_manager.has_method("update_cash_label"):
			var food_instance = food_scene.instantiate()
			get_parent().add_child(food_instance)
			food_instance.global_transform.origin = global_transform.origin + Vector3(-0.6, 1, 0.6)  # Spawn above the box
			print("Soda was Spwanned 🥤")
