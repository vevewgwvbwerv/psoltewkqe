-- 🎯 ФИНАЛЬНЫЙ ПРОЕКТ - GUI ДЛЯ ВСЕХ ИНСТРУМЕНТОВ
-- Все инструменты для поиска и фиксации магического idle момента

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer

-- 🔍 ПОИСК ПИТОМЦА (общая функция)
local function findPet()
    local character = player.Character
    if not character then return nil end
    
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return nil end
    
    local playerPosition = humanoidRootPart.Position
    
    for _, model in pairs(Workspace:GetChildren()) do
        if model:IsA("Model") and model.Name:match("%x%x%x%x%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%x%x%x%x%x%x%x%x") then
            local petRootPart = model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("Torso")
            if petRootPart then
                local distance = (petRootPart.Position - playerPosition).Magnitude
                if distance <= 100 then
                    return model
                end
            end
        end
    end
    return nil
end

-- 🎯 ПРОВЕРКА НА МАГИЧЕСКИЙ МОМЕНТ
local function isMagicalIdleMoment(petModel)
    local humanoid = petModel:FindFirstChildOfClass("Humanoid")
    
    -- Условие 1: Нет движения
    local noMovement = true
    if humanoid then
        noMovement = humanoid.MoveDirection.Magnitude < 0.01
    end
    
    -- Условие 2: Есть только idle анимации
    local hasOnlyIdleAnimation = false
    local animationCount = 0
    
    for _, obj in pairs(petModel:GetDescendants()) do
        if obj:IsA("Animator") then
            local tracks = obj:GetPlayingAnimationTracks()
            animationCount = #tracks
            
            if animationCount > 0 then
                hasOnlyIdleAnimation = true
                for _, track in pairs(tracks) do
                    local name = track.Animation.Name:lower()
                    local id = track.Animation.AnimationId:lower()
                    
                    if not name:find("idle") and not id:find("1073293904134356") then
                        hasOnlyIdleAnimation = false
                        break
                    end
                end
            end
            break
        end
    end
    
    return noMovement and hasOnlyIdleAnimation and animationCount > 0
end

