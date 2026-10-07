extends GdToolsTest
## Smoke suite: proves the gd-tools native test runtime boots inside Godot.
## Replaced by real unit suites as core modules land (Phase B onward).


func test_runtime_boots() -> void:
	assert_true(true, "smoke: GdToolsTest runtime executes suites")


func test_project_data_dir_exists() -> void:
	assert_true(DirAccess.dir_exists_absolute("res://data"), "smoke: res://data directory present")
