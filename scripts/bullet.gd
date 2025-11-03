extends Area2D

const SPD = 1200.0
var direction := 1  # 1 = direita, -1 = esquerda

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))

func _physics_process(delta):
	position.x += SPD * direction * delta

func _on_body_entered(body):
	if body.is_in_group("enemy"):
		print("Bala atingiu o inimigo!")
		if body.has_method("take_damage"):
			body.take_damage(10)
		queue_free()
