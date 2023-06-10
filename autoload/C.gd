extends Node

# firebase event
const event_next_level: String = "next_level"
const event_fail_level: String = "fail_level"
const event_ball_rewarded: String = "ball_rewarded"
const event_ball_bought: String = "ball_bought"

# android achievements
const achievement_15_x_fast_shot: String = "CgkI5q-mtaQOEAIQAg"
const achievement_all_6_continents: String = "CgkI5q-mtaQOEAIQAw"
const achievement_last_second_pass: String = "CgkI5q-mtaQOEAIQBA"
const achievement_fast_shot_5x: String = "CgkI5q-mtaQOEAIQBQ"
const achievement_same_country: String = "CgkI5q-mtaQOEAIQBg"
const achievement_goal_on_first_second: String = "CgkI5q-mtaQOEAIQBw"
const achievement_shot_to_corner_100_plus: String = "CgkI5q-mtaQOEAIQCA"
const achievement_shot_to_center_50_plus: String = "CgkI5q-mtaQOEAIQCQ"
const achievement_world_champion: String = "CgkI5q-mtaQOEAIQDg"
const achievement_50_second_rounds: String = "CgkI5q-mtaQOEAIQCg"
const achievement_60_second_rounds: String = "CgkI5q-mtaQOEAIQCw"
const achievement_70_second_rounds: String = "CgkI5q-mtaQOEAIQDA"
const achievement_only_goals: String = "CgkI5q-mtaQOEAIQDQ"


# ios achievements
const ios_achievement_fast_shot_5x: String = "fast_5"
const ios_achievement_15_x_fast_shot: String = "fast15"
const ios_achievement_last_second_pass: String = "last_second"
const ios_achievement_goal_on_first_second: String = "first_second"
const ios_achievement_50_second_rounds: String = "50_sec"
const ios_achievement_shot_to_center_50_plus: String = "center"
const ios_achievement_shot_to_corner_100_plus: String = "corner"
const ios_achievement_same_country: String = "same_country"
const ios_achievement_60_second_rounds: String = "60_sec"
const ios_achievement_only_goals: String = "100_percent_goals"
const ios_achievement_70_second_rounds: String = "70_sec"
const ios_achievement_all_6_continents: String = "all_6"
const ios_achievement_world_champion: String = "champion"


# android leaderboard
const leaderboard_goat: String = "CgkI5q-mtaQOEAIQAQ"

# ios leaderboard
const ios_leaderboard_goat: String = "goat"



# temp
var fast_shot_counter := 0

# ...
var default_balls_count := 3
const MAX_BALLS_ALLOWED := 10


# level
const FLAG: String = "FLAG"
const COUNTRY: String = "COUNTRY"
const TIME_LIMIT: String = "TIME_LIMIT"
const DIFFICULTY: String = "DIFFICULTY"
const PASS_SCORE: String = "PASS_SCORE"
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
const TOKENS: String = "TOKENS"

const GAME_MODE: String = "GAME_MODE"
const EURO_MODE: String = "EURO_MODE"
const NOT_SET_MODE: String = "NOT_SET_MODE"
const WORLD_MODE: String = "WORLD_MODE"



const various_section_dictionary_keys = [
	TOKENS,
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
	 BEST_SCORE,
	 UNLOCKED,
	 REWARDED_BALLS
]


const VARIOUS_SECTION: String = "VARIOUS_SECTION"

func vibrate(duration: int = 10):
	if OS.has_feature("vibrate"):
		match OS.get_name():
			"Android":
				Input.vibrate_handheld(duration)
			"iOS":
				Input.vibrate_handheld(duration / 2)


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
	

func get_flag_path() -> String:
	var path = "res://art/flag/"
	if Data.game_mode == C.EURO_MODE:
		path = "res://art/team_flag/"
	return path
	

func get_extension() -> String:
	var extension = ".png"
	if Data.game_mode == C.EURO_MODE:
		extension = ".jpg"
	return extension
