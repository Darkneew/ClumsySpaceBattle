extends CharacterBody2D

signal hurt(lethal: bool)

var SPEED : float = 3000
var DEVIATION_LIMIT = 0.8
var ROTATE_SPEED = 0.6

var is_moving := false
var next: Callable
var fuel: float 
var health: int 
var player: int

var last_rotation: float
var last_pos: Vector2

@onready var timer: Timer = get_node("MovementTimer")
@onready var dtimer: Timer = get_node("DeviationTimer")
var deviation: float = 0

func speed():
	if 2*timer.time_left > timer.wait_time:
		return lerpf(0, SPEED, (2*timer.time_left)/timer.wait_time) * (1 + fuel / 30)
	else:
		return lerpf(SPEED, 0, (timer.wait_time - 2*timer.time_left)/timer.wait_time) * (1 + fuel / 30)

func move(_fuel: float, _health, _player, _next: Callable):
	last_rotation = rotation
	last_pos = position
	deviation = 0
	fuel = _fuel
	health = _health
	next = _next
	player = _player
	is_moving = true
	timer.start(2 + fuel/20)
	dtimer.start(0.3)

func die():
	$AnimationPlayer.play("death")
	await $AnimationPlayer.animation_finished
	queue_free.call_deferred()

func _physics_process(delta):
	if not is_moving:
		return
	rotation += delta * (deviation + Input.get_axis(str(player + 1) + "_left", str(player + 1) + "_right")) * ROTATE_SPEED
	velocity = Vector2.UP.rotated(rotation) * delta * speed()
	move_and_slide()
	if get_slide_collision_count() > 0:
		is_moving = false
		var col = get_last_slide_collision().get_collider()
		if col.collision_layer & 4:
			hurt.emit(true, reset)
		elif col.collision_layer & 1:
			hurt.emit(false, reset)
		elif col.collision_layer & 2:
			col.hurt.emit(false, reset)

func reset():
	rotation = last_rotation
	position = last_pos

func _on_timeout():
	if not is_moving:
		return
	is_moving = false
	next.call()


func _on_deviation():
	if not is_moving:
		deviation = 0
		return
	deviation = randf_range(-DEVIATION_LIMIT, DEVIATION_LIMIT) * (4 - health)
	dtimer.start(randf_range(0.5, 4))
