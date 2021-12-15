extends Area

func _on_Area_body_entered(body):
	if body.has_method("can_eat"):
		body.can_eat(true)


func _on_Area_body_exited(body):
	if body.has_method("can_eat"):
		body.can_eat(false)
