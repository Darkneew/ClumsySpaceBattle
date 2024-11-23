extends CanvasLayer

signal start(_nb_players: int)

var nb_players := 2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$NumberPlayers.text = str(nb_players)
	$Veil.unveil()

func on_start():
	start.emit(nb_players)
	
func pm_players(pm: int):
	nb_players = clamp(nb_players + pm, 2, 4)
	$NumberPlayers.text = str(nb_players)
