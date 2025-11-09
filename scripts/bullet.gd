extends Area2D

const spd = 1200.0
var direction := 1  # 1 = direita, -1 = esquerda
var damage = [5, 10]

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))

func _physics_process(delta):
	position.x += spd * direction * delta

func _on_body_entered(body):
	if body.is_in_group("enemy"):
		print("Bala atingiu o inimigo!")
		if body.has_method("take_damage"):
			var final_damage = randf_range(damage[0], damage[1])
			body.take_damage(randf_range(damage[0], damage[1]))
			body.showDamage(final_damage)
		queue_free()
