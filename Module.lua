-- // Vars
local taskwait = task.wait or wait

-- // Signal Class
local Signal = {}
Signal.__index = Signal
Signal.__type = "Signal"
Signal.ClassName = "Signal"

-- // Connection Class
local Connection = {}
Connection.__index = Connection
Connection.__type = "Connection"
Connection.ClassName = "Connection"

-- // Connection Constructor
function Connection.new(Signal: table, Callback: any): table

    -- // Create
    local self = setmetatable({}, Connection)

    -- // Set properties
    self.Function = Callback
    self.State = true
    self.Signal = Signal

    -- // Return new class
    return self
end

-- // Enable a conneciton
function Connection.Enable(self: table): nil
    self.State = true
end

-- // Disable a connection
function Connection.Disable(self: table): nil
    self.State = false
end

-- // Disconnect a connection
function Connection.Disconnect(self: table): nil
    -- // Vars
    local Connections = self.Signal.Connections
    local selfInTable = table.find(Connections, self)

    -- // Remove
    table.remove(Connections, selfInTable)
end

-- // Signal Constructor
function Signal.new(Name: string): table

    -- // Create
    local self = setmetatable({}, Signal)

    -- // Set properties
    self.Name = Name
    self.Connections = {}

    -- // Return new class
    return self
end

-- // Connect to a signal
function Signal.Connect(self: table, Callback: any): table

    -- // Create Connection Object
    local connection = Connection.new(self, Callback)

    -- // Add to connections
    table.insert(self.Connections, connection)

    -- // Return
    return connection
end
Signal.connect = Signal.Connect

-- // Fire a signal
function Signal.Fire(self: table, ...): nil
    -- // Loop through connections
    for _, connection in ipairs(self.Connections) do
        -- // See whether it can be fired
        if not (connection.State) then
            continue
        end

        -- // Fire
        coroutine.wrap(connection.Function)(...)
    end
end
Signal.fire = Signal.Fire

-- // Wait for a signal
function Signal.Wait(self: table, Timeout: number): any
    -- // Default value
    Timeout = Timeout or (1/0)
    
    -- // Vars
    local returnVal = {}
    local Fired = false

    -- // Connect
    local connection = self:Connect(function(...)
        returnVal = {...}
        Fired = true
    end)

    -- // Constant loop
    local timeElapsed = tick()
    while (true) do
        -- // Wait
        taskwait()

        -- // Set time elapsed
        timeElapsed = tick() - timeElapsed

        -- // See if fired or timed out
        if not (Fired or timeElapsed > Timeout) then
            continue
        end

        -- // Break out of the loop
        break
    end

    -- // Return
    return unpack(returnVal)
end

-- // Destroy a signal
function Signal.Destroy(self: table): nil
    self = nil
end

-- //
return Signal
