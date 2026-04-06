local Manipulator = {}

local function ScaleToPixelSize(UD2:UDim2|Vector2,ReferenceSize:Vector2?)
    local Ref=ReferenceSize or workspace.CurrentCamera.ViewportSize
    local scalex,scaley

        if typeof(UD2) == "UDim2" then
            scalex,scaley=UD2.X.Scale,UD2.Y.Scale
                else
            scalex,scaley=UD2.X,UD2.Y
        end

    return Vector2.new(scalex,scaley)*Ref
end

local function PixelSizeToScale(UD2:UDim2|Vector2,ReferenceSize:Vector2?)
    local Ref=ReferenceSize or workspace.CurrentCamera.ViewportSize
    local scalex,scaley

        if typeof(UD2) == "UDim2" then
            scalex,scaley=UD2.X.Offset,UD2.Y.Offset
                else
            scalex,scaley=UD2.X,UD2.Y
        end

    return Vector2.new(scalex,scaley)/Ref
end

Manipulator.ScaleToPixelSize=ScaleToPixelSize
Manipulator.PixelSizeToScale=PixelSizeToScale

return Manipulator