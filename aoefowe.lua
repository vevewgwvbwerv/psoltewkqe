-- 🔍 ГЛУБОКАЯ ДИАГНОСТИКА АНИМАЦИИ ПИТОМЦА В РУКЕ
-- Ищем ВСЕ возможные источники анимации: Animator, TweenService, Scripts, CFrame изменения

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

print("🔍 === ГЛУБОКАЯ ДИАГНОСТИКА АНИМАЦИИ ПИТОМЦА В РУКЕ ===")

-- 📊 Глобальные переменные для отслеживания
local handPetTool = nil
local animationData = {
    animators = {},
    animationTracks = {},
    tweens = {},
    scripts = {},
    motor6ds = {},
    cframes = {},
    lastUpdate = 0
}

-- 🔍 Функция поиска питомца в руке (из PetScaler)
local function findHandPetTool()
    if not character then return nil end
    
    for _, tool in pairs(character:GetChildren()) do
        if tool:IsA("Tool") and string.find(tool.Name, "%[") and string.find(tool.Name, "KG%]") then
            print("🎒 Найден Tool:", tool.Name)
            return tool
        end
    end
    return nil
end

-- 🎭 Глубокий анализ Animator и AnimationTracks
local function analyzeAnimators(model)
    print("\n🎭 === АНАЛИЗ ANIMATOR И ANIMATIONTRACKS ===")
    
    for _, obj in pairs(model:GetDescendants()) do
        if obj:IsA("Animator") then
            table.insert(animationData.animators, obj)
            print("✅ Найден Animator:", obj:GetFullName())
            
            -- Проверяем активные AnimationTracks
            local tracks = obj:GetPlayingAnimationTracks()
            for _, track in pairs(tracks) do
                table.insert(animationData.animationTracks, track)
                print(string.format("🎬 AnimationTrack: %s | Looped=%s | Speed=%.2f | Weight=%.2f", 
                    track.Animation and track.Animation.Name or "Unknown",
                    tostring(track.Looped),
                    track.Speed,
                    track.WeightCurrent))
            end
        elseif obj:IsA("Humanoid") then
            print("👤 Найден Humanoid:", obj:GetFullName())
            print("   WalkSpeed:", obj.WalkSpeed, "JumpPower:", obj.JumpPower)
            
            -- Проверяем Animator в Humanoid
            local animator = obj:FindFirstChild("Animator")
            if animator then
                print("   📽️ Animator в Humanoid найден")
                local tracks = animator:GetPlayingAnimationTracks()
                for _, track in pairs(tracks) do
                    print(string.format("   🎬 Track: %s | Looped=%s", 
                        track.Animation and track.Animation.Name or "Unknown",
                        tostring(track.Looped)))
                end
            end
        end
    end
end

-- 🔧 Анализ всех скриптов в модели
local function analyzeScripts(model)
    print("\n🔧 === АНАЛИЗ СКРИПТОВ ===")
    
    for _, obj in pairs(model:GetDescendants()) do
        if obj:IsA("LocalScript") or obj:IsA("Script") or obj:IsA("ModuleScript") then
            table.insert(animationData.scripts, obj)
            print(string.format("📜 %s: %s | Enabled=%s", 
                obj.ClassName, obj:GetFullName(), tostring(obj.Enabled or "N/A")))
        end
    end
end

-- ⚙️ Анализ Motor6D и их изменений
local function analyzeMotor6Ds(model)
    print("\n⚙️ === АНАЛИЗ MOTOR6D ===")
    
    animationData.motor6ds = {}
    for _, obj in pairs(model:GetDescendants()) do
        if obj:IsA("Motor6D") then
            animationData.motor6ds[obj.Name] = {
                motor = obj,
                lastC0 = obj.C0,
                lastC1 = obj.C1,
                changeCount = 0
            }
            print(string.format("🔗 Motor6D: %s | Part0=%s | Part1=%s", 
                obj.Name,
                obj.Part0 and obj.Part0.Name or "NIL",
                obj.Part1 and obj.Part1.Name or "NIL"))
        end
    end
end

