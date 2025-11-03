extends CharacterBody2D

const SPEED = 300.0
const JUMP_FORCE = -700.0
const GRAVITY = 1200.0

var life: int
var max_life: int = 50

var damage

@onready var health_bar: ProgressBar = $HealthBar
@onready var marker_2d: Marker2D = $Marker2D
@onready var player = get_tree().get_first_node_in_group("player")

func _ready():
	life = max_life

func take_damage(amount: int) -> void:
	life -= amount
	print("Inimigo levou dano! Vida:", life)
	if life <= 0:
		queue_free()

func _process(delta):
	# Mantém a barra de vida no lugar certo
	health_bar.global_position = marker_2d.global_position
	health_bar.value = life
	health_bar.max_value = max_life

func _physics_process(delta: float) -> void:
	# Seguir o player
	var velocity = self.velocity

	if player:
		if global_position.distance_to(player.global_position) > 20:
			var direction = (player.global_position - global_position).normalized()
			velocity.x = direction.x * SPEED

	# Gravidade
	if not is_on_floor():
		velocity.y += GRAVITY * delta

	self.velocity = velocity
	move_and_slide()

func dodge():
	# Pulo de desvio
	if is_on_floor():
		velocity.y = JUMP_FORCE

func _on_area_2d_area_entered(area):
	if area.is_in_group("bullet"):
		print("Bala detectada! Desviando...")
		dodge()
