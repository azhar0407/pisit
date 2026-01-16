-- KURAS LAUT - INSTANT FISHING GOD MODE
-- ON = langsung mancing dapat ikan berkali-kali!

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

-- CONFIG
local KURAS_LAUT = {
    ENABLED = false,
    SPEED = 100, -- Ikan per detik
    MULTIPLIER = 10, -- Ikan per cast
    AUTO_SELL = true,
    INFINITE_BAIT = true,
    NO_COOLDOWN = true
}

-- REMOTES UTAMA
local remotes = {}

-- Setup semua remote penting
local function setupRemotes()
    print("🔧 Setup remotes KURAS LAUT...")
    
    remotes = {
        -- AUTO FISHING
        updateAutoFish = ReplicatedStorage:WaitForChild("RF/UpdateAutoFishingState"),
        chargeRod = ReplicatedStorage:WaitForChild("RF/ChargeFishingRod"),
        cancelInputs = ReplicatedStorage:WaitForChild("RF/CancelFishingInputs"),
        
        -- CATCH SYSTEM
        fishCaught = ReplicatedStorage:WaitForChild("RE/FishCaught"),
        fishingCompleted = ReplicatedStorage:WaitForChild("RE/FishingCompleted"),
        fishingStopped = ReplicatedStorage:WaitForChild("RE/FishingStopped"),
        
        -- MINIGAME
        requestMinigame = ReplicatedStorage:WaitForChild("RF/RequestFishingMinigameStarted"),
        minigameChanged = ReplicatedStorage:WaitForChild("RE/FishingMinigameChanged"),
        
        -- BAIT SYSTEM
        equipBait = ReplicatedStorage:WaitForChild("RE/EquipBait"),
        baitCast = ReplicatedStorage:WaitForChild("RE/BaitCastVisual"),
        baitSpawned = ReplicatedStorage:WaitForChild("RE/BaitSpawned"),
        baitDestroyed = ReplicatedStorage:WaitForChild("RE/BaitDestroyed"),
        
        -- RADAR & EFFECTS
        updateRadar = ReplicatedStorage:WaitForChild("RF/UpdateFishingRadar"),
        playEffect = ReplicatedStorage:WaitForChild("RE/PlayFishingEffect"),
        fishVisual = ReplicatedStorage:WaitForChild("RE/CaughtFishVisual"),
        
        -- SHOP
        purchaseRod = ReplicatedStorage:WaitForChild("RF/PurchaseFishingRod"),
        purchaseBait = ReplicatedStorage:WaitForChild("RF/PurchaseBait"),
        
        -- AUTO SELL
        updateAutoSell = ReplicatedStorage:FindFirstChild("RF/UpdateAutoSellThreshold")
    }
    
    print("✅ Remotes setup complete!")
    return remotes
end

-- MODE KURAS LAUT: INSTANT FISHING
local function startKurasLaut()
    if KURAS_LAUT.ENABLED then return end
    
    print("\n" .. string.rep("⚡", 50))
    print("🚀 KURAS LAUT DIHIDUPKAN!")
    print("🎣 INSTANT FISHING GOD MODE")
    print(string.rep("⚡", 50))
    
    KURAS_LAUT.ENABLED = true
    
    -- Setup remotes
    if not remotes.updateAutoFish then
        setupRemotes()
    end
    
    -- 1. AKTIFKAN AUTO-FISHING
    pcall(function()
        remotes.updateAutoFish:InvokeServer(true)
        print("✅ Auto-fishing: ON")
    end)
    
    -- 2. SET AUTO-SELL MAX (jika ada)
    if remotes.updateAutoSell then
        pcall(function()
            remotes.updateAutoSell:InvokeServer(100) -- Jual 100%
            print("💰 Auto-sell: 100%")
        end)
    end
    
    -- 3. INFINITE BAIT HACK
    if KURAS_LAUT.INFINITE_BAIT then
        spawn(function()
            while KURAS_LAUT.ENABLED do
                pcall(function()
                    -- Equip bait terus menerus
                    remotes.equipBait:FireServer("BasicBait") -- Ganti dengan bait ID yang benar
                    remotes.baitSpawned:FireServer()
                    task.wait(5)
                end)
            end
        end)
        print("🪱 Infinite bait: ON")
    end
    
    -- 4. INSTANT CHARGE (NO COOLDOWN)
    if KURAS_LAUT.NO_COOLDOWN then
        spawn(function()
            while KURAS_LAUT.ENABLED do
                pcall(function()
                    remotes.chargeRod:InvokeServer()
                    task.wait(0.1) -- Charge super cepat
                end)
            end
        end)
        print("⚡ No cooldown: ON")
    end
    
    -- 5. MAIN LOOP: KURAS LAUT!
    spawn(function()
        local fishCount = 0
        local startTime = os.time()
        
        while KURAS_LAUT.ENABLED do
            -- UPDATE RADAR untuk deteksi ikan
            pcall(function() remotes.updateRadar:InvokeServer() end)
            
            -- INSTANT MINIGAME COMPLETE
            pcall(function()
                remotes.requestMinigame:InvokeServer()
                remotes.minigameChanged:FireServer("COMPLETED")
            end)
            
            -- MULTI-CATCH SYSTEM (Dapat banyak ikan sekaligus)
            for i = 1, KURAS_LAUT.MULTIPLIER do
                pcall(function()
                    -- FIRE CATCH EVENT
                    remotes.fishCaught:FireServer({
                        fishType = "Rare", -- Ganti dengan fish data
                        weight = 100,
                        value = 1000,
                        perfect = true
                    })
                    
                    -- COMPLETE FISHING
                    remotes.fishingCompleted:FireServer()
                    
                    -- VISUAL EFFECTS
                    remotes.fishVisual:FireServer()
                    remotes.playEffect:FireServer()
                    
                    fishCount = fishCount + 1
                end)
                
                -- Speed control
                task.wait(1 / KURAS_LAUT.SPEED)
            end
            
            -- CANCEL INPUTS untuk reset cepat
            pcall(function() remotes.cancelInputs:InvokeServer() end)
            
            -- UPDATE STATS SETIAP 100 IKAN
            if fishCount % 100 == 0 then
                local elapsed = os.time() - startTime
                local fishPerSecond = fishCount / elapsed
                print(string.format("🐟 %d ikan | 🚀 %.1f ikan/detik", fishCount, fishPerSecond))
            end
        end
        
        print("\n⏹️ KURAS LAUT DIMATIKAN")
        print(string.format("📊 Total ikan: %d", fishCount))
    end)
