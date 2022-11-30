extends VBoxContainer

var payment = null
const BALL = "ball"
const INTERMEDIATE_ADS = "intermediate_ads"
const TWO_BALLS_NO_ADS = "two_balls_and_remove_ads"


var SKUS = [
	BALL,
	INTERMEDIATE_ADS,
	TWO_BALLS_NO_ADS
]


func _set(property, value):
	if property == "visible":
		var max_balls_count = Data.get_max_balls_to_add_count()
		if value == true and max_balls_count == 0:
			ball.disabled = true
			maximum_reached.visible = true
			two_balls_no_ads.disabled = true
			maximum_reached_ads.visible = true
		elif value == true and max_balls_count == 1:
			two_balls_no_ads.disabled = true
			maximum_reached_ads.visible = true
		else:
			ball.disabled = false
			maximum_reached.visible = false
			two_balls_no_ads.disabled = false
			maximum_reached_ads.visible = false


onready var maximum_reached_ads = $TwoBallsNoAds/MaximumReachedAds
onready var maximum_reached = $Ball/MaximumReached
onready var ball = $Ball
onready var intermediate_ads = $IntermediateAds
onready var two_balls_no_ads = $TwoBallsNoAds


signal add_ball

func _ready():
	if Engine.has_singleton("GodotGooglePlayBilling"):
		payment = Engine.get_singleton("GodotGooglePlayBilling")
		# No params.
		payment.connect("connected", self, "_on_connected")
		# No params.
		payment.connect("disconnected", self, "_on_disconnected")
		# No params.
		payment.connect("billing_resume", self, "_on_billing_resume")
		# Response ID (int), Debug message (string).
		payment.connect("connect_error", self, "_on_connect_error")
		# Purchases (Dictionary[]).
		payment.connect("purchases_updated", self, "_on_purchases_updated")
		# Response ID (int), Debug message (string).
		payment.connect("purchase_error", self, "_on_purchase_error")
		# SKUs (Dictionary[]).
		payment.connect("product_details_query_completed", self, "_on_product_details_query_completed")
		# Response ID (int), Debug message (string), Queried SKUs (string[]).
		payment.connect("product_details_query_error", self, "_on_product_details_query_error")
		# Purchase token (string).
		payment.connect("purchase_acknowledged", self, "_on_purchase_acknowledged")
		# Response ID (int), Debug message (string), Purchase token (string).
		payment.connect("purchase_acknowledgement_error", self, "_on_purchase_acknowledgement_error")
		# Purchase token (string).
		payment.connect("purchase_consumed", self, "_on_purchase_consumed")
		# Response ID (int), Debug message (string), Purchase token (string).
		payment.connect("purchase_consumption_error", self, "_on_purchase_consumption_error")
		# Purchases (Dictionary[])
		payment.connect("query_purchases_response", self, "_on_query_purchases_response")
		payment.startConnection()
	else:
		print("Android IAP support is not enabled. Make sure you have enabled 'Custom Build' and installed and enabled the GodotGooglePlayBilling plugin in your Android export settings! This application will not work.")


func _on_connected():
	print("PurchaseManager connected")
	payment.queryPurchases("inapp") # Use "subs" for subscriptions.
	payment.querySkuDetails(SKUS, "inapp")


func _on_billing_resume():
	print("PurchaseManager resumed")


func _on_query_purchases_response(query_result):
	if query_result.status == OK:
		for purchase in query_result.purchases:
			# We must acknowledge all puchases.
			# See https://developer.android.com/google/play/billing/integrate#process for more information
			if not purchase.is_acknowledged:
				print("Purchase " + str(purchase.sku) + " has not been acknowledged. Acknowledging...")
				payment.acknowledgePurchase(purchase.purchase_token)
	else:
		print("queryPurchases failed, response code: ",
				query_result.response_code,
				" debug message: ", query_result.debug_message)

# "description":"One permanent ball you can use in all levels",
# "id":"ball",
# "one_time_purchase_details":{"formatted_price":"€1.99","price_amount_micros":1990000,"price_currency_code":"EUR"},
# "title":"Ball (com.indest.penalty2d (unreviewed))",
# "type":"inapp"

