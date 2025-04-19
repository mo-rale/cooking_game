extends Node

var player_cash = 20  # Initial cash amount
var cash: int = 20  # Player's cash amount
var food_prices = {
	"burger": 5,   # $5
	"pizza": 8,    # $8
	"soda": 2      # $2
}

func _ready():
	update_cash_ui()  # Ensure UI updates on start

# Function to add cash
func add_cash(amount: int):
	cash += amount
	update_cash_ui()
	print("💰 Cash added: ", amount, " | Total: ", cash)

# Function to subtract cash
func subtract_cash(amount: int) -> bool:
	if cash >= amount:
		cash -= amount
		update_cash_ui()  # Ensure UI updates after purchase
		print("💸 Cash subtracted: ", amount, " | Total: ", cash)
		return true
	else:
		print("❌ Not enough cash!")
		return false

# Function to update UI
func update_cash_ui():
	if has_node("UI/CashLabel"):
		var label = get_node("UI/CashLabel")
		label.text = "Cash: $" + str(cash)
		print("🔄 UI Updated: Cash = ", cash)  # Debugging
	else:
		print("❌ CashLabel not found in UI!")

func update_cash_label(amount = 0):  
	player_cash += amount  
	cash = player_cash  # Ensure cash and player_cash stay in sync
	update_cash_ui()  # Call UI update function
