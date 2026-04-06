local Types={}
local FakeConnections=require(game.ReplicatedStorage.Shared.Misc.FakeConnections)
export type Object={
    Size:Vector2;
    Position:Vector2;
    PropertyChangedSignal:FakeConnections.FakeConnection;
    Remove:(Object)->();
}
export type RaycastResult={
    Intersected:Object|{};
    Position:Vector2?;
    Normal:Vector2?;
}
return Types