end

-- STOP KURAS LAUT
local function stopKurasLaut()
    if not KURAS_LAUT.ENABLED then return end
    
    KURAS_LAUT.ENABLED = false
    
    -- Matikan auto-fishing
    pcall(function()
        remotes.updateAutoFish:InvokeServer(false)
    end)
    
    print("\n⏹️ KURAS LAUT DIMATIKAN")
end

-- GUI KONTROL SEDERHANA
local function createKurasLautGUI()
    local PlayerGui = player:WaitForChild("PlayerGui")
    
    -- Hapus GUI lama
    if PlayerGui:FindFirstChild("KurasLautGUI") then
        PlayerGui.KurasLautGUI:Destroy()
    end
    
    -- Buat GUI
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "KurasLautGUI"
    ScreenGui.Parent = PlayerGui
    
    -- Main Frame
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 300, 0, 250)
    MainFrame.Position = UDim2.new(0.5, -150, 0.5, -125)
    MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
    MainFrame.Parent = ScreenGui
    MainFrame.Active = true
    MainFrame.Draggable = true
    
    -- Corner
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 12)
    Corner.Parent = MainFrame
    
    -- Header
    local Header = Instance.new("Frame")
    Header.Size = UDim2.new(1, 0, 0, 40)
    Header.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
    Header.Parent = MainFrame
    
    local HeaderCorner = Instance.new("UICorner")
    HeaderCorner.CornerRadius = UDim.new(0, 12)
    HeaderCorner.Parent = Header
    
    local Title = Instance.new("TextLabel")
    Title.Text = "⚡ KURAS LAUT MODE ⚡"
    Title.Size = UDim2.new(1, 0, 1, 0)
    Title.BackgroundTransparency = 1
    Title.TextColor3 = Color3.new(1, 1, 1)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 18
    Title.Parent = Header
    
    -- Status Indicator
    local StatusFrame = Instance.new("Frame")
    StatusFrame.Size = UDim2.new(0.9, 0, 0, 40)
    StatusFrame.Position = UDim2.new(0.05, 0, 0.2, 0)
    StatusFrame.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    StatusFrame.Parent = MainFrame
    
    local StatusCorner = Instance.new("UICorner")
    StatusCorner.CornerRadius = UDim.new(0, 8)
    StatusCorner.Parent = StatusFrame
    
    local StatusText = Instance.new("TextLabel")
    StatusText.Text = "🚫 OFF - KURAS LAUT"
    StatusText.Size = UDim2.new(1, 0, 1, 0)
    StatusText.BackgroundTransparency = 1
    StatusText.TextColor3 = Color3.new(1, 1, 1)
    StatusText.Font = Enum.Font.GothamBold
    StatusText.TextSize = 16
    StatusText.Parent = StatusFrame
    
    -- Start Button
    local StartBtn = Instance.new("TextButton")
    StartBtn.Text = "🚀 START KURAS LAUT"
    StartBtn.Size = UDim2.new(0.9, 0, 0, 50)
    StartBtn.Position = UDim2.new(0.05, 0, 0.4, 0)
    StartBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
    StartBtn.TextColor3 = Color3.new(1, 1, 1)
    StartBtn.Font = Enum.Font.GothamBold
    StartBtn.TextSize = 16
    StartBtn.Parent = MainFrame
    
    local StartCorner = Instance.new("UICorner")
    StartCorner.CornerRadius = UDim.new(0, 8)
    StartCorner.Parent = StartBtn
    
    -- Stop Button
    local StopBtn = Instance.new("TextButton")
    StopBtn.Text = "⏹️ STOP KURAS LAUT"
    StopBtn.Size = UDim2.new(0.9, 0, 0, 50)
    StopBtn.Position = UDim2.new(0.05, 0, 0.65, 0)
    StopBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    StopBtn.TextColor3 = Color3.new(1, 1, 1)
    StopBtn.Font = Enum.Font.GothamBold
    StopBtn.TextSize = 16
    StopBtn.Parent = MainFrame
    
    local StopCorner = Instance.new("UICorner")
    StopCorner.CornerRadius = UDim.new(0, 8)
    StopCorner.Parent = StopBtn
    
    -- Speed Slider
    local SpeedFrame = Instance.new("Frame")
    SpeedFrame.Size = UDim2.new(0.9, 0, 0, 40)
    SpeedFrame.Position = UDim2.new(0.05, 0, 0.88, 0)
    SpeedFrame.BackgroundTransparency = 1
    SpeedFrame.Parent = MainFrame
    
    local SpeedLabel = Instance.new("TextLabel")
    SpeedLabel.Text = "⚡ Speed: " .. KURAS_LAUT.SPEED .. " ikan/detik"
    SpeedLabel.Size = UDim2.new(0.7, 0, 1, 0)
    SpeedLabel.BackgroundTransparency = 1
    SpeedLabel.TextColor3 = Color3.new(1, 1, 1)
    SpeedLabel.Font = Enum.Font.Gotham
    SpeedLabel.TextSize = 14
    SpeedLabel.TextXAlignment = Enum.TextXAlignment.Left
    SpeedLabel.Parent = SpeedFrame
    
    local SpeedPlus = Instance.new("TextButton")
    SpeedPlus.Text = "+"
    SpeedPlus.Size = UDim2.new(0.1, 0, 0.7, 0)
    SpeedPlus.Position = UDim2.new(0.85, 0, 0.15, 0)
    SpeedPlus.BackgroundColor3 = Color3.fromRGB(50, 150, 255)
    SpeedPlus.TextColor3 = Color3.new(1, 1, 1)
    SpeedPlus.Font = Enum.Font.GothamBold
    SpeedPlus.TextSize = 16
    SpeedPlus.Parent = SpeedFrame
    
    local SpeedMinus = Instance.new("TextButton")
    SpeedMinus.Text = "-"
    SpeedMinus.Size = UDim2.new(0.1, 0, 0.7, 0)
    SpeedMinus.Position = UDim2.new(0.72, 0, 0.15, 0)
    SpeedMinus.BackgroundColor3 = Color3.fromRGB(50, 150, 255)
    SpeedMinus.TextColor3 = Color3.new(1, 1, 1)
    SpeedMinus.Font = Enum.Font.GothamBold
    SpeedMinus.TextSize = 16
    SpeedMinus.Parent = SpeedFrame
    
    -- Button Events
    StartBtn.MouseButton1Click:Connect(function()
        if not KURAS_LAUT.ENABLED then
            startKurasLaut()
            StatusFrame.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
            StatusText.Text = "✅ ON - KURAS LAUT AKTIF!"
            StartBtn.Text = "🔥 SEDANG KURAS LAUT..."
            StartBtn.BackgroundColor3 = Color3.fromRGB(255, 165, 0)
        end
    end)
    
    StopBtn.MouseButton1Click:Connect(function()
        if KURAS_LAUT.ENABLED then
            stopKurasLaut()
            StatusFrame.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
            StatusText.Text = "🚫 OFF - KURAS LAUT"
            StartBtn.Text = "🚀 START KURAS LAUT"
            StartBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
        end
    end)
    
    SpeedPlus.MouseButton1Click:Connect(function()
        KURAS_LAUT.SPEED = math.min(1000, KURAS_LAUT.SPEED + 10)
        SpeedLabel.Text = "⚡ Speed: " .. KURAS_LAUT.SPEED .. " ikan/detik"
        print("⚡ Speed: " .. KURAS_LAUT.SPEED .. " ikan/detik")
    end)
    
    SpeedMinus.MouseButton1Click:Connect(function()
        KURAS_LAUT.SPEED = math.max(1, KURAS_LAUT.SPEED - 10)
        SpeedLabel.Text = "⚡ Speed: " .. KURAS_LAUT.SPEED .. " ikan/detik"
        print("⚡ Speed: " .. KURAS_LAUT.SPEED .. " ikan/detik")
    end)
    
    -- Close button
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Text = "X"
    CloseBtn.Size = UDim2.new(0, 30, 0, 30)
    CloseBtn.Position = UDim2.new(0.95, -35, 0, 5)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    CloseBtn.TextColor3 = Color3.new(1, 1, 1)
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.TextSize = 16
    CloseBtn.Parent = MainFrame
    
    CloseBtn.MouseButton1Click:Connect(function()
        stopKurasLaut()
        ScreenGui:Destroy()
    end)
    
    print("\n" .. string.rep("=", 50))
    print("⚡ KURAS LAUT GUI LOADED!")
    print("🎣 Tekan START untuk kuras laut!")
    print(string.rep("=", 50))
    
    return ScreenGui
