extends CharacterBody2D

const spd = 600.0
const jump_force = -700.0
const gravity = 1200.0
const attack_cooldown = 0.6

var life: int
var max_life: int = 60
var damage = [5, 10]
var can_attack = true 

var damageIndicator = preload("res://entities/DamageIndicatorEnemy.tscn")
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
	health_bar.global_position = marker_2d.global_position
	health_bar.value = life
	health_bar.max_value = max_life

func _physics_process(delta: float) -> void:
	var velocity = self.velocity

	# Seguir o player
	if player:
		if global_position.distance_to(player.global_position) > 20:
			var direction = (player.global_position - global_position).normalized()
			velocity.x = direction.x * spd

	# Gravidade
	if not is_on_floor():
		velocity.y += gravity * delta

	self.velocity = velocity
	move_and_slide()

	#Checar colisão com o player
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		if collision == null:
			continue

		var body = collision.get_collider()
		if body and body.is_in_group("player") and can_attack:
			var final_damage = randf_range(damage[0], damage[1])
			body.showDamage(final_damage)
			body.take_damage(final_damage)
			can_attack = false
			await get_tree().create_timer(attack_cooldown).timeout
			can_attack = true

func dodge():
	if is_on_floor():
		velocity.y = jump_force
		
		
func showDamage(damage):
	var label = damageIndicator.instantiate()
	label.get_node("Label").text = "-" + str("%.2f" % damage)
	label.position = position
	owner.add_child(label)

func _on_area_2d_area_entered(area):
	if area.is_in_group("bullet"):
		print("Bala detectada! Desviando...")
		dodge()
