extends Node2D
@onready var spawn_timer: Timer = %CharacterSpawnTimer
@onready var happiness_bar: ProgressBar = %HappinessBar

var characterScene = preload("res://scenes/Character.tscn")

var target_config: Dictionary  = {}
var characters: Character
const MAX_PART_ID: int = 2


func _ready():
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	spawn_timer.start()
	
	print("Target Config: ", generate_new_target())

func generate_new_target() -> Dictionary:
	target_config = {}
	
	for part_type in BodyParts.PartsType.values():
		var part_name = BodyParts.PartsType.keys()[part_type]
		target_config[part_name] = randi_range(1, MAX_PART_ID)

	return target_config
	
func _on_spawn_timer_timeout():
	spawn_person()

func spawn_person():
	var characterInstance = characterScene.instantiate() as CharacterBody2D
	add_child(characterInstance)
	characterInstance.position.y = 300.0
	
	characterInstance.character_clicked.connect(_on_character_clicked)
	pass

func _on_character_clicked(_character):
	if _character.is_hailed:
		return
	
	_character.is_hailed = true
	if(target_config == _character.caracteristics):
		print("Character riconosciuto")
		happiness_bar.value += 10
	else:
		print("Sconosciuto salutato")
		happiness_bar.value -= 10
		
