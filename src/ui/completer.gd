class_name Completer
extends RefCounted
## Tab completion over the terminal's known vocabulary: verbs, query targets
## (sectors, units, personnel) and log file ids. Case-insensitive; completes
## to the longest common prefix of all candidates.

var _verbs: Array[String] = []
var _targets: Array[String] = []
var _file_ids: Array[String] = []


func set_vocabulary(verbs: Array[String], targets: Array[String], file_ids: Array[String]) -> void:
	_verbs = verbs
	_targets = targets
	_file_ids = file_ids


## Returns the completed input line, or `input` unchanged when nothing
## matches. A successful completion always ends with a trailing space so the
## operator can keep typing.
func complete_for(input: String) -> String:
	var tokens: PackedStringArray = input.strip_edges().split(" ", false)
	if tokens.is_empty():
		return input

	var verb: String = tokens[0].to_lower()
	var ends_with_space: bool = input.length() > 0 and input[input.length() - 1] == " "

	if tokens.size() == 1 and not ends_with_space:
		var completed: String = _complete_token(input, verb, _verbs)
		return completed if completed != input else input

	var candidates: Array[String] = []
	if verb == "log":
		candidates = _file_ids
	else:
		candidates = _targets
	if candidates.is_empty():
		return input

	var prefix: String = "" if ends_with_space else tokens[tokens.size() - 1]
	var completed_arg: String = _complete_token(prefix, prefix.to_lower(), candidates)
	if completed_arg == prefix:
		return input
	# Rebuild the full line: replace the final partial token in place.
	if ends_with_space:
		return input + completed_arg
	return input.substr(0, input.length() - prefix.length()) + completed_arg


func _complete_token(raw_prefix: String, lower_prefix: String, candidates: Array[String]) -> String:
	if raw_prefix == "":
		return raw_prefix
	var matched: Array[String] = []
	for candidate in candidates:
		if candidate.to_lower().begins_with(lower_prefix):
			matched.append(candidate)
	if matched.is_empty():
		return raw_prefix
	if matched.size() == 1:
		return matched[0] + " "

	# Multiple candidates: complete to the longest common prefix.
	var common: String = matched[0]
	for candidate: String in matched.slice(1):
		while not candidate.to_lower().begins_with(common.to_lower()):
			common = common.substr(0, common.length() - 1)
			if common == "":
				return raw_prefix
	return common + " "
