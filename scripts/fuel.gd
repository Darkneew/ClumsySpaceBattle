extends RigidBody2D

const MAX_SPEED = 500

var points: float

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	if state.linear_velocity.length_squared() > MAX_SPEED * MAX_SPEED:
		state.linear_velocity = state.linear_velocity.normalized() * MAX_SPEED

func rand_size():
	points = randf_range(5, 15)
	$Sprite2D.scale = Vector2.ONE * 0.006 * points
	$CollisionShape2D.scale = Vector2.ONE * 0.03 * points
