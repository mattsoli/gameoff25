extends CharacterBody3D

class_name Character3D

enum ClickType {
	SINGLE,
	MULTI,
	HOLD
}

@onready var eyesSlot: Sprite3D = $Eyes/Sprite3D
@onready var headSlot: Sprite3D = $Head/Sprite3D
@onready var bodySlot: Sprite3D = $Body/Sprite3D

@export var comicsOk: Texture2D
@export var comicsError: Texture2D
@export var comicsChecking: Texture2D

@onready var comicsSprite: Sprite3D = $ComicsSprite

const MAX_PART_ID: int = 2
var config: Dictionary = {}

@export var speed: float = 50.0
@export var max_speed: float = 100.0
var move_direction: Vector3
var is_direction_left: bool

var is_hailed: bool = false
var is_target: bool = false

# Click variables
@export var hold_time: float = 1.5  # Tempo per considerare un hold (secondi)
@export var max_click_count: int = 3  # Numero di click necessari per multi-click
var click_type: ClickType
var click_count: int = 0
var hold_timer: float = 0.0
var holding: bool = false
var mouse_down_time: float = 0.0
var click_processed: bool = false  # Flag per evitare doppi processing

signal character_clicked(character: Character3D)
signal character_hold_clicked(character: Character3D)
signal character_multi_clicked(character: Character3D)

func _ready() -> void:
	config = generate_random_body_config()
	comicsSprite.visible = false

	var clickArea: Area3D = %ClickCollider
	clickArea.input_event.connect(_on_input_event)
	
func _process(delta: float) -> void:
	if is_hailed or click_processed:
		return

	# Gestione HOLD CLICK
	if click_type == ClickType.HOLD and holding:
		handle_hold_click(delta)
		return

	# Gestione SINGLE click - attiva subito al primo click
	if click_type == ClickType.SINGLE and click_count == 1:
		print("Click singolo")
		emit_signal("character_clicked", self)
		check_is_target()
		click_count = 0

	# Gestione MULTI click - attiva quando raggiunge il count richiesto
	if click_type == ClickType.MULTI and click_count >= max_click_count:
		print("Multi click completato: %d click" % click_count)
		emit_signal("character_multi_clicked", self)
		check_is_target()
		click_count = 0


func check_is_target() -> void:
	click_processed = true
	comicsSprite.visible = true
	
	if is_target:
		comicsSprite.texture = comicsOk
		print("✓ Target corretto!")
	else:
		comicsSprite.texture = comicsError
		speed = max_speed
		print("✗ Target sbagliato!")

func handle_hold_click(delta: float) -> void:
	hold_timer += delta
	comicsSprite.visible = true
	comicsSprite.texture = comicsChecking
	
	if hold_timer >= hold_time:
		print("Hold completato: %.2f secondi" % hold_timer)
		emit_signal("character_hold_clicked", self)
		holding = false
		hold_timer = 0.0
		check_is_target()

func set_character(_is_direction_left: bool, _target_config: Dictionary) -> void:
	is_target = _target_config == config
	click_type = ClickType.values().pick_random() 
	move_direction = Vector3.LEFT if _is_direction_left else Vector3.RIGHT
	
	var click_type_name: String = ClickType.keys()[click_type]
	
	print("─────────────────────────")
	print("Character config: ", config)
	print("Character click type: ", click_type_name)
	print("Character is target: ", is_target)
	print("─────────────────────────")
	
func generate_random_body_config() -> Dictionary:
	var body_config: Dictionary = {}
	
	for part_type: int in BodyParts.PartsType.values():
		var part_name: String = BodyParts.PartsType.keys()[part_type]
		
		body_config[part_name] = randi_range(1, MAX_PART_ID)
		
		match part_name:
			"head":
				headSlot.texture = load("res://resources/%s_%d.tres" % [part_name, body_config[part_name]]).texture
			"body":
				bodySlot.texture = load("res://resources/%s_%d.tres" % [part_name, body_config[part_name]]).texture
			"eyes":
				eyesSlot.texture = load("res://resources/%s_%d.tres" % [part_name, body_config[part_name]]).texture
		
	return body_config

func _physics_process(_delta: float) -> void:
	velocity = move_direction * speed
	move_and_slide()

func _on_input_event(_camera: Camera3D, event: InputEvent, _position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if click_processed:
			return
			
		if event.pressed:
			# Mouse premuto
			if click_type == ClickType.HOLD:
				holding = true
				hold_timer = 0.0
				comicsSprite.visible = true
				comicsSprite.texture = comicsChecking
			mouse_down_time = Time.get_ticks_msec()
		else:
			# Mouse rilasciato
			var press_duration: float = (Time.get_ticks_msec() - mouse_down_time) / 1000.0
			
			# Se era un tentativo di hold ma non è durato abbastanza
			if click_type == ClickType.HOLD and holding:
				holding = false
				hold_timer = 0.0
				comicsSprite.visible = false
				print("Hold interrotto (durata: %.2f secondi)" % press_duration)
				return
			
			# Per SINGLE e MULTI click
			if click_type != ClickType.HOLD:
				click_count += 1
				if click_type == ClickType.MULTI:
					comicsSprite.visible = true
					comicsSprite.texture = comicsChecking
				print("Click registrato: %d/%d" % [click_count, max_click_count if click_type == ClickType.MULTI else 1])
