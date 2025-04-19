extends CharacterBody3D

@export_category("Player Settings")
@export var move_speed: float = 5.0
@export var jump_velocity: float = 4.5
@export var mouse_sensitivity: float = 0.003  

@export_category("Player Movement")
@export var move_forward = "ui_up"
@export var move_back = "ui_down"
@export var move_left = "ui_left"
@export var move_right = "ui_right"
@export var jump = "ui_accept"
@export var interact = "interact"

const gravity: float = 9.8  
var velocity_y: float = 0.0  
var mouse_locked: bool = true  
var grabbed_object: RigidBody3D = null  

@onready var raycast: RayCast3D = $head/Camera3D/Interaction  
@onready var camera = $head/Camera3D  
@onready var anim = $AnimationPlayer
@onready var animation_tree: AnimationTree = $AnimationTree # Use AnimationTree for 3D animations
@onready var state_machine = animation_tree.get("parameters/playback")  # Reference to the state machine


func _physics_process(delta: float):
	if not is_on_floor():
		velocity_y -= gravity * delta
	else:
		velocity_y = 0.0  

	if Input.is_action_just_pressed(jump) and is_on_floor():
		velocity_y = jump_velocity
		state_machine.travel("jump")  # Transition to jump state

	var input_dir := Input.get_vector(move_left, move_right, move_back, move_forward)
	var direction := Vector3.ZERO

	if input_dir != Vector2.ZERO:
		var forward = -camera.global_transform.basis.z  
		var right = camera.global_transform.basis.x  
		forward.y = 0  
		right.y = 0
		forward = forward.normalized()
		right = right.normalized()
		direction = (forward * input_dir.y + right * input_dir.x).normalized()
		if is_on_floor():
			state_machine.travel("walk")  # Transition to walk state
	elif is_on_floor():
		state_machine.travel("idle")  # Transition to idle state

	velocity = direction * move_speed
	velocity.y = velocity_y  
	move_and_slide()

	if grabbed_object:
		var target_position = camera.global_transform.origin + camera.global_transform.basis.z * -2.0
		grabbed_object.global_transform.origin = target_position

func _input(event):
	if event is InputEventMouseMotion and mouse_locked:
		rotate_y(-event.relative.x * mouse_sensitivity)  
		camera.rotation.x = clamp(camera.rotation.x - event.relative.y * mouse_sensitivity, deg_to_rad(-75), deg_to_rad(75))  

	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		mouse_locked = not mouse_locked
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED if mouse_locked else Input.MOUSE_MODE_VISIBLE

	if event is InputEventMouseButton:
		if event.is_action_pressed(interact):
			if grabbed_object:
				drop_object()
			else:
				try_grab_object()
			state_machine.travel("interact")  # Transition to interact state

	if event is InputEventKey and event.pressed and event.keycode == KEY_E:
		if raycast.is_colliding():
			var hit_object = raycast.get_collider()
			if hit_object and hit_object.is_in_group("food_box"):  
				hit_object.spawn_food()

	if event is InputEventKey and event.pressed and event.keycode == KEY_F:
		give_item_to_npc()

func try_grab_object():
	if raycast.is_colliding():
		var obj = raycast.get_collider()
		if obj is RigidBody3D:
			grabbed_object = obj
			grabbed_object.freeze = true  

func drop_object():
	if grabbed_object:
		grabbed_object.freeze = false  
		grabbed_object = null

func give_item_to_npc():
	if not grabbed_object:
		print("No item to give!")
		return

	if raycast.is_colliding():
		var hit_object = raycast.get_collider()
		if hit_object and hit_object.has_method("receive_item"):
			hit_object.receive_item(grabbed_object)
			grabbed_object = null  
		else:
			print("No NPC found to give item!")
