extends Node3D

@export_group("Days Config")
@export var days: Array[GameDay]
var current_day: GameDay

@onready var happiness_bar: ProgressBar = %HappinessBar
@onready var gameover_text: Label = %GameOverText
@onready var debug_target_text: Label = %TargetConfigText
@onready var debug_antitarget_text: Label = %AntiTargetConfigText
@onready var target_config: TargetConfig = %CharacterConfig
@onready var combo_meter_text: Label = %ComboMeterText
@onready var combo_counter_text: Label = %ComboCounterText
@onready var day_timer_text: Label = %DayTimerText
@onready var day_counter_text: Label = %DayCounterText

# END DAY PANEL
@onready var end_day_panel: Control = %EndDayPanel
@onready var next_day_btn: Button = %NextDayButton

# END GAME PANEL
@onready var end_game_panel: Control = %EndGamePanel
@onready var restart_game_btn: Button = %RestartGameButton

@export_group("Target Icons")
@export var valid_icons: Array[TextureRect]
@export var invalid_icons: Array[TextureRect]

@export_group("Day Timer")
@onready var day_timer: Timer = %DayTimer

@export_group("Character Spawn")
@onready var spawn_timer: Timer = %CharacterSpawnTimer
@export var character_spawn_time: float = 5.0

@export_group("Hail points")
@export var hail_point: int 

@export_group("Combo Meter")
@export var min_combo_counter: int = 5
@export var medium_combo_counter: int = 10
@export var max_combo_counter: int = 20
@export var combo_mul_1: float = 1.5
@export var combo_mul_2: float = 2
@export var combo_mul_3: float = 3

@onready var popup: CustomPopup = %CustomPopup

var current_day_index: int = 0

var characterScene: PackedScene = preload("res://scenes/Character.tscn")

var is_game_over: bool = false
var is_day_over: bool = false

var combo_counter: int = 0
var combo_mul: float = 1

func _ready() -> void:
	show_popup("INIZIO " + str(current_day_index + 1) +  "° GIORNATA")
	
	day_timer.timeout.connect(_on_day_timer_timeout)
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	next_day_btn.pressed.connect(_on_next_day)
	restart_game_btn.pressed.connect(_on_restart_game)
	popup.on_popup_disappeared.connect(start_day)

func _process(_delta: float) -> void:
	handle_game_over()
	handle_combo_meter()
	update_day_ui()

func start_day() -> void:
	print("Start day " + str(current_day_index + 1))
	current_day = days[current_day_index]
	
	is_game_over = false
	is_day_over = false
	
	end_day_panel.hide()
	end_game_panel.hide()
	day_timer_text.show()
	
	target_config.set_target_config(current_day.max_valid_categories, current_day.max_invalid_categories)
	set_target_icons()
	
	start_timers()
	
func start_timers() -> void:
	start_day_timer()
	start_character_spawn_timer()

func update_day_ui() -> void:
	day_timer_text.text = str(int(day_timer.time_left))
	day_counter_text.text = "Day: " + str(current_day_index + 1)

func start_day_timer() -> void:
	day_timer.wait_time = current_day.max_day_duration + 1
	day_timer.start()

func start_character_spawn_timer() -> void:
	spawn_timer.wait_time = character_spawn_time
	spawn_timer.start()

func set_target_icons() -> void:
	# Valid categories icons
	for index: int in range(0, target_config.valid_categories.size()):
		valid_icons[index].texture = target_config.valid_categories[index].icon
	
	# Invalid categories icons
	for index: int in range(0, target_config.invalid_categories.size()):
		invalid_icons[index].texture = target_config.invalid_categories[index].icon

func day_over() -> void:
	end_day_panel.show()
	spawn_timer.stop()
	day_timer.stop()
	day_timer_text.hide()
		
	if happiness_bar.value < 50.0:
		# vecchietto finisce triste
		pass
	elif happiness_bar.value >= 50.0:
		# vecchietto finisce felice
		pass

func handle_game_over() -> void:
	if happiness_bar.value == 0:
		# vecchietto finisce triste
		gameover_text.text = "Happiness is 0\nYou Lose!"
		is_game_over = true
	elif happiness_bar.value == 100:
		# vecchietto finisce felice
		gameover_text.text = "Happiness is 100\nYou Win!"
		is_game_over = true

func go_next_day() -> void:
	current_day_index += 1
	pass

func spawn_person() -> void:
	var characterInstance: Character = characterScene.instantiate() as Character
	add_child(characterInstance)

	var spawnSide: int = randi_range(0, 1)
	var spawnPosition: PathFollow3D

	characterInstance.set_character(spawnSide == 0, target_config.valid_category_types, target_config.invalid_category_types, current_day.additional_character_speed)

	spawnPosition = %SpawnPositionRight if spawnSide == 0 else %SpawnPositionLeft
	spawnPosition.progress_ratio = randf()

	characterInstance.global_position = spawnPosition.global_position

	match characterInstance.click_type:
		Character.ClickType.SINGLE:
			characterInstance.character_clicked.connect(_on_character_clicked)
		Character.ClickType.HOLD:
			characterInstance.character_hold_clicked.connect(_on_character_clicked)

func handle_combo_meter() -> void:
	if combo_counter >= min_combo_counter and combo_counter < medium_combo_counter:
		combo_mul = combo_mul_1
	elif combo_counter >= medium_combo_counter and combo_counter < max_combo_counter:
		combo_mul = combo_mul_2
	elif combo_counter >= max_combo_counter:
		combo_mul = combo_mul_3
	else:
		combo_mul = 1
	
	combo_counter_text.text = "Combo : " + str(combo_counter)
	combo_meter_text.text = "Mul: " + str(combo_mul) + "X"

func hail_character(_character: Character) -> void:
	_character.is_hailed = true

	if _character.is_target:
		print("++++++++++++++++++++++")
		print("Character riconosciuto")
		combo_counter += 1
		happiness_bar.value += hail_point * combo_mul
		print("Happiness ottenuta: ",  hail_point * combo_mul)
	else:
		print("-------------------------")
		print("Sconosciuto salutato")
		combo_counter = 0
		happiness_bar.value -= hail_point
		print("Happiness rimossa: ", hail_point)	

func end_game() -> void:
	end_day_panel.hide()
	end_game_panel.show()
	
func _on_next_day() -> void:
	go_next_day()
	end_day_panel.hide()
	
	show_popup("INIZIO " + str(current_day_index + 1) +  "° GIORNATA")
	

func show_popup(main_text: String) -> void:
	popup.show_popup()
	popup.set_popup(main_text)
	popup.start_popup_timer()

func _on_restart_game() -> void:
	current_day_index = 0
	current_day = days[current_day_index]
	
	start_day()

func _on_day_timer_timeout() -> void:
	day_over()
	
	if current_day_index == 4:
		end_game() 

func _on_spawn_timer_timeout() -> void:
	spawn_person()

func _on_character_clicked(_character: Character) -> void:
	if _character.is_hailed:
		return
	hail_character(_character)
