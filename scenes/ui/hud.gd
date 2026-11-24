class_name Hud
extends CanvasLayer
## Interface de la salle. Reste active pendant la pause pour permettre de recommencer.
## wave_total = 0 : salle sans vagues, le compteur est masqué.

signal start_wave_pressed

@onready var _stats_label: Label = $StatsLabel
@onready var _character_label: Label = $CharacterLabel
@onready var _items_label: Label = $ItemsLabel
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


## Stats finales du personnage (base + objets), façon Isaac : ▲ mieux que la base, ▼ moins bien.
## À droite : types de tours et objets possédés.
func set_character(state: RunState) -> void:
	var lines: PackedStringArray = ["PERSONNAGE"]
	lines.append(_stat_line(state, "PV max", &"max_health", "%d" % state.max_health))
	lines.append(_stat_line(state, "Vitesse", &"speed", "%d" % state.stat_int(&"speed")))
	lines.append(_stat_line(state, "Dégâts", &"shot_damage", _number(state.stat(&"shot_damage"))))
	lines.append(_stat_line(state, "Cadence", &"shot_cooldown", _number(1.0 / state.stat(&"shot_cooldown")) + "/s"))
	lines.append(_stat_line(state, "Portée", &"shot_range", "%d" % state.stat_int(&"shot_range")))
	lines.append(_stat_line(state, "Ramassage", &"pickup_radius", "%d" % state.stat_int(&"pickup_radius")))
	lines.append("")
	lines.append("SORT")
	lines.append(_stat_line(state, "Dégâts", &"spell_damage", _number(state.stat(&"spell_damage"))))
	lines.append(_stat_line(state, "Recharge", &"spell_cooldown", _number(state.stat(&"spell_cooldown")) + " s"))
	lines.append("")
	lines.append("TOURS")
	lines.append(_stat_line(state, "Dégâts", &"tower_damage", "×" + _number(state.stat(&"tower_damage"), 2)))
	lines.append(_stat_line(state, "Cadence", &"tower_fire_rate", "×" + _number(state.stat(&"tower_fire_rate"), 2)))
	lines.append(_stat_line(state, "Portée", &"tower_range", "×" + _number(state.stat(&"tower_range"), 2)))
	lines.append(_stat_line(state, "Rendu", &"tower_refund", "%d %%" % roundi(state.stat(&"tower_refund") * 100.0)))
	_character_label.text = "\n".join(lines)

	var right: PackedStringArray = ["TYPES DE TOURS %d/%d" % [state.tower_types.size(), state.stat_int(&"tower_slots")]]
	for tower in state.tower_types:
		right.append("  " + tower.display_name)
	right.append("")
	right.append("OBJETS")
	if state.items.is_empty():
		right.append("  aucun")
	for item in state.items:
		right.append("  " + item.display_name)
	_items_label.text = "\n".join(right)


func get_message() -> String:
	return _message_label.text


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


func _stat_line(state: RunState, label: String, stat_name: StringName, value: String) -> String:
	var trend: int = state.stat_trend(stat_name)
	var arrow: String = " ▲" if trend > 0 else (" ▼" if trend < 0 else "")
	return "%s  %s%s" % [label, value, arrow]


## Nombre à la française : virgule, décimales seulement si utiles.
static func _number(value: float, decimals: int = 1) -> String:
	if is_equal_approx(value, roundf(value)):
		return "%d" % roundi(value)
	return (("%." + str(decimals) + "f") % value).replace(".", ",")
