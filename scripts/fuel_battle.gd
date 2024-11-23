extends Node2D

signal end_game(points, pa)

# check vitesse de spawn, qd est ce que ca s'arrete, nombre de spawn

@export var playersAlive: Array

var player_number
const NB_BALL_PER_PLAYER = 4
const SPAWNS = [Vector2(0,0), Vector2(1152, 648), Vector2(1152, 0), Vector2(0, 648)]
const SPAWN_ANGLES = [Vector2(1, 1)/sqrt(2), Vector2(-1, -1)/sqrt(2), Vector2(-1, 1)/sqrt(2), Vector2(1, -1)/sqrt(2)]
const FUEL = preload("res://scenes/fuel.tscn")
const TOTAL_TIME: float = 15

var points := [0,0,0,0]
var balls_to_send: int
var balls_left: int
var time_med: float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player_number = playersAlive.count(true)
	balls_to_send = NB_BALL_PER_PLAYER * player_number + randi_range(0, player_number * 2)
	balls_left = balls_to_send
	time_med = TOTAL_TIME / balls_to_send
	for i in range(1, 5):
		if playersAlive[i-1]:
			get_node("Map/Border" + str(i)).queue_free.call_deferred()
		else:
			get_node("Ship" + str(i)).queue_free.call_deferred()

func on_point(fuel: float, player: int):
	points[player - 1] += fuel
	balls_left -= 1
	if balls_left == 0:
		end_game.emit(points, playersAlive)

func on_ball_spawn():
	if balls_to_send == 0:
		return
	balls_to_send -= 1
	$FuelSpawner.wait_time = randf_range(time_med / 2, time_med * 1.5)
	$FuelSpawner.start()
	var spawn_nb = randi_range(0, 3)
	var fuel: RigidBody2D = FUEL.instantiate()
	$Fuel.add_child(fuel)
	fuel.position = SPAWNS[spawn_nb]
	fuel.linear_velocity = SPAWN_ANGLES[spawn_nb] * randf_range(fuel.MAX_SPEED / 5, fuel.MAX_SPEED)
	fuel.rand_size()
