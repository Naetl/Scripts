-- Fully Client-Side CMDR Localization (No-Task Version)
-- Optimized for Client_CMDR separation and reliable Autocomplete display
local GuiService = game:GetService("GuiService")
local UserInputService = game:GetService("UserInputService")
local TextChatService = game:GetService("TextChatService")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer

local WINDOW_MAX_HEIGHT = 300
local MOUSE_TOUCH_ENUM = { Enum.UserInputType.MouseButton1, Enum.UserInputType.MouseButton2, Enum.UserInputType.Touch }

-- Window handles the command bar GUI
local Window = {
	Valid = true,
	AutoComplete = nil,
	OnTextChanged = nil,
	Cmdr = nil,
	HistoryState = nil,
}

local pGui = Player:WaitForChild("PlayerGui")

-- ==========================================
-- UI SEPARATION (Client_CMDR Folding)
-- ==========================================
local originalCmdr = pGui:WaitForChild("Cmdr")
local CmdrGui = pGui:FindFirstChild("Client_CMDR")

if not CmdrGui then
	CmdrGui = originalCmdr:Clone()
	CmdrGui.Name = "Client_CMDR"
	CmdrGui.Enabled = false
	CmdrGui.DisplayOrder = 2000 
	CmdrGui.Parent = pGui
	
	-- Cleanup scripts to prevent interference
	for _, desc in ipairs(CmdrGui:GetDescendants()) do
		if desc:IsA("LocalScript") or desc:IsA("ModuleScript") then
			desc:Destroy()
		end
	end
end

local Gui = CmdrGui:WaitForChild("Frame")
local Line = Gui:WaitForChild("Line")
local Entry = Gui:WaitForChild("Entry")
local ACFrame = CmdrGui:WaitForChild("Autocomplete")

-- Set UI Elements
Entry.TextBox.PlaceholderText = "Admin Console Cmd"
Line.Parent = nil

-- ==========================================
-- CLIENT COMMANDS REGISTRY
-- ==========================================
--[[
    [ DOCUMENTATION: HOW TO ADD COMMANDS ]
    --------------------------------------
    To add a new command, use the RegisterCommand function below.
    
    Syntax:
        RegisterCommand("PrimaryName", {
            Aliases = {"alias1", "alias2"}, -- Optional: List of alternative names
            Description = "Description of the command",
            Args = { -- Optional: List of arguments for autocomplete/help
                {
                    Name = "PlayerName",
                    Type = "Player",
                    Description = "The player to target"
                }
            },
            Execute = function(window, args)
                -- Your code here.
                -- 'window' allows you to output text: window:AddLine("Text", Color3.new(1,1,1))
                -- 'args' is a table of strings passed by the user.
            end
        })

    Example:
        RegisterCommand("hello", {
            Aliases = {"hi"},
            Description = "Says hello.",
            Args = {},
            Execute = function(window, args)
                window:AddLine("Hello World!", Color3.fromRGB(0, 255, 0))
            end
        })
]]

local ClientCommands = {}

local function RegisterCommand(name, data)
	data.Name = name -- Store the primary name
	ClientCommands[name:lower()] = data
	
	if data.Aliases then
		for _, alias in ipairs(data.Aliases) do
			ClientCommands[alias:lower()] = data
		end
	end
end

RegisterCommand("help", {
	Aliases = {"h"},
	Description = "Displays all available client commands.",
	Args = {},
	Execute = function(window)
		window:AddLine(" ", Color3.fromRGB(255, 255, 255))
		window:AddLine("━━━━━━━━━━━━━ CLIENT HELP ━━━━━━━━━━━━━", Color3.fromRGB(255, 215, 0))
		window:AddLine("Type the commands below to run local functions.", Color3.fromRGB(180, 180, 180))
		
		local displayed = {}
		for _, data in pairs(ClientCommands) do
			-- Use the unique data table as key to avoid duplicates from aliases
			if not displayed[data] then
				displayed[data] = true
				
				local aliasStr = ""
				if data.Aliases and #data.Aliases > 0 then
					aliasStr = " (" .. table.concat(data.Aliases, ", ") .. ")"
				end
				
				local argStr = ""
				for _, arg in ipairs(data.Args or {}) do
					argStr = argStr .. " <" .. arg.Name .. ">"
				end
				
				window:AddLine(" ● " .. data.Name:upper() .. aliasStr .. argStr, Color3.fromRGB(255, 255, 255))
				window:AddLine("    " .. data.Description, Color3.fromRGB(150, 150, 150))
			end
		end
		window:AddLine("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━", Color3.fromRGB(255, 215, 0))
		window:AddLine(" ", Color3.fromRGB(255, 255, 255))
	end
})

