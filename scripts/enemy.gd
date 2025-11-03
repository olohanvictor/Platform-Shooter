extends CharacterBody2D

const SPD = 700.0
const JUMP = -700.0
const GRAVITY = 1200.0
var life
var max_life = 50
@onready var health_bar: ProgressBar = $HealthBar
@onready var marker_2d: Marker2D = $Marker2D

func _ready():
	life = max_life

func take_damage(amount: int) -> void:
	life -= amount
	print("Inimigo levou dano! Vida:", life)
	if life <= 0:
		queue_free()  # morre
	
func _process(delta):
	health_bar.global_position = marker_2d.global_position
	health_bar.value = life
	health_bar.max_value = max_life

func _physics_process(delta: float) -> void:
	var velocity = self.velocity

	# Gravidade
	if not is_on_floor():
		velocity.y += GRAVITY * delta

	self.velocity = velocity
	move_and_slide()