func _on_product_details_query_completed(sku_details):
	for available_sku in sku_details:
		var price = available_sku["one_time_purchase_details"]["formatted_price"]
		if available_sku["id"] == BALL:
			ball.text = available_sku["title"].get_slice("(", 0) + " - " + price
			ball.disabled = false
		elif available_sku["id"] == INTERMEDIATE_ADS:
			intermediate_ads.text = available_sku["title"].get_slice("(", 0) + " - " + price
			intermediate_ads.disabled = false
		elif available_sku["id"] == TWO_BALLS_NO_ADS:
			two_balls_no_ads.text = available_sku["title"].get_slice("(", 0) + " - " + price
			two_balls_no_ads.disabled = false
		print(to_json(available_sku))


#{"is_acknowledged":false,
#"is_auto_renewing":false,
#"order_id":"GPA.3319-2871-9696-71923",
#"original_json":"{\"orderId\":\"GPA.3319-2871-9696-71923\",
#\"packageName\":\"com.indest.penalty2d\",
#\"productId\":\"ball\",
#\"purchaseTime\":1669751718344,
#\"purchaseState\":0,
#\"purchaseToken\":\"gafkpajggancdhjaifahkhgj.AO-J1OzNbuv8fDgsV2u98PvuAIwF8gOOZ45p0iyNvvd-wJ16xju0XG73KbWQsqv1ajl1qGi5jl3SSfiXH1nyimwjHQyn6nGKYQ\",
#\"quantity\":1,
#\"acknowledged\":false}",
#"package_name":"com.indest.penalty2d",
#"products":["ball"],
#"purchase_state":1,
#"purchase_time":1669751718344,
#"purchase_token":"REMOVED",
#"quantity":1,
#"signature":"REMOVED

func _handle_purchase(purchase):
	if purchase.purchase_state == 1:
		_give_content(purchase.products[0])
		if purchase.products[0] == BALL:
			_consume(purchase.purchase_token)
		else:
			if !purchase.is_acknowledged:
				print("Purchase " + str(purchase.sku) + " has not been acknowledged. Acknowledging...")
				payment.acknowledgePurchase(purchase.purchase_token)


func _give_content(sku):
	match sku:
		BALL:
			emit_signal("add_ball")
		INTERMEDIATE_ADS:
			pass
		TWO_BALLS_NO_ADS:
			pass


func _on_purchases_updated(purchases):
	print("Purchases updated: %s" % to_json(purchases))
	# See _on_connected
	for purchase in purchases:
		_handle_purchase(purchase)


func _on_purchase_acknowledged(purchase_token):
	print("Purchase acknowledged: %s" % purchase_token)
	

func _on_purchase_consumed(purchase_token):
	print("Purchase consumed successfully: %s" % purchase_token)
	
	
func _on_purchase_error(code, message):
	print("Purchase error %d: %s" % [code, message])
	

func _on_purchase_acknowledgement_error(code, message):
	print("Purchase acknowledgement error %d: %s" % [code, message])
	
	
func _on_purchase_consumption_error(code, message, purchase_token):
	print("Purchase consumption error %d: %s, purchase token: %s" % [code, message, purchase_token])


func _on_product_details_query_error(code, message):
	print("SKU details query error %d: %s" % [code, message])
	

func _on_disconnected():
	print("GodotGooglePlayBilling disconnected. Will try to reconnect in 10s...")
	yield(get_tree().create_timer(10), "timeout")
	payment.startConnection()
	

func _purchase(sku):
	var response = payment.purchase(sku)
	if response.status != OK:
		print("Purchase error %s: %s" % [response.response_code, response.debug_message])


func _consume(sku_token):
	if sku_token == null:
		print("You need to set 'test_item_purchase_token' first! (either by hand or in code)")
		return
	payment.consumePurchase(sku_token)


# GUI
func _on_Ball_pressed():
	get_parent()._on_BackButton_pressed()
	_purchase(BALL)


func _on_IntermediateAds_pressed():
	get_parent()._on_BackButton_pressed()
	_purchase(INTERMEDIATE_ADS)


func _on_TwoBallsNoAds_pressed():
	get_parent()._on_BackButton_pressed()
	_purchase(TWO_BALLS_NO_ADS)
