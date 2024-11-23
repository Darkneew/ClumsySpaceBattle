extends Node2D

signal fuel_battle_start(nb_player: Array)
signal death(player: int)
signal win(player: int)

enum State {SHIPCHOOSING, DIRECTING, FUELING, MOVING}

@export var nb_players: int
var in_transition : bool
var _state : State
var _player_turn: int
var fuel : Array
var shipsHealth: Array 
var shipChosen: Array
var ships: Array
var playersAlive := [false, false, false, false]

var rotationSpeed: float = 3

@onready var cam : Camera2D = $MainCamera
@onready var displayNode : RichTextLabel = $UI/Text
@onready var timer : Timer = $UI/TextTimer
var camSpeed = 1
var targetZoom : float = 0.2
var target: Node2D = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	in_transition = true
	_state = State.DIRECTING
	_player_turn = -1
	for i in range(4):
		if i < nb_players:
			playersAlive[i] = true
			fuel.append([0,i])
			shipChosen.append(0)
			shipsHealth.append([3, 3, 3])
			ships.append([])
			for j in range(3):
				ships[i].append(get_node("Ships/Ship%1.f%1.f" % [i+1, j+1]))
		else:
			for j in range(3):
				get_node("Ships/Ship%1.f%1.f" % [i+1, j+1]).queue_free.call_deferred()
	fuel.shuffle()
	await get_tree().create_timer(2).timeout
	next_step()

func sort_ascending(a, b):
	if a[0] < b[0]:
		return true
	return false

func end_fuel_battle(score):
	for i in range(nb_players):
		fuel[i] = [score[i],i]
	fuel.shuffle()
	fuel.sort_custom(sort_ascending)
	next_step()

func next_step():
	camSpeed = 1
	in_transition = true
	if _state == State.FUELING:
		target = null
		targetZoom = 0.2
		_state = State.MOVING
		if not is_inside_tree():
			await tree_entered
		display("Time to move!", 2)
		await timer.timeout
		_player_turn = 0
		if not playersAlive[fuel[nb_players - 1][1]]:
			next_step()
			return
		begin_move(fuel[nb_players - 1][1])
	elif _state == State.DIRECTING:
		_player_turn += 1
		if _player_turn >= nb_players:
			_state = State.FUELING
			fuel_battle_start.emit(playersAlive)
		else:
			_state = State.SHIPCHOOSING
			if not playersAlive[fuel[_player_turn][1]]:
				next_step()
				return
			begin_choose(fuel[_player_turn][1])
	elif _state == State.MOVING:
		_player_turn += 1
		if _player_turn >= nb_players:
			_player_turn = 0
			_state = State.SHIPCHOOSING
			target = null
			targetZoom = 0.2
			display("Next round", 3)
			await timer.timeout
			if not playersAlive[fuel[0][1]]:
				next_step()
				return
			begin_choose(fuel[0][1])
		else:
			if not playersAlive[fuel[nb_players - 1 - _player_turn][1]]:
				next_step()
				return
			begin_move(fuel[nb_players - 1 - _player_turn][1])
	elif _state == State.SHIPCHOOSING:
		_state = State.DIRECTING
		if not playersAlive[fuel[_player_turn][1]]:
				next_step()
				return
		begin_direct(fuel[_player_turn][1])

func _on_text_timeout():
	displayNode.text = ""

func display(text: String, time : float = 1):
	if not timer.is_inside_tree():
		await timer.tree_entered
	displayNode.text = "[center]%s[/center]" % text
	timer.start(time)

func selectShip(player: int, ship: int):
	shipChosen[player] = ship-1
	shipChosen[player] = find_next(player, 1)
	target = ships[player][shipChosen[player]]
	display("Ship %1.f\nHealth: %1.f" % [shipChosen[player] + 1, shipsHealth[player][shipChosen[player]]], 3)

func begin_move(player: int):
	display("Turn of player %1.f" % (player + 1), 2)
	target = null
	targetZoom = 0.2
	await timer.timeout
	if shipsHealth[player][shipChosen[player]] <= 0:
		display("Ship is dead.." % (player + 1), 2)
		await timer.timeout
		next_step()
		return
	targetZoom = 1.2
	target = ships[player][shipChosen[player]]
	display("3")
	await timer.timeout
	display("2")
	await timer.timeout
	display("1")
	await timer.timeout
	in_transition = false
	camSpeed = 3
	target.move(fuel[nb_players - 1 - _player_turn][0], shipsHealth[player][shipChosen[player]], player, next_step)
	
func begin_choose(player: int):
	display("Turn of player %1.f" % (player + 1), 1.5)
	target = null
	targetZoom = 0.2
	await timer.timeout
	targetZoom = 1.2
	selectShip(player, 0)
	in_transition = false
	
func begin_direct(_player: int):
	display("Choose your direction", 1.5)
	await get_tree().create_timer(0.5).timeout 
	in_transition = false

func twocycle(obj):
	if obj > 2:
		return 0
	elif obj < 0:
		return 2
	return obj

func find_next(_player, shift):
	var obj = twocycle(shipChosen[_player] + shift)
	if shipsHealth[_player][obj] <= 0:
		obj = twocycle(obj + shift)
	if shipsHealth[_player][obj] <= 0:
		obj = twocycle(obj + shift)
	return obj

func _process(delta):
	# CAMERA
	if target == null:
		cam.position = lerp(cam.position, Vector2.ZERO, camSpeed*delta)
	else:
		cam.position = lerp(cam.position, target.position, camSpeed*delta)
	cam.zoom = Vector2(lerpf(cam.zoom.x, targetZoom, camSpeed*delta),lerpf(cam.zoom.x, targetZoom, camSpeed*delta))
	
	if in_transition:
		return
	var pl = fuel[_player_turn][1]
	# Choice of ship 
	if _state == State.SHIPCHOOSING:
		if Input.is_action_just_pressed(str(pl + 1) + "_up"):
			next_step()
		elif Input.is_action_just_pressed(str(pl + 1) + "_left"):
			selectShip(pl, find_next(pl, -1))
		elif Input.is_action_just_pressed(str(pl + 1) + "_right"):
			selectShip(pl, find_next(pl, 1))
	# Direction
	elif _state == State.DIRECTING:
		if Input.is_action_just_pressed(str(pl + 1) + "_up"):
			next_step()
		else:
			ships[pl][shipChosen[pl]].rotation += Input.get_axis(str(pl+1) + "_left", str(pl+1) + "_right") * delta * rotationSpeed

func last_player():
	for i in range(4):
		if playersAlive[i]:
			return i
	return -1

func get_hurted(lethal: bool, reset: Callable, player: int, ship: int):
	if player-1 == fuel[nb_players - 1 - _player_turn][1] and not ship-1 == shipChosen[player-1]:
		pass
	elif not lethal:
		shipsHealth[player-1][ship-1] -= 1
		if player-1 != fuel[nb_players - 1 - _player_turn][1]:
			target = ships[player-1][ship-1]
			reset.call()
	else:
		shipsHealth[player-1][ship-1] = 0
	if shipsHealth[player-1][ship-1] == 0:
		target = ships[player-1][ship-1]
		ships[player-1][ship-1].die()
	await get_tree().create_timer(1).timeout
	if shipsHealth[player-1].count(0) == 3:
		playersAlive[player-1] = false
		if playersAlive.count(true) == 1:
			win.emit(last_player() + 1)
		else:
			death.emit(player)
	else:
		next_step()
