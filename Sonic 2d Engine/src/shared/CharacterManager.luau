local CharacterManager={
    Character=nil;
    Position=Vector2.new(0,0);
    MoveVector=Vector2.new(0,0);
    Velocity=Vector2.new(0,0);
    AccelerationPower=1.5;
    JumpPower=20;
    Grounded=false;
}
local ReplicatedStorage=game:GetService"ReplicatedStorage"
local FloorSensor1=Vector2.new(1,1)
local FloorSensor2=Vector2.new(0,1)
local CeilingSensor1=Vector2.new(0,0)
local CeilingSensor2=Vector2.new(1,0)
local FSensorObject1=nil
local FSensorObject2=nil
local BlockData=require(ReplicatedStorage.Shared.BlockData)
local CollisionData=require(ReplicatedStorage.Shared.CollisionData)
local DataDump=require(ReplicatedStorage.Shared.DataDump)
local PhysicsManager=require(ReplicatedStorage.Shared.PhysicsManager)
local CellManager=require(ReplicatedStorage.Shared.CellManager)
local RegularCellSize=Vector2.new(16,16)
local function CreateSensor(Position,Color)
    local Frame=Instance.new("Frame")
    Frame.Size=UDim2.fromOffset(2,2)
    Frame.Position=UDim2.fromOffset(Position.X-1,Position.Y-1)
    Frame.Parent=CharacterManager.Character
    Frame.BackgroundColor3=Color or Color3.new(1,1,1)
    return Frame
    --game:GetService("Debris"):AddItem(Frame,5)
end
local function VisualizeCells(Position,Color)
    local Frame=Instance.new("Frame")
    Frame.Size=UDim2.fromOffset(DataDump.Settings.CellSize.X,DataDump.Settings.CellSize.Y)
    Frame.Position=UDim2.fromOffset(Position.X,Position.Y)
    Frame.Parent=DataDump.Settings.Terrain
    Frame.BackgroundColor3=Color or Color3.new(1,1,1)
    --return Frame
    game:GetService("Debris"):AddItem(Frame,5)
end
local function ArrayLen(array)
	local length=0
	for _,v in array do
		length+=1
	end
	return length
end

local function GetPositionInsideCell(Position:Vector2)
    local ResolutionMultiplier=(DataDump.Settings.CellSize/RegularCellSize):Ceil()
    local CurrentCell=(Position/DataDump.Settings.CellSize)
    local InCellPositionPercent=CurrentCell-CurrentCell:Floor()
    --VisualizeCells(CurrentCell,Color3.new(1,0,0))
    --VisualizeCells(Position)
    local InCellPosition=((DataDump.Settings.CellSize*InCellPositionPercent)/ResolutionMultiplier):Ceil()
    return InCellPosition
end

local function GetFloor(Cells:{{}?},Position:Vector2)
    for index,array in Cells do
        if not array[2] or not BlockData[DataDump.Settings.CurrentLevel] or not BlockData[DataDump.Settings.CurrentLevel].SpriteSheets[array[1]] then continue end
        local CollisionMask=CollisionData[BlockData[DataDump.Settings.CurrentLevel].SpriteSheets[array[1]].c]
        local angle=BlockData[DataDump.Settings.CurrentLevel].SpriteSheets[array[1]].a
        local Pos=GetPositionInsideCell(Position)
        local iX=0
        if array[4] then
            iX=16
            angle*=-1
        end
        local Vertical=CollisionMask[math.max(1,math.abs((iX-(Pos.X))))]
        --print(Vertical)
        --local Horizontal=CollisionMask[2][math.max(1,Pos.X)]
        if Vertical then
            return math.floor(Vertical*(DataDump.Settings.CellSize/RegularCellSize):Ceil().Y)-1.9,index,angle
        -- else
        --     return math.abs(CollisionMask[1][ArrayLen(CollisionMask[1])]-15),index,angle
        end
    end
    table.clear(Cells)
end
local function GetCells(Position:Vector2,Direction:Vector2,EndLoop:number)
    --local ResolutionMultiplier=(DataDump.Settings.CellSize/RegularCellSize):Ceil()
    local Cells={}
    local Way={}
    local Dir=DataDump.Settings.CellSize*Direction
    local CellPos=(Position/DataDump.Settings.CellSize):Floor()
    local CellPosition=DataDump.Settings.CellSize*(CellPos)
    local Cell=CellManager.Check(math.floor(CellPosition.X),math.floor(CellPosition.Y))
    if Cell then 
        table.insert(Cells,Cell)
        table.insert(Way,CellPosition)
    end
    --VisualizeCells(CellPosition,Color3.new(0,1,0))
    if EndLoop<=1 then return Cells,Way end
    local Count=1
    for i=2,EndLoop,1 do
        local CellPos=((Position+(Dir*Count))/DataDump.Settings.CellSize):Floor()
        local CellPosition=DataDump.Settings.CellSize*(CellPos)
        --VisualizeCells(CellPosition,Color3.fromRGB(0,255,0))
        local Cell=CellManager.Check(CellPosition.X,CellPosition.Y)
        if Cell then 
            table.insert(Cells,Cell)
            table.insert(Way,CellPosition)
        end
        Count+=1
    end
    return Cells,Way
