extends Node

signal level_lost
signal level_won
signal level_won_and_changed(level_path : String)

@export_file("*.tscn") var next_level_path : String

const ProductDevelopmentDialog = preload("res://scenes/game_scene/product_development_dialog.tscn")
var product_dialog: AcceptDialog

var level_state : LevelState
var current_products : Array[Product] = []
var current_buyers : Array[Buyer] = []
var current_leads : Array[Lead] = []
var marketing_dept : Marketing = Marketing.new()
var sales_dept : Sales = Sales.new()
var finance_dept : Finance = Finance.new()
var operations_dept : Operations = Operations.new()
var game_time : float = 0.0

func _on_lose_button_pressed() -> void:
	level_lost.emit()

func _on_win_button_pressed() -> void:
	if not next_level_path.is_empty():
		level_won_and_changed.emit(next_level_path)
	else:
		level_won.emit()

func open_tutorials() -> void:
	%TutorialManager.open_tutorials()
	level_state.tutorial_read = true
	GlobalState.save()

func _ready() -> void:
	level_state = GameState.get_level_state(scene_file_path)
	if not level_state.tutorial_read:
		open_tutorials()
	
	# Initialize product development dialog
	product_dialog = ProductDevelopmentDialog.instantiate()
	add_child(product_dialog)
	product_dialog.setup(finance_dept)
	product_dialog.product_developed.connect(_on_product_developed)
	
	# Get reference to product list container
	var product_list_vbox = %ProductListVBox
	
	# Initialize buyers for the market
	initialize_buyers()
	
	# Update GUI displays
	update_gui_displays()

func _on_color_picker_button_color_changed(color : Color) -> void:
	%BackgroundColor.color = color
	level_state.color = color
	GlobalState.save()

func _on_tutorial_button_pressed() -> void:
	open_tutorials()

# Product Development functionality
func create_new_product(product_name: String = "") -> Product:
	# Calculate development cost
	var development_cost = finance_dept.calculate_product_development_cost()
	
	# Check if business can afford the development
	if not finance_dept.can_afford(development_cost):
		print("Cannot afford product development! Cost: $", development_cost, ", Balance: $", finance_dept.get_cash_balance())
		return null
	
	var new_product = Product.new(product_name if not product_name.is_empty() else "Product " + str(current_products.size() + 1))
	
	# Record the development expense
	finance_dept.record_expense(development_cost, "product_development")
	
	# Add intellectual property value to assets
	var ip_value = development_cost * 0.7  # 70% of development cost becomes IP value
	finance_dept.add_asset_value(ip_value, "intellectual_property")
	
	current_products.append(new_product)
	print("Created new product: ", new_product.product_name)
	print("  - Attractiveness: ", new_product.attractiveness)
	print("  - Utility: ", new_product.utility)
	print("  - Quality: ", new_product.quality)
	print("  - Development Cost: $", development_cost)
	return new_product

func get_products() -> Array[Product]:
	return current_products

func _on_create_product_button_pressed() -> void:
	product_dialog.show_dialog()

func _on_product_developed(product: Product) -> void:
	# Calculate development cost
	var development_cost = finance_dept.calculate_product_development_cost()
	
	# Record the development expense
	finance_dept.record_expense(development_cost, "product_development")
	
	# Add intellectual property value to assets
	var ip_value = development_cost * 0.7  # 70% of development cost becomes IP value
	finance_dept.add_asset_value(ip_value, "intellectual_property")
	
	current_products.append(product)
	print("Developed new product: ", product.product_name)
	print("  - Attractiveness: ", product.attractiveness)
	print("  - Utility: ", product.utility)
	print("  - Quality: ", product.quality)
	print("  - Innovation: ", product.innovation_level)
	print("  - Development Cost: $", development_cost)
	update_product_display()

func _on_product_button_pressed(product_index: int) -> void:
	if product_index >= 0 and product_index < current_products.size():
		show_product_attributes(current_products[product_index])

