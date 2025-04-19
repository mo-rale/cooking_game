extends StaticBody3D

@export var cooking_time: float = 7  # Time it takes to cook the food
var cooking_foods: Array = []  # Stores up to 2 food items

@onready var cooking_state: MeshInstance3D = $heat
@onready var cooking_particles: GPUParticles3D = $smoke
@onready var cooking_start_sound: AudioStreamPlayer3D = $cooking
@onready var cooking_place_sound: AudioStreamPlayer3D = $place
@onready var cooking_finish_sound: AudioStreamPlayer3D = $cooked

func _ready():
	$Area3D.connect("body_entered", _on_body_entered)
	cooking_state.visible = false
	cooking_particles.emitting = false

func _on_body_entered(body: Node3D):
	# Check if the body is food and specifically for grilling
	if body.is_in_group("grill_food") and body not in cooking_foods and cooking_foods.size() < 2:
		print("Food started cooking on grill: ", body.name)
		cooking_foods.append(body)
		start_cooking(body)

func start_cooking(food: RigidBody3D):
	# Create a new timer for the food
	var timer = Timer.new()
	timer.wait_time = cooking_time
	timer.one_shot = true
	add_child(timer)
	cooking_place_sound.play()
 
	timer.connect("timeout", func():
		_on_food_cooked(food, timer))

	timer.start()

	# Activate visuals & sound when at least one food is cooking
	cooking_particles.emitting = true
	cooking_state.visible = true
	cooking_start_sound.play()

func _on_food_cooked(food: RigidBody3D, timer: Timer):
	if food in cooking_foods:
		print("Food grilled: ", food.name)
		cooking_finish_sound.play()
		food.cook()  # Assuming the food has a cook() function
		cooking_foods.erase(food)
		timer.queue_free()  # Remove the timer after use

	# If no more food is cooking, stop visuals & sounds
	if cooking_foods.is_empty():
		cooking_particles.emitting = false
		cooking_state.visible = false
		cooking_start_sound.stop()
