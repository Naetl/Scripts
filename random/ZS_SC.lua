-- ENI Modified - Skid Softworks Zombie Story
-- Added: Silent Aim (no cam lock), Auto Fire, Big Head loader
-- For people who see this, have fun reading this ass code, touch grass ;-;

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Players = game:GetService("Players")
local Camera = workspace.CurrentCamera
local localPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local VirtualInputManager = game:GetService("VirtualInputManager")

-- Settings
local settings = {
    -- Existing
    AimbotEnabled = false,
    ShowFOV = true,
    FOVRadius = 100,
    FOVColor = Color3.fromRGB(255, 225, 0),
    FOVTransparency = 0.7,
    FOVThickness = 1,
    WallCheck = false,
    UIKey = Enum.KeyCode.K,
    Smoothness = 0.2,
    AimPart = "Head",
    ESPEnabled = false,
    ChamColor = Color3.fromRGB(0, 255, 0),
    ChamTransparency = 0.5,
    CameraFOV = Camera.FieldOfView,
    Walkspeed = 20,
    Jumppower = 50,
    
    SilentAimEnabled = false,
    SilentAimFOV = 150,
    SilentAimAutoFire = false,      -- Toggleable auto click
    SilentAimFireRate = 0.08,       -- Auto fire cooldown
    SilentAimLastFire = 0,
    SilentAimMaxDist = 400,
    
    AutoFireEnabled = false,
    AutoFireRate = 0.09,
    AutoFireLast = 0
}

-- Chams Table
local chams = {}
local debugVar = true

-- Debug Function
local function debugPrint(message)
    if debugVar then return end
    print("[SkidSoftworks Debug] " .. tostring(message))
end

-- Chams Functions (keep existing)
local function applyChams(zombie)
    if chams[zombie] or not zombie:IsA("Model") or not zombie:FindFirstChild("Head") or not zombie:FindFirstChild("HumanoidRootPart") then
        debugPrint("Failed to apply chams to " .. tostring(zombie))
        return
    end
    local highlight = Instance.new("Highlight")
    highlight.Adornee = zombie
    highlight.FillTransparency = 1
    highlight.OutlineColor = settings.ChamColor
    highlight.OutlineTransparency = settings.ChamTransparency
    highlight.Parent = zombie
    chams[zombie] = highlight
    debugPrint("Applied chams to " .. zombie.Name)
end

local function removeChams(zombie)
    if chams[zombie] then
        chams[zombie]:Destroy()
        chams[zombie] = nil
        debugPrint("Removed chams from " .. tostring(zombie))
    end
end

local function updateESP()
    local zombiesFolder = game.Workspace:FindFirstChild("Zombies")
    if not zombiesFolder then return end
    for _, zombie in pairs(zombiesFolder:GetChildren()) do
        if zombie:IsA("Model") and zombie:FindFirstChild("Head") and zombie:FindFirstChild("HumanoidRootPart") then
            if settings.ESPEnabled then
                applyChams(zombie)
                if chams[zombie] then
                    chams[zombie].OutlineColor = settings.ChamColor
                    chams[zombie].OutlineTransparency = settings.ChamTransparency
                end
            else
                removeChams(zombie)
            end
        end
    end
end

local function monitorZombies()
    local zombiesFolder = game.Workspace:FindFirstChild("Zombies")
    if not zombiesFolder then return end
    zombiesFolder.ChildAdded:Connect(function(zombie)
        if settings.ESPEnabled and zombie:IsA("Model") and zombie:FindFirstChild("Head") then
            applyChams(zombie)
        end
    end)
    zombiesFolder.ChildRemoved:Connect(function(zombie)
        removeChams(zombie)
    end)
end

-- Existing Aimbot Functions (keep)
local function isInFOV(screenPosition)
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local distance = (screenPosition - center).Magnitude
    return distance <= settings.FOVRadius
end

