extends Control

var GodotBluetooth344

var location_permission
var location_status
var bluetooth_status
var connected

var devices = []
var item_selected

# Test UUIDs
var service_uuid = "6e400001-b5a3-f393-e0a9-e50e24dcca9e"
var read_uuid    = "6e400003-b5a3-f393-e0a9-e50e24dcca9e"
var write_uuid   = "6e400002-b5a3-f393-e0a9-e50e24dcca9e"

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
		GodotBluetooth344.connect("_on_characteristic_found", self, "_on_characteristic_found")
		GodotBluetooth344.connect("_on_characteristic_finding", self, "_on_characteristic_finding")
		GodotBluetooth344.connect("_on_characteristic_read", self, "_on_characteristic_read")

	# Check the permissions
	check_permissions()
	
	connected = false
	set_connected()
	
	
func _on_characteristic_read(data):
	# data is a dictionary with the following keys
	# * service_uuid: The serice UUID
	# * characteristic_uuid: The characteristic UUID
	# * bytes: They raw bytes of the payload
	log_string("[_on_characteristic_read] " + str(data.characteristic_uuid))
	
	log_string(str(data.bytes))
	
	# If your bytes represent a UTF-8 string, use the 
	# following code:
	var string = PoolByteArray(data.bytes).get_string_from_utf8()
	log_string(string)

func _on_characteristic_finding(status):
	# There can be 2 status:
	# * processing
	# * done
	
	log_string("[_on_characteristic_finding] " + str(status))
	
	if status == "done":
		GodotBluetooth344.subscribeToCharacteristic(service_uuid, read_uuid)
	
func _on_characteristic_found(characteristic):
	
	# characteristic is a dictionary with the following keys
	# * service_uuid: The serice UUID
	# * characteristic_uuid: The characteristic UUID
	# * real_mask: The mask of the characteristic, for more information check: https://developer.android.com/reference/android/bluetooth/BluetoothGattCharacteristic.html#getProperties()
	# * readable: If this characteristic is readable
	# * writable: If this characteristic is writable
	# * writable_no_response: If this characteristic is writable with no response
	log_string("[_on_characteristic_found] " + str(characteristic))

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
		connected = true
	else:
		connected = false
	
	set_connected()

func _on_location_status_change(status):
	
	# There can be 2 status:
	# * on
	# * off
	log_string("[_on_location_status_change] " + status)
	
	if status == "on":
		
		location_status = true
	else:
		location_status = false

	set_location_status()
	
func _on_bluetooth_status_change(status):
	
	# There can be 4 status:
	# * on
	# * turning_on
	# * off
	# * turning_off
	log_string("[_on_bluetooth_status_change] " + status)
	
	if status == "on":
		
		bluetooth_status = true
	else:
		bluetooth_status = false
		
	set_bluetooth_status()
	
func check_permissions():
	
	var boolean
	
	log_string("Checking bluetooth status")
	boolean = GodotBluetooth344.bluetoothStatus()
	log_string(boolean)
	bluetooth_status = boolean
		
	log_string("Checking location status")
	boolean = GodotBluetooth344.locationStatus()
	log_string(boolean)
	location_status = boolean
	
	log_string("Checking location permissions")
	boolean = GodotBluetooth344.hasLocationPermissions()
	log_string(boolean)
	location_permission = boolean
	
	set_location_permission()
	set_bluetooth_status()
	set_location_status()
	set_location_permission()
	
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
	set_buttons()
	
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
	set_buttons()

func _on_SendTextButton_button_up():
		
	var text = send_line_edit.text
	
	if text != "":
		
		GodotBluetooth344.writeStringToCharacteristic(service_uuid, write_uuid, text)
		
# UI helpers
onready var bluetooth_label = $VBoxContainer/TopLabels/HBoxContainer2/HBoxContainer/BluetoohStatusLabel2
onready var location_label = $VBoxContainer/TopLabels/VBoxContainer/HBoxContainer3/LocationStatusLabel2
onready var location_permission_label = $VBoxContainer/TopLabels/VBoxContainer/HBoxContainer/LocationPermissionLabel2
onready var connected_label = $VBoxContainer/TopLabels/HBoxContainer2/HBoxContainer2/ConnectedLabel2

func set_bluetooth_status():
	
	if bluetooth_status:
		
		bluetooth_label.text = "On"
	else:
		bluetooth_label.text = "Off"
		
	set_buttons()
	
func set_location_status():
	
	if location_status:
		
		location_label.text = "On"
	else:
		location_label.text = "Off"
		
	set_buttons()
	
func set_location_permission():
	
	if location_permission:
		
		location_permission_label.text = "Yes"
	else:
		location_permission_label.text = "No"
		
	set_buttons()
	
func set_connected():
	
	if connected:
		
		connected_label.text = "Yes"
	else:
		connected_label.text = "No"
		
	set_buttons()

onready var send_button = $VBoxContainer/TextAndButtons/HBoxContainer/SendTextButton
onready var scan_button = $VBoxContainer/TextAndButtons/Buttons/ScanButton
onready var connect_button = $VBoxContainer/TextAndButtons/Buttons/ConnectButton
onready var disconnect_button = $VBoxContainer/TextAndButtons/Buttons/DisconnectButton

func set_buttons():
	
	send_button.disabled = true
	scan_button.disabled = true
	connect_button.disabled = true
	disconnect_button.disabled = true
	
	# We need all 3 things to be able to scan
	if bluetooth_status and location_status and location_permission and not connected:
		
		# It is not necessary to disable the button when connected,
		# we can scan while connected but shows the workflow more clear
		# for the demo
		scan_button.disabled = false
	
	# If we have selected a device, enable the connect button
	if bluetooth_status and location_status and location_permission and item_selected != null and not connected:
		
		connect_button.disabled = false
		
	if bluetooth_status and location_status and location_permission and connected:
		
		send_button.disabled = false
		disconnect_button.disabled = false
		
