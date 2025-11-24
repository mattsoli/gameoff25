extends CharacterBody3D

class_name Character

enum ClickType {
	SINGLE,
	HOLD
}



@onready var headSlot: Sprite3D = %HeadSprite
@onready var bodySlot: Sprite3D = %BodySprite
@onready var extraSlot: Sprite3D = %ExtraSprite

@onready var comicsSprite: Sprite3D = %ComicsSprite

@export var comicsOk: Texture2D
@export var comicsError: Texture2D
@export var comicsChecking: Texture2D

const MAX_PART_ID: int = 9

@export var speed: float = 2.0
@export var max_speed: float = 6.0

var move_direction: Vector3
var is_direction_left: bool

var is_hailed: bool = false
var is_target: bool = false

# Click variables
@export var hold_time: float = 1.5 
var click_type: ClickType
var is_clicked: bool
var hold_timer: float = 0.0
var holding: bool = false
var mouse_down_time: float = 0.0
var click_processed: bool = false  

var body_parts: Array[BodyParts]
var categories: Array[Category.CategoryType]

signal character_clicked(character: Character)
signal character_hold_clicked(character: Character)

func _ready() -> void:
	generate_random_body_config()
	comicsSprite.visible = false

	var clickArea: Area3D = %ClickCollider
	clickArea.input_event.connect(_on_input_event)
	
func _process(delta: float) -> void:
	if is_hailed or click_processed:
		return
		
	if is_clicked:
		print("Click singolo")
		emit_signal("character_clicked", self)
		check_is_target()

	if click_type == ClickType.HOLD and holding:
		handle_hold_click(delta)
		return

func generate_random_body_config() -> void:
	var body_config: Dictionary = {}
	
	for part_type: int in BodyParts.PartType.values():
		if part_type == BodyParts.PartType.extra: continue
		
		var part_name: String = BodyParts.PartType.keys()[part_type]
		body_config[part_name] = randi_range(1, MAX_PART_ID)
		
		# check with break if MAX PART ID not exists
		
		var body_part: BodyParts = load("res://resources/bodyparts/%s_%d.tres" % [part_name, body_config[part_name]])
		body_parts.append(body_part)
		
		var part_category: Category.CategoryType = body_part.category.category_type
		if part_category not in categories:
			categories.append(part_category)
		
		var part_texture: Texture2D = body_part.texture
		
		match part_name:
			"head":
				headSlot.texture = part_texture
			"body":
				bodySlot.texture = part_texture
			"extra":
				extraSlot.texture = part_texture

func check_is_target() -> void:
	click_processed = true
	comicsSprite.visible = true
	
	if is_target:
		comicsSprite.texture = comicsOk
		print("✓ Target corretto!")
		print("++++++++++++++++++++++")

	else:
		comicsSprite.texture = comicsError
		speed = max_speed
		print("✗ Target sbagliato!")
		print("-------------------------")

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

func set_character(_is_direction_left: bool, valid_category_types: Array[Category.CategoryType], invalid_category_types: Array[Category.CategoryType]) -> void:
	is_target = set_is_target(valid_category_types, invalid_category_types)
	
	click_type = ClickType.values().pick_random() 
	move_direction = Vector3.LEFT if _is_direction_left else Vector3.RIGHT
	
	var click_type_name: String = ClickType.keys()[click_type]
	
	var categories_valid_names: Array[String] = []
	for cat: Category.CategoryType in categories:
		var type_name: String = Category.CategoryType.keys()[cat]
		categories_valid_names.append(type_name)

	print("─────────────────────────")
	print("Character categories: ", categories_valid_names)
	print("Character click type: ", click_type_name)
	print("Character is target: ", is_target)
	print("─────────────────────────")
	
func set_is_target(valid_category_types: Array[Category.CategoryType], invalid_category_types: Array[Category.CategoryType]) -> bool:
	for category: Category.CategoryType in categories:
		if category in invalid_category_types:
			return false
			
	# Se non esiste nessuna parte valida
	var has_valid: bool = false

	for category: Category.CategoryType in categories:
		if category in valid_category_types:
			has_valid = true
			break

	if not has_valid:
		return false

	return true
	
func _physics_process(_delta: float) -> void:
	velocity = move_direction * speed
	move_and_slide()

func _on_input_event(_camera: Camera3D, event: InputEvent, _position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if click_processed:
			return
			
		if event.pressed:
			if click_type == ClickType.HOLD:
				holding = true
				hold_timer = 0.0
				comicsSprite.visible = true
				comicsSprite.texture = comicsChecking
				
			if click_type != ClickType.HOLD:
				is_clicked = true
				
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
			
			if click_type != ClickType.HOLD:
				is_clicked = true
