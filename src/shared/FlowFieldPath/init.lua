--!strict
export type newGrid = {
	grid: BasePart,
	row: number,
	column: number,
	cost: number,
	bestCost: number,
}

export type FlowField = {
	new: (
		startPoint: BasePart,
		gridSize: Vector3,
		row: number,
		column: number,
		cost: number
	) -> newGrid,

	generateGrids: (
		startPoint: BasePart,
		gridSize: Vector3,
		rows: number,
		columns: number,
		toBlock: { [number]: { number } }
	) -> (),

	sortOut: () -> (),
	getNeighbor: (currentCell: newGrid) -> newGrid, -- Best grid
	computeBestPath: (startRow: number, startColumn: number) -> (),

	Grids: { [number]: { [number]: newGrid } },
}

local FlowField = {} :: FlowField
FlowField.Grids = {} -- Grids

local toCheck: { [string]: newGrid } = {} -- Replace with dict
local Checked: { [newGrid]: boolean } = {} -- Replace with dict

-- Now we can do the AI

local targetRow = 2
local targetColumn = 3

function FlowField.new(
	startPoint: BasePart,
	gridSize: Vector3,
	row: number,
	column: number,
	cost: number
): newGrid
	local self = {}

	self.grid = Instance.new("Part") :: BasePart
	self.grid.Size = gridSize
	self.grid.CFrame = CFrame.new(
		-(startPoint.Size.X / 2) + (row * gridSize.X),
		startPoint.Position.Y + gridSize.Y,
		-(startPoint.Size.Z / 2) + (column * gridSize.Z)
	)

	self.grid.Material = Enum.Material.SmoothPlastic
	self.grid.Anchored = true

	self.grid.CanCollide = false
	self.grid.Parent = workspace:FindFirstChild("Grids")

	self.row = row
	self.column = column
	self.cost = cost -- if cost 0 then its the target point.
	self.bestCost = math.huge -- Basically an huge number

	return self
end

local function getCount(t): number
	local count = 0

	for _, _ in t do
		count += 1
	end

	return count
end

function FlowField.generateGrids(
	startPoint: BasePart,
	gridSize: Vector3,
	rows: number,
	columns: number
)
	local op = OverlapParams.new()
	op.FilterDescendantsInstances = { startPoint }

	for r = 1, rows do
		FlowField.Grids[r] = {}

		for c = 1, columns do
			local isTarget = r == targetRow and c == targetColumn

			local gridData =
				FlowField.new(startPoint, gridSize, r, c, isTarget and 0 or 1)

			if #workspace:GetPartsInPart(gridData.grid, op) > 0 then
				gridData.cost = 255
			end

			if isTarget then
				gridData.bestCost = 0
				toCheck["1"] = gridData
			end

			FlowField.Grids[r][c] = gridData
		end
	end
end

local function getHeatmap(cell)
	return 1 / math.pow(cell.bestCost, 0.75)
end

function FlowField.sortOut()
	local currentOrder = 1
	local toCheckOrder = 1

	while getCount(toCheck) > 0 do
		local currentCell = toCheck[tostring(currentOrder)]
		if not currentCell then break end

		currentCell[tostring(currentOrder)] = nil

		for row = currentCell.row - 1, currentCell.row + 1 do
			if not FlowField.Grids[row] then continue end

			for column = currentCell.column - 1, currentCell.column + 1 do
				if row ~= currentCell.row and column % 2 <= 0 then continue end

				local Cell = FlowField.Grids[row][column]

				if not Cell then continue end
				if Cell == currentCell then continue end -- There is no point checking this
				if Checked[Cell] then continue end
				if Cell.cost >= 255 then continue end

				if currentCell.bestCost + Cell.cost >= Cell.bestCost then
					continue
				end

				Cell.bestCost = currentCell.bestCost + Cell.cost
				Cell.grid.Color = Color3.fromHSV(getHeatmap(Cell), 1, 1)

				toCheckOrder += 1

				toCheck[tostring(toCheckOrder)] = Cell
				Checked[Cell] = true
			end
		end

		currentOrder += 1
		if currentOrder % (35 ^ 2) == 0 then task.wait() end
	end
end

return FlowField
