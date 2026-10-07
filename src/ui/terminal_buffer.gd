class_name TerminalBuffer
extends RefCounted
## Line store for the terminal screen: enforces the 80x24 grid contract by
## hard-wrapping at COLS columns on word boundaries, keeps a bounded
## scrollback, and mirrors every display line to a per-run log file.

const COLS := 80
const DEFAULT_SCROLLBACK := 200

var _max_lines: int
var _mirror_path: String
var _mirror: FileAccess
var _lines: PackedStringArray = []


func _init(max_lines: int = DEFAULT_SCROLLBACK, mirror_path: String = "") -> void:
	_max_lines = max_lines
	_mirror_path = mirror_path
	if _mirror_path != "":
		_mirror = FileAccess.open(_mirror_path, FileAccess.WRITE)


## Accepts text that may contain embedded newlines; every resulting display
## row is wrapped to COLS columns and mirrored.
func append_line(text: String) -> void:
	for raw_line in text.split("\n"):
		for row in _wrap(raw_line):
			_push(row)


func line_count() -> int:
	return _lines.size()


func line_at(index: int) -> String:
	return _lines[index]


func render() -> String:
	return "\n".join(_lines)


func clear() -> void:
	_lines.clear()


func _push(row: String) -> void:
	_lines.append(row)
	while _lines.size() > _max_lines:
		_lines.remove_at(0)
	if _mirror != null:
		_mirror.store_line(row)
		_mirror.flush()


## Greedy word wrap: break at the last space that fits; words longer than
## COLS are hard-broken.
func _wrap(text: String) -> PackedStringArray:
	var rows := PackedStringArray()
	var rest := text
	while rest.length() > COLS:
		var cut := rest.rfind(" ", COLS)
		if cut <= 0:
			cut = COLS
		rows.append(rest.substr(0, cut))
		rest = rest.substr(cut).strip_edges(true, false)
	rows.append(rest)
	return rows
