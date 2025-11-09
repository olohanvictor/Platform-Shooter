extends RigidBody2D

@onready var timer = $Timer

# Called when the node enters the scene tree for the first time.
func _ready():
	timer.connect("Timeout", didTimeOut)
	timer.start(0.9)
	linear_velocity = Vector2(randf_range(190, -190), randf_range(-310, -400))
	
func didTimeOut():
	queue_free()
