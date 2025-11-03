extends CharacterBody2D

var bullet_scene = preload("res://entities/bullet.tscn")
@onready var sprite = $Sprite2D
@onready var HealthBar: ProgressBar = $HealthBar
@onready var HealthBarPlace: Marker2D = $HealthBarPlace

const spd = 700.0
const jump = -700.0
const gravity = 1200.0

var life: int
var max_life: int = 10

func _ready():
	life = max_life

func _process(delta):
	HealthBar.global_position = HealthBarPlace.global_position
	HealthBar.value = life
	HealthBar.max_value = max_life

func take_damage(amount: int) -> void:
	life -= amount
	print("Player levou dano! Vida:", life)
	if life <= 0:
		queue_free()

func _physics_process(delta):
	var velocity = self.velocity

	# Horizontal
	var horizontal = Input.get_axis("left", "right")
	if horizontal != 0:
		sprite.flip_h = horizontal < 0
	velocity.x = horizontal * spd

	# Gravidade e pulo
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		if Input.is_action_just_pressed("jump"):
			velocity.y = jump


	# Aplica movimento
	self.velocity = velocity

	# Atirando
	if Input.is_action_just_pressed("shoot"):
		shoot()

	move_and_slide()

func shoot():
	var bullet = bullet_scene.instantiate()
	bullet.position = $Marker2D.global_position
	bullet.direction = -1 if sprite.flip_h else 1
	get_parent().add_child(bullet)
