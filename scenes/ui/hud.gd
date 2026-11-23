class_name Hud
extends CanvasLayer
## Interface de la salle. Reste active pendant la pause pour permettre de recommencer.

signal start_wave_pressed

@onready var _stats_label: Label = $StatsLabel
@onready var _towers_label: Label = $TowersLabel
@onready var _spell_label: Label = $SpellLabel
@onready var _message_label: Label = $MessageLabel
@onready var _start_wave_button: Button = $StartWaveButton


func _ready() -> void:
	_start_wave_button.pressed.connect(func() -> void: start_wave_pressed.emit())
	_message_label.text = ""


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("restart"):
		get_tree().paused = false
		get_tree().reload_current_scene()


func set_stats(base_health: int, base_max: int, energy: int, wave_number: int, wave_total: int) -> void:
	_stats_label.text = "Base : %d / %d PV     Énergie : %d     Vague : %d / %d" % [
		base_health, base_max, energy, wave_number, wave_total
	]


func set_towers(tower_types: Array[TowerData], selected: int, energy: int) -> void:
	var lines: PackedStringArray = []
	for i in tower_types.size():
		var tower: TowerData = tower_types[i]
		var marker: String = "▶ " if i == selected else "   "
		var affordable: String = "" if energy >= tower.cost else "  (pas assez)"
		lines.append("%s[%d] %s — %d énergie%s" % [marker, i + 1, tower.display_name, tower.cost, affordable])
	_towers_label.text = "\n".join(lines)


func set_spell(time_left: float) -> void:
	if time_left <= 0.0:
		_spell_label.text = "Onde de givre [E / clic droit] : prête"
	else:
		_spell_label.text = "Onde de givre : %.1f s" % time_left


func set_wave_button(visible_now: bool, label: String) -> void:
	_start_wave_button.visible = visible_now
	_start_wave_button.text = label


func show_message(text: String) -> void:
	_message_label.text = text
