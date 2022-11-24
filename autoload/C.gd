extends Node


# level
const FLAG: String = "FLAG"
const COUNTRY: String = "COUNTRY"
const TIME_LIMIT: String = "TIME_LIMIT"
const DIFFICULTY: String = "DIFFICULTY"
const PASS_SCORE: String = "PASS_SCORE"
const PLAYER_SCORE: String = "PLAYER_SCORE"
const BEST_SCORE: String = "BEST_SCORE"
const UNLOCKED: String = "UNLOCKED"


# global
const TOTAL_SCORE: String = "TOTAL_SCORE"
const CURRENT_LEVEL: String = "CURRENT_LEVEL"


const VARIOUS_SECTION: String = "VARIOUS_SECTION"

func vibrate(duration: int = 10):
	if OS.has_feature("vibrate"):
		Input.vibrate_handheld(duration)
