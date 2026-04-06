local FakeConnections = {}
export type BaseConnection = {
	Disconnect: (self: BaseConnection) -> (),
	
	Once: boolean,
	
	Dead: boolean,
	
}
export type FakeConnection= {
	--Disconnect: (self: FakeConnection) -> (),
	Connections: {() -> ()},
	
	DisconnectAll: (self: FakeConnection) -> nil,
	
	Fire: (self:FakeConnection,any?) -> nil,
	
	Connect: (self:FakeConnection,func:()->())->BaseConnection,
	
	Once: (self:FakeConnection,func:()->())->BaseConnection,
	
	Remove: (self:FakeConnection)->(),
}
function FakeConnections.new(Connections:{}?)
	local self = setmetatable({},FakeConnections)
	
	self.Connections = Connections or {}
	
	self.DisconnectAll = function(self)
		
		for _,connection:BaseConnection in self.Connections do
			connection:Disconnect()
		end
		
	end
	
	self.Fire = function(self,...)
		if #self.Connections < 0 then return end
		
		for _,connection:BaseConnection in self.Connections do
			
			if connection.Dead then continue end
			
			if connection.Once then	connection:Disconnect() end 
			
			task.spawn(connection.Callback or warn,...)
			
		end
		
	end
	self.Connect = function(self,func)
		local connection:BaseConnection = {}
		connection.Dead = false
		connection.Once = false
		connection.Callback=func
		
		connection.Disconnect = function(connection)
			
			connection.Dead = true
			table.remove(self.Connections,table.find(self.Connections,connection))
			
		end
		
		table.insert(self.Connections,connection)
		return connection
	end
	self.Once=function(self,func)
		local connection:BaseConnection = {}
		connection.Dead = false
		connection.Once = true
		connection.Callback= func
		
		connection.Disconnect = function(connection)
			
			connection.Dead = true
			table.remove(self.Connections,table.find(self.Connections,connection))
			
		end
		
		table.insert(self.Connections,connection)
		return connection
	end
	
	self.Remove = function(self)
		self:DisconnectAll()
		setmetatable(self,nil)
	end
	
	return self
end
return FakeConnections
