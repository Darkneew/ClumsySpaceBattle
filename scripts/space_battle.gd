extends Node2D

signal fuel_battle_start(nb_player: int)

enum State {DIRECTING, FUELING, MOVING}

@export var nb_players: int
var _state : State
var _player_turn: int
var fuel := [0,0,0,0]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_state = State.DIRECTING
	_player_turn = 0

func end_fuel_battle(score):
	fuel = score
	next_step()

func next_step():
	if _state == State.FUELING:
		_player_turn = 1
		_state = State.MOVING
		begin_move()
		return
	elif _state == State.DIRECTING:
		if _player_turn == nb_players:
			_state = State.FUELING
			fuel_battle_start.emit(nb_players)
			return
		_player_turn += 1
		begin_direct()
		return
	elif _state == State.MOVING:
		if _player_turn == nb_players:
			_player_turn = 1
			_state = State.DIRECTING
			begin_direct()
		_player_turn += 1
		begin_move()
		return

func begin_move():
	pass
	
func begin_direct():
	pass
