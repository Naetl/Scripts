--// Tower Spawner UI
--// Built for LO. Clean, modular, no bloat.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local mouse = player:GetMouse()

--// Data
local towers = {
    "Army Camp", "Bruiser", "Builder", "Chemblaster", "Chronomancer",
    "Commando", "Composer", "Cryo Crypt", "Cupid", "Demolitionist",
    "Druid", "Dummy", "Easter Blaster", "Flamethrower", "Gatling Gunner",
    "Heavy", "Hitman", "Hunter", "Icebreaker", "Investor",
    "Lookout", "Manufactory", "Medic", "Missile Trooper", "Necromancer",
    "Operator", "Partisan", "Scarecrow", "Sharpshooter", "Shocker",
    "Shotgunner", "Signaleer", "Sniper", "Trickster", "Warrior", "Workshop",
}

local towerSkins = {
    ["Gatling Gunner"] = {"Awakened", "Default", "Desert", "Elf Melter"},
    ["Workshop"] = {"Default", "Festive", "Hoppy"},
    ["Manufactory"] = {"Blue", "Celebration", "Default", "Desert", "Festive", "Red"},
    ["Shotgunner"] = {"Bionic", "Comfy", "Default", "Surfer", "Survivor", "White", "Yellow"},
    ["Composer"] = {"Boombox", "Bouquet", "Default", "Grave Keeper", "Popstar", "Rockstar"},
    ["Army Camp"] = {"Blue", "Cat Camp", "Default", "Pink", "Red", "Warehouse", "Wendigo Hunter", "Yellow"},
    ["Cupid"] = {"Default"},
    ["Missile Trooper"] = {"Catzooka", "Celebration", "Default", "Easter", "Festive", "Ghost", "Patriot", "Simple"},
    ["Flamethrower"] = {"Arcane", "Beast Tamer", "Default", "Frostburn", "Green", "Haunted", "Heartburn", "Hydro", "Red"},
    ["Commando"] = {"Default", "Frosted Warden", "Pumpkin"},
    ["Builder"] = {"Basket", "Blue", "Creator", "Default", "Festive", "Glacier", "Grave Digger", "Traffic"},
    ["Chemblaster"] = {"Blue", "Celebration", "Default", "Lovecaster", "Pink", "Plague Bringer", "Red", "Rotten", "Toxic"},
    ["Bruiser"] = {"Black", "Blue", "Default", "Green", "Pink", "Red", "Scrambled", "White", "Yellow"},
    ["Cryo Crypt"] = {"Default"},
    ["Lookout"] = {"Baller", "Beach", "Blue", "Bunny", "Celebration", "Default", "Fashui", "Festive", "Greenest", "Love Letter", "Pink", "Red", "Simple", "Spectre", "Yellow"},
    ["Hitman"] = {"Default", "Gilded", "Glacier", "Green", "Moody", "Phantom", "Pink", "Summer", "Valentines", "Yellow"},
    ["Sniper"] = {"Cold Heart", "Default", "Fortress"},
    ["Scarecrow"] = {"Beekeeper", "Default", "Pumpkin Farmer"},
    ["Dummy"] = {"Default"},
    ["Signaleer"] = {"Celebration", "Default", "Festive", "Galactic", "Green", "Lifeguard", "Sinister", "Yellow"},
    ["Icebreaker"] = {"Default"},
    ["Hunter"] = {"Arctic", "Blue", "Cupid", "Deadeye", "Default", "Green", "Pumpkin"},
    ["Warrior"] = {"Black", "Blue", "Default", "Green", "Pink", "Red", "White", "Yellow"},
    ["Trickster"] = {"Default", "Festive"},
    ["Partisan"] = {"Bounty Hunter", "Cupid", "Default"},
    ["Demolitionist"] = {"Default", "Festive", "Green", "Patriot", "Pink", "Pumpkin", "Yellow"},
    ["Easter Blaster"] = {"Default"},
    ["Heavy"] = {"Bunny", "Celebration", "Cyborg", "Default", "Fortress", "Ghost", "Pink", "Yellow"},
    ["Necromancer"] = {"Deepfrost", "Default"},
    ["Druid"] = {"Default"},
    ["Sharpshooter"] = {"Assassin", "Black", "Blue", "Default", "Green", "Lovestruck", "Pink", "Red", "Wendigo Hunter", "White", "Yellow"},
    ["Medic"] = {"Arcane", "Bunny", "Celebration", "Default", "Fortress", "Frost Tyrant", "Pink", "Summer", "Valentines"},
    ["Investor"] = {"Alternate", "Beach", "Comfy", "Default", "Easter", "Leprechaun", "Moody"},
    ["Shocker"] = {"Bunny", "Cupid", "Default", "Ghost", "Hazmat", "Red"},
    ["Chronomancer"] = {"Default"},
    ["Operator"] = {"Arctic", "Celebration", "Default", "Festive", "Glacier", "Phantom", "Pink", "Pumpkin", "Red", "Simple", "Valentines", "White"},
}