RegisterCommand("rejoin", {
	Aliases = {"rj"},
	Description = "Rejoins the current server.",
	Args = {},
	Execute = function(window)
		window:AddLine("Rejoining server...", Color3.fromRGB(255, 255, 0))
		wait(0.5)
		if #Players:GetPlayers() <= 1 then
			TeleportService:Teleport(game.PlaceId, Player)
		else
			TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, Player)
		end
	end
})

RegisterCommand("speed", {
	Aliases = {"ws"},
	Description = "Sets WalkSpeed locally.",
	Args = {{ Name = "number", Type = "Number", Description = "The speed value" }},
	Execute = function(window, args)
		local speed = tonumber(args[1]) or 16
		if Player.Character and Player.Character:FindFirstChild("Humanoid") then
			Player.Character.Humanoid.WalkSpeed = speed
			window:AddLine("WalkSpeed set to: " .. speed, Color3.fromRGB(0, 255, 150))
		end
	end
})

RegisterCommand("reset", {
	Aliases = {"re"},
	Description = "Resets your character locally.",
	Args = {},
	Execute = function(window)
		if Player.Character then 
			Player.Character:BreakJoints() 
			window:AddLine("Character has been reset.", Color3.fromRGB(255, 100, 100)) 
		end
	end
})

RegisterCommand("clear", {
	Aliases = {"cls"},
	Description = "Clears the console lines.",
	Args = {},
	Execute = function(window)
		for _, child in ipairs(Gui:GetChildren()) do
			if child.Name == "Line" then child:Destroy() end
		end
		window:UpdateWindowHeight()
	end
})

