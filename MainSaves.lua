local rs = game:GetService("ReplicatedStorage")
local ds = game:GetService("DataStoreService")
local store = ds:GetDataStore("saveStore")
local library = rs:WaitForChild("Library")



local dir = {}

local function edit(player, list)
	dir[player.Name] = list
end

local function setup(player, list)
	for i = 1, #list do
		local tool = library:FindFirstChild(list[i])
		if tool then
			local clone = tool:Clone()
			clone.Parent = player.Backpack
		else
			print(list[i] .. " ERROR")
		end
	end
end



game.Players.PlayerAdded:connect(function(player)

	local ready = false

	player.CharacterAdded:connect(function(char)

		local bp = player.Backpack
		local data = nil

		if ready == false then
			ready = true

			data = store:GetAsync(player.UserId)

			if data then
				setup(player, data)
				edit(player, data)
			end
		end	

		char.Humanoid.Died:connect(function()
			char.Humanoid:UnequipTools()

			local old = player.StarterGear:GetChildren()
			for i = 1, #old do
				old[i]:Destroy()
			end

			local new = player.Backpack:GetChildren()
			for i = 1, #new do
				new[i].Parent = player.StarterGear
			end		
		end)	



		local count = 0

		local function adjust()

			if char.Humanoid.Health > 0 then

				local list = {}

				local equipped = char:FindFirstChildOfClass("Tool")
				if equipped then
					table.insert(list, equipped.Name)
				end	

				local tools = bp:GetChildren()
				for i = 1, #tools do
					table.insert(list, tools[i].Name)
				end

				if count ~= #list then
					edit(player, list)
					count = #list
				end
			end
		end



		bp.ChildAdded:connect(adjust)	
		bp.ChildRemoved:connect(adjust)	

		char.ChildAdded:connect(function(child)
			if child.ClassName == "Tool" then
				adjust()
			end
		end)

		char.ChildRemoved:connect(function(child)
			if child.ClassName == "Tool" then
				adjust()
			end
		end)	

	end)
end)

game.Players.PlayerRemoving:connect(function(player)
	store:SetAsync(player.UserId, dir[player.Name])
	dir[player.Name] = nil
end)



game:BindToClose(function()
	wait(5)
end)