func show_product_attributes(product: Product) -> void:
	var dialog = AcceptDialog.new()
	dialog.title = "Product Attributes - " + product.product_name
	dialog.size = Vector2i(450, 500)
	
	var scroll = ScrollContainer.new()
	var vbox = VBoxContainer.new()
	scroll.add_child(vbox)
	dialog.add_child(scroll)
	
	scroll.anchors_preset = Control.PRESET_FULL_RECT
	scroll.offset_left = 8
	scroll.offset_top = 8
	scroll.offset_right = -8
	scroll.offset_bottom = -36
	
	# Add product information
	var info_lines = [
		"Product Name: " + product.product_name,
		"",
		"Core Attributes:",
		"  Attractiveness: " + str(int(product.attractiveness)) + "/100",
		"  Utility: " + str(int(product.utility)) + "/100", 
		"  Quality: " + str(int(product.quality)) + "/100",
		"  Value: " + str(int(product.value)) + "/100",
		"",
		"Business Metrics:",
		"  Brand Appeal: " + str(int(product.brand_appeal)) + "/100",
		"  Market Fit: " + str(int(product.market_fit)) + "/100",
		"  Innovation Level: " + str(int(product.innovation_level)) + "/100",
		"  Durability: " + str(int(product.durability)) + "/100",
		"  Environmental Impact: " + str(int(product.environmental_impact)) + "/100",
		"",
		"Financial:",
		"  Production Cost: $" + str(int(product.cost)),
		"  Retail Price: $" + str(int(product.retail_price)),
		"  Profit Margin: " + str(int(product.get_profit_margin())) + "%",
		"",
		"Performance:",
		"  Overall Score: " + str(int(product.get_overall_score())) + "/100",
		"  Market Demand: " + str(int(product.estimate_market_demand())) + "/100",
		"  Market Ready: " + ("Yes" if product.is_market_ready() else "No")
	]
	
	for line in info_lines:
		var label = Label.new()
		label.text = line
		if line.begins_with("  "):
			label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
		elif line == "":
			label.custom_minimum_size.y = 5
		elif line.ends_with(":"):
			label.add_theme_color_override("font_color", Color(0.9, 0.9, 1.0))
		vbox.add_child(label)
	
	add_child(dialog)
	dialog.popup_centered()
	dialog.confirmed.connect(func(): dialog.queue_free())

func _on_product_development_pane_gui_input(event: InputEvent) -> void:
	# Removed automatic product creation on click - use Create Product button instead
	pass

# Initialize buyers for the market
func initialize_buyers(count: int = 20) -> void:
	current_buyers.clear()
	for i in range(count):
		var buyer = Buyer.new()
		current_buyers.append(buyer)
	print("Initialized ", count, " buyers for the market")

# Marketing functionality
func create_marketing_campaign(campaign_type: Marketing.CampaignType = Marketing.CampaignType.AWARENESS) -> void:
	if current_products.is_empty():
		print("No products available to market!")
		return
	
	# Estimate campaign cost (marketing dept will calculate actual cost)
	var estimated_cost = 1500.0  # Average campaign cost
	if not finance_dept.can_afford(estimated_cost):
		print("Cannot afford marketing campaign! Estimated cost: $", estimated_cost, ", Balance: $", finance_dept.get_cash_balance())
		return
	
	var product_names: Array[String] = []
	for product in current_products:
		product_names.append(product.product_name)
	
	var campaign = marketing_dept.create_campaign("", campaign_type, product_names)
	if campaign != null:
		# Record the actual campaign cost as expense
		finance_dept.record_expense(campaign.cost, "marketing")
		marketing_dept.launch_campaign(campaign)
		print("Marketing campaign launched! Cost: $", campaign.cost)
	else:
		print("Failed to create marketing campaign")