--// State
local selectedTower = "Hunter"
local selectedSkin = "Default"
local levelNum1 = 4
local levelNum2 = 4

--// UI Creation
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "Admin UI"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = game:GetService("CoreGui")

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 420, 0, 520)
mainFrame.Position = UDim2.new(0.5, -210, 0.5, -260)
mainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

--// Corner + Stroke
local corner = Instance.new("UICorner", mainFrame)
corner.CornerRadius = UDim.new(0, 8)

local stroke = Instance.new("UIStroke", mainFrame)
stroke.Color = Color3.fromRGB(60, 60, 70)
stroke.Thickness = 1

--// Title Bar
local titleBar = Instance.new("Frame")
titleBar.Name = "TitleBar"
titleBar.Size = UDim2.new(1, 0, 0, 36)
titleBar.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

local titleCorner = Instance.new("UICorner", titleBar)
titleCorner.CornerRadius = UDim.new(0, 8)

local titleText = Instance.new("TextLabel")
titleText.Name = "Title"
titleText.Size = UDim2.new(1, -40, 1, 0)
titleText.Position = UDim2.new(0, 12, 0, 0)
titleText.BackgroundTransparency = 1
titleText.Text = "Admin UI"
titleText.TextColor3 = Color3.fromRGB(220, 220, 230)
titleText.TextSize = 14
titleText.Font = Enum.Font.GothamBold
titleText.TextXAlignment = Enum.TextXAlignment.Left
titleText.Parent = titleBar

--// Close Button
local closeBtn = Instance.new("TextButton")
closeBtn.Name = "Close"
closeBtn.Size = UDim2.new(0, 28, 0, 28)
closeBtn.Position = UDim2.new(1, -34, 0, 4)
closeBtn.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.TextSize = 12
closeBtn.Font = Enum.Font.GothamBold
closeBtn.Parent = titleBar

local closeCorner = Instance.new("UICorner", closeBtn)
closeCorner.CornerRadius = UDim.new(0, 6)

closeBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

--// Dragging
local dragging = false
local dragStart, startPos

titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

--// Helper: Create Section Label
local function createLabel(parent, text, posY)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -24, 0, 18)
    label.Position = UDim2.new(0, 12, 0, posY)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(140, 140, 150)
    label.TextSize = 11
    label.Font = Enum.Font.GothamSemibold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = parent
    return label
end

