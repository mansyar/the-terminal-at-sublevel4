class_name CommandExecutor
extends RefCounted
## Executes parsed commands against WorldState and data files, returning
## structured records the UI renders verbatim.
##
## Time cost: every successfully executed command advances the facility
## clock by CLOCK_COST_MINUTES. Errors cost nothing.

const CLOCK_COST_MINUTES := 2
const DEFAULT_LOGS_DIR := "res://data/logs/"

var _world_state: WorldState
var _logs_dir: String


func _init(world_state: WorldState, logs_dir: String = DEFAULT_LOGS_DIR) -> void:
	_world_state = world_state
	_logs_dir = logs_dir


func execute(parsed: Dictionary) -> Dictionary:
	match parsed["kind"]:
		"empty":
			return {"kind": "empty"}
		"unknown":
			return parsed
		"ok":
			return _dispatch(parsed)
	return {"kind": "error", "message": "unhandled command kind"}


func _dispatch(parsed: Dictionary) -> Dictionary:
	var result: Dictionary
	match parsed["verb"]:
		"help":
			result = _help()
		"query":
			result = _query(parsed["args"])
		"log":
			result = _log(parsed["args"])
		_:
			result = {"kind": "error", "message": "no handler for verb '%s'" % parsed["verb"]}
	if result["kind"] != "error":
		_world_state.advance_minutes(CLOCK_COST_MINUTES)
	return result


func _help() -> Dictionary:
	return {
		"kind": "help",
		"lines":
		[
			"AVAILABLE COMMANDS:",
			"  query <sector | unit | personnel>  - read raw telemetry",
			"  log <file_id>                      - retrieve facility records",
			"  help                               - this screen",
		],
	}


func _query(args: Array) -> Dictionary:
	if args.is_empty():
		return {"kind": "error", "message": "usage: query <sector | unit | personnel>"}

	var target := String(args[0]).to_lower()
	var snapshot: Dictionary = _world_state.snapshot()

	for sector_id in snapshot["sectors"]:
		var sector: Dictionary = snapshot["sectors"][sector_id]
		if target == String(sector_id).to_lower():
			return {"kind": "sector", "record": sector}
		for unit_id in sector["doors"]:
			if target == String(unit_id).to_lower():
				return {
					"kind": "unit",
					"record":
					{
						"unit_id": unit_id,
						"door": sector["doors"][unit_id],
						"sensors": sector["sensors"].get(unit_id, {}),
					},
				}

	for person_id in snapshot["personnel"]:
		if target == String(person_id).to_lower():
			return {"kind": "personnel", "record": snapshot["personnel"][person_id]}

	return {"kind": "error", "message": "unknown target: %s" % args[0]}


func _log(args: Array) -> Dictionary:
	if args.is_empty():
		return {"kind": "error", "message": "usage: log <file_id>"}

	var file_id := String(args[0])
	if not file_id.is_valid_filename() or file_id.contains(".."):
		return {"kind": "error", "message": "unknown record: %s" % file_id}
	var result := DataLoader.load_json("%s/%s.json" % [_logs_dir, file_id])
	if not result["ok"]:
		return {"kind": "error", "message": result["error"]}

	var data: Dictionary = result["data"]
	return {
		"kind": "log",
		"record":
		{
			"file_id": file_id,
			"title": data.get("title", file_id),
			"body": data.get("body", ""),
		},
	}
