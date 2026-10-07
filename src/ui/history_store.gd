class_name HistoryStore
extends RefCounted
## Command history for the terminal: Up/Down recall and ghost-text lookup.
## Recall semantics match classic shells: Up walks toward older entries and
## stops at the oldest; Down returns toward the live input and yields ""
## once back at it.

var _entries: PackedStringArray = []
var _cursor: int = -1  # -1 = live input; otherwise index into _entries


func entry_count() -> int:
	return _entries.size()


func push(command: String) -> void:
	var trimmed := command.strip_edges()
	if trimmed == "":
		return
	if not _entries.is_empty() and _entries[_entries.size() - 1] == trimmed:
		_cursor = -1
		return
	_entries.append(trimmed)
	_cursor = -1


func recall_up() -> String:
	if _entries.is_empty():
		return ""
	if _cursor == -1:
		_cursor = _entries.size() - 1
	elif _cursor > 0:
		_cursor -= 1
	return _entries[_cursor]


func recall_down() -> String:
	if _cursor == -1:
		return ""
	if _cursor >= _entries.size() - 1:
		_cursor = -1
		return ""
	_cursor += 1
	return _entries[_cursor]


func reset_cursor() -> void:
	_cursor = -1


## Returns the unmatched suffix of the most recent entry that starts with
## `input`, for rendering as dim inline ghost text. "" when no match.
func ghost_for(input: String) -> String:
	if input == "":
		return ""
	for i in range(_entries.size() - 1, -1, -1):
		var entry := _entries[i]
		if entry.begins_with(input) and entry.length() > input.length():
			return entry.substr(input.length())
	return ""
