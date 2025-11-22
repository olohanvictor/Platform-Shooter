extends CharacterBody2D

const spd = 600.0
const jump_force = -700.0
const gravity = 1200.0

var life: int
var max_life: int = 60
var damage = [5, 10]

var can_attack = true 
const attack_cooldown = 0.6
var can_shoot = true
var shoot_cooldown = 0.6

var state = ["beserk", "attack", "defense"]
var current_state = "beserk"


var damageIndicator = preload("res://entities/DamageIndicatorEnemy.tscn")
@onready var health_bar: ProgressBar = $HealthBar
@onready var marker_2d: Marker2D = $Marker2D
@onready var player = get_tree().get_first_node_in_group("player")
var bullet_scene = preload("res://entities/bulletenemy.tscn")

#Basics
func dodge():
	if is_on_floor():
		velocity.y = jump_force
		
func showDamage(damage):
	var label = damageIndicator.instantiate()
	label.get_node("Label").text = "-" + str("%.2f" % damage)
	label.position = position
	owner.add_child(label)

func take_damage(amount: int) -> void:
	life -= amount
	print("Enemy took damage! hp:", life)
	if life <= 0:
		queue_free()

func shoot():
	can_shoot = false

	var bullet = bullet_scene.instantiate()
	bullet.position = global_position

	var direction = (player.global_position - global_position).normalized()
	bullet.direction = direction

	get_parent().add_child(bullet)

	await get_tree().create_timer(shoot_cooldown).timeout
	can_shoot = true


#State Machine
func choose_state():
	current_state = state.pick_random()
	print("New state:", current_state)

func start_state_timer():
	var t = Timer.new()
	t.wait_time = 5
	t.autostart = true
	t.one_shot = false
	add_child(t)
	t.timeout.connect(choose_state)

#Estados
func beserk():
	print("state: beserk")
	if player:
		if global_position.distance_to(player.global_position) > 20:
			var direction = (player.global_position - global_position).normalized()
			velocity.x = direction.x * spd
			
func attack():
	print("state: attack")
	if not player:
		return
	
	if can_shoot:
		shoot()

func defense():
	print("state: defense")
	
#Main
func _ready():
	randomize()
	life = max_life
	start_state_timer()

func _process(delta):
	health_bar.global_position = marker_2d.global_position
	health_bar.value = life
	health_bar.max_value = max_life

func _physics_process(delta: float) -> void:
	velocity.x = 0
	match current_state:
		"beserk":
			beserk()
		"attack":
			attack()
		"defense":
			defense()

	# Gravidade
	if not is_on_floor():
		velocity.y += gravity * delta
	
	#Fazendo se mexer the fato
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

#Others
func _on_area_2d_area_entered(area):
	if current_state != "beserk":
		if area.is_in_group("bullet") and not area.is_in_group("enemy_bullet"):
			print("Bullet detected! Dodging...")
			dodge()
