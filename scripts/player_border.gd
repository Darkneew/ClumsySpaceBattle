extends StaticBody2D

signal point(points: float)

func _on_exit(body: Node2D) -> void:
	body.queue_free.call_deferred()
	point.emit(body.points)
