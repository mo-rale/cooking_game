extends StaticBody3D

@export var cooking_time: float = 10
 # Time it takes to cook the food
var is_cooking: bool = false
var current_food: RigidBody3D = null


@onready var cooking_start_sound: AudioStreamPlayer3D = $cooking
@onready var cooking_finish_sound: AudioStreamPlayer3D = $cooked
@onready var cook_hit: AudioStreamPlayer3D = $hit
@onready var cooking_particles: GPUParticles3D = $oil

func _ready():
	$Area3D.connect("body_entered", _on_body_entered)
	$Timer.connect("timeout", _on_cooking_timer_timeout)
	cooking_particles.emitting = false


func _on_body_entered(body: Node3D):
	if body.is_in_group("fry_food") and not is_cooking:
		print("Food is cooking")
		current_food = body as RigidBody3D
		start_cooking()

func start_cooking():
	is_cooking = true
	cooking_particles.emitting = true
	cooking_start_sound.play()
	print("Cooking started: Sizzling sound")
	$Timer.start(cooking_time)

func _on_cooking_timer_timeout():
	is_cooking = false
	cooking_particles.emitting = false
	cooking_finish_sound.play()
	print("Ding! Cooking finished")
	cooking_start_sound.stop()
	update_food()

func update_food():
	if current_food:
		current_food.cook()  # Call a method on the food to change its state
		current_food = null
 
