#macro NETDATA_TEST 0
#macro NETDATA_CLIENTDISCONNECT 1
#macro NETDATA_TESTROOM 2

function GameConnection() constructor
{
	static server = -4
	static client = -4
	static serverInstance = undefined
	
	static CreateServerSocket = function()
	{
		if (server >= 0)
			return server;
		
		var port = 7250
		while (server < 0 && port < 65535)
		{
			server = network_create_server(network_socket_tcp, port, 1)
			if (server < 0)
				print("Port ", port, " not available, trying ", ++port)
		}
		
		print("Created server socket")
		print("Server port: ", port)
		
		return server;
	}
	
	static DestroyServerSocket = function()
	{
		if (server >= 0)
		{
			network_destroy(server)
			server = -4
		}
	}
	
	static SendClientDisconnect = function()
	{
		if (client >= 0)
		{
			print("Sending request to stop connection...")
			
			var buf = CreateData(NETDATA_CLIENTDISCONNECT)
			SendData(buf)
			
			network_destroy(client)
			client = -4
		}
	}
	
	static TestConnection = function()
	{
		StartServer().testMode = true
		return serverInstance;
	}
	
	static StartServer = function()
	{
		if is_undefined(serverInstance)
		{
			print("Starting server")
			serverInstance = instance_create_depth(0, 0, 0, obj_connectionServer)
		}
			
		return serverInstance;
	}
	
	static StopServer = function()
	{
		if !is_undefined(serverInstance)
		{
			print("Stopping server")
			instance_destroy(serverInstance)
		}
	}
	
	static CreateData = function(type)
	{
		var buf = buffer_create(2, buffer_grow, 1)
		buffer_write(buf, buffer_u8, type)
		
		switch type
		{
			case NETDATA_TEST:
				buffer_write(buf, buffer_string, "Hello World!")
				break
		}
		
		return buf;
	}
	
	static SendData = function(buffer)
	{
		if (client >= 0)
			network_send_packet(client, buffer, buffer_get_size(buffer))
	}
	
	static TestRoomInGame = function()
	{
		if (server < 0)
		{
			error_message("You need to start the server first and have the game connected to it before you can test the room.")
			exit;
		}
		
		if (client < 0)
		{
			error_message("The game needs to be connected to the server before you can test the room.")
			exit;
		}
		
		var savefunc = save_room_rf
		if (obj_roomManager.roomFormat == ROOMFORMAT_CYOP)
			savefunc = save_room_cyop
			
		var rm = savefunc()
		var jsonstr = json_stringify(rm)
		var b64str = base64_encode(jsonstr)
		
		var buf = CreateData(NETDATA_TESTROOM)
		buffer_write(buf, buffer_string, b64str)
		SendData(buf)
	}
}

static_get(new GameConnection())