extends CharacterBody2D
class_name Character

enum ClickType {
	SINGLE,
	MULTI,
	HOLD
}

@onready var earsSlot: Sprite2D = $Ears/Sprite2D
@onready var headSlot: Sprite2D = $Head/Sprite2D
@onready var bodySlot: Sprite2D = $Body/Sprite2D
@onready var armsSlot: Sprite2D = $Arms/Sprite2D
@onready var legsSlot: Sprite2D = $Legs/Sprite2D
@onready var eyesSlot: Sprite2D = $Eyes/Sprite2D
@onready var noseSlot: Sprite2D = $Nose/Sprite2D
@onready var mouthSlot: Sprite2D = $Mouth/Sprite2D

@export var comicsOk: Texture2D
@export var comicsError: Texture2D
@export var comicsChecking: Texture2D

@onready var comicsSprite: Sprite2D = %ComicsSprite

const MAX_PART_ID: int = 2
var config: Dictionary = {}

@export var speed: float = 50.0
@export var max_speed: float = 100.0
var move_direction: Vector2
var is_direction_left: bool

var is_hailed: bool = false
var is_target: bool = false

# Click variables
@export var hold_time: float = 2.0
@export var max_click_count: int = 0
@export var multi_click_interval: float = 2.0
var click_type: ClickType
var click_count: int = 0
var hold_timer: float = 0.0
var click_timer: float = 0.0
var holding: bool = false
var mouse_down_time: float = 0.0

signal character_clicked(character: Character)
signal character_hold_clicked(character: Character)
signal character_multi_clicked(character: Character)

func _ready() -> void:
	config = generate_random_body_config()
	comicsSprite.visible = false

	var clickArea: Area2D = %ClickCollider
	clickArea.input_event.connect(_on_input_event)
	
func _process(delta: float) -> void:
	if is_hailed: return
	
	handle_hold_click(delta)
	
	if click_count > 0:
		comicsSprite.visible = true
		
		handle_single_click()
		handle_multi_clicks(delta)	
		

func check_is_target() -> void:
	if is_target:
		comicsSprite.texture = comicsOk
	else:
		comicsSprite.texture = comicsError
		speed = max_speed

func handle_hold_click(delta: float) -> void:
	if click_type == ClickType.HOLD:
		if holding:
			hold_timer += delta
			comicsSprite.visible = true
			comicsSprite.texture = comicsChecking
			
			if hold_timer >= hold_time:
				emit_signal("character_hold_clicked", self)
				
				holding = false
				check_is_target()
				
func handle_multi_clicks(delta: float) -> void:
	if click_type == ClickType.MULTI:
			click_timer += delta
			comicsSprite.texture = comicsChecking 
			
			if click_timer > multi_click_interval:
				if click_count > 1:
					print("multi click: ", click_count)
					if click_count >= max_click_count:
						emit_signal("character_multi_clicked", self)
						
						check_is_target()
							
						click_count = 0
					click_timer = 0.0

func handle_single_click() -> void:
	if click_type == ClickType.SINGLE:
		print("click singolo")
		emit_signal("character_clicked", self)
		check_is_target()
		click_count = 0
		click_timer = 0.0

func set_character(_is_direction_left: bool, _target_config: Dictionary) -> void:
	is_target = _target_config == config
	click_type = ClickType.values().pick_random() 
	move_direction = Vector2.LEFT if _is_direction_left else Vector2.RIGHT
	
	var click_type_name: String = ClickType.keys()[click_type]
	
	print("Character config: ", config)
	print("Character click type: ", click_type_name)
	print("Character is target: ", is_target)
	
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

func _physics_process(_delta: float ) -> void:
	velocity = move_direction * speed
	move_and_slide()
	
	# FIX DESTROY CHARACTERS
	if is_direction_left:
		if position.x > get_viewport_rect().size.x:
			queue_free()
	else:
		if position.x > -100:
			pass
			#queue_free()

func _on_input_event(_viewport: Object, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				# Mouse premuto: inizia il timer di hold
				holding = true
				hold_timer = 0.0
				mouse_down_time = Time.get_ticks_msec()
			else:
				# Mouse rilasciato: interrompi l'hold
				holding = false
				hold_timer = 0.0
				
				# Gestione multi-click
				click_count += 1
				click_timer = 0.0
