extends StaticBody


func _on_DropArea_body_entered(body):
	if body.has_method("can_collect"):
		body.can_collect()
