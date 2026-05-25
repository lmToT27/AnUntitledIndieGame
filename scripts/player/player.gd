extends CharacterBody3D

enum State {
	IDLE,
	COMBAT,
	SHEATHE
}

var current_state = State.IDLE
var is_night : bool = false

# MOVEMENT PARAMETERS
const SPEED : float = 4.0
const SPRINT_SPEED : float = 9.0
const JUMP_VELOCITY : float = 10
var gravity : float = ProjectSettings.get_setting("physics/3d/default_gravity") * 3

# JUMP PARAMETERS
const JUMP_COOLDOWN : float = 0.5
const JUMP_MOMENTUM_PENALTY : float = 0.6
var jump_cooldown_timer : float = 0.0
var was_on_floor : bool = true

# HEALTH & STAMINA
var max_health : float = 100.0
var current_health : float = 100.0
var max_stamina : float = 150.0
var current_stamina : float = 150.0

# STAMINA COST PARAMETERS
const BASE_STAMINA_COST : float = 15.0
const JUMP_STAMINA_COST : float = 10.0
const WEIGHT_FACTOR : float = 2.0
const HOLD_TIME_REQUIRED : float = 3.0

const STAMINA_DRAIN_RATE : float = 20.0
const STAMINA_REGEN_RATE : float = 15.0
const REGEN_DELAY : float = 0.5

var hold_timer : float = 0.0
var stamina_regen_timer : float = 0.0
var is_sprinting : bool = false

@export var mouse_sensitivity : float = 0.002
@onready var head = $Head
@onready var camera = $Head/Camera3D

@onready var health_bar = $HUD/MarginContainer/VBoxContainer/HealthBar
@onready var stamina_bar = $HUD/MarginContainer/VBoxContainer/StaminaBar


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	health_bar.max_value = max_health
	health_bar.value = current_health
	stamina_bar.max_value = max_stamina
	stamina_bar.value = current_stamina

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * mouse_sensitivity)
		head.rotate_x(-event.relative.y * mouse_sensitivity)
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-90), deg_to_rad(90))

func _physics_process(delta: float) -> void:
	if jump_cooldown_timer > 0:
		jump_cooldown_timer -= delta
		
	if stamina_regen_timer > 0:
		stamina_regen_timer -= delta

	is_sprinting = false
	
	var just_landed = is_on_floor() and not was_on_floor
	if just_landed:
		jump_cooldown_timer = JUMP_COOLDOWN
		stamina_regen_timer = REGEN_DELAY
	
	if not is_on_floor():
		velocity.y -= gravity * delta

	if is_on_floor():
		var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
		var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

		is_sprinting = Input.is_action_pressed("sprint") and direction != Vector3.ZERO and current_stamina > 0
		var current_speed = SPRINT_SPEED if is_sprinting else SPEED

		if direction:
			velocity.x = direction.x * current_speed
			velocity.z = direction.z * current_speed
		else:
			velocity.x = move_toward(velocity.x, 0, current_speed)
			velocity.z = move_toward(velocity.z, 0, current_speed)

		if is_sprinting:
			current_stamina -= STAMINA_DRAIN_RATE * delta
			current_stamina = max(current_stamina, 0)
			stamina_regen_timer = REGEN_DELAY
			UpdateUI()
			
	if Input.is_action_just_pressed("jump") and is_on_floor() and current_stamina >= JUMP_STAMINA_COST and jump_cooldown_timer <= 0.0:
		velocity.y = JUMP_VELOCITY
		
		velocity.x *= JUMP_MOMENTUM_PENALTY
		velocity.z *= JUMP_MOMENTUM_PENALTY
		
		current_stamina -= JUMP_STAMINA_COST
		stamina_regen_timer = REGEN_DELAY
		UpdateUI()

	if is_on_floor() and not is_sprinting and stamina_regen_timer <= 0.0 and current_stamina < max_stamina:
		current_stamina += STAMINA_REGEN_RATE * delta
		current_stamina = min(current_stamina, max_stamina)
		UpdateUI()

	move_and_slide()
	was_on_floor = is_on_floor()

	match current_state:
		State.IDLE:
			HandleIdling()
		State.COMBAT:
			HandleCombat()
		State.SHEATHE:
			HandleSheathe(delta)

func HandleIdling() -> void:
	if Input.is_action_just_pressed("attack"):
		StartAttack()
	elif Input.is_action_just_pressed("sheathe"):
		current_state = State.SHEATHE
		hold_timer = 0.0 

func StartAttack() -> void:
	current_state = State.COMBAT

	var stamina_cost : float = BASE_STAMINA_COST
	if is_night:
		stamina_cost += WEIGHT_FACTOR * GameManager.guilt_score

	if current_stamina >= stamina_cost:
		current_stamina -= stamina_cost
		
		stamina_regen_timer = REGEN_DELAY 
		UpdateUI()
		
		if is_night:
			PerformHeavyAttack()
		else:
			PerformNormalAttack()
		await get_tree().create_timer(0.5).timeout 
	else:
		print("Out of stamina! Cannot attack.")
		
	current_state = State.IDLE

func HandleCombat() -> void:
	pass

func HandleSheathe(delta: float) -> void:
	if Input.is_action_pressed("sheathe"):
		hold_timer += delta
		
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

func UpdateUI() -> void:
	health_bar.value = current_health
	stamina_bar.value = current_stamina

func TakeDamage(amount: float) -> void:
	current_health -= amount
	current_health = clamp(current_health, 0, max_health)
	UpdateUI()
	if current_health <= 0:
		print("Player Died!")

func PerformNormalAttack() -> void:
	print("normal attack")

func PerformHeavyAttack() -> void:
	print("a heavy slash")

func PerformNormalSheathe() -> void:
	print("normal sheathe")

func TriggerTrueEnding() -> void:
	pass
