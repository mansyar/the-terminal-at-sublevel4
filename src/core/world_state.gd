class_name WorldState
extends RefCounted
## Authoritative game state for Facility Boreas (Phase 0 baseline).
## Pure logic: no scene-tree dependencies. Constructed from a seed so that
## any run can be reproduced exactly from its seed string.
##
## Contract (tested in tests/core/test_world_state.gd):
##   - clock starts at 01:50 and advances only via advance_minutes()
##   - same seed -> identical state; different seed -> varied sensor readings
##   - baseline variables: power_units, sectors (L4), personnel (3)

const START_MINUTES := 110  # 01:50 AM

var _minutes: int = START_MINUTES
var _rng := RandomNumberGenerator.new()
var _power_units: int = 100
var _sectors: Dictionary = {}
var _personnel: Dictionary = {}


func _init(seed_text: String = "boreas") -> void:
	_rng.seed = _stable_hash(seed_text)
	_build_baseline()


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


func _build_baseline() -> void:
	_sectors = {
		"L4":
		{
			"name": "Sub-Level 4 — Containment Corridor",
			"doors":
			{
				"L4-02":
				{
					"state": "sealed",
					"integrity": "nominal",
				},
			},
			"sensors":
			{
				"L4-02":
				{
					"temp_c": _jittered(-18.0, 0.8),
					"co2_pct": _jittered(0.04, 0.004),
					"bio_count": 0,
					"pressure_kpa": _jittered(101.3, 0.5),
				},
			},
		},
	}
	_personnel = {
		"arisova": _person("Dr. Elena Arisova", "L4 Lab A", "on-shift"),
		"miller": _person("Sgt. Dana Miller", "L4 Checkpoint", "on-shift"),
		"chen": _person("Chief Engineer Chen", "Sub-Level 2", "on-shift"),
	}


func _person(display_name: String, location: String, status: String) -> Dictionary:
	return {
		"name": display_name,
		"location": location,
		"status": status,
		"heart_rate_bpm": _jittered(68.0, 4.0),
	}


func _jittered(base: float, spread: float) -> float:
	return snappedf(base + _rng.randf_range(-spread, spread), 0.01)


func _stable_hash(text: String) -> int:
	# FNV-1a: stable across Godot sessions and machines, unlike hash().
	var digest := 2166136261
	for ch in text.to_utf8_buffer():
		digest = (digest ^ ch) * 16777619
		digest &= 0xFFFFFFFF
	return int(digest)
