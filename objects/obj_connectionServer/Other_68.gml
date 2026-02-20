var type = ds_map_find_value(async_load, "type")
var socket = ds_map_find_value(async_load, "id")
var ip = ds_map_find_value(async_load, "ip")
var port = ds_map_find_value(async_load, "port")

switch type
{
	case network_type_connect:
		GameConnection.client = ds_map_find_value(async_load, "socket")
		print("Socket connecting with ID ", GameConnection.client)
		
		if testMode
		{
			var buf = GameConnection.CreateData(NETDATA_TEST)
			GameConnection.SendData(buf)
		}
		break
		
	case network_type_data:
		var buffer = ds_map_find_value(async_load, "buffer")
		var size = ds_map_find_value(async_load, "size")
		
		print("Received data from socket ID ", socket)
		
		var type = buffer_read(buffer, buffer_u8)
		switch type
		{
			case NETDATA_TEST:
				print("Got connection test result")
				if testMode
				{
					error_message("Connection test successful")
					instance_destroy()
				}
				break
		}
		break
}