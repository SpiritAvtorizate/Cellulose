local Physics={}
local Gravity=48--64
local Friction=9
local function CalculateGravity(Acceleration:Vector2,DeltaTime:number)
    return Vector2.new(Acceleration.X,math.lerp(Acceleration.Y,Gravity,DeltaTime))
end
local function CalculateFriction(Acceleration:Vector2,DeltaTime:number)
    return Vector2.new(math.max(0,math.abs(Acceleration.X)-(Friction*DeltaTime))*math.sign(Acceleration.X),Acceleration.Y)
end

local function CheckIf()
    
end

Physics.ForceGravity=CalculateGravity
Physics.ForceFriction=CalculateFriction
return Physics