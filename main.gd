extends Node2D
@onready var spawn_timer: Timer = %CharacterSpawnTimer
@onready var happiness_bar: ProgressBar = %HappinessBar
@onready var gameover_text: Label = %GameOverText
@onready var debug_target_text: Label = %TargetConfigText
@onready var debug_antitarget_text: Label = %AntiTargetConfigText 

var characterScene: PackedScene = preload("res://scenes/Character.tscn")

@export var hail_point: int 

var target_config: Dictionary  = {}
var anti_target_config: Dictionary = {}
var characters: Character
const MAX_PART_ID: int = 2
var is_gameover: bool = false

func _ready() -> void:
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	spawn_timer.start()
	
	target_config = generate_new_config()
	debug_target_text.text = "Target:\n"+str(target_config)
	anti_target_config = generate_anticonfig(target_config)
	debug_antitarget_text.text = "Anti Target:\n"+str(anti_target_config)
	
	print("Target Config: ", target_config)
	print("Anti Target Config: ", anti_target_config)
	
func _process(_delta: float) -> void:
	handle_gameover()

func handle_gameover() -> void:
	if is_gameover:
		spawn_timer.stop()
	
	if happiness_bar.value == 0:
		gameover_text.text = "Happiness is 0\nYou Lose!"
		is_gameover = true
		
	elif happiness_bar.value == 100:
		gameover_text.text = "Happiness is 100\nYou Win!"
		is_gameover = true

func generate_new_config() -> Dictionary:
	var config: Dictionary = {}
	
	for part_type: int in BodyParts.PartsType.values():
		var part_name: String = BodyParts.PartsType.keys()[part_type]
		config[part_name] = randi_range(1, MAX_PART_ID)

	return config
	
func generate_anticonfig(_target_config: Dictionary) -> Dictionary:
	var config: Dictionary = {}
	
	for part_type: int in BodyParts.PartsType.values():
		var part_name: String = BodyParts.PartsType.keys()[part_type]
		
		var available_ids: Array = []
		for id: int in range(1, MAX_PART_ID + 1):
			if _target_config[part_name] != id:
				available_ids.append(id)
		
		# Scegli un valore diverso dal target
		config[part_name] = available_ids.pick_random()
	
	return config

	
func _on_spawn_timer_timeout() -> void:
	spawn_person()

func spawn_person() -> void:
	var characterInstance: Character = characterScene.instantiate() as Character
	add_child(characterInstance)
	
	var spawnSide: int = randi_range(0, 1)
	var spawnPosition: PathFollow2D
	
	characterInstance.set_character(spawnSide, target_config)
	
	spawnPosition = %SpawnPositionLeft if spawnSide == 0 else %SpawnPositionRight
	spawnPosition.progress_ratio = randf()
	
	characterInstance.global_position = spawnPosition.global_position
	
	match characterInstance.click_type:
		Character.ClickType.SINGLE:
			characterInstance.character_clicked.connect(_on_character_clicked)
		Character.ClickType.MULTI:
			characterInstance.character_multi_clicked.connect(_on_character_clicked)
		Character.ClickType.HOLD:
			characterInstance.character_hold_clicked.connect(_on_character_clicked)
	pass

func _on_character_clicked(_character: Character) -> void:
	if _character.is_hailed:
		return
	
	hail_character(_character)
	
func hail_character(_character: Character) -> void:
	_character.is_hailed = true
	
	if is_valid_character(_character.config, target_config, anti_target_config):
		print("Character riconosciuto")
		happiness_bar.value += hail_point
	else:
		print("Sconosciuto salutato")
		happiness_bar.value -= hail_point
	pass

func is_valid_character(_character_config: Dictionary, _target_config: Dictionary, _anti_target_config: Dictionary) -> bool:
	# Verifica che ci sia almeno un elemento che corrisponde al target
	var has_target_match: bool = false
	for key: String in _target_config.keys():
		if _character_config.has(key) and _character_config[key] == _target_config[key]:
			has_target_match = true
			break
	
	if not has_target_match:
		return false
	
	# Verifica che NON ci siano elementi che corrispondono all'anti-target
	for key: String in _anti_target_config.keys():
		if _character_config.has(key) and _character_config[key] == _anti_target_config[key]:
			return false
	
	return true
