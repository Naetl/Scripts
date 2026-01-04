--[[
    TDS TOWER EQUIFFER - WINDOWS XP EDITION
    ---------------------------------------------------------
    Style: Retro Windows XP (Gray System Color)
    Features: 
    - XP Blue Title Bar
    - Classic Inset/Outset Bevel Borders
    - Real-time Tower Resolver
    ---------------------------------------------------------
]]

local Towers = {
    "Scout","Sniper","Paintballer","Demoman","Hunter","Soldier","Militant",
    "Freezer","Assassin","Shotgunner","Pyromancer","Ace Pilot","Medic","Farm",
    "Rocketeer","Trapper","Military Base","Crook Boss",
    "Electroshocker","Commander","Warden","Cowboy","DJ Booth","Minigunner",
    "Ranger","Pursuit","Gatling Gun","Turret","Mortar","Mercenary Base",
    "Brawler","Necromancer","Accelerator","Engineer","Hacker",
    "Gladiator","Commando","Slasher","Frost Blaster","Archer","Swarmer",
    "Toxic Gunner","Sledger","Executioner","Elf Camp","Jester","Cryomancer",
    "Hallow Punk","Harvester","Snowballer","Elementalist",
    "Firework Technician","Biologist","Warlock","Spotlight Tech","Mecha Base"
}

local function normalize(s)
    return s:lower():gsub("[^a-z0-9]", "")
end

local Normalized = {}
for _, name in ipairs(Towers) do
    Normalized[#Normalized + 1] = {
        raw = name,
        norm = normalize(name),
        words = name:lower():split(" ")
    }
end

local function resolveTower(input)
    if input == "" then return end
    local n = normalize(input)

    for _, t in ipairs(Normalized) do
        if t.norm == n then return t.raw end
    end
    for _, t in ipairs(Normalized) do
        if t.norm:sub(1, #n) == n then return t.raw end
    end
    for _, t in ipairs(Normalized) do
        for _, w in ipairs(t.words) do
            if w:sub(1, #n) == n then return t.raw end
        end
    end
end

local TDS = shared.TDS_Table or {} 
shared.TDS_Table = TDS

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")

function TDS:Equip(input_name)
    local tower_name = resolveTower(input_name) 
    
    if not tower_name then 
        warn("Tower tidak ditemukan: " .. tostring(input_name))
        return false 
    end
    
    local success = false
    local attempts = 0
    local maxAttempts = 15
    local remote = game:GetService("ReplicatedStorage"):WaitForChild("RemoteFunction")
    
    repeat
        attempts = attempts + 1
        
        local ok = pcall(function()
            remote:InvokeServer("Inventory", "Equip", "tower", tower_name)
            task.wait(0.1)
            remote:InvokeServer("Inventory", "Equip", "pvptower", tower_name)
        end)

        if ok then
            success = true
            print("Success Equip " .. tower_name .. " (Normal & PVP)")
        else
            warn("Failed attempt:" .. attempts .. ", Trying...")
            task.wait(0.3)
        end
    until success or attempts >= maxAttempts

    return success
end

function TDS:Addons()
    local start = os.clock()
    repeat
        if os.clock() - start > 8 then return false end
        task.wait()
    until TDS.Equip
    return true
end

-- // UI CONSTRUCTION (XP STYLE)
if PlayerGui:FindFirstChild("EquipTowerGUI") then
    PlayerGui.EquipTowerGUI:Destroy()
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "EquipTowerGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = PlayerGui

-- Window Frame
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 220, 0, 110)
frame.Position = UDim2.new(0, 20, 0, 20)
frame.BackgroundColor3 = Color3.fromRGB(212, 208, 200) -- Classic XP Gray
frame.BorderSizePixel = 1
frame.BorderColor3 = Color3.fromRGB(255, 255, 255)
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

-- Outset Border Effect
local border = Instance.new("UIStroke")
border.Thickness = 2
border.Color = Color3.fromRGB(128, 128, 128)
border.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
border.Parent = frame

-- Title Bar (XP Blue)
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, -6, 0, 22)
titleBar.Position = UDim2.new(0, 3, 0, 3)
titleBar.BackgroundColor3 = Color3.fromRGB(0, 85, 230)
titleBar.BorderSizePixel = 0
titleBar.Parent = frame

local titleText = Instance.new("TextLabel")
titleText.Text = " tower_equipper.exe"
titleText.Size = UDim2.new(1, -25, 1, 0)
titleText.BackgroundTransparency = 1
titleText.TextColor3 = Color3.new(1, 1, 1)
titleText.Font = Enum.Font.SourceSansBold
titleText.TextSize = 14
titleText.TextXAlignment = Enum.TextXAlignment.Left
titleText.Parent = titleBar

-- Fake Close Button
local closeBtn = Instance.new("TextLabel")
closeBtn.Text = "X"
closeBtn.Size = UDim2.new(0, 18, 0, 18)
closeBtn.Position = UDim2.new(1, -20, 0, 2)
closeBtn.BackgroundColor3 = Color3.fromRGB(232, 17, 35)
closeBtn.TextColor3 = Color3.new(1, 1, 1)
closeBtn.BorderSizePixel = 1
closeBtn.Font = Enum.Font.SourceSansBold
closeBtn.TextSize = 14
closeBtn.Parent = titleBar

-- Input Label
local label = Instance.new("TextLabel")
label.Text = "Select Tower Name:"
label.Size = UDim2.new(1, -20, 0, 20)
label.Position = UDim2.new(0, 10, 0, 35)
label.BackgroundTransparency = 1
label.TextColor3 = Color3.new(0, 0, 0)
label.Font = Enum.Font.SourceSans
label.TextSize = 14
label.TextXAlignment = Enum.TextXAlignment.Left
label.Parent = frame

-- TextBox (Inset Style)
local textbox = Instance.new("TextBox")
textbox.PlaceholderText = "Wait..."
textbox.Size = UDim2.new(1, -20, 0, 25)
textbox.Position = UDim2.new(0, 10, 0, 65)
textbox.BackgroundColor3 = Color3.new(1, 1, 1)
textbox.TextColor3 = Color3.new(0, 0, 0)
textbox.Font = Enum.Font.SourceSans
textbox.TextSize = 16
textbox.TextEditable = false
textbox.Text = ""
textbox.BorderSizePixel = 2
textbox.BorderColor3 = Color3.fromRGB(128, 128, 128)
textbox.Parent = frame

-- // LOGIC
task.spawn(function()
    if TDS:Addons() then
        textbox.PlaceholderText = "Type tower..."
        textbox.TextEditable = true
    end
end)

textbox.FocusLost:Connect(function(enterPressed)
    if not enterPressed or not TDS.Equip then return end
    local tower = resolveTower(textbox.Text)
    if tower then
        textbox.Text = "Equipping: " .. tower
        local ok = pcall(TDS.Equip, TDS, tower)
        task.wait(0.5)
    end
    textbox.Text = ""
end)

return TDS
