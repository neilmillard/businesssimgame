extends AcceptDialog

signal campaign_created(campaign_name: String, campaign_type: int, budget: float, duration: int)

var finance_dept: Finance

func _ready():
	_setup_campaign_types()
	_update_cost_estimate()

func setup(finance_department: Finance):
	finance_dept = finance_department

func _setup_campaign_types():
	var type_option = %TypeOptionButton
	type_option.clear()
	type_option.add_item("Awareness Campaign")
	type_option.add_item("Lead Generation")
	type_option.add_item("Conversion Campaign")
	type_option.add_item("Retention Campaign")
	type_option.selected = 0

func _on_campaign_type_changed(_index: int):
	_update_cost_estimate()

func _on_budget_changed(_value: float):
	_update_cost_estimate()

func _on_duration_changed(_value: float):
	_update_cost_estimate()

func _update_cost_estimate():
	var budget = %BudgetSpinBox.value
	var duration = %DurationSpinBox.value
	var campaign_type = %TypeOptionButton.selected
	
	# Calculate estimated campaign cost based on budget and duration
	var base_multiplier = 1.0
	match campaign_type:
		0: # Awareness
			base_multiplier = 1.0
		1: # Lead Generation
			base_multiplier = 1.2
		2: # Conversion
			base_multiplier = 1.5
		3: # Retention
			base_multiplier = 0.8
	
	var estimated_cost = budget * base_multiplier * (duration / 7.0)  # Weekly baseline
	
	%CostEstimateLabel.text = "Estimated Campaign Cost: $" + str(int(estimated_cost))
	
	# Update launch button enabled state based on affordability
	if finance_dept:
		%LaunchButton.disabled = not finance_dept.can_afford(estimated_cost)
		if not finance_dept.can_afford(estimated_cost):
			%LaunchButton.text = "Cannot Afford"
		else:
			%LaunchButton.text = "Launch Campaign"

func _on_launch_button_pressed():
	var campaign_name = %NameLineEdit.text
	if campaign_name.is_empty():
		campaign_name = "Campaign " + str(randi() % 1000)
	
	var campaign_type = %TypeOptionButton.selected
	var budget = %BudgetSpinBox.value
	var duration = int(%DurationSpinBox.value)
	
	campaign_created.emit(campaign_name, campaign_type, budget, duration)
	hide()

func _on_cancel_button_pressed():
	hide()

func show_dialog():
	# Reset form to defaults
	%NameLineEdit.text = ""
	%TypeOptionButton.selected = 0
	%BudgetSpinBox.value = 1500.0
	%DurationSpinBox.value = 7.0
	_update_cost_estimate()
	show()