end

-- VERSION SUPER KURAS (EXTREME)
local function startSuperKuras()
    print("\n" .. string.rep("🔥", 50))
    print("☢️ SUPER KURAS LAUT MODE!")
    print("💥 INSTANT 1000 IKAN/DETIK!")
    print(string.rep("🔥", 50))
    
    KURAS_LAUT.ENABLED = true
    KURAS_LAUT.SPEED = 1000
    KURAS_LAUT.MULTIPLIER = 100
    
    -- Setup remotes
    setupRemotes()
    
    -- AKTIFKAN SEMUA FITUR
    pcall(function() remotes.updateAutoFish:InvokeServer(true) end)
    
    if remotes.updateAutoSell then
        pcall(function() remotes.updateAutoSell:InvokeServer(100) end)
    end
    
    -- MASS FISHING LOOP
    spawn(function()
        local fishCount = 0
        local startTime = os.time()
        
        while KURAS_LAUT.ENABLED do
            -- MASS CATCH: 100 ikan sekaligus
            for i = 1, 100 do
                pcall(function()
                    remotes.fishCaught:FireServer({
                        fishType = "LEGENDARY_FISH",
                        weight = 999,
                        value = 9999,
                        perfect = true
                    })
                    remotes.fishingCompleted:FireServer()
                    fishCount = fishCount + 1
                end)
            end
            
            -- Update setiap 1000 ikan
            if fishCount % 1000 == 0 then
                local elapsed = os.time() - startTime
                local fishPerSecond = fishCount / elapsed
                print(string.format("🐟 %d ikan | ⚡ %.0f ikan/detik", fishCount, fishPerSecond))
                
                -- Effects
                pcall(function() remotes.playEffect:FireServer() end)
            end
            
            task.wait(0.01) -- SUPER FAST
        end
    end)
