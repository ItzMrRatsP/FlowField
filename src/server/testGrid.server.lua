local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FlowFieldPath = require(ReplicatedStorage.FlowFieldPath)

local Baseplate = workspace.Baseplate
local GridSize = 10

local gridsToBlock = { [3] = { [3] = true }, [2] = { [2] = true, [4] = true } }

FlowFieldPath.generateGrids(
	Baseplate,
	Vector3.one * GridSize,
	Baseplate.Size.X / GridSize,
	Baseplate.Size.Z / GridSize,
	gridsToBlock
)

-- local targetRow = 2
-- local targetColumn = 3

FlowFieldPath.sortOut() -- Sorts the algorithm
-- FlowFieldPath.generateGrids(startPoint, gridSize, rows, columns)
