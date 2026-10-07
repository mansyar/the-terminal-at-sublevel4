extends GdToolsTest
## Red-phase contract tests for DataLoader (Phase B).
## Fixtures live in tests/fixtures/data/ — one per failure mode.

const DataLoader := preload("res://src/core/data_loader.gd")

const FIXTURES := "res://tests/fixtures/data/"


func test_loads_valid_schema_versioned_file() -> void:
	var result := DataLoader.load_json(FIXTURES + "valid.json")
	assert_true(result["ok"], "valid fixture loads")
	assert_eq(result["data"]["schema_version"], 1, "schema_version preserved")
	assert_eq(result["data"]["kind"], "test", "payload preserved")


func test_missing_file_reports_error() -> void:
	var result := DataLoader.load_json(FIXTURES + "does_not_exist.json")
	assert_false(result["ok"], "missing file fails")
	assert_true(result["error"].contains("does_not_exist"), "error names the file")


func test_malformed_json_reports_parse_error() -> void:
	var result := DataLoader.load_json(FIXTURES + "malformed.json")
	assert_false(result["ok"], "malformed JSON fails")


func test_missing_schema_version_rejected() -> void:
	var result := DataLoader.load_json(FIXTURES + "missing_version.json")
	assert_false(result["ok"], "no schema_version fails")
	assert_true(result["error"].contains("schema_version"), "error names schema_version")


func test_future_schema_version_rejected() -> void:
	var result := DataLoader.load_json(FIXTURES + "future_version.json")
	assert_false(result["ok"], "unsupported schema_version fails")


func test_non_dictionary_root_rejected() -> void:
	var result := DataLoader.load_json(FIXTURES + "array_root.json")
	assert_false(result["ok"], "non-dictionary root fails")