# Process marketing activities (called periodically)
func _process(delta: float) -> void:
	game_time += delta
	
	# Run marketing cycles every few seconds
	if int(game_time) % 3 == 0:  # Every 3 seconds
		var new_leads = marketing_dept.run_marketing_cycle(current_buyers, current_products, delta)
		
		# Pass new leads to sales department
		if not new_leads.is_empty():
			sales_dept.receive_leads(new_leads)
		
		for lead in new_leads:
			current_leads.append(lead)
		
		# Update buyer states over time
		for buyer in current_buyers:
			buyer.update_state_time(delta)
		
		# Update lead ages
		for lead in current_leads:
			lead.update_age(delta)
		
		# Run operations cycle (production and delivery)
		var operations_results = operations_dept.run_operations_cycle(delta, finance_dept)
		
		# Process customer reviews for marketing feedback
		var customer_reviews = operations_dept.get_customer_reviews_for_marketing()
		if not customer_reviews.is_empty():
			marketing_dept.process_customer_reviews(customer_reviews)
		
		# Update GUI displays with latest data
		update_gui_displays()

# Get buyer state summary
func get_buyer_summary() -> Dictionary:
	var oblivious_count = 0
	var educated_count = 0
	var interested_count = 0
	
	for buyer in current_buyers:
		match buyer.current_state:
			Buyer.BuyerState.OBLIVIOUS:
				oblivious_count += 1
			Buyer.BuyerState.EDUCATED:
				educated_count += 1
			Buyer.BuyerState.INTERESTED:
				interested_count += 1
	
	return {
		"oblivious": oblivious_count,
		"educated": educated_count,
		"interested": interested_count,
		"total": current_buyers.size(),
		"leads": current_leads.size()
	}

func _on_marketing_pane_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		create_marketing_campaign()
		update_marketing_display()
		var summary = get_buyer_summary()
		print("Buyer states - Oblivious: ", summary.oblivious, ", Educated: ", summary.educated, ", Interested: ", summary.interested, ", Leads: ", summary.leads)

# Sales functionality
func process_sales() -> void:
	# Track revenue before processing sales
	var previous_revenue = sales_dept.total_revenue
	
	var results = sales_dept.run_sales_cycle(current_products)
	var performance = sales_dept.get_performance_summary()
	
	# Calculate new revenue generated this cycle
	var new_revenue = sales_dept.total_revenue - previous_revenue
	if new_revenue > 0:
		finance_dept.record_revenue(new_revenue, "sales")
	
	# Pass new sales to operations for production
	if results.has("new_sales") and not results.new_sales.is_empty():
		for sale in results.new_sales:
			operations_dept.process_new_sale(sale)
	
	print("Sales Results - Contacted: ", results.contacted, ", Qualified: ", results.qualified, ", Converted: ", results.converted)
	print("Sales Performance - Total Sales: ", performance.total_sales, ", Revenue: $", performance.total_revenue, ", Conversion Rate: ", performance.conversion_rate, "%")

func _on_sales_pane_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		process_sales()
		update_sales_display()

func _on_operations_pane_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		# Manual operations processing for testing/demonstration
		var ops_results = operations_dept.run_operations_cycle(1.0, finance_dept)
		print("Manual Operations Cycle - Production Started: ", ops_results.production_started, 
			  ", Production Completed: ", ops_results.production_completed,
			  ", Deliveries Started: ", ops_results.deliveries_started,
			  ", Deliveries Completed: ", ops_results.deliveries_completed)
		update_operations_display()

# GUI Update Functions
func update_gui_displays() -> void:
	update_product_display()
	update_marketing_display()
	update_sales_display()
	update_operations_display()
	update_finance_display()

