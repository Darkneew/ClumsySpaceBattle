extends Node2D

const GAME_SCENE = preload("res://scenes/space_battle.tscn")
const FUEL_SCENE = preload("res://scenes/fuel_battle.tscn")
const SCORE_SCENE = preload("res://scenes/fuel_score.tscn")

var main_menu: Node
var game: Node

func on_start_game(nb_players):
	main_menu = get_node("Menu")
	remove_child.bind(main_menu).call_deferred()
	game = GAME_SCENE.instantiate()
	game.nb_players = nb_players
	add_child(game)
	game.fuel_battle_start.connect(on_fuel_battle_start)

func on_fuel_battle_start(nb_players):
	remove_child.bind(game).call_deferred()
	var fuel_scene = FUEL_SCENE.instantiate()
	fuel_scene.player_number = nb_players
	add_child(fuel_scene)
	fuel_scene.end_game.connect(on_fuel_battle_end)	
	
func on_fuel_battle_end(scene, score, nbp):
	remove_child.bind(scene).call_deferred()
	var transcene = SCORE_SCENE.instantiate()
	var text = "P1: %3.f\nP2: %3.f" % [score[0], score[1]]
	if nbp > 2:
		text += "\nP3: %3.f" % score[2]
	if nbp > 3:
		text += "\nP4: %3.f" % score[3]
	transcene.get_node("Scoreboard").text = text
	add_child(transcene)
	get_tree().create_timer(4).timeout.connect(on_fuel_transition_end.bind(transcene, score))

func on_fuel_transition_end(scene, score):
	remove_child.bind(scene).call_deferred()
	add_child(game)
	game.end_fuel_battle(score)
	pass
