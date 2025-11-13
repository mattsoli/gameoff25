extends Node2D
@onready var spawn_timer: Timer = %CharacterSpawnTimer
@onready var happiness_bar: ProgressBar = %HappinessBar
@onready var gameover_text: Label = %GameOverText

var characterScene = preload("res://scenes/Character.tscn")

var target_config: Dictionary  = {}
var characters: Character
const MAX_PART_ID: int = 2
var is_gameover: bool = false

func _ready():
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	spawn_timer.start()
	
	print("Target Config: ", generate_new_target())
	
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

func generate_new_target() -> Dictionary:
	target_config = {}
	
	for part_type in BodyParts.PartsType.values():
		var part_name = BodyParts.PartsType.keys()[part_type]
		target_config[part_name] = randi_range(1, MAX_PART_ID)

	return target_config
	
func _on_spawn_timer_timeout():
	spawn_person()

func spawn_person():
	var characterInstance = characterScene.instantiate() as Character
	add_child(characterInstance)
	
	var spawnSide: int = randi_range(0, 1)
	var spawnPosition: PathFollow2D
	
	characterInstance.set_character(spawnSide, target_config)
	
	if spawnSide == 0:
		# LEFT
		spawnPosition = %SpawnPositionLeft
	elif spawnSide == 1:
		# RIGHT
		spawnPosition = %SpawnPositionRight
		
		# spawnPosition = %SpawnPositionLeft if spawnSide == 0 else %SpawnPositionRight
		
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
	if(target_config == _character.config):
		print("Character riconosciuto")
		happiness_bar.value += 10
	else:
		print("Sconosciuto salutato")
		happiness_bar.value -= 10
	pass
