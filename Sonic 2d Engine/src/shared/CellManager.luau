local Manager={}
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local Shared=ReplicatedStorage:WaitForChild"Shared"
local RequiredServices={
    Dump=require(Shared.DataDump);
    FakeConnections=require(Shared.Misc.FakeConnections)
}
Manager.RemoveConnection=RequiredServices.FakeConnections.new()
local function Check(X:number,Y:number) 
    local CellY=RequiredServices.Dump.Cells[Y]
    if not CellY then return end
    local CellX=CellY[X]
    return CellX :: {}?
end

local function ArrayLen(array)
	local length=0
	for _,v in array do
		length+=1
        break
	end
	return length
end

local function Struct(X:number,Y:number,Array:{}?) : {}?
    local Built=Check(X,Y)
    if Built then return Built end
    if not RequiredServices.Dump.Cells[Y] then RequiredServices.Dump.Cells[Y]={} end
    RequiredServices.Dump.Cells[Y][X]=Array or {}
    return RequiredServices.Dump.Cells[Y][X] :: {}?
end

local function Remove(X:number,Y:number) : nil
    local Found=Check(X,Y)
    if not Found then return end    
    Manager.RemoveConnection:Fire(Found)
    table.clear(Found)
    RequiredServices.Dump.Cells[Y][X]=nil    
    if ArrayLen(RequiredServices.Dump.Cells[Y]) ==0 then table.clear(RequiredServices.Dump.Cells[Y]) RequiredServices.Dump.Cells[Y]=nil end
end

local function RayCast(Position:Vector2)
    
end
Manager.Check=Check
Manager.Struct=Struct
Manager.Remove=Remove

return Manager