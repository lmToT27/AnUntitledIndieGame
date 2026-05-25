extends Node

var current_day : int = 1
var pacifist_streak : int = 0
var total_kills_today : int = 0

var guilt_score : float = 20.0

const REQUIRED_STREAK_FOR_TRUE_ENDING : int = 3

signal environment_changed(current_streak: int)

func OnEnemyKilled() -> void:
	total_kills_today += 1
	pacifist_streak = 0
	guilt_score += 0.2

func OnSunrise() -> void:
	current_day += 1
	
	if total_kills_today == 0:
		pacifist_streak += 1
		guilt_score = max(0, guilt_score - 4.0)
		environment_changed.emit(pacifist_streak)
	else:
		pass
		
	total_kills_today = 0

func CanTriggerTrueEnding() -> bool:
	return pacifist_streak >= REQUIRED_STREAK_FOR_TRUE_ENDING