-- 📊 ЗАПИСЬ МАГИЧЕСКИХ ПОЗ
local function recordMagicalPoses(petModel, duration)
    print("🎬 Записываю МАГИЧЕСКИЕ idle позы...")
    
    local motor6Ds = {}
    for _, obj in pairs(petModel:GetDescendants()) do
        if obj:IsA("Motor6D") then
            table.insert(motor6Ds, obj)
        end
    end
    
    if #motor6Ds == 0 then
        print("❌ Motor6D не найдены!")
        return nil
    end
    
    local poses = {}
    local frameCount = 0
    local targetFrames = duration * 60
    
    local recordConnection
    recordConnection = RunService.Heartbeat:Connect(function()
        frameCount = frameCount + 1
        
        local framePoses = {}
        for _, motor in pairs(motor6Ds) do
            framePoses[motor.Name] = {
                C0 = motor.C0,
                C1 = motor.C1,
                Transform = motor.Transform
            }
        end
        
        table.insert(poses, framePoses)
        
        if frameCount >= targetFrames then
            recordConnection:Disconnect()
        end
    end)
    
    while frameCount < targetFrames and recordConnection.Connected do
        wait(0.1)
    end
    
    print(string.format("✅ Записано %d магических idle поз!", #poses))
    return poses, motor6Ds
end

-- 🔒 ФИКСАЦИЯ В МАГИЧЕСКОМ СОСТОЯНИИ
local function lockInMagicalIdle(petModel, magicalPoses, motor6Ds)
    print("🔒 Фиксирую питомца в МАГИЧЕСКОМ idle состоянии...")
    
    local humanoid = petModel:FindFirstChildOfClass("Humanoid")
    local rootPart = petModel:FindFirstChild("HumanoidRootPart") or petModel:FindFirstChild("Torso")
    local originalPosition = rootPart and rootPart.Position or Vector3.new(0, 0, 0)
    
    local currentFrame = 1
    local frameRate = 60
    local frameInterval = 1 / frameRate
    local lastFrameTime = tick()
    
    local lockConnection
    lockConnection = RunService.Heartbeat:Connect(function()
        local now = tick()
        
        -- УЛЬТРА-АГРЕССИВНАЯ блокировка
        if humanoid then
            humanoid.WalkSpeed = 0
            humanoid.JumpPower = 0
            humanoid.PlatformStand = true
        end
        
        if rootPart then
            rootPart.Anchored = true
            if (rootPart.Position - originalPosition).Magnitude > 0.05 then
                rootPart.Position = originalPosition
                rootPart.Velocity = Vector3.new(0, 0, 0)
                rootPart.AngularVelocity = Vector3.new(0, 0, 0)
            end
        end
        
        -- Уничтожение НЕ-idle анимаций
        for _, obj in pairs(petModel:GetDescendants()) do
            if obj:IsA("Animator") then
                local tracks = obj:GetPlayingAnimationTracks()
                for _, track in pairs(tracks) do
                    local name = track.Animation.Name:lower()
                    local id = track.Animation.AnimationId:lower()
                    
                    if not name:find("idle") and not id:find("1073293904134356") then
                        track:Stop()
                        track:Destroy()
                    end
                end
            end
        end
        
        -- Применение магических поз
        if now - lastFrameTime >= frameInterval then
            lastFrameTime = now
            
            local framePoses = magicalPoses[currentFrame]
            if framePoses then
                for _, motor in pairs(motor6Ds) do
                    local pose = framePoses[motor.Name]
                    if pose then
                        pcall(function()
                            motor.C0 = pose.C0
                            motor.C1 = pose.C1
                            motor.Transform = pose.Transform
                        end)
                    end
                end
            end
            
            currentFrame = currentFrame + 1
            if currentFrame > #magicalPoses then
                currentFrame = 1
            end
        end
    end)
    
    return lockConnection
end

-- 🎯 МГНОВЕННАЯ ФИКСАЦИЯ (если питомец УЖЕ в idle)
local function instantMagicalFix()
    local petModel = findPet()
    if not petModel then
        print("❌ Питомец не найден!")
        return
    end
    
    if isMagicalIdleMoment(petModel) then
        print("🌟 Питомец УЖЕ в магическом idle! Фиксирую...")
        
        local magicalPoses, motor6Ds = recordMagicalPoses(petModel, 3)
        if magicalPoses then
            local connection = lockInMagicalIdle(petModel, magicalPoses, motor6Ds)
            print("🎉 УСПЕХ! Питомец зафиксирован в магическом idle!")
            
            spawn(function()
                wait(300)
                connection:Disconnect()
                print("⏹️ Фиксация остановлена через 5 минут")
            end)
        end
    else
        print("❌ Питомец НЕ в idle состоянии!")
        print("💡 Дождись когда питомец встанет и попробуй снова")
    end
end

-- 🔍 АВТОМАТИЧЕСКИЙ ЛОВЕЦ
local function autoMagicalCatcher()
    local petModel = findPet()
    if not petModel then
        print("❌ Питомец не найден!")
        return
    end
    
    print("🔍 Автоматический поиск магического момента...")
    print("⏰ Максимальное время: 60 секунд")
    
    local searchStartTime = tick()
    local lastCheckTime = 0
    
    local searchConnection
    searchConnection = RunService.Heartbeat:Connect(function()
        local now = tick()
        
        if now - lastCheckTime >= 0.1 then
            lastCheckTime = now
            
            if isMagicalIdleMoment(petModel) then
                print("🌟 МАГИЧЕСКИЙ МОМЕНТ ПОЙМАН!")
                searchConnection:Disconnect()
                
                local magicalPoses, motor6Ds = recordMagicalPoses(petModel, 3)
                if magicalPoses then
                    local connection = lockInMagicalIdle(petModel, magicalPoses, motor6Ds)
                    print("🎉 Питомец зафиксирован в магическом idle!")
                    
                    spawn(function()
                        wait(300)
                        connection:Disconnect()
                        print("⏹️ Фиксация остановлена")
                    end)
                end
                return
            end
            
            if now - searchStartTime >= 60 then
                searchConnection:Disconnect()
                print("⏰ Время поиска истекло!")
            end
        end
    end)
end

-- 📊 ДЕТАЛЬНЫЙ АНАЛИЗ
local function detailedAnalysis()
    local petModel = findPet()
    if not petModel then
        print("❌ Питомец не найден!")
        return
    end
    
    print("📊 Детальный анализ состояния питомца...")
    
    local logCount = 0
    local connection = RunService.Heartbeat:Connect(function()
        if tick() % 1 < 0.016 then -- каждую секунду
            logCount = logCount + 1
            
            local humanoid = petModel:FindFirstChildOfClass("Humanoid")
            local trackCount = 0
            local idleTracks = 0
            
            for _, obj in pairs(petModel:GetDescendants()) do
                if obj:IsA("Animator") then
                    local tracks = obj:GetPlayingAnimationTracks()
                    trackCount = #tracks
                    
                    for _, track in pairs(tracks) do
                        local name = track.Animation.Name:lower()
                        local id = track.Animation.AnimationId:lower()
                        if name:find("idle") or id:find("1073293904134356") then
                            idleTracks = idleTracks + 1
                        end
                    end
                    break
                end
            end
            
            local moveSpeed = humanoid and humanoid.MoveDirection.Magnitude or 0
            local isMagical = isMagicalIdleMoment(petModel)
            
            print(string.format("📊 #%d | Треков: %d (idle: %d) | Движение: %.3f | Магический: %s", 
                logCount, trackCount, idleTracks, moveSpeed, isMagical and "✨ ДА" or "❌ НЕТ"))
            
            if logCount >= 30 then -- 30 секунд
                connection:Disconnect()
                print("📊 Анализ завершен")
            end
        end
    end)
end

-- 🖥️ СОЗДАНИЕ GUI
local function createFinalGUI()
    local playerGui = player:WaitForChild("PlayerGui")
    
    -- Удаляем старый GUI если есть
    local existingGui = playerGui:FindFirstChild("FinalProjectGUI")
    if existingGui then
        existingGui:Destroy()
    end
    
    -- Основной фрейм
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "FinalProjectGUI"
    screenGui.Parent = playerGui
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 350, 0, 400)
    mainFrame.Position = UDim2.new(0, 10, 0, 10)
    mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui
    
    -- Заголовок
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    title.BorderSizePixel = 0
    title.Text = "🎯 FINAL PROJECT - Магический Idle"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 16
    title.Font = Enum.Font.SourceSansBold
    title.Parent = mainFrame
    
    -- Функция создания кнопки
    local function createButton(text, position, color, callback)
        local button = Instance.new("TextButton")
        button.Size = UDim2.new(1, -20, 0, 50)
        button.Position = position
        button.BackgroundColor3 = color
        button.BorderSizePixel = 0
        button.Text = text
        button.TextColor3 = Color3.fromRGB(255, 255, 255)
        button.TextSize = 14
        button.Font = Enum.Font.SourceSansBold
        button.Parent = mainFrame
        
        button.MouseButton1Click:Connect(function()
            local originalText = button.Text
            local originalColor = button.BackgroundColor3
            
            button.Text = "⏳ Выполняется..."
            button.BackgroundColor3 = Color3.fromRGB(255, 165, 0)
            
            spawn(function()
                callback()
                wait(2)
                button.Text = originalText
                button.BackgroundColor3 = originalColor
            end)
        end)
        
        return button
    end
    
    -- Кнопки
    createButton("🌟 Мгновенная фиксация (если УЖЕ idle)", 
        UDim2.new(0, 10, 0, 60), 
        Color3.fromRGB(255, 0, 255), 
        instantMagicalFix)
    
    createButton("🔍 Автоматический ловец (60 сек)", 
        UDim2.new(0, 10, 0, 120), 
        Color3.fromRGB(0, 255, 0), 
        autoMagicalCatcher)
    
    createButton("📊 Детальный анализ (30 сек)", 
        UDim2.new(0, 10, 0, 180), 
        Color3.fromRGB(0, 150, 255), 
        detailedAnalysis)
    
    -- Информационная панель
    local infoLabel = Instance.new("TextLabel")
    infoLabel.Size = UDim2.new(1, -20, 0, 150)
    infoLabel.Position = UDim2.new(0, 10, 0, 240)
    infoLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    infoLabel.BorderSizePixel = 0
    infoLabel.Text = [[💡 ИНСТРУКЦИЯ:

🌟 Мгновенная фиксация:
   Используй когда питомец УЖЕ стоит в idle

🔍 Автоматический ловец:
   Ждет пока питомец войдет в idle и фиксирует

📊 Детальный анализ:
   Показывает состояние питомца в реальном времени]]
    infoLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    infoLabel.TextSize = 12
    infoLabel.Font = Enum.Font.SourceSans
    infoLabel.TextYAlignment = Enum.TextYAlignment.Top
    infoLabel.TextXAlignment = Enum.TextXAlignment.Left
    infoLabel.Parent = mainFrame
    
    print("🖥️ Final Project GUI создан!")
end

-- 🚀 ЗАПУСК
print("\n🎯 === FINAL PROJECT - МАГИЧЕСКИЙ IDLE ===")
print("✨ Все инструменты для поиска и фиксации магического момента!")
print("🖥️ GUI будет создан через 2 секунды...")

spawn(function()
    wait(2)
    createFinalGUI()
end)