--// Helper: Create Scrolling List
local function createScrollingList(parent, pos, size, itemList, callback)
    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = size
    scroll.Position = pos
    scroll.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
    scroll.BorderSizePixel = 0
    scroll.ScrollBarThickness = 4
    scroll.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 90)
    scroll.CanvasSize = UDim2.new(0, 0, 0, #itemList * 28)
    scroll.Parent = parent
    
    local scrollCorner = Instance.new("UICorner", scroll)
    scrollCorner.CornerRadius = UDim.new(0, 6)
    
    local layout = Instance.new("UIListLayout", scroll)
    layout.Padding = UDim.new(0, 2)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    
    local buttons = {}
    
    for i, item in ipairs(itemList) do
        local btn = Instance.new("TextButton")
        btn.Name = item
        btn.Size = UDim2.new(1, -8, 0, 26)
        btn.Position = UDim2.new(0, 4, 0, 0)
        btn.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
        btn.Text = item
        btn.TextColor3 = Color3.fromRGB(180, 180, 190)
        btn.TextSize = 12
        btn.Font = Enum.Font.Gotham
        btn.Parent = scroll
        
        local btnCorner = Instance.new("UICorner", btn)
        btnCorner.CornerRadius = UDim.new(0, 4)
        
        btn.MouseButton1Click:Connect(function()
            for _, b in pairs(buttons) do
                b.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
                b.TextColor3 = Color3.fromRGB(180, 180, 190)
            end
            btn.BackgroundColor3 = Color3.fromRGB(60, 100, 160)
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            callback(item)
        end)
        
        table.insert(buttons, btn)
    end
    
    -- Select first by default
    if #buttons > 0 then
        buttons[1].BackgroundColor3 = Color3.fromRGB(60, 100, 160)
        buttons[1].TextColor3 = Color3.fromRGB(255, 255, 255)
    end
    
    return scroll, buttons
end

--// Tower List Section
createLabel(mainFrame, "SELECT", 44)
local refreshSkins

local towerScroll, towerButtons = createScrollingList(
    mainFrame,
    UDim2.new(0, 12, 0, 64),
    UDim2.new(0.5, -18, 0, 180),
    towers,
    function(name)
        selectedTower = name
        -- Refresh skin list
        refreshSkins(name)
    end
)

--// Skin List Section
createLabel(mainFrame, "SELECT SKIN", 44)

local skinScroll
local skinButtons = {}

refreshSkins = function(towerName)
    if skinScroll then skinScroll:Destroy() end
    skinButtons = {}
    
    local skins = towerSkins[towerName] or {"Default"}
    
    skinScroll = Instance.new("ScrollingFrame")
    skinScroll.Size = UDim2.new(0.5, -18, 0, 180)
    skinScroll.Position = UDim2.new(0.5, 6, 0, 64)
    skinScroll.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
    skinScroll.BorderSizePixel = 0
    skinScroll.ScrollBarThickness = 4
    skinScroll.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 90)
    skinScroll.CanvasSize = UDim2.new(0, 0, 0, #skins * 28)
    skinScroll.Parent = mainFrame
    
    local scrollCorner = Instance.new("UICorner", skinScroll)
    scrollCorner.CornerRadius = UDim.new(0, 6)
    
    local layout = Instance.new("UIListLayout", skinScroll)
    layout.Padding = UDim.new(0, 2)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    
    for i, skin in ipairs(skins) do
        local btn = Instance.new("TextButton")
        btn.Name = skin
        btn.Size = UDim2.new(1, -8, 0, 26)
        btn.Position = UDim2.new(0, 4, 0, 0)
        btn.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
        btn.Text = skin
        btn.TextColor3 = Color3.fromRGB(180, 180, 190)
        btn.TextSize = 12
        btn.Font = Enum.Font.Gotham
        btn.Parent = skinScroll
        
        local btnCorner = Instance.new("UICorner", btn)
        btnCorner.CornerRadius = UDim.new(0, 4)
        
        btn.MouseButton1Click:Connect(function()
            for _, b in pairs(skinButtons) do
                b.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
                b.TextColor3 = Color3.fromRGB(180, 180, 190)
            end
            btn.BackgroundColor3 = Color3.fromRGB(60, 100, 160)
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            selectedSkin = skin
        end)
        
        table.insert(skinButtons, btn)
    end
    
    -- Select "Default" or first
    local defaultIdx = table.find(skins, "Default") or 1
    skinButtons[defaultIdx].BackgroundColor3 = Color3.fromRGB(60, 100, 160)
    skinButtons[defaultIdx].TextColor3 = Color3.fromRGB(255, 255, 255)
    selectedSkin = skins[defaultIdx]
end

refreshSkins(selectedTower)

--// Level Controls Section
createLabel(mainFrame, "LEVEL SETTINGS", 256)

local function createLevelControl(parent, labelText, posY, defaultVal, callback)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -24, 0, 40)
    container.Position = UDim2.new(0, 12, 0, posY)
    container.BackgroundTransparency = 1
    container.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.3, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = labelText
    label.TextColor3 = Color3.fromRGB(160, 160, 170)
    label.TextSize = 12
    label.Font = Enum.Font.GothamSemibold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container
    
    local minusBtn = Instance.new("TextButton")
    minusBtn.Size = UDim2.new(0, 32, 0, 28)
    minusBtn.Position = UDim2.new(0.35, 0, 0.5, -14)
    minusBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    minusBtn.Text = "-"
    minusBtn.TextColor3 = Color3.fromRGB(200, 200, 210)
    minusBtn.TextSize = 14
    minusBtn.Font = Enum.Font.GothamBold
    minusBtn.Parent = container
    
    local minusCorner = Instance.new("UICorner", minusBtn)
    minusCorner.CornerRadius = UDim.new(0, 4)
    
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0, 40, 0, 28)
    valueLabel.Position = UDim2.new(0.35, 38, 0.5, -14)
    valueLabel.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
    valueLabel.Text = tostring(defaultVal)
    valueLabel.TextColor3 = Color3.fromRGB(220, 220, 230)
    valueLabel.TextSize = 13
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.Parent = container
    
    local valCorner = Instance.new("UICorner", valueLabel)
    valCorner.CornerRadius = UDim.new(0, 4)
    
    local plusBtn = Instance.new("TextButton")
    plusBtn.Size = UDim2.new(0, 32, 0, 28)
    plusBtn.Position = UDim2.new(0.35, 82, 0.5, -14)
    plusBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    plusBtn.Text = "+"
    plusBtn.TextColor3 = Color3.fromRGB(200, 200, 210)
    plusBtn.TextSize = 14
    plusBtn.Font = Enum.Font.GothamBold
    plusBtn.Parent = container
    
    local plusCorner = Instance.new("UICorner", plusBtn)
    plusCorner.CornerRadius = UDim.new(0, 4)
    
    local current = defaultVal
    
    minusBtn.MouseButton1Click:Connect(function()
        current = math.max(0, current - 1)
        valueLabel.Text = tostring(current)
        callback(current)
    end)
    
    plusBtn.MouseButton1Click:Connect(function()
        current = math.min(7, current + 1)
        valueLabel.Text = tostring(current)
        callback(current)
    end)
    
    return container