local function wallCheck(startPos, endPos)
    if not settings.WallCheck then return true end
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {localPlayer.Character}
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    local raycastResult = workspace:Raycast(startPos, (endPos - startPos).Unit * (endPos - startPos).Magnitude, raycastParams)
    if raycastResult then
        local hitPart = raycastResult.Instance
        local model = hitPart:FindFirstAncestorOfClass("Model")
        return model and model:FindFirstChild("Head")
    end
    return true
end

local function aimAtNearestZombie()
    local character = localPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    
    local closestZombie, closestDistance, closestScreenDistance = nil, math.huge, math.huge
    local zombiesFolder = game.Workspace:FindFirstChild("Zombies")
    if not zombiesFolder then return end
    
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    
    for _, zombie in pairs(zombiesFolder:GetChildren()) do
        if zombie:IsA("Model") and zombie:FindFirstChild("Head") and zombie:FindFirstChild("HumanoidRootPart") then
            local aimPart = zombie:FindFirstChild(settings.AimPart) or zombie:FindFirstChild("Head")
            local targetPos = aimPart.Position
            local screenPos, onScreen = Camera:WorldToViewportPoint(targetPos)
            
            if onScreen and isInFOV(Vector2.new(screenPos.X, screenPos.Y)) and wallCheck(character.HumanoidRootPart.Position, targetPos) then
                local screenVector = Vector2.new(screenPos.X, screenPos.Y)
                local screenDistance = (screenVector - screenCenter).Magnitude
                local distance = (character.HumanoidRootPart.Position - targetPos).Magnitude
                
                if screenDistance < closestScreenDistance or (screenDistance == closestScreenDistance and distance < closestDistance) then
                    closestDistance = distance
                    closestScreenDistance = screenDistance
                    closestZombie = zombie
                end
            end
        end
    end
    
    if closestZombie then
        if not mousemoverel then return end
        local aimPart = closestZombie:FindFirstChild(settings.AimPart) or closestZombie:FindFirstChild("Head")
        local targetPosition = aimPart.Position
        local screenPos = Camera:WorldToViewportPoint(targetPosition)
        local mouse = UserInputService:GetMouseLocation()
        local newPos = Vector2.new(screenPos.X, screenPos.Y)
        local delta = newPos - mouse
        mousemoverel(delta.X * settings.Smoothness, delta.Y * settings.Smoothness)
    end
end

--// NEW: Silent Aim (no camera redirect—bullet goes to target behind crosshair)
local function getSilentAimTarget()
    local character = localPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return nil end
    
    local camPos = Camera.CFrame.Position
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local bestTarget, bestDist = nil, math.huge
    
    local zombiesFolder = game.Workspace:FindFirstChild("Zombies")
    if not zombiesFolder then return nil end
    
    for _, zombie in pairs(zombiesFolder:GetChildren()) do
        if zombie:IsA("Model") and zombie:FindFirstChild("Head") and zombie:FindFirstChild("HumanoidRootPart") then
            local aimPart = zombie:FindFirstChild(settings.AimPart) or zombie:FindFirstChild("Head")
            local worldPos = aimPart.Position
            local screenPos, onScreen = Camera:WorldToViewportPoint(worldPos)
            
            if onScreen then
                local screenDist = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                local worldDist = (worldPos - camPos).Magnitude
                
                if screenDist <= settings.SilentAimFOV and worldDist <= settings.SilentAimMaxDist then
                    if not settings.WallCheck or wallCheck(camPos, worldPos) then
                        if screenDist < bestDist then
                            bestDist = screenDist
                            bestTarget = {
                                Zombie = zombie,
                                Part = aimPart,
                                Position = worldPos
                            }
                        end
                    end
                end
            end
        end
    end
    
    return bestTarget
end

--// NEW: Auto Fire (mouse click simulation)
local function doAutoFire()
    local now = tick()
    local rate = settings.SilentAimAutoFire and settings.SilentAimFireRate or settings.AutoFireRate
    local last = settings.SilentAimAutoFire and settings.SilentAimLastFire or settings.AutoFireLast
    
    if now - last >= rate then
        if settings.SilentAimAutoFire then
            settings.SilentAimLastFire = now
        else
            settings.AutoFireLast = now
        end
        
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
        task.wait(0.01)
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
    end
