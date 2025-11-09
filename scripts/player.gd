extends CharacterBody2D

var bulletScene = preload("res://entities/bullet.tscn")
var damageIndicator = preload("res://entities/DamageIndicator.tscn")
@onready var sprite = $Sprite2D
@onready var HealthBar: ProgressBar = $HealthBar
@onready var HealthBarPlace: Marker2D = $HealthBarPlace

const spd = 600.0
const jump = -700.0
const gravity = 1200.0

var life: int
var max_life: int = 60
var shoot_cooldown = 0.3

var can_shoot = true

func _ready():
	life = max_life

func _process(delta):
	# Atualiza posição e valores da barra de vida
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

	# Movimento horizontal
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

	self.velocity = velocity
	move_and_slide()

	# Atirar
	if Input.is_action_just_pressed("shoot"):
		shoot()

func shoot():
	if can_shoot:
		var bullet = bulletScene.instantiate()
		bullet.position = $Marker2D.global_position
		bullet.direction = -1 if sprite.flip_h else 1
		get_parent().add_child(bullet)

		# Cooldown do tiro
		can_shoot = false
		await get_tree().create_timer(shoot_cooldown).timeout
		can_shoot = true
		
func showDamage(damage):
	var label = damageIndicator.instantiate()
	label.get_node("Label").text = "-" + str("%.2f" % damage)
	label.position = position
	owner.add_child(label)
