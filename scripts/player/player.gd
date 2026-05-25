extends CharacterBody3D

enum State {
	IDLE,
	COMBAT,
	SHEATHE
}

var current_state = State.IDLE
var is_night : bool = false

var current_stamina : float = 150.0

const BASE_STAMINA_COST : float = 15.0
const WEIGHT_FACTOR : float = 2.0
const HOLD_TIME_REQUIRED : float = 3.0

var hold_timer : float = 0.0

func _physics_process(delta: float) -> void:
	match current_state:
		State.IDLE:
			HandleIdling()
		State.COMBAT:
			HandleCombat()
		State.SHEATHE:
			HandleSheathe(delta)

func HandleIdling() -> void:
	if Input.is_action_just_pressed("attack"):
		current_state = State.COMBAT
	elif Input.is_action_just_pressed("sheathe"):
		current_state = State.SHEATHE
		hold_timer = 0.0

func HandleCombat() -> void:
	var stamina_cost : float = BASE_STAMINA_COST

	if is_night:
		stamina_cost += WEIGHT_FACTOR * GameManager.guilt_score
	
	if current_stamina >= stamina_cost:
		current_stamina -= stamina_cost
		if is_night:
			PerformHeavyAttack()
		else:
			PerformNormalAttack()
		await get_tree().create_timer(0.5).timeout 
		
	else:
		print(current_stamina,stamina_cost)
		print("Out of stamina! Cannot attack.")

	current_state = State.IDLE


func HandleSheathe(delta: float) -> void:
	if Input.is_action_pressed("sheathe"):
		hold_timer += delta
		print("Holding... ", hold_timer)
		
		if hold_timer >= HOLD_TIME_REQUIRED:
			if is_night:
				TriggerTrueEnding()
			else:
				PerformNormalSheathe()
			
			hold_timer = 0.0
			current_state = State.IDLE
			
	elif Input.is_action_just_released("sheathe"):
		hold_timer = 0.0
		current_state = State.IDLE

func PerformNormalAttack() -> void:
	print("normal attack")

func PerformHeavyAttack() -> void:
	print("a heavy slash")

func PerformNormalSheathe() -> void:
	print("normal sheathe")

func TriggerTrueEnding() -> void:
	if GameManager.CanTriggerTrueEnding():
		print("true ending triggered!")
		pass
	else:
		PerformNormalSheathe()
