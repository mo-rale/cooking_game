extends StaticBody3D

# -- Order & Patience Variables --
@export var food_prices = {
	"burger": 5,   # $5
	"pizza": 8,    # $8
	"soda": 2,     # $2
	"fries": 4     # $4
}

var spawner = null  
var order: Array[String] = []
var original_order: Array[String] = []  
var patience_started = false  
@export var patience_time = 2.0  # ✅ Patience time stored inside the script

# -- Node References --
@onready var order_label: Label3D = $OrderLabel
@onready var area: Area3D = $DetectionArea  
@onready var received: AudioStreamPlayer3D = $received
@onready var error: AudioStreamPlayer3D = $error
@onready var hey: AudioStreamPlayer3D = $notice
@onready var anim: AnimationPlayer = $"character-male-a2/AnimationPlayer"

func _ready():
	anim.play("idle")
	order = pick_random_order()
	original_order = order.duplicate(true)
	area.body_entered.connect(_on_food_entered)

# --------------------------------------------------------------------------
# ORDER & PATIENCE FUNCTIONS
# --------------------------------------------------------------------------
func pick_random_order() -> Array[String]:
	var food_options: Array[String] = ["burger", "pizza", "soda", "fries"]
	var order_count = randi_range(1, 3)
	var selected_orders: Array[String] = []
	while selected_orders.size() < order_count:
		var food_item = food_options.pick_random()
		if food_item not in selected_orders:
			selected_orders.append(food_item)
	return selected_orders

func update_order_label():
	var formatted_order = ", ".join(order)
	order_label.text = "Order: %s\nPatience: %d" % [formatted_order, int(patience_time)]

func start_patience_timer():
	if not patience_started:
		update_order_label()
		patience_started = true
		anim.play("walk")
		await anim.animation_finished
		anim.play("interact-left")
		hey.play()
		await anim.animation_finished
		anim.play("idle")
		set_process(true)

func _process(delta):
	if patience_started and patience_time > 0:
		patience_time -= delta
		update_order_label()
		if patience_time <= 0:
			_on_patience_timer_timeout()

# --------------------------------------------------------------------------
# FOOD DETECTION & ORDER HANDLING
# --------------------------------------------------------------------------
func _on_food_entered(body: Node3D):
	if body is RigidBody3D:
		for food_item in order:
			if body.is_in_group(food_item):
				print("✅ Customer received correct food:", food_item)
				anim.play("emote-yes")
				received.play()
				body.queue_free()
				order.erase(food_item)
				update_order_label()
				if order.is_empty():
					var total_price = calculate_order_price()
					add_cash(total_price)
					await received.finished
					leave()
				return
		error.play()
		anim.play("emote-no")
		print("❌ Wrong food given!")

func calculate_order_price() -> int:
	var total_price = 0
	for food_item in original_order:
		if food_item in food_prices:
			total_price += food_prices[food_item]
	return total_price

func add_cash(amount: int):
	print("💰 Earned $", amount)
	var game_manager = get_tree().get_first_node_in_group("GameManager")
	if game_manager and game_manager.has_method("update_cash_label"):
		game_manager.update_cash_label(amount)
	else:
		push_error("🚨 GameManager not found!")

# --------------------------------------------------------------------------
# CUSTOMER LEAVE FUNCTION
# --------------------------------------------------------------------------
func leave():
	set_process(false)
	var target_position = global_transform.origin + Vector3(-5, 0, 0)
	var direction = (target_position - global_transform.origin).normalized()
	var target_basis = Basis.looking_at(-direction, Vector3.UP)
	var target_rotation = target_basis.get_euler()
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "rotation", target_rotation, 0.5)
	await tween.finished
	tween = create_tween()
	tween.tween_property(self, "global_transform:origin", target_position, 1.8)
	anim.play("walk")
	await anim.animation_finished
	anim.play("walk")
	await tween.finished
	queue_free()
	if spawner and spawner.has_method("on_customer_leave"):
		spawner.on_customer_leave()

func _on_patience_timer_timeout():
	print("⏳ Customer left due to impatience!")
	leave()
