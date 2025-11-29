extends Control
class_name DynamicPopup

@onready var main_text: Label = %DynamicPopupMainText
@onready var secondary_text: Label = %DynamicPopupSecondaryText
@onready var timer: Timer = %DynamicPopupTimer
@onready var text_timer: Timer = %DynamicPopupTextTimer
@onready var sfx: AudioStreamPlayer = %DynamicPopupSFX

signal on_popup_appeared
signal on_popup_disappeared

var secondary_texts: Array[String] = []
var current_text_index: int = 0

func set_popup(_main_text: String, _secondary_text: Array[String]) -> void:
	main_text.text = _main_text
	secondary_texts = _secondary_text
	current_text_index = 0
	
	# Imposta il primo testo immediatamente
	if secondary_texts.size() > 0:
		secondary_text.text = secondary_texts[0]

func show_popup() -> void:
	show()
	sfx.play()
	on_popup_appeared.emit()
	
	# Avvia il timer per cambiare il testo
	if secondary_texts.size() > 1:
		text_timer.start()
	
func hide_popup() -> void:
	hide()
	text_timer.stop()
	on_popup_disappeared.emit()
	
func start_popup_timer() -> void:
	timer.start()
	
func _on_dynamic_popup_timer_timeout() -> void:
	hide_popup()
	timer.stop()

func _on_dynamic_popup_text_timer_timeout() -> void:
	# Passa al testo successivo
	current_text_index += 1
	
	# Se abbiamo raggiunto la fine dell'array, ricomincia dall'inizio
	if current_text_index >= secondary_texts.size():
		current_text_index = 0
	
	# Aggiorna il testo
	secondary_text.text = secondary_texts[current_text_index]
