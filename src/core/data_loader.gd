class_name DataLoader
extends RefCounted
## Loads and validates JSON data files from res://data/.
## Every content file carries a `schema_version`; unsupported files are
## rejected with a precise error so content drift is caught at load time.

const SUPPORTED_SCHEMA_VERSION := 1


## Returns { ok: bool, data: Dictionary, error: String }.
## On failure, data is empty and error describes the reason.
static func load_json(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return _fail("File not found: %s" % path)

	var text := FileAccess.get_file_as_string(path)
	var json := JSON.new()
	# Instance parse (not JSON.parse_string) so malformed input returns an
	# error code instead of spamming the engine error log.
	if json.parse(text) != OK:
		return _fail("Malformed JSON in %s: %s" % [path, json.get_error_message()])
	var parsed: Variant = json.get_data()
	if not parsed is Dictionary:
		return _fail("Root of %s must be a JSON object" % path)

	var data: Dictionary = parsed
	if not data.has("schema_version"):
		return _fail("%s is missing schema_version" % path)
	if data["schema_version"] != SUPPORTED_SCHEMA_VERSION:
		return _fail(
			(
				"%s has unsupported schema_version %s (supported: %d)"
				% [path, data["schema_version"], SUPPORTED_SCHEMA_VERSION]
			)
		)

	return {"ok": true, "data": data, "error": ""}


static func _fail(reason: String) -> Dictionary:
	return {"ok": false, "data": {}, "error": reason}
