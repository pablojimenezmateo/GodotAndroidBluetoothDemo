extends Control

var GodotBluetooth344

var location_permissions
var location_status
var bluetooth_status

var devices = []
var item_selected

onready var devices_list = $VBoxContainer/Devices/FoundDevicesList
onready var log_node = $VBoxContainer/Log/Log

# Called when the node enters the scene tree for the first time.
func _ready():
	
	if Engine.has_singleton("GodotBluetooth344"):
		
		GodotBluetooth344 = Engine.get_singleton("GodotBluetooth344")
		GodotBluetooth344.connect("_on_debug_message", self, "_on_debug_message")
		GodotBluetooth344.connect("_on_device_found", self, "_on_device_found")
		GodotBluetooth344.connect("_on_bluetooth_status_change", self, "_on_bluetooth_status_change")
		GodotBluetooth344.connect("_on_location_status_change", self, "_on_location_status_change")
		GodotBluetooth344.connect("_on_connection_status_change", self, "_on_connection_status_change")

func _on_connection_status_change(status):
	# There can be 2 states:
	# * connected
	# * disconnected
	log_string("[_on_connection_status_change] " + status)

func _on_location_status_change(status):
	
	# There can be 2 states:
	# * on
	# * off
	log_string("[_on_location_status_change] " + status)

func _on_bluetooth_status_change(status):
	
	# There can be 4 states:
	# * on
	# * turning_on
	# * off
	# * turning_off
	log_string("[_on_bluetooth_status_change] " + status)
	
func _on_Button_button_up():
	
	var boolean
	
	log_string("Checking bluetooth status")
	boolean = GodotBluetooth344.bluetoothStatus()
	log_string(boolean)
		
	log_string("Checking location status")
	boolean = GodotBluetooth344.locationStatus()
	log_string(boolean)
	
	log_string("Checking location permissions")
	boolean = GodotBluetooth344.hasLocationPermissions()
	log_string(boolean)
	
	
func _on_debug_message(s):
	
	log_string("[DEBUG] " + s)

func _on_device_found(new_device):
	
	log_string("Got a new device: " + str(new_device))
	devices.append(new_device)
	devices_list.add_item(new_device.name + " " + new_device.address + " " + str(new_device.rssi))

func _on_scanButton_button_up():
	
	# Erase the results from the previous scan
	devices = []
	devices_list.clear()
	item_selected = null
	
	GodotBluetooth344.scan()
	
# Prints and writes to the log
func log_string(s):
	
	var time = OS.get_time()
	var time_str = String(time.hour) +":"+String(time.minute)+":"+String(time.second)
	
	var text = "[" + time_str + "] " + str(s)
	
	log_node.add_text(text + "\n")
	print(text)
	


func _on_ConnectButton_button_up():
	
	if item_selected != null:
		
		var address = devices[item_selected].address
		
		log_string("Connecting to " + address)
		
		GodotBluetooth344.connect(address)


func _on_DisconnectButton_button_up():
	
	GodotBluetooth344.disconnect()


# When a device on the list is selected, save the index
func _on_FoundDevicesList_item_selected(index):
	
	item_selected = index
