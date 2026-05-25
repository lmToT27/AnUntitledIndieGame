extends Node3D

@onready var player = $Player 

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_page_up"): 
		GameManager.OnEnemyKilled()
		print("Killed one, guilt score: ", GameManager.guilt_score, " ---")

	if Input.is_action_just_pressed("ui_page_down"):
		player.is_night = !player.is_night
		print(player.is_night)

	if Input.is_action_just_pressed("ui_home"):
		player.is_night = false
		GameManager.OnSunrise()
		print("--- Day ", GameManager.current_day)
		print("--- Pacifist Streak: ", GameManager.pacifist_streak, " ---")
