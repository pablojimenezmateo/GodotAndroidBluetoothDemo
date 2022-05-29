extends Control

var GodotBluetooth344

var location_permissions
var location_status
var bluetooth_status

var devices = []
var item_selected

# Test UUIDs
var service_uuid = "6e400001-b5a3-f393-e0a9-e50e24dcca9e"
var read_uuid = "6e400003-b5a3-f393-e0a9-e50e24dcca9e"
var write_uuid = "6e400002-b5a3-f393-e0a9-e50e24dcca9e"

onready var devices_list = $VBoxContainer/Devices/FoundDevicesList
onready var log_node = $VBoxContainer/Log/Log
onready var send_line_edit = $VBoxContainer/TextAndButtons/HBoxContainer/SendTextLine

# Called when the node enters the scene tree for the first time.
func _ready():
	
	if Engine.has_singleton("GodotBluetooth344"):
		
		GodotBluetooth344 = Engine.get_singleton("GodotBluetooth344")
		GodotBluetooth344.connect("_on_debug_message", self, "_on_debug_message")
		GodotBluetooth344.connect("_on_device_found", self, "_on_device_found")
		GodotBluetooth344.connect("_on_bluetooth_status_change", self, "_on_bluetooth_status_change")
		GodotBluetooth344.connect("_on_location_status_change", self, "_on_location_status_change")
		GodotBluetooth344.connect("_on_connection_status_change", self, "_on_connection_status_change")
		GodotBluetooth344.connect("_on_characteristic_read", self, "_on_characteristic_read")
		GodotBluetooth344.connect("_on_characteristic_reading", self, "_on_characteristic_reading")
		
func _on_characteristic_reading(status):
	# There can be 2 status:
	# * processing
	# * done
	
	log_string("[_on_characteristic_reading] " + str(status))
	
	if status == "done":
		GodotBluetooth344.subscribeToCharacteristic(service_uuid, read_uuid)
	
func _on_characteristic_read(characteristic):
	
	# characteristic is a dictionary with the following keys
	# * service_uuid: The serice UUID
	# * characteristic_uuid: The characteristic UUID
	# * real_mask: The mask of the characteristic, for more information check: https://developer.android.com/reference/android/bluetooth/BluetoothGattCharacteristic.html#getProperties()
	# * readable: If this characteristic is readable
	# * writable: If this characteristic is writable
	# * writable_no_response: If this characteristic is writable with no response
	log_string("[_on_characteristic_read] " + str(characteristic))

func _on_connection_status_change(status):
	# There can be 3 status:
	# * connected
	# * disconnected
	# * An integer, this means an error, check https://developer.android.com/reference/android/bluetooth/BluetoothGatt.html#constants_2 for more information
	log_string("[_on_connection_status_change] " + status)
	
	# If you do not know the services and characteristics of the peer device
	# call listServicesAndCharacteristics() once connected
	if status == "connected":
		GodotBluetooth344.listServicesAndCharacteristics()

func _on_location_status_change(status):
	
	# There can be 2 status:
	# * on
	# * off
	log_string("[_on_location_status_change] " + status)

func _on_bluetooth_status_change(status):
	
	# There can be 4 status:
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
	print(s)
	
	log_string("[DEBUG] " + s)

func _on_device_found(new_device):
	# new_device is a dictionary with the following keys:
	# * address: MAC address of the device
	# * name: Name of the device
	# * rssi: Signal strength of the device in dBm
	
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

func _on_SendTextButton_button_up():
		
	var text = send_line_edit.text
	
	if text != "":
		
		GodotBluetooth344.writeToCharacteristic(service_uuid, write_uuid, text)
		
