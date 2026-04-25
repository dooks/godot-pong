extends CanvasLayer

@onready var players = GameState.players

func update_score() -> void:
	var text := ""
	var i := 1

	for player in players:
		text += "Player " + str(i) + ": "
		text += str(players[player].score) + "\n"
		i += 1
	$Score.text = text

func _ready() -> void:
	update_score()
	GameState.score_goal.connect(func(_p): update_score())
	GameState.reset_game.connect(update_score)
