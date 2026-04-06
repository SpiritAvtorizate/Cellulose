local editimage=game:GetService("AssetService"):CreateEditableImageAsync(game.StarterGui.Main.Scene.Label.ImageContent)
local function read(pixelPosition:Vector2)
local a=editimage:ReadPixelsBuffer(pixelPosition,Vector2.new(16,16))
local sqnc=4
local chunks={}
local aaaa=0
for i=0,((16*2)^2)-1,sqnc do chunks[aaaa+1]={} for c=i,i+sqnc-1 do table.insert(chunks[aaaa+1],buffer.readi8(a,c)) end aaaa+=1 end
local count=0
local currenty=0
game.StarterGui.Main.Scene.dump:ClearAllChildren()
local VerticalArray={}
local HorizontalArray={}
local function CheckIfBlank(array)
	return (array[1]==-1 and array[2]==-1 and array[3]==-1)
end

local function sort(v1,v2)
	return v1>v2
end
local function compare(array)
	return (array and not CheckIfBlank(array))
end
for i,v in ipairs(chunks) do
	if CheckIfBlank(v) and ((not chunks[i-16] or not CheckIfBlank(chunks[i-16])) or compare(chunks[i-1]) and compare(chunks[i+1])) then
		table.insert(VerticalArray,currenty)
		table.insert(HorizontalArray,count)
	end
	count+=1
	if count>15 then
		count=0
		currenty+=1
	end
	
end
--table.sort(VerticalArray,sort)
--count=0
--currenty=0
return {VerticalArray;HorizontalArray}
end
return read