end

createLevelControl(mainFrame, "Level Left", 276, 7, function(v)
    levelNum1 = v
end)

createLevelControl(mainFrame, "Level Right", 320, 7, function(v)
    levelNum2 = v
end)

--// Spawn Button
local spawnBtn = Instance.new("TextButton")
spawnBtn.Name = "SpawnButton"
spawnBtn.Size = UDim2.new(1, -24, 0, 40)
spawnBtn.Position = UDim2.new(0, 12, 0, 380)
spawnBtn.BackgroundColor3 = Color3.fromRGB(60, 140, 80)
spawnBtn.Text = "SPAWN TOWER"
spawnBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
spawnBtn.TextSize = 14
spawnBtn.Font = Enum.Font.GothamBold
spawnBtn.Parent = mainFrame

local spawnCorner = Instance.new("UICorner", spawnBtn)
spawnCorner.CornerRadius = UDim.new(0, 6)

--// Status Label
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -24, 0, 20)
statusLabel.Position = UDim2.new(0, 12, 0, 426)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Ready"
statusLabel.TextColor3 = Color3.fromRGB(100, 180, 100)
statusLabel.TextSize = 11
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextXAlignment = Enum.TextXAlignment.Center
statusLabel.Parent = mainFrame

--// Add this after the Spawn Button section in your existing code

--// Divider
local divider = Instance.new("Frame")
divider.Size = UDim2.new(1, -24, 0, 1)
divider.Position = UDim2.new(0, 12, 0, 450)
divider.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
divider.BorderSizePixel = 0
divider.Parent = mainFrame

--// Equip Section Label
createLabel(mainFrame, "EQUIP TOWER", 458)

