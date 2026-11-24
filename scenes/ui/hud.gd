class_name Hud
extends CanvasLayer
## Interface de la salle. Reste active pendant la pause pour permettre de recommencer.
## wave_total = 0 : salle sans vagues, le compteur est masqué.

signal start_wave_pressed

@onready var _stats_label: Label = $StatsLabel
@onready var _towers_label: Label = $TowersLabel
@onready var _spell_label: Label = $SpellLabel
@onready var _next_wave_label: Label = $NextWaveLabel
@onready var _message_label: Label = $MessageLabel
@onready var _start_wave_button: Button = $StartWaveButton


func _ready() -> void:
	_start_wave_button.pressed.connect(func() -> void: start_wave_pressed.emit())
	_message_label.text = ""
	_next_wave_label.text = ""


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("restart"):
		get_tree().paused = false
		get_tree().reload_current_scene()


func set_stats(health: int, max_health: int, energy: int, wave_number: int, wave_total: int) -> void:
	_stats_label.text = "PV : %d / %d     Énergie : %d" % [health, max_health, energy]
	if wave_total > 0:
		_stats_label.text += "     Vague : %d / %d" % [wave_number, wave_total]


## costs : coût actuel de chaque type dans la salle. selected : type en cours de pose, ou -1.
func set_towers(tower_types: Array[TowerData], costs: Array[int], selected: int, energy: int) -> void:
	var lines: PackedStringArray = []
	for i in tower_types.size():
		var tower: TowerData = tower_types[i]
		var marker: String = "▶ " if i == selected else "   "
		var affordable: String = "" if energy >= costs[i] else "  (pas assez)"
		lines.append("%s[%d] %s — %d énergie%s" % [marker, i + 1, tower.display_name, costs[i], affordable])
	if selected >= 0:
		lines.append("Clic gauche : poser hors du chemin — Échap : annuler")
	_towers_label.text = "\n".join(lines)


func set_spell(time_left: float) -> void:
	if time_left <= 0.0:
		_spell_label.text = "Onde de givre [E] : prête"
	else:
		_spell_label.text = "Onde de givre : %.1f s" % time_left


## seconds < 0 : aucune vague en attente.
func set_next_wave(seconds: float, wave_number: int) -> void:
	_next_wave_label.text = "" if seconds < 0.0 else "Vague %d dans %d s" % [wave_number, ceili(seconds)]


func set_wave_button(visible_now: bool) -> void:
	_start_wave_button.visible = visible_now


func show_message(text: String) -> void:
	_message_label.text = text
