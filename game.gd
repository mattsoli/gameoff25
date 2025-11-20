extends Node3D

@onready var spawn_timer: Timer = %CharacterSpawnTimer
@onready var happiness_bar: ProgressBar = %HappinessBar
@onready var gameover_text: Label = %GameOverText
@onready var debug_target_text: Label = %TargetConfigText
@onready var debug_antitarget_text: Label = %AntiTargetConfigText
@onready var target_config: TargetConfig = %TargetConfig

@onready var valid1: TextureRect = %Valid1
@onready var valid2: TextureRect  = %Valid2
@onready var valid3: TextureRect  = %Valid3

@onready var invalid1: TextureRect  = %Invalid1
@onready var invalid2: TextureRect  = %Invalid2

var characterScene: PackedScene = preload("res://scenes/Character.tscn")

@export var hail_point: int 
@export var max_body_parts_to_guess : int
@export var max_body_parts_to_avoid : int

const MAX_PART_ID: int = 3

var is_gameover: bool = false

func _ready() -> void:
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	spawn_timer.start()

	valid1.texture = target_config.valid_config[0].texture
	valid2.texture = target_config.valid_config[1].texture
	valid3.texture = target_config.valid_config[2].texture
	
	invalid1.texture = target_config.invalid_config[0].texture
	#invalid2.texture = target_config.invalid_config[1].texture

func _process(_delta: float) -> void:
	handle_gameover()

func handle_gameover() -> void:
	if is_gameover:
		spawn_timer.stop()
		return

	if happiness_bar.value == 0:
		gameover_text.text = "Happiness is 0\nYou Lose!"
		is_gameover = true

	elif happiness_bar.value == 100:
		gameover_text.text = "Happiness is 100\nYou Win!"
		is_gameover = true


func _on_spawn_timer_timeout() -> void:
	spawn_person()


func spawn_person() -> void:
	var characterInstance: Character = characterScene.instantiate() as Character
	add_child(characterInstance)

	var spawnSide: int = randi_range(0, 1)
	var spawnPosition: PathFollow3D

	characterInstance.set_character(spawnSide == 0, target_config.valid_config, target_config.invalid_config)

	spawnPosition = %SpawnPositionRight if spawnSide == 0 else %SpawnPositionLeft
	spawnPosition.progress_ratio = randf()

	characterInstance.global_position = spawnPosition.global_position

	match characterInstance.click_type:
		Character.ClickType.SINGLE:
			characterInstance.character_clicked.connect(_on_character_clicked)
		Character.ClickType.HOLD:
			characterInstance.character_hold_clicked.connect(_on_character_clicked)


func _on_character_clicked(_character: Character) -> void:
	if _character.is_hailed:
		return

	hail_character(_character)

func hail_character(_character: Character) -> void:
	_character.is_hailed = true

	if _character.is_target:
		print("Character riconosciuto")
		happiness_bar.value += hail_point
	else:
		print("Sconosciuto salutato")
		happiness_bar.value -= hail_point
