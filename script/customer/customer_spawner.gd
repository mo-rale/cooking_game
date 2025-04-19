extends Node3D

@export var CUSTOMER_SCENES: Array[PackedScene]  # Array of customer scenes
@export var max_customers: int = 3
@export var move_duration: float = 0.5

@onready var spawn_point: Marker3D = $SpawnPoint
@onready var customer_queue: Node3D = $CustomerQueue

var customers: Array[StaticBody3D] = []

func _ready():
	await get_tree().process_frame
	for i in range(max_customers):
		spawn_customer()

func spawn_customer():
	if customers.size() < max_customers and CUSTOMER_SCENES.size() > 0:
		var random_scene = CUSTOMER_SCENES[randi() % CUSTOMER_SCENES.size()]  # Pick random scene
		var new_customer = random_scene.instantiate() as StaticBody3D
		new_customer.spawner = self
		customer_queue.add_child(new_customer)
		customers.append(new_customer)

		# Position customer at the end of the queue
		var target_position = spawn_point.global_transform.origin - Vector3(0, 0, (customers.size() - 1) * 2)
		new_customer.global_transform.origin = target_position
		arrange_customers()

func on_customer_leave():
	if customers.is_empty():
		return

	var leaving_customer = customers.pop_front()
	leaving_customer.queue_free()
	arrange_customers()

	# Delay before spawning a new customer
	await get_tree().create_timer(1.0).timeout
	spawn_customer()

func arrange_customers():
	for i in range(customers.size()):
		var target_position = spawn_point.global_transform.origin - Vector3(0, 0, i * 2)
		var tween = create_tween()
		tween.tween_property(customers[i], "global_transform:origin", target_position, move_duration).set_trans(Tween.TRANS_LINEAR)

	# Start patience timer for the first customer if available
	if customers.size() > 0 and customers[0].has_method("start_patience_timer"):
		customers[0].start_patience_timer()
