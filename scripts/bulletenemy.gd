extends Area2D

const SPD = 1200.0
var direction: Vector2 = Vector2.ZERO
var damage = [3, 6]

var start_pos: Vector2
const MAX_DISTANCE = 3000.0  # distância máxima antes de desaparecer

func _ready():
	start_pos = global_position
	add_to_group("enemy_bullet")
	connect("body_entered", Callable(self, "_on_body_entered"))

func _physics_process(delta):
	# movimento
	position += direction * SPD * delta

	# destruir só quando andar MUITO longe
	if global_position.distance_to(start_pos) > MAX_DISTANCE:
		queue_free()

func _on_body_entered(body):
	if body.is_in_group("player"):
		var final_damage = randf_range(damage[0], damage[1])

		# aplica dano
		if body.has_method("take_damage"):
			body.take_damage(final_damage)
			body.showDamage(final_damage)

		queue_free()
		return

	# se bater em parede/chão
	if body.is_in_group("solid"):
		queue_free()
