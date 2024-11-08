--!strict
export type newGrid = {
	grid: BasePart,
	CFrame: CFrame,
	row: number,
	column: number,
	cost: number,
	bestCost: number,
}

export type FlowField = {
	new: (
		startPoint: BasePart,
		gridSize: number,
		row: number,
		column: number
	) -> newGrid,

	cleanUp: () -> (),
	generateGrids: (startPoint: BasePart, gridSize: number) -> (),

	sortOut: () -> (),
	getNeighbor: (currentCell: newGrid) -> newGrid, -- Best grid
	computeBestPath: (startRow: number, startColumn: number) -> (),

	Grids: { [number]: { [number]: newGrid } },
}

local FlowField = {} :: FlowField
FlowField.Grids = {} -- Grids

local toCheck: { [string]: newGrid } = {} -- Replace with dict
local Checked: { [newGrid]: boolean } = {} -- Replace with dict

local TargetRow = 2
local TargetColumn = 4

function FlowField.new(
	startPoint: BasePart,
	gridSize: number,
	row: number,
	column: number
): newGrid
	local self = {}

	self.grid = Instance.new("Part") :: BasePart
	self.grid.Size = Vector3.one * gridSize

	self.CFrame = startPoint.CFrame
		* CFrame.new(
			-(startPoint.Size.X / 2) - (gridSize / 2) + (row * gridSize),
			gridSize,
			-(startPoint.Size.Z / 2) - (gridSize / 2) + (column * gridSize)
		)

	self.grid.CFrame = self.CFrame

	self.grid.Material = Enum.Material.SmoothPlastic
	self.grid.Anchored = true

	self.grid.CanCollide = false
	self.grid.Parent = workspace:FindFirstChild("Grids")

	self.row = row
	self.column = column
	self.cost = 1 -- if cost 0 then its the target point.
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

function FlowField.cleanUp()
	for _, Data in FlowField.Grids do
		for _, SubData in Data do
			SubData.grid:Destroy() -- For now
		end

		table.clear(Data)
	end

	table.clear(Checked)
	table.clear(toCheck)
end

function FlowField.generateGrids(startPoint: BasePart, gridSize: number)
	local Row = startPoint.Size.X / gridSize
	local Column = startPoint.Size.Z / gridSize

	local LUT = {}

	local op = OverlapParams.new()
	op.FilterDescendantsInstances = { startPoint }

	FlowField.cleanUp()

	for r = 1, Row do
		FlowField.Grids[r] = {}

		for c = 1, Column do
			local GridData = FlowField.new(startPoint, gridSize, r, c)

			FlowField.Grids[r][c] = GridData
			LUT[GridData.grid] = GridData
		end
	end

	for Grid, Data in LUT do
		local isTarget: boolean = Data.row == TargetRow
			and Data.column == TargetColumn

		if isTarget then
			Data.bestCost = 0
			toCheck["1"] = Data
		end

		if #workspace:GetPartsInPart(Data.grid, op) > 0 then Data.cost = 255 end
		Grid:Destroy()
	end

	FlowField.sortOut()
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
		if currentOrder % (255 ^ 2) == 0 then task.wait() end
	end
end

return FlowField