--// Equip Tower List (compact, half height)
local equipScroll = Instance.new("ScrollingFrame")
equipScroll.Name = "EquipScroll"
equipScroll.Size = UDim2.new(1, -24, 0, 120)
equipScroll.Position = UDim2.new(0, 12, 0, 478)
equipScroll.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
equipScroll.BorderSizePixel = 0
equipScroll.ScrollBarThickness = 4
equipScroll.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 90)
equipScroll.CanvasSize = UDim2.new(0, 0, 0, #towers * 28)
equipScroll.Parent = mainFrame

local equipScrollCorner = Instance.new("UICorner", equipScroll)
equipScrollCorner.CornerRadius = UDim.new(0, 6)

local equipLayout = Instance.new("UIListLayout", equipScroll)
equipLayout.Padding = UDim.new(0, 2)
equipLayout.SortOrder = Enum.SortOrder.LayoutOrder

local equipButtons = {}
local equipSelectedTower = "Commando"

for i, towerName in ipairs(towers) do
    local btn = Instance.new("TextButton")
    btn.Name = towerName
    btn.Size = UDim2.new(1, -8, 0, 26)
    btn.Position = UDim2.new(0, 4, 0, 0)
    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
    btn.Text = towerName
    btn.TextColor3 = Color3.fromRGB(180, 180, 190)
    btn.TextSize = 12
    btn.Font = Enum.Font.Gotham
    btn.Parent = equipScroll
    
    local btnCorner = Instance.new("UICorner", btn)
    btnCorner.CornerRadius = UDim.new(0, 4)
    
    btn.MouseButton1Click:Connect(function()
        for _, b in pairs(equipButtons) do
            b.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
            b.TextColor3 = Color3.fromRGB(180, 180, 190)
        end
        btn.BackgroundColor3 = Color3.fromRGB(60, 100, 160)
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        equipSelectedTower = towerName
        print("[TowerSpawner] Equip selected:", towerName)
    end)
    
    table.insert(equipButtons, btn)
end

-- Select first by default
if #equipButtons > 0 then
    equipButtons[1].BackgroundColor3 = Color3.fromRGB(60, 100, 160)
    equipButtons[1].TextColor3 = Color3.fromRGB(255, 255, 255)
    equipSelectedTower = towers[1]
end

--// Equip Button
local equipBtn = Instance.new("TextButton")
equipBtn.Name = "EquipButton"
equipBtn.Size = UDim2.new(1, -24, 0, 36)
equipBtn.Position = UDim2.new(0, 12, 0, 604)
equipBtn.BackgroundColor3 = Color3.fromRGB(80, 60, 140)
equipBtn.Text = "EQUIP TOWER"
equipBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
equipBtn.TextSize = 13
equipBtn.Font = Enum.Font.GothamBold
equipBtn.Parent = mainFrame

local equipBtnCorner = Instance.new("UICorner", equipBtn)
equipBtnCorner.CornerRadius = UDim.new(0, 6)

--// Equip Status
local equipStatus = Instance.new("TextLabel")
equipStatus.Size = UDim2.new(1, -24, 0, 18)
equipStatus.Position = UDim2.new(0, 12, 0, 644)
equipStatus.BackgroundTransparency = 1
equipStatus.Text = "Ready to equip"
equipStatus.TextColor3 = Color3.fromRGB(140, 140, 180)
equipStatus.TextSize = 11
equipStatus.Font = Enum.Font.Gotham
equipStatus.TextXAlignment = Enum.TextXAlignment.Center
equipStatus.Parent = mainFrame

--// Equip Logic
equipBtn.MouseButton1Click:Connect(function()
    local args = {
        equipSelectedTower,
        "Equip"
    }
    
    local success, result = pcall(function()
        return ReplicatedStorage:WaitForChild("events"):WaitForChild("EquipTower"):InvokeServer(unpack(args))
    end)
    
    if success then
        equipStatus.Text = "Equipped: " .. equipSelectedTower
        equipStatus.TextColor3 = Color3.fromRGB(120, 100, 200)
    else
        equipStatus.Text = "Error: " .. tostring(result)
        equipStatus.TextColor3 = Color3.fromRGB(200, 60, 60)
    end
end)

--// Hover effects
equipBtn.MouseEnter:Connect(function()
    TweenService:Create(equipBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(100, 80, 170)}):Play()
end)

equipBtn.MouseLeave:Connect(function()
    TweenService:Create(equipBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(80, 60, 140)}):Play()
end)

--// Resize main frame to fit new content
mainFrame.Size = UDim2.new(0, 420, 0, 670)

--// Spawn Logic
local function getPlayerPosition()
    local char = player.Character
    if not char then return nil end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    return hrp.CFrame
end

spawnBtn.MouseButton1Click:Connect(function()
    local pos = getPlayerPosition()
    if not pos then
        statusLabel.Text = "Error: Character not found"
        statusLabel.TextColor3 = Color3.fromRGB(200, 60, 60)
        return
    end
    
    local args = {
        selectedTower,
        pos,
        selectedSkin,
        false,
        levelNum1,
        levelNum2
    }
    
    local success, result = pcall(function()
        return ReplicatedStorage:WaitForChild("events"):WaitForChild("PromptPlaceTower"):InvokeServer(unpack(args))
    end)
    
    if success then
        statusLabel.Text = string.format("Spawned: %s [%s] Lv.%d/%d", selectedTower, selectedSkin, levelNum1, levelNum2)
        statusLabel.TextColor3 = Color3.fromRGB(100, 180, 100)
    else
        statusLabel.Text = "Error: " .. tostring(result)
        statusLabel.TextColor3 = Color3.fromRGB(200, 60, 60)
    end
end)

--// Hover effects
spawnBtn.MouseEnter:Connect(function()
    TweenService:Create(spawnBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(75, 170, 95)}):Play()
end)

spawnBtn.MouseLeave:Connect(function()
    TweenService:Create(spawnBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(60, 140, 80)}):Play()
end)

--// Open/Close with RightShift
local uiVisible = true
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.RightShift then
        uiVisible = not uiVisible
        mainFrame.Visible = uiVisible
    end
end)

print("[Tower Spawner] Loaded. Press RightShift to toggle.")