end

-- KEYBINDS
local UserInputService = game:GetService("UserInputService")
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.P then
        -- P = Start Kuras Laut
        if not KURAS_LAUT.ENABLED then
            startKurasLaut()
        end
    elseif input.KeyCode == Enum.KeyCode.O then
        -- O = Stop Kuras Laut
        if KURAS_LAUT.ENABLED then
            stopKurasLaut()
        end
    elseif input.KeyCode == Enum.KeyCode.L then
        -- L = Super Kuras Mode
        startSuperKuras()
    elseif input.KeyCode == Enum.KeyCode.G then
        -- G = Toggle GUI
        createKurasLautGUI()
    end
end)

-- AUTO START (OPTIONAL)
local function autoStartOnJoin()
    task.wait(5) -- Tunggu game load
    
    print("\n" .. string.rep("🎣", 50))
    print("KURAS LAUT SYSTEM READY!")
    print("Hotkeys:")
    print("  P = Start Kuras Laut")
    print("  O = Stop Kuras Laut")
    print("  L = Super Kuras Mode")
    print("  G = Toggle GUI")
    print(string.rep("🎣", 50))
    
    -- Auto create GUI
    createKurasLautGUI()
end

-- MAIN EXECUTION
if not game:IsLoaded() then
    game.Loaded:Wait()
end
task.wait(2)

setupRemotes()
autoStartOnJoin()

-- Export functions
getgenv().StartKurasLaut = startKurasLaut
getgenv().StopKurasLaut = stopKurasLaut
getgenv().SuperKuras = startSuperKuras

print("\n✅ KURAS LAUT SYSTEM LOADED!")
print("⚡ Type: StartKurasLaut() untuk mulai!")
