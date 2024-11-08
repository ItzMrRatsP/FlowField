local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FlowFieldPath = require(ReplicatedStorage.FlowFieldPath)

local Baseplate = workspace.Baseplate
local GridSize = 2

local gridsToBlock = { [3] = { [3] = true }, [2] = { [2] = true, [4] = true } }

FlowFieldPath.generateGrids(
	Baseplate,
	Vector3.one * GridSize,
	Baseplate.Size.X / GridSize,
	Baseplate.Size.Z / GridSize,
	gridsToBlock
)

FlowFieldPath.sortOut()
