-- PetAnimationResearch.lua
-- ГЛУБОКОЕ ИССЛЕДОВАНИЕ: Как работают анимации у питомца

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

print("=== 🔬 PET ANIMATION RESEARCH ===")

-- Поиск питомца в руках
local function findPetInHands()
    local character = player.Character
    if not character then return nil end
    
    for _, tool in pairs(character:GetChildren()) do
        if tool:IsA("Tool") and string.find(tool.Name, "%[") and string.find(tool.Name, "KG%]") then
            return tool
        end
    end
    return nil
end

-- ПОЛНЫЙ анализ структуры питомца
local function analyzeStructure(obj, depth, path)
    local indent = string.rep("  ", depth)
    local fullPath = path == "" and obj.Name or (path .. "." .. obj.Name)
    
    print(indent .. "📁 " .. obj.Name .. " (" .. obj.ClassName .. ")")
    
    -- Детальный анализ для важных компонентов
    if obj:IsA("Animator") then
        print(indent .. "  🎭 ANIMATOR НАЙДЕН!")
        print(indent .. "     Parent: " .. tostring(obj.Parent))
        
        -- Ищем анимационные треки
        local tracks = obj:GetPlayingAnimationTracks()
        print(indent .. "     Активных треков: " .. #tracks)
        for i, track in pairs(tracks) do
            print(indent .. "       Track " .. i .. ": " .. tostring(track.Animation))
            print(indent .. "         IsPlaying: " .. tostring(track.IsPlaying))
            print(indent .. "         Length: " .. tostring(track.Length))
            print(indent .. "         Speed: " .. tostring(track.Speed))
        end
    end
    
    if obj:IsA("Motor6D") then
        print(indent .. "  ⚙️ MOTOR6D: " .. obj.Name)
        print(indent .. "     Part0: " .. tostring(obj.Part0))
        print(indent .. "     Part1: " .. tostring(obj.Part1))
        print(indent .. "     C0: " .. tostring(obj.C0))
        print(indent .. "     C1: " .. tostring(obj.C1))
        print(indent .. "     CurrentAngle: " .. tostring(obj.CurrentAngle))
        print(indent .. "     DesiredAngle: " .. tostring(obj.DesiredAngle))
    end
    
    if obj:IsA("BasePart") then
        print(indent .. "  🧱 PART: " .. obj.Name)
        print(indent .. "     CFrame: " .. tostring(obj.CFrame))
        print(indent .. "     Anchored: " .. tostring(obj.Anchored))
        print(indent .. "     CanCollide: " .. tostring(obj.CanCollide))
        print(indent .. "     AssemblyRootPart: " .. tostring(obj.AssemblyRootPart))
    end
    
    if obj:IsA("LocalScript") or obj:IsA("Script") then
        print(indent .. "  📜 SCRIPT: " .. obj.Name)
        print(indent .. "     Enabled: " .. tostring(obj.Enabled))
        print(indent .. "     Disabled: " .. tostring(obj.Disabled))
        print(indent .. "     RunContext: " .. tostring(obj.RunContext or "N/A"))
    end
    
    if obj:IsA("Animation") then
        print(indent .. "  🎬 ANIMATION: " .. obj.Name)
        print(indent .. "     AnimationId: " .. tostring(obj.AnimationId))
    end
    
    if obj:IsA("Weld") then
        print(indent .. "  🔗 WELD: " .. obj.Name)
        print(indent .. "     Part0: " .. tostring(obj.Part0))
        print(indent .. "     Part1: " .. tostring(obj.Part1))
        print(indent .. "     C0: " .. tostring(obj.C0))
        print(indent .. "     C1: " .. tostring(obj.C1))
    end
    
    -- Рекурсивно анализируем детей
    for _, child in pairs(obj:GetChildren()) do
        analyzeStructure(child, depth + 1, fullPath)
    end
end

-- Мониторинг изменений в реальном времени
local function startRealTimeMonitoring(pet)
    print("\n🔄 === МОНИТОРИНГ В РЕАЛЬНОМ ВРЕМЕНИ ===")
    
    local connection
    local frameCount = 0
    local maxFrames = 300 -- 5 секунд при 60 FPS
    
    connection = RunService.Heartbeat:Connect(function()
        frameCount = frameCount + 1
        
        if frameCount % 30 == 0 then -- Каждые 0.5 секунды
            print("\n⏱️ Кадр " .. frameCount .. " (+" .. (frameCount/60) .. "s)")
            
            -- Мониторим Animator
            local animator = pet:FindFirstChildOfClass("Animator")
            if animator then
                local tracks = animator:GetPlayingAnimationTracks()
                print("🎭 Активных треков: " .. #tracks)
                for i, track in pairs(tracks) do
                    print("   Track " .. i .. ": Playing=" .. tostring(track.IsPlaying) .. ", Time=" .. tostring(track.TimePosition))
                end
            else
                print("❌ Animator не найден!")
            end
            
            -- Мониторим Motor6D
            for _, motor in pairs(pet:GetDescendants()) do
                if motor:IsA("Motor6D") then
                    print("⚙️ " .. motor.Name .. ": C0=" .. tostring(motor.C0))
                end
            end
            
            -- Мониторим BasePart позиции
            local handle = pet:FindFirstChild("Handle")
            if handle then
                print("🧱 Handle CFrame: " .. tostring(handle.CFrame))
            end
        end
        
        if frameCount >= maxFrames then
            connection:Disconnect()
            print("\n✅ Мониторинг завершен!")
        end
    end)
    
    print("🔄 Мониторинг запущен на 5 секунд...")
end

-- Анализ анимационных скриптов
local function analyzeAnimationScripts(pet)
    print("\n📜 === АНАЛИЗ АНИМАЦИОННЫХ СКРИПТОВ ===")
    
    for _, obj in pairs(pet:GetDescendants()) do
        if obj:IsA("LocalScript") or obj:IsA("Script") then
            print("📜 Скрипт: " .. obj.Name)
            print("   Parent: " .. tostring(obj.Parent))
            print("   Enabled: " .. tostring(obj.Enabled))
            print("   Source доступен: " .. tostring(obj.Source ~= nil))
            
            -- Пытаемся найти ключевые слова в скрипте
            if obj.Source then
                local source = obj.Source
                if string.find(source, "Animator") then
                    print("   🎭 Содержит Animator код!")
                end
                if string.find(source, "Motor6D") then
                    print("   ⚙️ Содержит Motor6D код!")
                end
                if string.find(source, "TweenService") then
                    print("   🔄 Содержит TweenService код!")
                end
                if string.find(source, "RunService") then
                    print("   ⏱️ Содержит RunService код!")
                end
            end
        end
    end
end

-- Основная функция исследования
local function researchPetAnimations()
    print("\n🔬 === НАЧИНАЮ ИССЛЕДОВАНИЕ ===")
    
    local pet = findPetInHands()
    if not pet then
        print("❌ Питомец в руках не найден!")
        print("📋 Возьмите питомца в руки и запустите исследование")
        return false
    end
    
    print("✅ Исследую питомца: " .. pet.Name)
    print("🔍 Анализирую структуру...")
    
    -- 1. Полный анализ структуры
    print("\n📊 === СТРУКТУРА ПИТОМЦА ===")
    analyzeStructure(pet, 0, "")
    
    -- 2. Анализ скриптов
    analyzeAnimationScripts(pet)
    
    -- 3. Поиск ключевых компонентов
    print("\n🔍 === ПОИСК КЛЮЧЕВЫХ КОМПОНЕНТОВ ===")
    
    local animator = pet:FindFirstChildOfClass("Animator")
    if animator then
        print("✅ Animator найден: " .. tostring(animator))
        print("   Parent: " .. tostring(animator.Parent))
    else
        print("❌ Animator НЕ найден!")
    end
    
    local motors = {}
    for _, obj in pairs(pet:GetDescendants()) do
        if obj:IsA("Motor6D") then
            table.insert(motors, obj)
        end
    end
    print("⚙️ Motor6D найдено: " .. #motors)
    
    local scripts = {}
    for _, obj in pairs(pet:GetDescendants()) do
        if obj:IsA("LocalScript") or obj:IsA("Script") then
            table.insert(scripts, obj)
        end
    end
    print("📜 Скриптов найдено: " .. #scripts)
    
    -- 4. Запуск мониторинга в реальном времени
    print("\n🔄 Запускаю мониторинг анимаций...")
    startRealTimeMonitoring(pet)
    
    return true
end

-- Создаем GUI для исследования
local function createResearchGUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "PetResearchGUI"
    screenGui.Parent = player:WaitForChild("PlayerGui")
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 300, 0, 180)
    frame.Position = UDim2.new(0.5, -150, 0.5, -90)
    frame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
    frame.BorderSizePixel = 2
    frame.BorderColor3 = Color3.new(0.3, 0.3, 0.3)
    frame.Parent = screenGui
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundColor3 = Color3.new(0.2, 0.4, 0.8)
    title.BorderSizePixel = 0
    title.Text = "🔬 PET ANIMATION RESEARCH"
    title.TextColor3 = Color3.new(1, 1, 1)
    title.TextScaled = true
    title.Font = Enum.Font.SourceSansBold
    title.Parent = frame
    
    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(1, -20, 0, 60)
    status.Position = UDim2.new(0, 10, 0, 50)
    status.BackgroundTransparency = 1
    status.Text = "ИССЛЕДОВАНИЕ АНИМАЦИЙ:\nВозьмите питомца в руки\nи нажмите 'Исследовать'"
    status.TextColor3 = Color3.new(1, 1, 1)
    status.TextScaled = true
    status.Font = Enum.Font.SourceSans
    status.TextWrapped = true
    status.Parent = frame
    
    -- Кнопка исследования
    local researchBtn = Instance.new("TextButton")
    researchBtn.Size = UDim2.new(1, -20, 0, 50)
    researchBtn.Position = UDim2.new(0, 10, 0, 120)
    researchBtn.BackgroundColor3 = Color3.new(0.2, 0.6, 0.8)
    researchBtn.BorderSizePixel = 0
    researchBtn.Text = "🔬 ИССЛЕДОВАТЬ анимации"
    researchBtn.TextColor3 = Color3.new(1, 1, 1)
    researchBtn.TextScaled = true
    researchBtn.Font = Enum.Font.SourceSansBold
    researchBtn.Parent = frame
    
    -- Событие исследования
    researchBtn.MouseButton1Click:Connect(function()
        status.Text = "🔬 Исследую анимации питомца..."
        status.TextColor3 = Color3.new(1, 1, 0)
        
        local success = researchPetAnimations()
        
        if success then
            status.Text = "✅ Исследование завершено!\nСмотрите консоль для деталей"
            status.TextColor3 = Color3.new(0, 1, 0)
        else
            status.Text = "❌ Ошибка!\nВозьмите питомца в руки!"
            status.TextColor3 = Color3.new(1, 0, 0)
        end
    end)
end

-- Дополнительная функция: Сравнение оригинала и копии
local function compareOriginalAndCopy()
    print("\n🔄 === СОЗДАНИЕ КОПИИ ДЛЯ СРАВНЕНИЯ ===")
    
    local pet = findPetInHands()
    if not pet then
        print("❌ Питомец не найден!")
        return
    end
    
    -- Создаем копию питомца
    local petCopy = pet:Clone()
    petCopy.Name = pet.Name .. "_COPY"
    petCopy.Parent = game.Workspace
    
    print("✅ Копия создана: " .. petCopy.Name)
    
    -- Сравниваем Animator
    local origAnimator = pet:FindFirstChildOfClass("Animator")
    local copyAnimator = petCopy:FindFirstChildOfClass("Animator")
    
    print("\n🎭 === СРАВНЕНИЕ ANIMATOR ===")
    print("Оригинал Animator: " .. tostring(origAnimator))
    print("Копия Animator: " .. tostring(copyAnimator))
    
    if origAnimator and copyAnimator then
        local origTracks = origAnimator:GetPlayingAnimationTracks()
        local copyTracks = copyAnimator:GetPlayingAnimationTracks()
        
        print("Оригинал треков: " .. #origTracks)
        print("Копия треков: " .. #copyTracks)
        
        -- Пытаемся запустить анимации на копии
        print("\n🎬 Пытаюсь запустить анимации на копии...")
        for _, track in pairs(origTracks) do
            local copyTrack = copyAnimator:LoadAnimation(track.Animation)
            copyTrack:Play()
            print("▶️ Запущен трек на копии: " .. tostring(track.Animation))
        end
    end
    
    -- Мониторим обе версии
    print("\n📊 === МОНИТОРИНГ ОРИГИНАЛА И КОПИИ ===")
    
    local monitorConnection
    local monitorFrames = 0
    
    monitorConnection = RunService.Heartbeat:Connect(function()
        monitorFrames = monitorFrames + 1
        
        if monitorFrames % 60 == 0 then -- Каждую секунду
            print("\n⏱️ Секунда " .. (monitorFrames/60))
            
            -- Сравниваем состояние
            if origAnimator and copyAnimator then
                local origActive = #origAnimator:GetPlayingAnimationTracks()
                local copyActive = #copyAnimator:GetPlayingAnimationTracks()
                
                print("🎭 Оригинал активных треков: " .. origActive)
                print("🎭 Копия активных треков: " .. copyActive)
            end
            
            -- Сравниваем позиции Handle
            local origHandle = pet:FindFirstChild("Handle")
            local copyHandle = petCopy:FindFirstChild("Handle")
            
            if origHandle and copyHandle then
                print("🧱 Оригинал Handle: " .. tostring(origHandle.CFrame))
                print("🧱 Копия Handle: " .. tostring(copyHandle.CFrame))
            end
        end
        
        if monitorFrames >= 300 then -- 5 секунд
            monitorConnection:Disconnect()
            print("\n✅ Сравнительный мониторинг завершен!")
            
            -- Удаляем копию
            petCopy:Destroy()
            print("🗑️ Копия удалена")
        end
    end)
end

-- Создаем расширенный GUI
local function createAdvancedResearchGUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "AdvancedPetResearchGUI"
    screenGui.Parent = player:WaitForChild("PlayerGui")
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 320, 0, 250)
    frame.Position = UDim2.new(0.5, -160, 0.5, -125)
    frame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
    frame.BorderSizePixel = 2
    frame.BorderColor3 = Color3.new(0.3, 0.3, 0.3)
    frame.Parent = screenGui
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundColor3 = Color3.new(0.2, 0.4, 0.8)
    title.BorderSizePixel = 0
    title.Text = "🔬 ADVANCED PET RESEARCH"
    title.TextColor3 = Color3.new(1, 1, 1)
    title.TextScaled = true
    title.Font = Enum.Font.SourceSansBold
    title.Parent = frame
    
    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(1, -20, 0, 50)
    status.Position = UDim2.new(0, 10, 0, 50)
    status.BackgroundTransparency = 1
    status.Text = "Возьмите питомца в руки\nи выберите тип исследования"
    status.TextColor3 = Color3.new(1, 1, 1)
    status.TextScaled = true
    status.Font = Enum.Font.SourceSans
    status.TextWrapped = true
    status.Parent = frame
    
    -- Кнопка структурного анализа
    local structBtn = Instance.new("TextButton")
    structBtn.Size = UDim2.new(1, -20, 0, 40)
    structBtn.Position = UDim2.new(0, 10, 0, 110)
    structBtn.BackgroundColor3 = Color3.new(0.2, 0.6, 0.8)
    structBtn.BorderSizePixel = 0
    structBtn.Text = "📊 АНАЛИЗ СТРУКТУРЫ"
    structBtn.TextColor3 = Color3.new(1, 1, 1)
    structBtn.TextScaled = true
    structBtn.Font = Enum.Font.SourceSansBold
    structBtn.Parent = frame
    
    -- Кнопка мониторинга
    local monitorBtn = Instance.new("TextButton")
    monitorBtn.Size = UDim2.new(1, -20, 0, 40)
    monitorBtn.Position = UDim2.new(0, 10, 0, 160)
    monitorBtn.BackgroundColor3 = Color3.new(0.6, 0.2, 0.8)
    monitorBtn.BorderSizePixel = 0
    monitorBtn.Text = "🔄 МОНИТОРИНГ АНИМАЦИЙ"
    monitorBtn.TextColor3 = Color3.new(1, 1, 1)
    monitorBtn.TextScaled = true
    monitorBtn.Font = Enum.Font.SourceSansBold
    monitorBtn.Parent = frame
    
    -- Кнопка сравнения
    local compareBtn = Instance.new("TextButton")
    compareBtn.Size = UDim2.new(1, -20, 0, 40)
    compareBtn.Position = UDim2.new(0, 10, 0, 210)
    compareBtn.BackgroundColor3 = Color3.new(0.8, 0.6, 0.2)
    compareBtn.BorderSizePixel = 0
    compareBtn.Text = "⚖️ СРАВНИТЬ ОРИГИНАЛ/КОПИЮ"
    compareBtn.TextColor3 = Color3.new(1, 1, 1)
    compareBtn.TextScaled = true
    compareBtn.Font = Enum.Font.SourceSansBold
    compareBtn.Parent = frame
    
    -- События
    structBtn.MouseButton1Click:Connect(function()
        status.Text = "📊 Анализирую структуру..."
        status.TextColor3 = Color3.new(1, 1, 0)
        
        local success = researchPetAnimations()
        
        if success then
            status.Text = "✅ Анализ завершен!\nСмотрите консоль"
            status.TextColor3 = Color3.new(0, 1, 0)
        else
            status.Text = "❌ Возьмите питомца в руки!"
            status.TextColor3 = Color3.new(1, 0, 0)
        end
    end)
    
    monitorBtn.MouseButton1Click:Connect(function()
        status.Text = "🔄 Мониторинг 5 секунд..."
        status.TextColor3 = Color3.new(1, 1, 0)
        
        local pet = findPetInHands()
        if pet then
            startRealTimeMonitoring(pet)
            status.Text = "✅ Мониторинг запущен!\nСмотрите консоль"
            status.TextColor3 = Color3.new(0, 1, 0)
        else
            status.Text = "❌ Возьмите питомца в руки!"
            status.TextColor3 = Color3.new(1, 0, 0)
        end
    end)
    
    compareBtn.MouseButton1Click:Connect(function()
        status.Text = "⚖️ Создаю копию и сравниваю..."
        status.TextColor3 = Color3.new(1, 1, 0)
        
        compareOriginalAndCopy()
        status.Text = "✅ Сравнение запущено!\nСмотрите консоль"
        status.TextColor3 = Color3.new(0, 1, 0)
    end)
end

-- Запускаем исследование
createAdvancedResearchGUI()
print("✅ Pet Animation Research готов!")
print("🔬 ГЛУБОКОЕ ИССЛЕДОВАНИЕ АНИМАЦИЙ!")
print("📋 Возьмите питомца в руки и начните исследование")