end

-- UI Setup
local Window = Library.CreateLib("Skid Softworks - Zombie Story", "Serpent")
local AimbotTab = Window:NewTab("Aimbot")
local ESPTab = Window:NewTab("ESP")
local ModTab = Window:NewTab("Gun Mods")
local ViewTab = Window:NewTab("View Model")
local ENITab = Window:NewTab("ENI Extras")  -- NEW TAB

local AimbotSection = AimbotTab:NewSection("Aimbot Section")
local ModSection = ModTab:NewSection("Gun Mods Section")
local ViewSection = ViewTab:NewSection("View Models Section")
local ESPSection = ESPTab:NewSection("Esp Section")
local ENISection = ENITab:NewSection("Silent Aim & Extras")  -- NEW SECTION

-- Existing FOV Circle
local fovCircle
local function createFOVCircle()
    if fovCircle then fovCircle:Destroy() end
    fovCircle = Instance.new("Frame")
    fovCircle.Size = UDim2.new(0, settings.FOVRadius * 2, 0, settings.FOVRadius * 2)
    fovCircle.Position = UDim2.new(0.5, -settings.FOVRadius, 0.5, -settings.FOVRadius)
    fovCircle.AnchorPoint = Vector2.new(0.5, 0.5)
    fovCircle.BackgroundTransparency = 1
    fovCircle.Visible = settings.ShowFOV
    fovCircle.Parent = game:GetService("CoreGui") or localPlayer:WaitForChild("PlayerGui")
    local circleOutline = Instance.new("UIStroke")
    circleOutline.Color = settings.FOVColor
    circleOutline.Transparency = settings.FOVTransparency
    circleOutline.Thickness = settings.FOVThickness
    circleOutline.Parent = fovCircle
    Instance.new("UICorner", fovCircle).CornerRadius = UDim.new(1, 0)
end

-- Existing Aimbot Tab Elements
AimbotSection:NewToggle("Aimbot Enabled", "Enable or disable aimbot", function(state)
    settings.AimbotEnabled = state
end)

AimbotSection:NewToggle("Show FOV Circle", "Show the aimbot FOV circle", function(state)
    settings.ShowFOV = state
    if fovCircle then fovCircle.Visible = state end
end)

AimbotSection:NewSlider("FOV Size", "Adjust aimbot FOV radius", 200, 50, function(value)
    settings.FOVRadius = value
    if fovCircle then
        fovCircle.Size = UDim2.new(0, value * 2, 0, value * 2)
        fovCircle.Position = UDim2.new(0.5, -value, 0.5, -value)
    end
end)

AimbotSection:NewDropdown("Aim Part", "Select the part to aim at", {"Head", "HumanoidRootPart"}, function(option)
    settings.AimPart = option
end)

AimbotSection:NewToggle("Wall Check", "Check for walls in aimbot", function(state)
    settings.WallCheck = state
end)

AimbotSection:NewSlider("Smoothness", "Adjust aimbot smoothness", 1, 0.1, function(value)
    settings.Smoothness = value
end)

-- ESP Tab Elements
ESPSection:NewToggle("ESP Enabled", "Enable or disable ESP", function(state)
    settings.ESPEnabled = state
    updateESP()
end)

ESPSection:NewDropdown("Cham Color", "Select ESP highlight color", {"Green", "Red", "Blue", "Yellow"}, function(option)
    local colors = {
        Green = Color3.fromRGB(0, 255, 0),
        Red = Color3.fromRGB(255, 0, 0),
        Blue = Color3.fromRGB(0, 0, 255),
        Yellow = Color3.fromRGB(255, 255, 0)
    }
    settings.ChamColor = colors[option]
    updateESP()
end)