func update_product_display() -> void:
	var product_count_label = %ProductCountLabel
	var product_list_vbox = %ProductListVBox
	
	if product_count_label:
		product_count_label.text = "Products: " + str(current_products.size())
	
	if product_list_vbox:
		# Clear existing buttons
		for child in product_list_vbox.get_children():
			child.queue_free()
		
		if current_products.is_empty():
			var no_products_label = Label.new()
			no_products_label.text = "No products yet"
			no_products_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			product_list_vbox.add_child(no_products_label)
		else:
			# Create individual buttons for each product
			for i in range(current_products.size()):
				var product = current_products[i]
				var product_button = Button.new()
				product_button.text = product.product_name + " (Score: " + str(int(product.get_overall_score())) + ")"
				product_button.alignment = HORIZONTAL_ALIGNMENT_LEFT
				
				# Connect button to show product attributes
				var product_index = i
				product_button.pressed.connect(_on_product_button_pressed.bind(product_index))
				
				product_list_vbox.add_child(product_button)

func update_marketing_display() -> void:
	var campaign_count_label = %CampaignCountLabel
	var buyer_states_label = %BuyerStatesLabel
	var leads_label = %LeadsLabel
	
	# Get marketing department data
	var active_campaigns = marketing_dept.get_active_campaigns().size()
	var summary = get_buyer_summary()
	
	if campaign_count_label:
		campaign_count_label.text = "Active Campaigns: " + str(active_campaigns)
	
	if buyer_states_label:
		buyer_states_label.text = "Oblivious: " + str(summary.oblivious) + " | Educated: " + str(summary.educated) + " | Interested: " + str(summary.interested)
	
	if leads_label:
		leads_label.text = "Leads Generated: " + str(summary.leads)

func update_sales_display() -> void:
	var leads_processed_label = %LeadsProcessedLabel
	var sales_performance_label = %SalesPerformanceLabel
	var conversion_rate_label = %ConversionRateLabel
	
	# Get sales department performance data
	var performance = sales_dept.get_performance_summary()
	
	if leads_processed_label:
		leads_processed_label.text = "Contacted: " + str(sales_dept.leads_contacted) + " | Qualified: " + str(sales_dept.leads_qualified)
	
	if sales_performance_label:
		sales_performance_label.text = "Converted: " + str(performance.total_sales) + " | Revenue: $" + str(int(performance.total_revenue))
	
	if conversion_rate_label:
		conversion_rate_label.text = "Conversion Rate: " + str(int(performance.conversion_rate)) + "%"

func update_operations_display() -> void:
	var sales_queue_label = %SalesQueueLabel
	var production_label = %ProductionLabel
	var delivery_label = %DeliveryLabel
	var reviews_label = %ReviewsLabel
	
	# Get operations data
	var ops_summary = operations_dept.get_operations_summary()
	
	if sales_queue_label:
		sales_queue_label.text = "Sales Queue: " + str(ops_summary.sales_in_queue)
	
	if production_label:
		production_label.text = "Production: " + str(ops_summary.active_production) + " active / " + str(ops_summary.production_queue) + " queue"
	
	if delivery_label:
		delivery_label.text = "Delivery: " + str(ops_summary.active_deliveries) + " active / " + str(ops_summary.delivery_queue) + " queue"
	
	if reviews_label:
		reviews_label.text = "Customer Reviews: " + str(ops_summary.customer_reviews)

func update_finance_display() -> void:
	var cash_balance_label = %CashBalanceLabel
	var revenue_label = %RevenueLabel
	var expenses_label = %ExpensesLabel
	var profit_loss_label = %ProfitLossLabel
	
	# Get financial data from finance department
	var balance = finance_dept.get_cash_balance()
	var total_revenue = finance_dept.get_total_revenue()
	var total_expenses = finance_dept.get_total_expenses()
	var net_profit = total_revenue - total_expenses
	
	if cash_balance_label:
		cash_balance_label.text = "Cash Balance: $" + str(int(balance))
	
	if revenue_label:
		revenue_label.text = "Revenue: $" + str(int(total_revenue))
	
	if expenses_label:
		expenses_label.text = "Expenses: $" + str(int(total_expenses))
	
	if profit_loss_label:
		if net_profit >= 0:
			profit_loss_label.text = "Net Profit: $" + str(int(net_profit))
		else:
			profit_loss_label.text = "Net Loss: $" + str(int(abs(net_profit)))