end

local function NewCharacter(SpawnPoint:Vector2)
    local Char=Instance.new("Frame")
    Char.Size=UDim2.fromOffset(DataDump.Settings.CharacterBoxSize.X,DataDump.Settings.CharacterBoxSize.Y)
    Char.Position=UDim2.fromOffset(SpawnPoint.X,SpawnPoint.Y)
    Char.BackgroundColor3=Color3.new(1,0,1)
    Char.BorderSizePixel=0
    Char.Parent=DataDump.Settings.CharacterContainer
    CharacterManager.Position=SpawnPoint
    local LastPositionPoint=15
    local function Update(DeltaTime)
        local CellResolution=DataDump.Settings.CellSize
        CharacterManager.Position=Vector2.new(Char.Position.X.Offset,Char.Position.Y.Offset)
        local MoveVectorX=CharacterManager.MoveVector.X
        local CellAccel=(CharacterManager.Velocity/RegularCellSize):Ceil()
        --print(CellAccel.Y)
        local Floor1,index1
        local Floor2,index2
        local NextSetPosition=CharacterManager.Position+CharacterManager.Velocity
        if CharacterManager.Velocity.Y>=0 then
        local FS1=CharacterManager.Position+(DataDump.Settings.CharacterBoxSize*FloorSensor1)
        local FS2=CharacterManager.Position+(DataDump.Settings.CharacterBoxSize*FloorSensor2)
        local Cells1,DownWard1=GetCells(FS1,Vector2.new(0,1),math.max(1,CellAccel.Y))
        Floor1,index1=GetFloor(Cells1,FS1)
        local Cells2,DownWard2=GetCells(FS2,Vector2.new(0,1),math.max(1,CellAccel.Y))
        Floor2,index2=GetFloor(Cells2,FS2)
        --print(Cells1)
        if (Floor1 and (Floor2 and ((DownWard1[index1].Y+Floor1)-DataDump.Settings.CharacterBoxSize.Y)<=((DownWard2[index2].Y+Floor2)-DataDump.Settings.CharacterBoxSize.Y))) or (Floor1 and not Floor2) then
            LastPositionPoint=Floor1
            NextSetPosition=Vector2.new(NextSetPosition.X,(DownWard1[index1].Y+Floor1)-DataDump.Settings.CharacterBoxSize.Y)
            local Setback,backwards=GetCells(NextSetPosition+(DataDump.Settings.CharacterBoxSize*FloorSensor1),Vector2.new(0,-1),2)
            if Setback[2] then
                --print(Setback)
                local Floor1,index1=GetFloor(Setback,FS1)
                NextSetPosition=Vector2.new(NextSetPosition.X,((backwards[index1].Y-Floor1))-DataDump.Settings.CharacterBoxSize.Y)
            end
            --CharacterManager.Velocity=Vector2.new(CharacterManager.Velocity.X,0)
        elseif Floor2 then        
            LastPositionPoint=Floor2
            if Floor2 then
                NextSetPosition=Vector2.new(NextSetPosition.X,(DownWard2[index2].Y+Floor2)-DataDump.Settings.CharacterBoxSize.Y)
            local Setback,backwards=GetCells(NextSetPosition+(DataDump.Settings.CharacterBoxSize*FloorSensor2),Vector2.new(0,-1),2)
            if Setback[2] then
                --print(Setback)
                local Floor1,index1=GetFloor(Setback,FS2)
                NextSetPosition=Vector2.new(NextSetPosition.X,((backwards[index1].Y-Floor1))-DataDump.Settings.CharacterBoxSize.Y)
            end
            end
            table.clear(DownWard2)
            table.clear(Cells2)
        end
        table.clear(DownWard1)
        table.clear(Cells1)  
        end
        Char.Position=UDim2.fromOffset(NextSetPosition.X,NextSetPosition.Y)    
        CharacterManager.Velocity=PhysicsManager.ForceGravity(CharacterManager.Velocity,DeltaTime)
        if MoveVectorX~=0 then
            CharacterManager.Velocity+=Vector2.new(MoveVectorX*CharacterManager.AccelerationPower*(DeltaTime*10),0)
        end
        if Floor1 or Floor2 then        

            CharacterManager.Grounded=true
			CharacterManager.Velocity=Vector2.new(CharacterManager.Velocity.X,0)
			if MoveVectorX==0 then
				CharacterManager.Velocity=PhysicsManager.ForceFriction(CharacterManager.Velocity,DeltaTime)
			end
        else
            CharacterManager.Grounded=false
        end
    end
    CharacterManager.Character=Char
    FSensorObject1=CreateSensor((DataDump.Settings.CharacterBoxSize*FloorSensor1),Color3.new(0,0,1))
    FSensorObject2=CreateSensor((DataDump.Settings.CharacterBoxSize*FloorSensor2),Color3.new(0,1,1))
    return Update
end
CharacterManager.New=NewCharacter
return CharacterManager