-- ==========================================
-- AUTOCOMPLETE MODULE (Fixed Logic)
-- ==========================================
local function InitializeAutoComplete(Cmdr, windowObj)
	local AutoComplete = {
		Items = {},
		SelectedItem = 1,
	}

	local Util = Cmdr.Util
	local ACGui = ACFrame
	local AutoItem = ACGui:WaitForChild("TextButton")
	local Title = ACGui:WaitForChild("Title")
	local Description = ACGui:WaitForChild("Description")
	
	ACGui.Visible = false
	ACGui.ZIndex = 5000
	AutoItem.Parent = nil

	local function SetText(obj, textObj, text, sizeFromContents)
		obj.Visible = text ~= nil
		textObj.Text = text or ""
		if sizeFromContents and Util and Util.GetTextSize then
			local success, size = pcall(function()
				return Util.GetTextSize(text or "", textObj, Vector2.new(1000, 1000), 1, 0)
			end)
			if success and size then
				textObj.Size = UDim2.new(0, size.X, obj.Size.Y.Scale, obj.Size.Y.Offset)
			end
		end
	end

	local function UpdateContainerSize()
		ACGui.Size = UDim2.new(
			0,
			math.max(Title.Field.TextBounds.X + Title.Field.Type.TextBounds.X + 40, 250),
			0,
			math.min(ACGui.UIListLayout.AbsoluteContentSize.Y + 10, 400)
		)
	end

	local function UpdateInfoDisplay(options)
		if not options then return end
		SetText(Title, Title.Field, options.name, true)
		SetText(Title.Field.Type, Title.Field.Type, options.type and ": " .. options.type)
		SetText(Description, Description.Label, options.description)
		Description.Label.TextColor3 = options.invalid and Color3.fromRGB(255, 73, 73) or Color3.fromRGB(255, 255, 255)
		
		Description.Size = UDim2.new(1, 0, 0, 40)
		while not Description.Label.TextFits do
			Description.Size = Description.Size + UDim2.new(0, 0, 0, 2)
			if Description.Size.Y.Offset > 500 then break end
		end
		
		wait()
		ACGui.UIListLayout:ApplyLayout()
		UpdateContainerSize()
	end

	function AutoComplete:Show(items, options)
		options = options or {}
		for _, item in pairs(self.Items) do if item.gui then item.gui:Destroy() end end

		self.SelectedItem = 1
		self.Items = items
		local autocompleteWidth = 250

		for i, item in pairs(self.Items) do
			local leftText = item[1]
			local rightText = item[2]
			local btn = AutoItem:Clone()
			btn.Name = leftText .. rightText
			btn.ZIndex = ACGui.ZIndex + 1
			btn.BackgroundTransparency = i == self.SelectedItem and 0.5 or 1
			
			local start, stop = string.find(rightText:lower(), leftText:lower(), 1, true)
			if start == nil then start, stop = 1, #rightText end
			
			btn.Typed.Text = string.rep(" ", start - 1) .. leftText
			btn.Suggest.Text = string.sub(rightText, 1, start - 1) .. string.rep(" ", #leftText) .. string.sub(rightText, (stop or 0) + 1)
			btn.Parent = ACGui
			btn.LayoutOrder = i
			
			local maxBounds = math.max(btn.Typed.TextBounds.X, btn.Suggest.TextBounds.X) + 30
			if maxBounds > autocompleteWidth then autocompleteWidth = maxBounds end
			item.gui = btn
		end

		ACGui.UIListLayout:ApplyLayout()
		
		local textBoxPos = Entry.TextBox.AbsolutePosition
		ACGui.Position = UDim2.fromOffset(textBoxPos.X, textBoxPos.Y + 45)
		ACGui.Visible = true

		local firstOptions = self.Items[1] and self.Items[1].options or options
		UpdateInfoDisplay(firstOptions)
	end

	function AutoComplete:Hide() ACGui.Visible = false end
	function AutoComplete:IsVisible() return ACGui.Visible end
	function AutoComplete:GetSelectedItem() return self:IsVisible() and self.Items[self.SelectedItem] or nil end

	function AutoComplete:Select(delta)
		if not ACGui.Visible then return end
		self.SelectedItem = self.SelectedItem + delta
		if self.SelectedItem > #self.Items then self.SelectedItem = 1 elseif self.SelectedItem < 1 then self.SelectedItem = #self.Items end
		
		for i, item in pairs(self.Items) do 
			if item.gui then item.gui.BackgroundTransparency = i == self.SelectedItem and 0.5 or 1 end 
		end
		
		ACGui.CanvasPosition = Vector2.new(0, math.max(0, (self.SelectedItem - 1) * AutoItem.Size.Y.Offset))
		local selectedOptions = self.Items[self.SelectedItem] and self.Items[self.SelectedItem].options
		if selectedOptions then
			UpdateInfoDisplay(selectedOptions)
		end
	end

	return AutoComplete
end

-- ==========================================
-- CORE WINDOW FUNCTIONS
-- ==========================================

function Window:UpdateLabel()
	local name = Player.Name
	local place = (self.Cmdr and self.Cmdr.PlaceName ~= "") and ("@" .. self.Cmdr.PlaceName) or ""
	Entry.TextLabel.Text = name .. place .. "$"
end

function Window:GetLabel() return Entry.TextLabel.Text end

function Window:UpdateWindowHeight()
	local h = Gui.UIListLayout.AbsoluteContentSize.Y + Gui.UIPadding.PaddingTop.Offset + Gui.UIPadding.PaddingBottom.Offset
	Gui.Size = UDim2.new(Gui.Size.X.Scale, Gui.Size.X.Offset, 0, math.clamp(h, 0, WINDOW_MAX_HEIGHT))
	Gui.CanvasPosition = Vector2.new(0, h)
end

function Window:AddLine(text, options)
	options = options or {}
	text = tostring(text)
	if typeof(options) == "Color3" then options = { Color = options } end
	if #text == 0 then self:UpdateWindowHeight() return end
	local str = (self.Cmdr and self.Cmdr.Util) and self.Cmdr.Util.EmulateTabstops(text, 8) or text
	local line = Line:Clone()
	line.Text = str
	line.TextColor3 = options.Color or line.TextColor3
	line.RichText = true
	line.Parent = Gui
end

function Window:SetVisible(visible)
	CmdrGui.Enabled = visible
	Gui.Visible = visible
	if visible then
		self.PrevChat = TextChatService.ChatWindowConfiguration.Enabled
		TextChatService.ChatWindowConfiguration.Enabled = false
		Entry.TextBox:CaptureFocus()
		self:SetEntryText("")
	else
		TextChatService.ChatWindowConfiguration.Enabled = self.PrevChat ~= nil and self.PrevChat or true
		Entry.TextBox:ReleaseFocus()
		if self.AutoComplete then self.AutoComplete:Hide() end
	end
end

function Window:SetEntryText(text)
	Entry.TextBox.Text = text
	if Gui.Visible then
		Entry.TextBox:CaptureFocus()
		Entry.TextBox.CursorPosition = #text + 1
		self:UpdateWindowHeight()
	end
end

function Window:SetIsValidInput(valid)
	Entry.TextBox.TextColor3 = valid and Color3.new(1,1,1) or Color3.fromRGB(255, 73, 73)
end

function Window.ProcessEntry(text)
	if #text == 0 then return end
	local args = string.split(text, " ")
	local cmdName = table.remove(args, 1):lower()

	Window:AddLine(Window:GetLabel() .. " " .. text, Color3.fromRGB(255, 223, 93))

	if ClientCommands[cmdName] then
		local success, err = pcall(function() ClientCommands[cmdName].Execute(Window, args) end)
		if not success then Window:AddLine("Execution Error: " .. tostring(err), Color3.fromRGB(255, 100, 100)) end
	else
		Window:AddLine("Command '" .. cmdName .. "' not found. Use 'help' for client commands.", Color3.fromRGB(255, 100, 100))
	end
	
	Window:SetVisible(false)
end

function Window.OnTextChanged(text)
	local args = string.split(text, " ")
	local cmdNameQuery = args[1] or ""
	
	if #args == 1 then
		local acItems = {}
		local sortedKeys = {}
		for k in pairs(ClientCommands) do table.insert(sortedKeys, k) end
		table.sort(sortedKeys)

		for _, name in ipairs(sortedKeys) do
			if name:lower():sub(1, #cmdNameQuery) == cmdNameQuery:lower() then
				local data = ClientCommands[name]
				-- name:upper() makes the alias/command name display in uppercase in the dropdown
				table.insert(acItems, { cmdNameQuery, name, options = { name = name:upper(), description = data.Description, type = "Client Command" }})
			end
		end
		
		if #acItems > 0 then
			Window:SetIsValidInput(true)
			if Window.AutoComplete then Window.AutoComplete:Show(acItems) end
		else
			Window:SetIsValidInput(#cmdNameQuery == 0)
			if Window.AutoComplete then Window.AutoComplete:Hide() end
		end
	else
		local cmdName = cmdNameQuery:lower()
		local command = ClientCommands[cmdName]
		if command then
			Window:SetIsValidInput(true)
			local argIndex = #args - 1
			local currentArg = command.Args[argIndex]
			if currentArg then
				if Window.AutoComplete then
					Window.AutoComplete:Show({{ args[#args], "" }}, {
						name = currentArg.Name,
						type = currentArg.Type,
						description = currentArg.Description
					})
				end
			else
				if Window.AutoComplete then Window.AutoComplete:Hide() end
			end
		else
			Window:SetIsValidInput(false)
			if Window.AutoComplete then Window.AutoComplete:Hide() end
		end
	end
end

-- Input Listeners
UserInputService.InputBegan:Connect(function(input, processed)
	if input.KeyCode == Enum.KeyCode.F2 then Window:SetVisible(not Gui.Visible) return end
	if not Gui.Visible then return end
	
	if input.KeyCode == Enum.KeyCode.Down then
		if Window.AutoComplete then Window.AutoComplete:Select(1) end
	elseif input.KeyCode == Enum.KeyCode.Up then
		if Window.AutoComplete then Window.AutoComplete:Select(-1) end
	elseif input.KeyCode == Enum.KeyCode.Tab then
		if Window.AutoComplete then
			local selected = Window.AutoComplete:GetSelectedItem()
			if selected then Window:SetEntryText(selected[2] .. " ") end
		end
	end
end)

Entry.TextBox.FocusLost:Connect(function(submit)
	if submit then Window.ProcessEntry(Entry.TextBox.Text) end
end)

Entry.TextBox:GetPropertyChangedSignal("Text"):Connect(function()
	local text = Entry.TextBox.Text
	if text:match("\t") then Entry.TextBox.Text = text:gsub("\t", "") return end
	Window.OnTextChanged(text)
	Window:UpdateWindowHeight()
end)

-- Initialization
spawn(function()
	while wait() do
		if Window.Cmdr then
			Window.AutoComplete = InitializeAutoComplete(Window.Cmdr, Window)
			Window:UpdateLabel()
			Window:UpdateWindowHeight()
			break
		end
	end
end)

return Window
