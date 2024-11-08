local ReplicatedStorage = game:GetService("ReplicatedStorage")

local FlowFieldPath = require(ReplicatedStorage.FlowFieldPath)

local Baseplate = workspace.Baseplate
local GridSize = 1

FlowFieldPath.generateGrids(Baseplate, GridSize)
