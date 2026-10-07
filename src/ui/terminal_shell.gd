extends Control
## The terminal shell: renders WorldState through the parser/executor onto
## an 80x24 CRT grid. Owns input capture, autocomplete, history, and the
## CRT display toggles. All core modules are constructed here (UI is the
## only consumer of WorldState, per the architecture decision).

const WorldState := preload("res://src/core/world_state.gd")
const CommandParser := preload("res://src/core/command_parser.gd")
const CommandExecutor := preload("res://src/core/command_executor.gd")
const TerminalBuffer := preload("res://src/ui/terminal_buffer.gd")
const HistoryStore := preload("res://src/ui/history_store.gd")
const Completer := preload("res://src/ui/completer.gd")

const PHOSPHOR_GREEN := Vector3(0.30, 1.0, 0.45)
const PHOSPHOR_AMBER := Vector3(1.0, 0.62, 0.18)
const FLICKER_ON := 0.07
const FLICKER_OFF := 0.0

const GHOST_COLOR := "5a8f68"

var _world_state: WorldState
var _executor: CommandExecutor
var _buffer: TerminalBuffer
var _history: HistoryStore
var _completer: Completer

var _input: String = ""
var _seed_text: String = ""
var _mirror_path: String = ""

@onready var _header: Label = %Header
@onready var _output: RichTextLabel = %Output
@onready var _input_line: RichTextLabel = %InputLine
@onready var _crt_material: ShaderMaterial = %CRTOverlay.material
@onready var _key_click: AudioStreamPlayer = %KeyClick


func _ready() -> void:
	_seed_text = _resolve_seed()
	_world_state = WorldState.new(_seed_text)
	_executor = CommandExecutor.new(_world_state)
	_buffer = TerminalBuffer.new(TerminalBuffer.DEFAULT_SCROLLBACK, _mirror_path)
	_history = HistoryStore.new()
	_completer = Completer.new()
	_refresh_vocabulary()

	_buffer.append_line("BOREAS SURFACE LINK v0.1 -- REMOTE OPERATIONS TERMINAL")
	_buffer.append_line("Facility Boreas, Siberian Permafrost Containment Site")
	_buffer.append_line("Type 'help' for available commands.")
	_buffer.append_line("[F1] phosphor toggle   [F2] flicker toggle")
	_buffer.append_line("")
	_refresh_display()


## Resolves the run seed: --seed=X user arg, then TSL4_SEED env, then default.
func _resolve_seed() -> String:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--seed="):
			return arg.substr(7)
	var from_env: String = OS.get_environment("TSL4_SEED")
	return from_env if from_env != "" else "boreas"


func _unhandled_key_input(event: InputEvent) -> void:
	var key: InputEventKey = event as InputEventKey
	if key == null or not key.pressed or key.echo:
		return

	match key.keycode:
		KEY_ENTER, KEY_KP_ENTER:
			_submit()
		KEY_BACKSPACE:
			if _input.length() > 0:
				_input = _input.substr(0, _input.length() - 1)
				_play_click()
			_refresh_input_display()
		KEY_UP:
			_input = _history.recall_up()
			_refresh_input_display()
		KEY_DOWN:
			_input = _history.recall_down()
			_refresh_input_display()
		KEY_TAB:
			_input = _completer.complete_for(_input)
			_refresh_input_display()
		KEY_F1:
			_toggle_phosphor()
		KEY_F2:
			_toggle_flicker()
		_:
			var ch: String = char(key.unicode)
			if key.unicode >= 32 and ch != "":
				_input += ch
				_play_click()
				_refresh_input_display()


func _submit() -> void:
	var line := _input.strip_edges()
	_input = ""
	_history.reset_cursor()
	buffer_append("> " + line)
	if line != "":
		_history.push(line)
		_render_result(_executor.execute(CommandParser.parse(line)))
		_refresh_vocabulary()
	_refresh_display()


## Test hook: submit a line exactly as if typed and executed.
func submit_line(line: String) -> void:
	_input = line
	_submit()


func buffer_append(text: String) -> void:
	_buffer.append_line(text)


## Renders an executor result record as diegetic terminal lines.
func _render_result(result: Dictionary) -> void:
	match result["kind"]:
		"empty":
			pass
		"unknown":
			var suggestion: String = result["suggestion"]
			if suggestion != "":
				buffer_append(
					"UNKNOWN COMMAND '%s'. DID YOU MEAN: %s?" % [result["verb"], suggestion]
				)
			else:
				buffer_append(
					"UNKNOWN COMMAND '%s'. TYPE 'HELP' FOR AVAILABLE COMMANDS." % result["verb"]
				)
		"error":
			buffer_append("ERR: %s" % result["message"])
		"help":
			for line in result["lines"]:
				buffer_append(String(line))
		"sector":
			_render_sector(result["record"])
		"unit":
			_render_unit(result["record"])
		"personnel":
			_render_personnel(result["record"])
		"log":
			_render_log(result["record"])


