extends Node

# achievements
const achievement_fast_shot: String = "CggIrImotG8QAhAC"
const achievement_all_6_continents: String = "CggIrImotG8QAhAD"
const achievement_last_second_pass: String = "CggIrImotG8QAhAE"
const achievement_fast_shot_5x: String = "CggIrImotG8QAhAF"
const achievement_same_country: String = "CggIrImotG8QAhAG"
const achievement_goal_on_first_second: String = "CggIrImotG8QAhAH"
const achievement_shot_to_corner: String = "CggIrImotG8QAhAI"
const achievement_shot_to_center: String = "CggIrImotG8QAhAJ"
const achievement_world_champion: String = "CggIrImotG8QAhAK"
const achievement_50_second_rounds: String = "CggIrImotG8QAhAL"
const achievement_60_second_rounds: String = "CggIrImotG8QAhAM"
const achievement_70_second_rounds: String = "CggIrImotG8QAhAN"

# leaderboard
const leaderboard_goat: String = "CggIrImotG8QAhAB"

# temp
var fast_shot_unlocked := false
var fast_shot_5x_counter := 0

# ...
var default_balls_count := 3
const MAX_BALLS_ALLOWED := 10


# level
const FLAG: String = "FLAG"
const COUNTRY: String = "COUNTRY"
const TIME_LIMIT: String = "TIME_LIMIT"
const DIFFICULTY: String = "DIFFICULTY"
const PASS_SCORE: String = "PASS_SCORE"
const PLAYER_SCORE: String = "PLAYER_SCORE"
const BEST_SCORE: String = "BEST_SCORE"
const UNLOCKED: String = "UNLOCKED"
const REWARDED_BALLS: String = "REWARDED_BALLS"


# global
const TOTAL_SCORE: String = "TOTAL_SCORE"
const CURRENT_LEVEL: String = "CURRENT_LEVEL"
const PLAYER_TEAM: String = "PLAYER_TEAM"
const FIRST_TIME: String = "FIRST_TIME"
const ETERNAL_BALLS: String = "ETERNAL_BALLS"
const INTERMEDIATE_ADS: String = "INTERMEDIATE_ADS"
const TWO_BALLS_PURCHASED: String = "TWO_BALLS_PURCHASED"


const various_section_dictionary_keys = [
	CURRENT_LEVEL,
	TOTAL_SCORE,
	PLAYER_TEAM,
	FIRST_TIME,
	ETERNAL_BALLS,
	INTERMEDIATE_ADS,
	TWO_BALLS_PURCHASED
]

const level_section_dictionary_keys = [
	 FLAG,
	 COUNTRY,
	 TIME_LIMIT,
	 DIFFICULTY,
	 PASS_SCORE,
	 PLAYER_SCORE,
	 BEST_SCORE,
	 UNLOCKED,
	 REWARDED_BALLS
]


const VARIOUS_SECTION: String = "VARIOUS_SECTION"

func vibrate(duration: int = 10):
	if OS.has_feature("vibrate"):
		Input.vibrate_handheld(duration)


func get_language() -> String:
	var locale = OS.get_locale()
	if locale:
		var language = locale.split("_")[0].to_lower()
		return language
	return "MISSING"
	
	
func get_country() -> String:
	var locale = OS.get_locale()
	if locale.findn("_") != -1:
		var country = locale.split("_")[1].to_lower()
		return country
	return "MISSING"
	


