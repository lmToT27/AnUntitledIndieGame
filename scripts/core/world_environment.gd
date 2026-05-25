extends WorldEnvironment

const TRANSITION_DURATION : float = 5.0

func _ready() -> void:
	GameManager.environment_changed.connect(OnEnvironmentChanged)

func OnEnvironmentChanged(current_streak: int) -> void:
	var env = environment

	var tween = create_tween()
	tween.set_parallel(true)
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)

	if current_streak == 0:
		tween.tween_property(env, "fog_light_color", Color(0.8, 0.2, 0.2), TRANSITION_DURATION)
		tween.tween_property(env, "fog_density", 0.4, TRANSITION_DURATION)
	elif current_streak == 1:
		tween.tween_property(env, "fog_light_color", Color(0.6, 0.3, 0.3), TRANSITION_DURATION)
		tween.tween_property(env, "fog_density", 0.2, TRANSITION_DURATION)
	elif current_streak == 2:
		tween.tween_property(env, "fog_light_color", Color(0.5, 0.5, 0.5), TRANSITION_DURATION)
		tween.tween_property(env, "fog_density", 0.1, TRANSITION_DURATION)
	else:
		tween.tween_property(env, "fog_light_color", Color(0.2, 0.3, 0.4), TRANSITION_DURATION)
		tween.tween_property(env, "fog_density", 0.05, TRANSITION_DURATION)