func _render_sector(record: Dictionary) -> void:
	buffer_append("SECTOR %s" % record["name"])
	for door_id in record["doors"]:
		var door: Dictionary = record["doors"][door_id]
		buffer_append(
			(
				"  DOOR %s: %s (integrity: %s)"
				% [door_id, String(door["state"]).to_upper(), door["integrity"]]
			)
		)
	for sensor_id in record["sensors"]:
		_render_sensor_line(sensor_id, record["sensors"][sensor_id])


func _render_unit(record: Dictionary) -> void:
	var door: Dictionary = record["door"]
	buffer_append(
		(
			"DOOR STATE: %s | INTEGRITY: %s"
			% [String(door["state"]).to_upper(), String(door["integrity"]).to_upper()]
		)
	)
	if record.has("sensors") and not (record["sensors"] as Dictionary).is_empty():
		_render_sensor_line("L4-02", record["sensors"])


func _render_sensor_line(sensor_id: String, sensors: Dictionary) -> void:
	buffer_append(
		(
			"  SENSOR %s: TEMP %.1fC | CO2 %.2f%% | PRESSURE %.1f kPa | BIO-COUNT: %d"
			% [
				sensor_id,
				sensors["temp_c"],
				sensors["co2_pct"],
				sensors["pressure_kpa"],
				sensors["bio_count"],
			]
		)
	)


func _render_personnel(record: Dictionary) -> void:
	buffer_append("PERSONNEL FILE: %s" % record["name"])
	buffer_append(
		"  LOCATION: %s | STATUS: %s" % [record["location"], String(record["status"]).to_upper()]
	)
	buffer_append("  HEART RATE: %.0f BPM" % record["heart_rate_bpm"])


func _render_log(record: Dictionary) -> void:
	buffer_append("RECORD %s: %s" % [record["file_id"], record["title"]])
	for line in String(record["body"]).split("\n"):
		buffer_append("  " + line)


func _refresh_vocabulary() -> void:
	var snapshot: Dictionary = _world_state.snapshot()
	var targets: Array[String] = []
	for sector_id in snapshot["sectors"]:
		targets.append(String(sector_id))
		var sector: Dictionary = snapshot["sectors"][sector_id]
		for unit_id in sector["doors"]:
			targets.append(String(unit_id))
	for person_id in snapshot["personnel"]:
		targets.append(String(person_id))
	_completer.set_vocabulary(CommandParser.VERBS, targets, [])


func _refresh_display() -> void:
	_refresh_header()
	_refresh_output()
	_refresh_input_display()


func _refresh_header() -> void:
	var snapshot: Dictionary = _world_state.snapshot()
	_header.text = (
		"SYSTEM STATUS: ONLINE | SEED: %s | CLOCK: %s\nPOWER ALLOCATION: AUXILIARY (%d UNITS)"
		% [_seed_text, snapshot["clock"], snapshot["power_units"]]
	)


func _refresh_output() -> void:
	var visible_lines := _buffer.line_count()
	var start := maxi(0, visible_lines - 19)
	var lines: Array[String] = []
	for i in range(start, visible_lines):
		lines.append(_buffer.line_at(i))
	_output.text = "\n".join(lines)


func _refresh_input_display() -> void:
	var ghost: String = _history.ghost_for(_input)
	var ghost_bbcode := ""
	if ghost != "":
		ghost_bbcode = "[color=#%s]%s[/color]" % [GHOST_COLOR, _bb_escape(ghost)]
	_input_line.text = (
		"> %s[color=#%s]_[/color]%s" % [_bb_escape(_input), GHOST_COLOR, ghost_bbcode]
	)


## Escapes user-provided text so it can never be parsed as bbcode tags.
func _bb_escape(text: String) -> String:
	return text.replace("[", "[lb]")


func _play_click() -> void:
	_key_click.play()


func _toggle_phosphor() -> void:
	var current: Vector3 = _crt_material.get_shader_parameter("phosphor_tint")
	var next: Vector3 = (
		PHOSPHOR_AMBER if current.is_equal_approx(PHOSPHOR_GREEN) else PHOSPHOR_GREEN
	)
	_crt_material.set_shader_parameter("phosphor_tint", next)


func _toggle_flicker() -> void:
	var current: float = _crt_material.get_shader_parameter("flicker_amplitude")
	var next: float = FLICKER_OFF if absf(current - FLICKER_ON) < 0.001 else FLICKER_ON
	_crt_material.set_shader_parameter("flicker_amplitude", next)
