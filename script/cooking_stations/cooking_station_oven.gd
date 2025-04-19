extends StaticBody3D

@export var cooking_time: float = 10
 # Time it takes to cook the food
var is_cooking: bool = false
var current_food: RigidBody3D = null

@onready var cooking_light: OmniLight3D = $heat  # Replacing PointLight3D with OmniLight3D
@onready var cooking_start_sound: AudioStreamPlayer3D = $cooking
@onready var cooking_finish_sound: AudioStreamPlayer3D = $cooked

func _ready():
	$Area3D.connect("body_entered", _on_body_entered)
	$Timer.connect("timeout", _on_cooking_timer_timeout)
	cooking_light.visible = false  # Ensure the light starts off

func _on_body_entered(body: Node3D):
	if body.is_in_group("oven_food") and not is_cooking:
		print("Food is cooking")
		current_food = body as RigidBody3D
		start_cooking()

func start_cooking():
	is_cooking = true
	cooking_start_sound.play()
	print("Cooking started: Sizzling sound")
	$Timer.start(cooking_time)
	cooking_light.visible = true 

func _on_cooking_timer_timeout():
	is_cooking = false
	cooking_light.visible = false  # Turn off the heat light effect
	cooking_finish_sound.play()
	print("Ding! Cooking finished")
	cooking_start_sound.stop()
	update_food()

func update_food():
	if current_food:
		current_food.cook()  # Call a method on the food to change its state
		current_food = null
 