-- 📐 Анализ CFrame изменений частей
local function analyzeCFrames(model)
    print("\n📐 === АНАЛИЗ CFRAME ИЗМЕНЕНИЙ ===")
    
    animationData.cframes = {}
    for _, obj in pairs(model:GetDescendants()) do
        if obj:IsA("BasePart") then
            animationData.cframes[obj.Name] = {
                part = obj,
                lastCFrame = obj.CFrame,
                changeCount = 0
            }
        end
    end
    print("📊 Отслеживаем CFrame для", #animationData.cframes, "частей")
end

-- 🎯 Мониторинг изменений в реальном времени
local function monitorChanges()
    local currentTime = tick()
    local changesDetected = {
        motor6d = 0,
        cframe = 0,
        total = 0
    }
    
    -- Проверяем Motor6D изменения
    for name, data in pairs(animationData.motor6ds) do
        if data.motor and data.motor.Parent then
            local currentC0 = data.motor.C0
            local currentC1 = data.motor.C1
            
            local c0Diff = (currentC0.Position - data.lastC0.Position).Magnitude
            local c1Diff = (currentC1.Position - data.lastC1.Position).Magnitude
            
            if c0Diff > 0.001 or c1Diff > 0.001 then
                data.changeCount = data.changeCount + 1
                data.lastC0 = currentC0
                data.lastC1 = currentC1
                changesDetected.motor6d = changesDetected.motor6d + 1
            end
        end
    end
    
    -- Проверяем CFrame изменения
    for name, data in pairs(animationData.cframes) do
        if data.part and data.part.Parent then
            local currentCFrame = data.part.CFrame
            local positionDiff = (currentCFrame.Position - data.lastCFrame.Position).Magnitude
            local rotationDiff = math.abs(currentCFrame.LookVector:Dot(data.lastCFrame.LookVector) - 1)
            
            if positionDiff > 0.001 or rotationDiff > 0.001 then
                data.changeCount = data.changeCount + 1
                data.lastCFrame = currentCFrame
                changesDetected.cframe = changesDetected.cframe + 1
            end
        end
    end
    
    changesDetected.total = changesDetected.motor6d + changesDetected.cframe
    
    -- Отчет каждые 3 секунды
    if math.floor(currentTime) % 3 == 0 and math.floor(currentTime * 10) % 10 == 0 then
        print(string.format("\n📊 МОНИТОРИНГ ИЗМЕНЕНИЙ (%.1f сек):", currentTime - animationData.lastUpdate))
        print(string.format("   ⚙️ Motor6D изменений: %d", changesDetected.motor6d))
        print(string.format("   📐 CFrame изменений: %d", changesDetected.cframe))
        print(string.format("   🎯 Всего изменений: %d", changesDetected.total))
        
        if changesDetected.total > 0 then
            print("✅ АНИМАЦИЯ ОБНАРУЖЕНА!")
        else
            print("⚠️ АНИМАЦИЯ НЕ ОБНАРУЖЕНА")
        end
        
        animationData.lastUpdate = currentTime
    end
end

-- 🚀 Основной цикл диагностики
local function startDiagnostic()
    print("🚀 Запуск глубокой диагностики...")
    
    local connection
    connection = RunService.Heartbeat:Connect(function()
        -- Ищем питомца в руке
        local currentTool = findHandPetTool()
        
        if currentTool and currentTool ~= handPetTool then
            handPetTool = currentTool
            print("\n🎒 === НОВЫЙ ПИТОМЕЦ В РУКЕ ОБНАРУЖЕН ===")
            print("Tool:", handPetTool.Name)
            
            -- Полный анализ модели
            analyzeAnimators(handPetTool)
            analyzeScripts(handPetTool)
            analyzeMotor6Ds(handPetTool)
            analyzeCFrames(handPetTool)
            
            print("\n🔄 Начинаем мониторинг изменений...")
        end
        
        if handPetTool then
            monitorChanges()
        end
    end)
    
    print("✅ Диагностика запущена! Возьми питомца в руки для анализа.")
    print("🛑 Для остановки введи: connection:Disconnect()")
    
    return connection
end

-- Запуск диагностики
local diagnosticConnection = startDiagnostic()

-- Возвращаем connection для возможности остановки
return diagnosticConnection
