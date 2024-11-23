extends Node2D

const GAME_SCENE = preload("res://scenes/space_battle.tscn")
const FUEL_SCENE = preload("res://scenes/fuel_battle.tscn")
const TEXT_SCENE = preload("res://scenes/text_scene.tscn")

@onready var main_menu: Node = get_node("Menu")
@onready var current_child: Node = get_node("Menu")
var game: Node

# UTILITY

func switch_new_scene(SCENE, parametrize: Callable) -> Node:
	var y = SCENE.instantiate()
	switch_scene(y)
	parametrize.call(y)
	return y

func switch_scene(scene: Node):
	current_child.get_node("Veil").veil()
	await get_tree().create_timer(0.3).timeout
	var x = current_child
	remove_child.call_deferred(x)
	add_child(scene)
	scene.get_node("Veil").unveil()
	current_child = scene

func transition(time:float, text, callback: Callable):
	switch_new_scene(TEXT_SCENE, ptext.bind(text))
	get_tree().create_timer(time).timeout.connect(callback)

# PARAMETERS

func ptext(scene, text):
	scene.set_text(text)

func pgame(scene, nb_players):
	scene.nb_players = nb_players
	scene.fuel_battle_start.connect(on_fuel_battle_start)
	scene.death.connect(on_death)
	scene.win.connect(on_win)

func pfuel(scene, playersAlive):
	scene.playersAlive = playersAlive
	scene.end_game.connect(on_fuel_battle_end)	

# EVENTS

func on_death(player: int):
	transition(3, "Player %1.f is eliminated" % player, on_death1)
	
func on_death1():
	switch_scene(game)
	game.next_step()

func on_win(player):
	transition(5, "Player %1.f is the winner !" % player, on_win1)
	
func on_win1():
	switch_scene(main_menu)

func on_start_game(nb_players):
	transition(1.6, "GAME\nSTART!", on_start_game1.bind(nb_players))
	
func on_start_game1(nb_players):
	game = switch_new_scene(GAME_SCENE, pgame.bind(nb_players))
	
func on_fuel_battle_start(playersAlive):
	transition(1.6, "Time to\nfuel up!", on_fuel_battle_start1.bind(playersAlive))

func on_fuel_battle_start1(playersAlive):
	switch_new_scene(FUEL_SCENE, pfuel.bind(playersAlive))
	
func on_fuel_battle_end(score, playersAlive):
	var text = null
	for i in range(4):
		if playersAlive[i]:
			if text == null:
				text = "Player %1.f: %3.f" % [i+1,score[i]]
			else:
				text += "\nPlayer %1.f: %3.f" % [i+1,score[i]]
	transition(4, text, on_fuel_battle_end1.bind(score))

func on_fuel_battle_end1(score):
	switch_scene(game)
	game.end_fuel_battle(score)

