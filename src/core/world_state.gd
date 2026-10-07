class_name WorldState
extends RefCounted
## Authoritative game state for Facility Boreas (Phase 0 baseline).
## Pure logic: no scene-tree dependencies. Constructed from a seed so that
## any run can be reproduced exactly from its seed string. Baseline content
## (sectors, personnel) loads from schema-versioned JSON via DataLoader;
## seeded jitter is applied on top of the loaded base values.
##
## Contract (tested in tests/core/test_world_state.gd,
## tests/core/test_world_state_data.gd):
##   - clock starts at 01:50 and advances only via advance_minutes()
##   - same seed -> identical state; different seed -> varied sensor readings
##   - baseline variables: power_units, sectors (L4), personnel (3)

const START_MINUTES := 110  # 01:50 AM
const DEFAULT_DATA_DIR := "res://data/"

var _minutes: int = START_MINUTES
var _rng := RandomNumberGenerator.new()
var _power_units: int = 100
var _sectors: Dictionary = {}
var _personnel: Dictionary = {}


func _init(seed_text: String = "boreas", data_dir: String = DEFAULT_DATA_DIR) -> void:
	_rng.seed = _stable_hash(seed_text)
	_build_baseline(data_dir)


## -- Time ------------------------------------------------------------------


func clock_text() -> String:
	var hours := _minutes / 60
	var mins := _minutes % 60
	return "%02d:%02d" % [hours, mins]


func advance_minutes(amount: int) -> void:
	if amount < 0:
		return
	_minutes += amount


func minutes_elapsed() -> int:
	return _minutes - START_MINUTES


## -- State access ----------------------------------------------------------


func snapshot() -> Dictionary:
	return {
		"clock": clock_text(),
		"power_units": _power_units,
		"sectors": _sectors.duplicate(true),
		"personnel": _personnel.duplicate(true),
	}


## Deterministic serialization of the whole state, for equality checks.
func dump() -> String:
	return JSON.stringify(snapshot(), "", false)


## -- Setup -----------------------------------------------------------------


func _build_baseline(data_dir: String) -> void:
	_sectors = _jitter_sectors(_load_content(data_dir, "sectors.json", "sectors"))
	_personnel = _jitter_personnel(_load_content(data_dir, "personnel.json", "personnel"))


func _load_content(data_dir: String, file_name: String, key: String) -> Dictionary:
	var result := DataLoader.load_json(data_dir.path_join(file_name))
	if not result["ok"]:
		push_warning("WorldState baseline incomplete: %s" % result["error"])
		return {}
	return result["data"].get(key, {})


## Seeded sensor jitter: organic drift on top of the authored base values.
func _jitter_sectors(sectors: Dictionary) -> Dictionary:
	for sector_id in sectors:
		var sensors: Dictionary = sectors[sector_id].get("sensors", {})
		for sensor_id in sensors:
			var reading: Dictionary = sensors[sensor_id]
			if reading.has("temp_c"):
				reading["temp_c"] = _jittered(reading["temp_c"], 0.8)
			if reading.has("co2_pct"):
				reading["co2_pct"] = _jittered(reading["co2_pct"], 0.004)
			if reading.has("pressure_kpa"):
				reading["pressure_kpa"] = _jittered(reading["pressure_kpa"], 0.5)
	return sectors


func _jitter_personnel(personnel: Dictionary) -> Dictionary:
	for person_id in personnel:
		var person: Dictionary = personnel[person_id]
		if person.has("heart_rate_bpm"):
			person["heart_rate_bpm"] = _jittered(person["heart_rate_bpm"], 4.0)
	return personnel


func _jittered(base: float, spread: float) -> float:
	return snappedf(base + _rng.randf_range(-spread, spread), 0.01)


func _stable_hash(text: String) -> int:
	# FNV-1a: stable across Godot sessions and machines, unlike hash().
	var digest := 2166136261
	for ch in text.to_utf8_buffer():
		digest = (digest ^ ch) * 16777619
		digest &= 0xFFFFFFFF
	return int(digest)
