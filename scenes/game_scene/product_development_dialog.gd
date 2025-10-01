extends AcceptDialog

signal product_developed(product: Product)

var finance_dept: Finance

func _ready():
	# Don't call _update_cost_estimate() here as UI nodes may not be ready yet
	# It will be called when show_dialog() is invoked
	pass

func setup(finance_department: Finance):
	finance_dept = finance_department

func _on_attribute_changed(_value: float):
	_update_cost_estimate()

func _update_cost_estimate():
	var attractiveness = %AttractSpinBox.value
	var utility = %UtilitySpinBox.value
	var quality = %QualitySpinBox.value
	var innovation = %InnovationSpinBox.value
	
	# Calculate estimated development cost based on attributes
	var base_cost = 10000.0
	var complexity_factor = (quality + innovation) / 200.0  # 0-1 range
	var feature_factor = (attractiveness + utility) / 200.0  # 0-1 range
	
	var estimated_cost = base_cost * (1.0 + complexity_factor + feature_factor)
	
	%CostEstimateLabel.text = "Estimated Development Cost: $" + str(int(estimated_cost))
	
	# Update develop button enabled state based on affordability
	if finance_dept:
		%DevelopButton.disabled = not finance_dept.can_afford(estimated_cost)
		if not finance_dept.can_afford(estimated_cost):
			%DevelopButton.text = "Cannot Afford"
		else:
			%DevelopButton.text = "Develop Product"

func _on_develop_button_pressed():
	var product_name = %NameLineEdit.text
	if product_name.is_empty():
		product_name = "Product " + str(randi() % 1000)
	
	# Create new product with configured attributes
	var product = Product.new(product_name)
	product.attractiveness = %AttractSpinBox.value
	product.utility = %UtilitySpinBox.value
	product.quality = %QualitySpinBox.value
	product.innovation_level = %InnovationSpinBox.value
	
	# Set other reasonable defaults based on configured values
	product.brand_appeal = max(20.0, product.attractiveness * 0.3)
	product.market_fit = (product.attractiveness + product.utility) / 2.0
	product.production_difficulty = (product.quality + product.innovation_level) / 2.0
	product.durability = product.quality * 0.8
	product.environmental_impact = 40.0  # Default value
	product.value = (product.attractiveness + product.utility + product.quality) / 3.0
	
	# Set basic pricing (can be refined later)
	product.cost = 50.0 + (product.quality * 2.0)
	product.retail_price = product.cost * (1.5 + product.attractiveness / 100.0)
	
	product_developed.emit(product)
	hide()

func _on_cancel_button_pressed():
	hide()

func show_dialog():
	# Reset form to defaults
	%NameLineEdit.text = ""
	%AttractSpinBox.value = 50.0
	%UtilitySpinBox.value = 50.0
	%QualitySpinBox.value = 50.0
	%InnovationSpinBox.value = 25.0
	_update_cost_estimate()
	show()