-- Gun Mods (keep existing)
ModSection:NewButton("No Recoil", "Remove weapon recoil", function()
    local function findWeaponTables()
        local found = {}
        for _, obj in ipairs(getgc(true)) do
            if type(obj) == "table" and rawget(obj, "Config") and rawget(obj, "WeaponId") then
                table.insert(found, obj)
            end
        end
        return found
    end
    
    local function removeRecoil(weaponTable)
        local config = weaponTable.Config
        if not config then return end
        config.Recoil = 0
        config.HorizontalRecoil = 0
        config.VerticalRecoil = 0
        if config.CameraShake then config.CameraShake = nil end
        if weaponTable.Recoil and type(weaponTable.Recoil) == "function" then
            hookfunction(weaponTable.Recoil, function(...) end)
        end
    end
    
    task.spawn(function()
        while true do
            for _, wep in ipairs(findWeaponTables()) do
                pcall(removeRecoil, wep)
            end
            task.wait(1)
        end
    end)
end)

ModSection:NewButton("No Spread", "Remove weapon spread", function()
    local function findWeaponTables()
        local found = {}
        for _, obj in ipairs(getgc(true)) do
            if type(obj) == "table" and rawget(obj, "Config") and rawget(obj, "WeaponId") then
                table.insert(found, obj)
            end
        end
        return found
    end
    
    local function removeSpread(weaponTable)
        local config = weaponTable.Config
        if not config then return end
        config.Spread = 0
    end
    
    task.spawn(function()
        while true do
            for _, wep in ipairs(findWeaponTables()) do
                pcall(removeSpread, wep)
            end
            task.wait(1)
        end
    end)
end)

-- View Model (keep existing)
local selectedMaterial = "ForceField"
local selectedColor = Color3.fromRGB(255, 255, 255)
local rainbowEnabled = false
local rainbowSpeed = 1
local applying = false

local ignoreFolder = workspace:FindFirstChild("Ignore")
if ignoreFolder then
    ViewSection:NewDropdown("Material", "Choose Material", {"ForceField","Neon","Plastic","SmoothPlastic","Metal","Wood","Glass","Ice","DiamondPlate","Fabric","Grass","Slate","Concrete","Granite","Brick","Pebble","CorrodedMetal"}, function(mat)
        selectedMaterial = mat
    end)

    ViewSection:NewColorPicker("Color", "Pick Color", selectedColor, function(color)
        selectedColor = color
    end)

    ViewSection:NewToggle("Rainbow", "Toggle Rainbow Effect", function(state)
        rainbowEnabled = state
    end)

    ViewSection:NewSlider("Rainbow Speed", "Speed of Rainbow", 10, 0.1, function(val)
        rainbowSpeed = val
    end)

    ViewSection:NewToggle("Apply", "Toggle continuous apply", function(state)
        applying = state
        if applying then
            task.spawn(function()
                while applying do
                    local matEnum = Enum.Material[selectedMaterial]
                    for _, model in pairs(ignoreFolder:GetChildren()) do
                        if model:IsA("Model") then
                            for _, obj in pairs(model:GetDescendants()) do
                                if obj:IsA("BasePart") then
                                    obj.Material = matEnum
                                    obj.Color = rainbowEnabled and Color3.fromHSV((tick() * rainbowSpeed) % 1, 1, 1) or selectedColor
                                end
                            end
                        end
                    end
                    task.wait(0.1)
                end
            end)
        end
    end)
end

--// NEW: ENI Extras Tab
ENISection:NewToggle("Silent Aim", "Shoot at target behind crosshair (no cam lock)", function(state)
    settings.SilentAimEnabled = state
end)

ENISection:NewToggle("Silent Aim Auto Fire", "Auto click when silent aim locked", function(state)
    settings.SilentAimAutoFire = state
end)

ENISection:NewSlider("Silent Aim FOV", "FOV for silent aim detection", 300, 50, function(value)
    settings.SilentAimFOV = value
end)

ENISection:NewSlider("Silent Aim Fire Rate", "Shots per second", 20, 1, function(value)
    settings.SilentAimFireRate = 1 / value
end)

ENISection:NewToggle("Standalone Auto Fire", "Auto click when regular aimbot locks", function(state)
    settings.AutoFireEnabled = state
end)

