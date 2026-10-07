extends GdToolsTest
## WorldState is data-driven: sectors and personnel load from schema-
## versioned JSON via DataLoader, with seeded jitter applied on top.

const WorldState := preload("res://src/core/world_state.gd")

const FIXTURES := "res://tests/fixtures/world_state/"


func test_state_reflects_fixture_data() -> void:
	var ws := WorldState.new("boreas", FIXTURES)
	var snapshot: Dictionary = ws.snapshot()
	var sector: Dictionary = snapshot["sectors"]["L4"]
	var door: Dictionary = sector["doors"]["L4-02"]
	assert_eq(door["state"], "open", "door state comes from JSON")
	assert_eq(door["integrity"], "compromised", "door integrity comes from JSON")


func test_fixture_sensors_loaded_and_jittered() -> void:
	var ws := WorldState.new("boreas", FIXTURES)
	var sensors: Dictionary = ws.snapshot()["sectors"]["L4"]["sensors"]["L4-02"]
	assert_true(
		sensors["temp_c"] >= 4.0 and sensors["temp_c"] <= 6.0, "temp base 5.0 jittered +/-0.8"
	)
	assert_eq(sensors["bio_count"], 3, "bio_count untouched by jitter")


func test_fixture_personnel_loaded() -> void:
	var ws := WorldState.new("boreas", FIXTURES)
	var snapshot: Dictionary = ws.snapshot()
	assert_eq(snapshot["personnel"].size(), 1, "personnel comes from JSON")
	assert_eq(snapshot["personnel"]["test_tech"]["name"], "Test Tech", "person fields from JSON")


func test_missing_data_dir_yields_empty_baseline() -> void:
	var ws := WorldState.new("boreas", "res://tests/fixtures/does_not_exist/")
	var snapshot: Dictionary = ws.snapshot()
	assert_eq(snapshot["sectors"], {}, "no sectors when data missing")
	assert_eq(snapshot["personnel"], {}, "no personnel when data missing")
