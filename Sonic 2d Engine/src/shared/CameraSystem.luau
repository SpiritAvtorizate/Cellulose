local Camera={
    Target=nil;
    Bounds={Xmin=0,Xmax=-2000,Ymin=1000,Ymax=-1000};
    CanUpdate=true;
}
local DataDump=require(game.ReplicatedStorage.Shared.DataDump)
local CharacterHandler=require(game.ReplicatedStorage.Shared.CharacterManager)
local function Update(DeltaTime)
    local cam=DataDump.Settings.CurrentCamera
    if not Camera.Target or not cam or not Camera.CanUpdate then return end
    local TargetPosition=Vector2.new(Camera.Target.Position.X.Offset,Camera.Target.Position.Y.Offset)
    local TargetSize=Vector2.new(Camera.Target.Size.X.Offset,Camera.Target.Size.Y.Offset)
    local CenterPosition=TargetPosition+TargetSize/2
    local Resolution=cam.AbsoluteSize
    local TrueCameraPosition=Vector2.new(cam.Position.X.Offset,cam.Position.Y.Offset)
    local CameraPosition=-CenterPosition+Resolution/2
    if CameraPosition.Y-TrueCameraPosition.Y>CharacterHandler.JumpPower/2 and CameraPosition.Y-TrueCameraPosition.Y<=CharacterHandler.JumpPower*2.5 then
        CameraPosition=Vector2.new(CameraPosition.X,TrueCameraPosition.Y)
    end
    cam.Position=cam.Position:Lerp(UDim2.fromOffset(math.clamp(CameraPosition.X,Camera.Bounds.Xmax,Camera.Bounds.Xmin),math.clamp(CameraPosition.Y,Camera.Bounds.Ymax,Camera.Bounds.Ymin)),DeltaTime*8)
end
Camera.Update=function(Camera,DeltaTime:number?)
    return Update(DeltaTime)
end
return Camera