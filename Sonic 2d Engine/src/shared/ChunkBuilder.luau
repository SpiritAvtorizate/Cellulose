local Builder={
    Cache={};
}
local ReplicatedStorage=game:GetService"ReplicatedStorage"
local Cached=ReplicatedStorage.Shared.TemporaryBuiltChunks
local ChunkData=require(ReplicatedStorage.Shared.ChunkData)
local CellManager=require(ReplicatedStorage.Shared.CellManager)
local DataDump=require(ReplicatedStorage.Shared.DataDump)
local BlockData=require(ReplicatedStorage.Shared.BlockData)
local MetablockSize=Vector2.new(128,256)
local RegularCellSize=Vector2.new(16,16)

local function FixGridByCellSize(Position:Vector2)
    return MetablockSize*((Position/MetablockSize):Floor())
end

local function SetUpCells(CollisionArray:{{}?},CenterPosition:Vector2)
    --local GridPosition=FixGridByCellSize(CenterPosition)
    CellManager.Struct(CenterPosition.X,CenterPosition.Y,CollisionArray)
end

local function CreateTerrainSprite(SpriteID:number,w:{X:number,Y:number},p:{X:number,Y:number},Position:Vector2,Parent:Frame,InverseY:boolean,InverseX:boolean)
    local Image=Instance.new("ImageLabel")
    Image.Position=UDim2.fromOffset(Position.X,Position.Y)
    Image.Size=UDim2.fromOffset(DataDump.Settings.CellSize.X,DataDump.Settings.CellSize.Y)
	Image.Image=SpriteID
	Image.BackgroundTransparency=1
	Image.ResampleMode=Enum.ResamplerMode.Pixelated
    local iX=w.X
	local iY=w.Y
	local pX=p.X
	local pY=p.Y
	if InverseY then
		iY=-iY
		pY=pY-iY
	end
	if InverseX then
		iX=-iX
		pX=pX-iX
	end
    Image.ImageRectOffset=Vector2.new(pX,pY)
    Image.ImageRectSize=Vector2.new(iX,iY)
    Image.Parent=Parent

end

local function SetUpCellsInArray(Array:{{}?},CenterPosition:Vector2)
    for y,a in Array do
        for x,arraydata in a do
            local Pos=DataDump.Settings.CellSize*Vector2.new(x-1,y-1)
            SetUpCells(table.clone(arraydata),CenterPosition+Pos)
        end
    end
end

local function RemoveAllCellsInArray(Array:{{}?},CenterPosition:Vector2)
    for y,a in Array do
        for x,arraydata in a do
            local Pos=CenterPosition+(DataDump.Settings.CellSize*Vector2.new(x-1,y-1))
            CellManager.Remove(Pos.X,Pos.Y)
        end
    end
end


local function Build(StorageIndex:string,ChunkIndex:number,Position:Vector2) 
    local MetablockSize=MetablockSize*((DataDump.Settings.CellSize/RegularCellSize):Ceil())
    local CenterPosition=FixGridByCellSize((Position-MetablockSize/2):Max(Vector2.new(0,0)))*((DataDump.Settings.CellSize/RegularCellSize):Ceil())
    local FoundInstance=if Cached:FindFirstChild(StorageIndex) then Cached:FindFirstChild(StorageIndex):FindFirstChild(ChunkIndex) else nil
    if FoundInstance and Builder.Cache[StorageIndex] and Builder.Cache[StorageIndex][ChunkIndex] then
        local Frame=FoundInstance:Clone()
        Frame.Parent=DataDump.Settings.Terrain
        Frame.Position=UDim2.fromOffset(CenterPosition.X,CenterPosition.Y)
        SetUpCellsInArray(Builder.Cache[StorageIndex][ChunkIndex],CenterPosition)
        local Connection
        Connection=Frame.Destroying:ConnectParallel(function()
            RemoveAllCellsInArray(Builder.Cache[StorageIndex][ChunkIndex],CenterPosition)
            task.synchronize()
            Connection:Disconnect()
        end)
        return FoundInstance 
    end
    local Data=if ChunkData[StorageIndex] then ChunkData[StorageIndex][ChunkIndex] else nil
    if not Data or not BlockData[StorageIndex] then return warn("Couldn't find data:",StorageIndex,ChunkIndex) end
    local Collideable={}
    if not Builder.Cache[StorageIndex] then Builder.Cache[StorageIndex]={} end
    local Frame=Instance.new("Frame")
    Frame.Name=ChunkIndex
    Frame.Parent=DataDump.Settings.Terrain
    Frame.Position=UDim2.fromOffset(CenterPosition.X,CenterPosition.Y)
    Frame.Size=UDim2.fromOffset(MetablockSize.X,MetablockSize.Y)
    Frame.BackgroundTransparency=1
    for y,a in Data do
        for x,arraydata in a do
            local Block=BlockData[StorageIndex].SpriteSheets[arraydata[1]]
            if not Block then print("no BlockData") continue end
            local Pos=DataDump.Settings.CellSize*Vector2.new(x-1,y-1)
            CreateTerrainSprite(BlockData[StorageIndex].SpriteID,Block.w,Block.p,Pos,Frame,arraydata[5],arraydata[4])
			if arraydata[2] or arraydata[3] then
                SetUpCells(table.clone(arraydata),CenterPosition+Pos)
                if not Collideable[y] then
                    Collideable[y]={}
                end
                Collideable[y][x]=arraydata
            end
        end
    end
    local Connection
    Connection=Frame.Destroying:ConnectParallel(function()
        RemoveAllCellsInArray(Collideable,CenterPosition)
        task.synchronize()
        Connection:Disconnect()
    end)
    local CachedStorage=Cached:FindFirstChild(StorageIndex) or Instance.new("Folder")
    CachedStorage.Parent=Cached
    CachedStorage.Name=StorageIndex
    if CachedStorage:FindFirstChild(ChunkIndex) then return Frame end
    Builder.Cache[StorageIndex][ChunkIndex]=Collideable
    Frame:Clone().Parent=CachedStorage
end
Builder.Build=Build
return Builder