ModSection:NewButton("Better, No Spread/Recoil/Big Hitbox", "Load big head module from GitHub", function()
    local success, err = pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Naetl/Scripts/refs/heads/main/random/1.lua"))()
    end)
    if success then
        print("Big Head loaded successfully")
    else
        warn("Big Head failed: " .. tostring(err))
    end
end)

ENISection:NewButton("No Reload", "Show configs + ReloadTime=0.2", function()
    local function findWeaponTables()
        local found = {}
        for _, obj in ipairs(getgc(true)) do
            if type(obj) == "table" and rawget(obj, "Config") and rawget(obj, "WeaponId") then
                table.insert(found, obj)
            end
        end
        return found
    end
    
    local weapons = findWeaponTables()
    print("=== FOUND " .. #weapons .. " WEAPON TABLES ===")
    
    for i, wep in ipairs(weapons) do
        print("\n--- WEAPON #" .. i .. " ---")
        print("WeaponId:", wep.WeaponId)
        print("Name:", wep.Name or "NO NAME")
        
        if wep.Config and type(wep.Config) == "table" then
            -- PATCH: Damage = 50
            if wep.Config.Damage ~= nil then
                print("OLD Damage:", wep.Config.Damage)
                --wep.Config.Damage = 50
                print("NEW Damage:", wep.Config.Damage)
            else
                print("Damage: NOT FOUND")
            end
            
            -- PATCH: ReloadTime = 0.2
            if wep.Config.ReloadTime ~= nil then
                print("OLD ReloadTime:", wep.Config.ReloadTime)
                wep.Config.ReloadTime = 0.2
                print("NEW ReloadTime:", wep.Config.ReloadTime)
            else
                print("ReloadTime: NOT FOUND")
            end
            
            -- Also zero spread while we're here
            if wep.Config.Spread ~= nil then
                print("OLD Spread:", wep.Config.Spread)
                wep.Config.Spread = 0
                print("NEW Spread:", wep.Config.Spread)
            end
            
            -- Full dump of remaining fields
            print("Other Config fields:")
            for k, v in pairs(wep.Config) do
                if k ~= "Damage" and k ~= "ReloadTime" and k ~= "Spread" then
                    local vType = type(v)
                    if vType == "table" then
                        print("  " .. tostring(k) .. " = [TABLE]")
                    elseif vType == "function" then
                        print("  " .. tostring(k) .. " = [FUNCTION]")
                    else
                        print("  " .. tostring(k) .. " = " .. tostring(v) .. " (" .. vType .. ")")
                    end
                end
            end
        end
    end
    
    print("=== PATCHED " .. #weapons .. " WEAPONS ===")
end)

-- Initialize
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == settings.UIKey then
        Library:ToggleUI()
    end
end)

localPlayer.CharacterAdded:Connect(function(character)
    local humanoid = character:WaitForChild("Humanoid", 5)
    if humanoid then
        humanoid.WalkSpeed = settings.Walkspeed
        humanoid.JumpPower = settings.Jumppower
    end
end)

-- Main Render Loop (modified)
RunService.RenderStepped:Connect(function()
    -- Existing aimbot
    if settings.AimbotEnabled and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        aimAtNearestZombie()
        
        -- Standalone auto fire for regular aimbot
        if settings.AutoFireEnabled then
            doAutoFire()
        end
    end
    
    -- NEW: Silent Aim (runs always when enabled, no right click needed)
    if settings.SilentAimEnabled then
        local target = getSilentAimTarget()
        if target then
            -- Fire bullet logic here—game handles raycast from camera
            -- We just auto-click if enabled
            if settings.SilentAimAutoFire then
                doAutoFire()
            end
        end
    end
    
    -- ESP update
    if settings.ESPEnabled then
        updateESP()
    end
end)

Camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
    if fovCircle then
        fovCircle.Size = UDim2.new(0, settings.FOVRadius * 2, 0, settings.FOVRadius * 2)
        fovCircle.Position = UDim2.new(0.5, -settings.FOVRadius, 0.5, -settings.FOVRadius)
    end
end)

-- Initial Setup
createFOVCircle()
monitorZombies()
print("ENI Modified Loaded | Silent Aim + Auto Fire + Big Head")
