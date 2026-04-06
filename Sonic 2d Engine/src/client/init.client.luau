local a= require(game.ReplicatedStorage.Shared.DataDump)
local Player=game.Players.LocalPlayer
local UI=Player.PlayerGui
local ScreenGUI:ScreenGui=UI:WaitForChild("Main")
local Scene:Frame=ScreenGUI.Scene
a.Settings.ScreenSize=ScreenGUI.AbsoluteSize
a.Settings.Terrain=Scene.Terrain
a.Settings.CharacterContainer=Scene.CharacterContainer
a.Settings.CurrentLevel="LZ"
local UIS=game:GetService"UserInputService"
local leveldata=require(game.ReplicatedStorage.Shared.LevelData).LZ
local level=leveldata.Chunks
local Builder=require(game.ReplicatedStorage.Shared.ChunkBuilder)
local CellManager=require(game.ReplicatedStorage.Shared.CellManager)
local CharacterBuilder=require(game.ReplicatedStorage.Shared.CharacterManager)
local CameraManager=require(game.ReplicatedStorage.Shared.CameraSystem)
CameraManager.Bounds=leveldata.Bounds
local function SetScreenSize()
    a.Settings.ScreenSize=ScreenGUI.AbsoluteSize
end
a.Settings.CurrentCamera=Scene
ScreenGUI:GetPropertyChangedSignal("AbsoluteSize"):Connect(SetScreenSize)
for _,v in level do
	Builder.Build("LZ",v[1],v[2])
end
local CharacterUpdate=CharacterBuilder.New(leveldata.SpawnPoint)
local DeltaTime=task.wait(1/60)

local MoveRight =function()
   CharacterBuilder.MoveVector+=Vector2.new(1,0) 
end

local MoveLeft =function()
   CharacterBuilder.MoveVector+=Vector2.new(-1,0) 
end

local Jump=function()
    CharacterBuilder.Velocity+=Vector2.new(0,-20)
end

local Inputs={
    [Enum.KeyCode.Left.Name]=MoveLeft;
    [Enum.KeyCode.Right.Name]=MoveRight;
    [Enum.KeyCode.Z.Name]=Jump
}

local InputsEnd={
    [Enum.KeyCode.Left.Name]=MoveRight;
    [Enum.KeyCode.Right.Name]=MoveLeft;
}

UIS.InputEnded:Connect(function(input, gameProcessedEvent)
    if InputsEnd[input.KeyCode.Name] then
        InputsEnd[input.KeyCode.Name]()
    end
end)

UIS.InputBegan:Connect(function(input, gameProcessedEvent)
    if Inputs[input.KeyCode.Name] then
        Inputs[input.KeyCode.Name]()
    end
end)
CameraManager.Target=CharacterBuilder.Character
while true do
    task.spawn(CharacterUpdate,DeltaTime)
    task.spawn(CameraManager.Update,CameraManager,DeltaTime)
    DeltaTime=task.wait(1/60)
end
