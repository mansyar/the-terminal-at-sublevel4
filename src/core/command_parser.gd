class_name CommandParser
extends RefCounted
## Parses one raw input line into a structured command record.
## Pure parsing: no WorldState or data access. Execution happens in the
## command executor; adding future verbs (override, power, chat, playback)
## only extends VERBS and the executor's handler map.

## Typo tolerance: suggestions are offered up to this edit distance.
const MAX_SUGGEST_DISTANCE := 2

const VERBS: Array[String] = ["query", "log", "help"]


## Returns one of:
##   { kind: "empty" }
##   { kind: "ok", verb: String, args: Array[String] }
##   { kind: "unknown", verb: String, suggestion: String }
static func parse(raw: String) -> Dictionary:
	var tokens := raw.strip_edges().split(" ", false)
	if tokens.is_empty():
		return {"kind": "empty"}

	var verb := tokens[0].to_lower()
	var args: Array = []
	args.assign(tokens.slice(1))

	if VERBS.has(verb):
		return {"kind": "ok", "verb": verb, "args": args}

	return {
		"kind": "unknown",
		"verb": verb,
		"suggestion": _closest_verb(verb),
	}


static func _closest_verb(word: String) -> String:
	var best := ""
	var best_distance := MAX_SUGGEST_DISTANCE + 1
	for verb in VERBS:
		var distance := _levenshtein(word, verb)
		if distance < best_distance:
			best_distance = distance
			best = verb
	return best


static func _levenshtein(a: String, b: String) -> int:
	var rows := a.length() + 1
	var cols := b.length() + 1
	var prev := PackedInt32Array()
	prev.resize(cols)
	for col in cols:
		prev[col] = col
	for row in range(1, rows):
		var current := PackedInt32Array()
		current.resize(cols)
		current[0] = row
		for col in range(1, cols):
			var substitution: int = prev[col - 1] + (0 if a[row - 1] == b[col - 1] else 1)
			current[col] = mini(prev[col] + 1, mini(current[col - 1] + 1, substitution))
		prev = current
	return prev[cols - 1]
