extends RigidBody3D

func _ready():
	add_to_group("soda")  # Add to the "soda" group for easy detection
	print("🥤 Soda is ready!")
	
