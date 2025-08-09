-- ModelExpansionAnalyzer.lua
-- АНАЛИЗАТОР РАСШИРЕНИЯ МОДЕЛИ: Отслеживает КАК базовая модель превращается в полную
-- Фиксирует каждый этап добавления частей, Motor6D, анимаций и скриптов

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

print("🔬 === MODEL EXPANSION ANALYZER ===")
print("🎯 Цель: Проследить расширение модели от базовой до полной")
print("=" .. string.rep("=", 60))

-- 📊 ДАННЫЕ АНАЛИЗАТОРА РАСШИРЕНИЯ
local ExpansionData = {
    baseModel = nil,
    expandedModel = nil,
    expansionSteps = {},
    snapshots = {},
    scripts = {},
    startTime = nil,
    isAnalyzing = false
}

-- 🖥️ КОНСОЛЬ РАСШИРЕНИЯ
local ExpansionConsole = nil
local ConsoleLines = {}
local MaxLines = 150

-- Создание консоли
local function createExpansionConsole()
    if ExpansionConsole then ExpansionConsole:Destroy() end
    
    ExpansionConsole = Instance.new("ScreenGui")
    ExpansionConsole.Name = "ModelExpansionAnalyzerConsole"
    ExpansionConsole.Parent = player:WaitForChild("PlayerGui")
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 850, 0, 650)
    frame.Position = UDim2.new(0, 10, 0, 10)
    frame.BackgroundColor3 = Color3.new(0.02, 0.1, 0.05)
    frame.BorderSizePixel = 3
    frame.BorderColor3 = Color3.new(0.2, 1, 0.5)
    frame.Parent = ExpansionConsole
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 35)
    title.BackgroundColor3 = Color3.new(0.2, 1, 0.5)
    title.BorderSizePixel = 0
    title.Text = "🔬 MODEL EXPANSION ANALYZER"
    title.TextColor3 = Color3.new(0, 0, 0)
    title.TextScaled = true
    title.Font = Enum.Font.SourceSansBold
    title.Parent = frame
    
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Size = UDim2.new(1, -10, 1, -45)
    scrollFrame.Position = UDim2.new(0, 5, 0, 40)
    scrollFrame.BackgroundColor3 = Color3.new(0.01, 0.05, 0.02)
    scrollFrame.BorderSizePixel = 0
    scrollFrame.ScrollBarThickness = 15
    scrollFrame.Parent = frame
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, -10, 1, 0)
    textLabel.Position = UDim2.new(0, 5, 0, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = "🔬 Анализатор расширения готов..."
    textLabel.TextColor3 = Color3.new(0.9, 1, 0.9)
    textLabel.TextSize = 10
    textLabel.Font = Enum.Font.SourceSans
    textLabel.TextXAlignment = Enum.TextXAlignment.Left
    textLabel.TextYAlignment = Enum.TextYAlignment.Top
    textLabel.TextWrapped = true
    textLabel.Parent = scrollFrame
    
    return textLabel
end

-- Функция логирования расширения
local function expansionLog(category, message, data)
    local timestamp = os.date("%H:%M:%S.") .. string.format("%03d", (tick() % 1) * 1000)
    local relativeTime = ExpansionData.startTime and string.format("+%.3f", tick() - ExpansionData.startTime) or "0.000"
    
    local prefixes = {
        EXPANSION = "🔬", BASE = "📦", STEP = "🔧", SNAPSHOT = "📸",
        SCRIPT = "📜", FOUND = "🎯", CRITICAL = "🔥", SUCCESS = "✅", 
        ERROR = "❌", INFO = "ℹ️", DETAIL = "📝", COMPARE = "⚖️"
    }
    
    local logLine = string.format("[%s] (%s) %s %s", timestamp, relativeTime, prefixes[category] or "ℹ️", message)
    
    if data and next(data) then
        for key, value in pairs(data) do
            logLine = logLine .. string.format("\n      %s: %s", key, tostring(value))
        end
    end
    
    table.insert(ConsoleLines, logLine)
    
    if #ConsoleLines > MaxLines then
        table.remove(ConsoleLines, 1)
    end
    
    -- Обновляем консоль
    if ExpansionConsole then
        local textLabel = ExpansionConsole:FindFirstChild("Frame"):FindFirstChild("ScrollingFrame"):FindFirstChild("TextLabel")
        if textLabel then
            textLabel.Text = table.concat(ConsoleLines, "\n")
            local scrollFrame = textLabel.Parent
            scrollFrame.CanvasSize = UDim2.new(0, 0, 0, textLabel.TextBounds.Y + 10)
            scrollFrame.CanvasPosition = Vector2.new(0, scrollFrame.CanvasSize.Y.Offset)
        end
    end
    
    print(logLine)
end

-- 📦 ПОИСК БАЗОВОЙ МОДЕЛИ
local function findBaseModel(petName)
    expansionLog("BASE", "📦 Поиск базовой модели для: " .. petName)
    
    -- Поиск в ReplicatedStorage.Skins
    local skins = ReplicatedStorage:FindFirstChild("Skins")
    if skins then
        local baseModel = skins:FindFirstChild(petName)
        if baseModel then
            ExpansionData.baseModel = baseModel
            
            expansionLog("SUCCESS", "✅ БАЗОВАЯ МОДЕЛЬ НАЙДЕНА!", {
                Name = baseModel.Name,
                Path = baseModel:GetFullName(),
                Children = #baseModel:GetChildren(),
                Descendants = #baseModel:GetDescendants(),
                ClassName = baseModel.ClassName
            })
            
            -- Детальный анализ базовой модели
            analyzeBaseModel(baseModel)
            return baseModel
        end
    end
    
    -- Поиск в других местах ReplicatedStorage
    for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("Model") and obj.Name == petName then
            ExpansionData.baseModel = obj
            
            expansionLog("SUCCESS", "✅ БАЗОВАЯ МОДЕЛЬ НАЙДЕНА В ДРУГОМ МЕСТЕ!", {
                Name = obj.Name,
                Path = obj:GetFullName(),
                Children = #obj:GetChildren(),
                Descendants = #obj:GetDescendants()
            })
            
            analyzeBaseModel(obj)
            return obj
        end
    end
    
    expansionLog("ERROR", "❌ Базовая модель не найдена!")
    return nil
end

-- 📝 АНАЛИЗ БАЗОВОЙ МОДЕЛИ
local function analyzeBaseModel(baseModel)
    expansionLog("DETAIL", "📝 ДЕТАЛЬНЫЙ АНАЛИЗ БАЗОВОЙ МОДЕЛИ: " .. baseModel.Name)
    
    local baseStructure = {}
    local baseParts = {}
    
    for _, obj in pairs(baseModel:GetDescendants()) do
        baseStructure[obj.ClassName] = (baseStructure[obj.ClassName] or 0) + 1
        
        if obj:IsA("BasePart") then
            table.insert(baseParts, {
                Name = obj.Name,
                Size = tostring(obj.Size),
                Material = tostring(obj.Material)
            })
        end
    end
    
    expansionLog("DETAIL", "📝 Структура базовой модели:", baseStructure)
    
    if #baseParts > 0 then
        expansionLog("DETAIL", "📝 Части базовой модели:")
        for i, part in ipairs(baseParts) do
            expansionLog("DETAIL", string.format("  Часть %d: %s", i, part.Name), part)
        end
    end
    
    -- Сохраняем снимок базовой модели
    ExpansionData.snapshots["base"] = {
        time = tick(),
        structure = baseStructure,
        parts = baseParts,
        children = #baseModel:GetChildren(),
        descendants = #baseModel:GetDescendants()
    }
end

-- 📸 СОЗДАНИЕ СНИМКА МОДЕЛИ
local function takeModelSnapshot(model, snapshotName)
    local structure = {}
    local parts = {}
    local motor6ds = {}
    local scripts = {}
    
    for _, obj in pairs(model:GetDescendants()) do
        structure[obj.ClassName] = (structure[obj.ClassName] or 0) + 1
        
        if obj:IsA("BasePart") then
            table.insert(parts, {
                Name = obj.Name,
                Size = tostring(obj.Size),
                Material = tostring(obj.Material),
                Anchored = obj.Anchored
            })
        elseif obj:IsA("Motor6D") then
            table.insert(motor6ds, {
                Name = obj.Name,
                Part0 = obj.Part0 and obj.Part0.Name or "NIL",
                Part1 = obj.Part1 and obj.Part1.Name or "NIL"
            })
        elseif obj:IsA("Script") or obj:IsA("LocalScript") then
            table.insert(scripts, {
                Name = obj.Name,
                ClassName = obj.ClassName,
                Parent = obj.Parent and obj.Parent.Name or "NIL"
            })
        end
    end
    
    local snapshot = {
        time = tick(),
        relativeTime = ExpansionData.startTime and (tick() - ExpansionData.startTime) or 0,
        structure = structure,
        parts = parts,
        motor6ds = motor6ds,
        scripts = scripts,
        children = #model:GetChildren(),
        descendants = #model:GetDescendants()
    }
    
    ExpansionData.snapshots[snapshotName] = snapshot
    
    expansionLog("SNAPSHOT", "📸 СНИМОК МОДЕЛИ: " .. snapshotName, {
        Children = snapshot.children,
        Descendants = snapshot.descendants,
        RelativeTime = string.format("%.3f сек", snapshot.relativeTime)
    })
    
    return snapshot
end

-- ⚖️ СРАВНЕНИЕ СНИМКОВ
local function compareSnapshots(snapshot1Name, snapshot2Name)
    local snap1 = ExpansionData.snapshots[snapshot1Name]
    local snap2 = ExpansionData.snapshots[snapshot2Name]
    
    if not snap1 or not snap2 then
        expansionLog("ERROR", "❌ Не удалось найти снимки для сравнения")
        return
    end
    
    expansionLog("COMPARE", string.format("⚖️ СРАВНЕНИЕ: %s VS %s", snapshot1Name, snapshot2Name))
    
    -- Сравнение общих показателей
    local childrenDiff = snap2.children - snap1.children
    local descendantsDiff = snap2.descendants - snap1.descendants
    
    expansionLog("COMPARE", "⚖️ Изменения общих показателей:", {
        ChildrenBefore = snap1.children,
        ChildrenAfter = snap2.children,
        ChildrenDiff = childrenDiff,
        DescendantsBefore = snap1.descendants,
        DescendantsAfter = snap2.descendants,
        DescendantsDiff = descendantsDiff
    })
    
    -- Сравнение структуры
    local structureDiff = {}
    
    -- Новые типы объектов
    for className, count in pairs(snap2.structure) do
        local oldCount = snap1.structure[className] or 0
        if count > oldCount then
            structureDiff[className] = string.format("+%d (было %d, стало %d)", count - oldCount, oldCount, count)
        end
    end
    
    -- Удаленные типы объектов
    for className, count in pairs(snap1.structure) do
        if not snap2.structure[className] then
            structureDiff[className] = string.format("-%d (удалено)", count)
        end
    end
    
    if next(structureDiff) then
        expansionLog("COMPARE", "⚖️ Изменения структуры:", structureDiff)
    else
        expansionLog("COMPARE", "⚖️ Структура не изменилась")
    end
    
    -- Сравнение Motor6D
    if #snap2.motor6ds > #snap1.motor6ds then
        expansionLog("COMPARE", string.format("⚖️ Добавлено Motor6D: %d", #snap2.motor6ds - #snap1.motor6ds))
        for i = #snap1.motor6ds + 1, #snap2.motor6ds do
            local motor = snap2.motor6ds[i]
            expansionLog("DETAIL", string.format("  Новый Motor6D: %s", motor.Name), motor)
        end
    end
    
    -- Сравнение скриптов
    if #snap2.scripts > #snap1.scripts then
        expansionLog("COMPARE", string.format("⚖️ Добавлено скриптов: %d", #snap2.scripts - #snap1.scripts))
        for i = #snap1.scripts + 1, #snap2.scripts do
            local script = snap2.scripts[i]
            expansionLog("DETAIL", string.format("  Новый скрипт: %s", script.Name), script)
        end
    end
end

-- 🔧 МОНИТОРИНГ РАСШИРЕНИЯ МОДЕЛИ
local function monitorModelExpansion(model)
    expansionLog("EXPANSION", "🔧 МОНИТОРИНГ РАСШИРЕНИЯ МОДЕЛИ: " .. model.Name)
    
    ExpansionData.expandedModel = model
    
    -- Начальный снимок
    takeModelSnapshot(model, "initial")
    
    -- Мониторинг изменений
    local stepCounter = 1
    
    local childAddedConnection = model.DescendantAdded:Connect(function(obj)
        local relativeTime = ExpansionData.startTime and (tick() - ExpansionData.startTime) or 0
        
        expansionLog("STEP", string.format("🔧 ШАГ %d: Добавлен объект %s", stepCounter, obj.Name), {
            ClassName = obj.ClassName,
            Parent = obj.Parent and obj.Parent.Name or "NIL",
            RelativeTime = string.format("%.3f сек", relativeTime)
        })
        
        -- Создаем снимок после каждого значительного изменения
        if obj:IsA("BasePart") or obj:IsA("Motor6D") or obj:IsA("Script") or obj:IsA("LocalScript") then
            local snapshotName = string.format("step_%d", stepCounter)
            takeModelSnapshot(model, snapshotName)
            
            -- Сравниваем с предыдущим снимком
            if stepCounter == 1 then
                compareSnapshots("initial", snapshotName)
            else
                compareSnapshots(string.format("step_%d", stepCounter - 1), snapshotName)
            end
        end
        
        stepCounter = stepCounter + 1
    end)
    
    -- Финальный снимок через некоторое время
    spawn(function()
        wait(5) -- Ждем 5 секунд для завершения расширения
        takeModelSnapshot(model, "final")
        compareSnapshots("initial", "final")
        
        expansionLog("CRITICAL", "🔥 АНАЛИЗ РАСШИРЕНИЯ ЗАВЕРШЕН!")
        generateExpansionReport()
        
        childAddedConnection:Disconnect()
    end)
    
    return childAddedConnection
end

-- 📋 ГЕНЕРАЦИЯ ОТЧЕТА О РАСШИРЕНИИ
local function generateExpansionReport()
    expansionLog("CRITICAL", "📋 === ОТЧЕТ О РАСШИРЕНИИ МОДЕЛИ ===")
    
    if ExpansionData.baseModel then
        expansionLog("INFO", "📦 Базовая модель: " .. ExpansionData.baseModel:GetFullName())
    end
    
    if ExpansionData.expandedModel then
        expansionLog("INFO", "🔧 Расширенная модель: " .. ExpansionData.expandedModel:GetFullName())
    end
    
    local initialSnap = ExpansionData.snapshots["initial"]
    local finalSnap = ExpansionData.snapshots["final"]
    
    if initialSnap and finalSnap then
        expansionLog("CRITICAL", "🔥 ИТОГОВЫЕ ИЗМЕНЕНИЯ:", {
            ChildrenBefore = initialSnap.children,
            ChildrenAfter = finalSnap.children,
            ChildrenIncrease = finalSnap.children - initialSnap.children,
            DescendantsBefore = initialSnap.descendants,
            DescendantsAfter = finalSnap.descendants,
            DescendantsIncrease = finalSnap.descendants - initialSnap.descendants
        })
    end
    
    expansionLog("CRITICAL", string.format("📊 Всего снимков: %d", #ExpansionData.snapshots))
    expansionLog("CRITICAL", "🔬 АНАЛИЗ РАСШИРЕНИЯ МОДЕЛИ ЗАВЕРШЕН!")
end

-- 🚀 ГЛАВНАЯ ФУНКЦИЯ АНАЛИЗА РАСШИРЕНИЯ
local function startExpansionAnalysis()
    expansionLog("EXPANSION", "🚀 ЗАПУСК АНАЛИЗА РАСШИРЕНИЯ МОДЕЛИ")
    expansionLog("EXPANSION", "🔬 Отслеживание превращения базовой модели в полную")
    
    ExpansionData.isAnalyzing = true
    ExpansionData.startTime = tick()
    
    -- Мониторинг появления модели в Visuals
    local visuals = Workspace:FindFirstChild("Visuals")
    if not visuals then
        expansionLog("ERROR", "❌ Папка Visuals не найдена!")
        return
    end
    
    expansionLog("SUCCESS", "✅ Папка Visuals найдена, начинаем мониторинг...")
    
    local visualsConnection = visuals.ChildAdded:Connect(function(obj)
        if obj:IsA("Model") then
            local name = obj.Name:lower()
            if name == "dog" or name == "bunny" or name == "golden lab" or 
               name == "cat" or name == "rabbit" or name == "puppy" or
               name == "goldenlab" or name:find("lab") then
                
                expansionLog("FOUND", "🎯 ПИТОМЕЦ ОБНАРУЖЕН В VISUALS: " .. obj.Name)
                
                -- Поиск базовой модели
                local baseModel = findBaseModel(obj.Name)
                
                -- Запуск мониторинга расширения
                monitorModelExpansion(obj)
                
                -- Отключаем мониторинг Visuals
                visualsConnection:Disconnect()
            end
        end
    end)
    
    expansionLog("EXPANSION", "✅ Анализ расширения активен!")
    expansionLog("EXPANSION", "🥚 ОТКРОЙТЕ ЯЙЦО ДЛЯ АНАЛИЗА!")
    
    -- Автоостановка через 3 минуты
    spawn(function()
        wait(180)
        if visualsConnection then
            visualsConnection:Disconnect()
        end
        ExpansionData.isAnalyzing = false
        expansionLog("EXPANSION", "⏰ Анализ завершен по таймауту")
    end)
end

-- Создаем GUI
local function createExpansionGUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "ModelExpansionAnalyzerGUI"
    screenGui.Parent = player:WaitForChild("PlayerGui")
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 350, 0, 120)
    frame.Position = UDim2.new(1, -370, 0, 10)
    frame.BackgroundColor3 = Color3.new(0.02, 0.1, 0.05)
    frame.BorderSizePixel = 0
    frame.Parent = screenGui
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 30)
    title.BackgroundColor3 = Color3.new(0.2, 1, 0.5)
    title.BorderSizePixel = 0
    title.Text = "🔬 EXPANSION ANALYZER"
    title.TextColor3 = Color3.new(0, 0, 0)
    title.TextScaled = true
    title.Font = Enum.Font.SourceSansBold
    title.Parent = frame
    
    local startBtn = Instance.new("TextButton")
    startBtn.Size = UDim2.new(1, -20, 0, 40)
    startBtn.Position = UDim2.new(0, 10, 0, 40)
    startBtn.BackgroundColor3 = Color3.new(0.2, 1, 0.5)
    startBtn.BorderSizePixel = 0
    startBtn.Text = "🔬 АНАЛИЗ РАСШИРЕНИЯ"
    startBtn.TextColor3 = Color3.new(0, 0, 0)
    startBtn.TextScaled = true
    startBtn.Font = Enum.Font.SourceSansBold
    startBtn.Parent = frame
    
    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(1, -20, 0, 30)
    status.Position = UDim2.new(0, 10, 0, 90)
    status.BackgroundTransparency = 1
    status.Text = "Готов к анализу расширения"
    status.TextColor3 = Color3.new(1, 1, 1)
    status.TextScaled = true
    status.Font = Enum.Font.SourceSans
    status.Parent = frame
    
    startBtn.MouseButton1Click:Connect(function()
        status.Text = "🔬 Анализ активен!"
        status.TextColor3 = Color3.new(0.2, 1, 0.5)
        startBtn.Text = "✅ АНАЛИЗ АКТИВЕН"
        startBtn.BackgroundColor3 = Color3.new(0.5, 0.5, 0.5)
        startBtn.Active = false
        
        startExpansionAnalysis()
    end)
end

-- Запускаем
local consoleTextLabel = createExpansionConsole()
createExpansionGUI()

expansionLog("EXPANSION", "✅ ModelExpansionAnalyzer готов!")
expansionLog("EXPANSION", "🔬 Анализ расширения модели от базовой до полной")
expansionLog("EXPANSION", "📸 Снимки на каждом этапе + сравнение изменений")
expansionLog("EXPANSION", "🚀 Нажмите 'АНАЛИЗ РАСШИРЕНИЯ' и откройте яйцо!")
