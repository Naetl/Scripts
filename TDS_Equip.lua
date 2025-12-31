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

-- // LOGIC: Normalisasi Nama
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

-- // LOGIC: Pencari Nama Tower
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

local TDS = {}
shared.TDS_Table = TDS

-- // LOGIC: Fungsi Equip Manual (Integrasi RemoteFunction)
function TDS:Equip(tower_name)
    local Remote = game:GetService("ReplicatedStorage"):WaitForChild("RemoteFunction")
    local args = {
        "Inventory",
        "Equip",
        "tower",
        tower_name
    }
    
    local success, err = pcall(function()
        Remote:InvokeServer(unpack(args))
    end)
    
    if success then
        print("Successfully equipped: " .. tower_name)
    else
        warn("Failed to equip tower: " .. tostring(err))
    end
end

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")

-- // UI SETUP
if PlayerGui:FindFirstChild("EquipTowerGUI") then
    PlayerGui.EquipTowerGUI:Destroy()
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "EquipTowerGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = PlayerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 220, 0, 100)
frame.Position = UDim2.new(0, 10, 0, 10)
frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)

local title = Instance.new("TextLabel")
title.Text = "TDS Tower Equipper"
title.Size = UDim2.new(1, 0, 0, 35)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.Parent = frame

local textbox = Instance.new("TextBox")
textbox.PlaceholderText = "Type Tower Name..."
textbox.Size = UDim2.new(1, -20, 0, 35)
textbox.Position = UDim2.new(0, 10, 0, 45)
textbox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
textbox.TextColor3 = Color3.fromRGB(255, 255, 255)
textbox.Font = Enum.Font.Gotham
textbox.TextSize = 14
textbox.Text = ""
textbox.Parent = frame
Instance.new("UICorner", textbox).CornerRadius = UDim.new(0, 4)

-- // LOGIC: Input Handler
textbox.FocusLost:Connect(function(enterPressed)
    if not enterPressed then return end
    
    local tower = resolveTower(textbox.Text)
    if tower then
        TDS:Equip(tower)
        textbox.PlaceholderText = "Equipped: " .. tower
    else
        textbox.PlaceholderText = "Tower not found!"
    end
    textbox.Text = ""
end)

return TDS
