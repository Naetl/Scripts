-- // DATA: Daftar Tower Lengkap
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

-- // LOGIC: Normalisasi String untuk Pencarian
local function normalize(s)
    return s:lower():gsub("[^a-z0-9]", "")
end

local TDS = {}
shared.TDS_Table = TDS

-- // LOGIC: Fungsi Equip Manual (Integrasi RemoteFunction)
function TDS:Equip(tower_name)
    -- Validasi nama tower sebelum mengirim ke server
    local isValid = false
    for _, t in ipairs(Towers) do
        if t == tower_name then isValid = true break end
    end
    
    if not isValid then
        warn("Invalid tower name tried to equip: " .. tostring(tower_name))
        return false
    end

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
        return true, tower_name
    else
        warn("Failed to equip tower: " .. tostring(err))
        return false, err
    end
end

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")

-- // UI SETUP (DIROMBAK TOTAL)
if PlayerGui:FindFirstChild("EquipTowerGUIv2") then
    PlayerGui.EquipTowerGUIv2:Destroy()
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "EquipTowerGUIv2"
screenGui.ResetOnSpawn = false
screenGui.Parent = PlayerGui

-- Frame Utama diperlebar dan dipertinggi untuk menampung daftar
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 700, 0, 400) -- Ukuran besar untuk 6 kolom
mainFrame.Position = UDim2.new(0.5, -350, 0.5, -200) -- Tengah layar
mainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 8)

local title = Instance.new("TextLabel")
title.Text = "TDS Tower Equipper - Grid Search"
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.Parent = mainFrame

local textbox = Instance.new("TextBox")
textbox.Name = "SearchBox"
textbox.PlaceholderText = "Click to search tower..."
textbox.Size = UDim2.new(1, -20, 0, 35)
textbox.Position = UDim2.new(0, 10, 0, 45)
textbox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
textbox.TextColor3 = Color3.fromRGB(255, 255, 255)
textbox.Font = Enum.Font.Gotham
textbox.TextSize = 16
textbox.Text = ""
textbox.ClearTextOnFocus = false
textbox.Parent = mainFrame
Instance.new("UICorner", textbox).CornerRadius = UDim.new(0, 6)

-- Container untuk daftar bergulir
local scrollingFrame = Instance.new("ScrollingFrame")
scrollingFrame.Name = "ListContainer"
scrollingFrame.Size = UDim2.new(1, -20, 1, -90) -- Mengisi sisa ruang di bawah textbox
scrollingFrame.Position = UDim2.new(0, 10, 0, 85)
scrollingFrame.BackgroundTransparency = 1
scrollingFrame.BorderSizePixel = 0
scrollingFrame.ScrollBarThickness = 6
scrollingFrame.Visible = false -- Tersembunyi di awal
scrollingFrame.Parent = mainFrame

-- Layout Grid untuk 6 kolom
local gridLayout = Instance.new("UIGridLayout")
gridLayout.Parent = scrollingFrame
gridLayout.SortOrder = Enum.SortOrder.LayoutOrder
-- Menghitung lebar sel agar pas 6 kolom (700px lebar frame / 6 dikurangi padding)
gridLayout.CellSize = UDim2.new(0, 108, 0, 35) 
gridLayout.CellPadding = UDim2.new(0, 5, 0, 5)

-- // LOGIC: Fungsi untuk Memperbarui Daftar Tower
local function updateTowerList(searchText)
    -- 1. Bersihkan daftar lama
    for _, child in pairs(scrollingFrame:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end

    local searchNorm = normalize(searchText)
    local count = 0

    -- 2. Filter dan buat tombol baru
    for i, towerName in ipairs(Towers) do
        -- Jika kotak pencarian kosong, tampilkan semua. Jika tidak, filter.
        if searchText == "" or normalize(towerName):find(searchNorm, 1, true) then
            count = count + 1
            local btn = Instance.new("TextButton")
            btn.Name = towerName
            btn.Text = towerName
            btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            btn.TextColor3 = Color3.fromRGB(240, 240, 240)
            btn.Font = Enum.Font.GothamSemibold
            btn.TextSize = 14
            btn.Parent = scrollingFrame
            btn.LayoutOrder = i -- Menjaga urutan alfabetis asli
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)

            -- LOGIC: Handler Klik Tombol
            btn.MouseButton1Click:Connect(function()
                local success = TDS:Equip(towerName)
                if success then
                    textbox.Text = ""
                    textbox.PlaceholderText = "Equipped: " .. towerName
                    scrollingFrame.Visible = false -- Sembunyikan daftar setelah memilih
                end
            end)
        end
    end

    -- 3. Perbarui ukuran scroll agar bisa digulir
    -- Hitung berapa baris yang dibutuhkan berdasarkan jumlah item (count) dibagi kolom (6)
    local rows = math.ceil(count / 6)
    local totalHeight = (rows * gridLayout.CellSize.Y.Offset) + ((rows - 1) * gridLayout.CellPadding.Y.Offset) + 10
    scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, totalHeight)
end

-- // LOGIC: Event Handlers untuk Textbox

-- Saat textbox diklik/fokus: Tampilkan daftar dan isi
textbox.Focused:Connect(function()
    scrollingFrame.Visible = true
    updateTowerList(textbox.Text)
end)

-- Saat mengetik: Filter daftar secara langsung
textbox:GetPropertyChangedSignal("Text"):Connect(function()
    if scrollingFrame.Visible then
        updateTowerList(textbox.Text)
    end
end)

-- Saat fokus hilang (klik di luar): Sembunyikan daftar
-- Menggunakan delay kecil agar klik pada tombol sempat terdaftar sebelum daftar hilang
textbox.FocusLost:Connect(function(enterPressed)
    task.delay(0.2, function()
        -- Cek ganda apakah masih fokus untuk mencegah kedipan jika berpindah fokus cepat
        if not textbox:IsFocused() then 
            scrollingFrame.Visible = false
        end
    end)
    
    -- Logika Enter lama tetap dipertahankan sebagai fallback
    if enterPressed and textbox.Text ~= "" then
        -- Gunakan fungsi resolve lama jika menekan Enter (opsional, kode di atas sudah cukup baik)
        -- Untuk konsistensi grid, lebih baik gunakan klik tombol.
        -- Jika ingin tetap pakai enter, Anda perlu mengembalikan fungsi resolveTower di script sebelumnya.
    end
end)

return TDS
