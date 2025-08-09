-- ScriptAssemblyAnalyzer.lua
-- АНАЛИЗАТОР СКРИПТОВ СБОРКИ: Отслеживает динамическую сборку модели питомца
-- Мониторит процесс превращения базовой модели (3 части) в полную (18 частей)

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer

print("🔧 === SCRIPT ASSEMBLY ANALYZER ===")
print("🎯 Цель: Отследить динамическую сборку модели питомца")
print("=" .. string.rep("=", 60))

-- 📊 ДАННЫЕ АНАЛИЗАТОРА СБОРКИ
local AssemblyData = {
    targetModel = nil,
    baseSnapshot = nil,
    assemblySteps = {},
    scriptCalls = {},
    instanceCreations = {},
    cloneOperations = {},
    isMonitoring = false,
    startTime = 0,
    assemblySequence = {}
}

-- 🖥️ КОНСОЛЬ АНАЛИЗАТОРА
local AnalyzerConsole = nil
local ConsoleLines = {}
local MaxLines = 150

-- Создание консоли
local function createAnalyzerConsole()
    if AnalyzerConsole then AnalyzerConsole:Destroy() end
    
    AnalyzerConsole = Instance.new("ScreenGui")
    AnalyzerConsole.Name = "ScriptAssemblyAnalyzerConsole"
    AnalyzerConsole.Parent = player:WaitForChild("PlayerGui")
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 950, 0, 750)
    frame.Position = UDim2.new(0, 10, 0, 10)
    frame.BackgroundColor3 = Color3.new(0.02, 0.1, 0.05)
    frame.BorderSizePixel = 3
    frame.BorderColor3 = Color3.new(0.1, 1, 0.5)
    frame.Parent = AnalyzerConsole
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 35)
    title.BackgroundColor3 = Color3.new(0.1, 1, 0.5)
    title.BorderSizePixel = 0
    title.Text = "🔧 SCRIPT ASSEMBLY ANALYZER"
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
    textLabel.Text = "🔧 Анализатор скриптов сборки готов..."
    textLabel.TextColor3 = Color3.new(0.8, 1, 0.9)
    textLabel.TextSize = 10
    textLabel.Font = Enum.Font.SourceSans
    textLabel.TextXAlignment = Enum.TextXAlignment.Left
    textLabel.TextYAlignment = Enum.TextYAlignment.Top
    textLabel.TextWrapped = true
    textLabel.Parent = scrollFrame
    
    return textLabel
end

-- Функция логирования анализатора
local function analyzerLog(category, message, data)
    local timestamp = os.date("%H:%M:%S.") .. string.format("%03d", (tick() % 1) * 1000)
    local relativeTime = AssemblyData.startTime > 0 and string.format("(+%.3f)", tick() - AssemblyData.startTime) or ""
    
    local prefixes = {
        ASSEMBLY = "🔧", SCRIPT = "📜", INSTANCE = "🆕", CLONE = "📋",
        STEP = "👣", MONITOR = "👁️", CRITICAL = "🔥", SUCCESS = "✅", 
        ERROR = "❌", INFO = "ℹ️", DETAIL = "📝", SEQUENCE = "🔄",
        CREATION = "⚡", ADDITION = "➕", STRUCTURE = "🏗️", TIMING = "⏱️"
    }
    
    local logLine = string.format("[%s] %s %s %s", timestamp, relativeTime, prefixes[category] or "ℹ️", message)
    
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
    if AnalyzerConsole then
        local textLabel = AnalyzerConsole:FindFirstChild("Frame"):FindFirstChild("ScrollingFrame"):FindFirstChild("TextLabel")
        if textLabel then
            textLabel.Text = table.concat(ConsoleLines, "\n")
            local scrollFrame = textLabel.Parent
            scrollFrame.CanvasSize = UDim2.new(0, 0, 0, textLabel.TextBounds.Y + 10)
            scrollFrame.CanvasPosition = Vector2.new(0, scrollFrame.CanvasSize.Y.Offset)
        end
    end
    
    print(logLine)
end

-- 📸 СОЗДАНИЕ СНИМКА СТРУКТУРЫ
local function createStructureSnapshot(model, snapshotName)
    local snapshot = {
        name = snapshotName,
        timestamp = tick(),
        relativeTime = AssemblyData.startTime > 0 and (tick() - AssemblyData.startTime) or 0,
        children = #model:GetChildren(),
        descendants = #model:GetDescendants(),
        structure = {}
    }
    
    -- Подсчет типов объектов
    local typeCounts = {}
    for _, obj in pairs(model:GetDescendants()) do
        local className = obj.ClassName
        typeCounts[className] = (typeCounts[className] or 0) + 1
    end
    
    snapshot.structure = typeCounts
    
    analyzerLog("STRUCTURE", string.format("📸 СНИМОК: %s", snapshotName), {
        Children = snapshot.children,
        Descendants = snapshot.descendants,
        RelativeTime = string.format("%.3f сек", snapshot.relativeTime)
    })
    
    -- Показываем структуру
    for className, count in pairs(typeCounts) do
        analyzerLog("DETAIL", string.format("  %s: %d", className, count))
    end
    
    return snapshot
end

-- ⚖️ СРАВНЕНИЕ СНИМКОВ
local function compareSnapshots(before, after)
    analyzerLog("SEQUENCE", string.format("⚖️ СРАВНЕНИЕ: %s VS %s", before.name, after.name))
    
    local childrenDiff = after.children - before.children
    local descendantsDiff = after.descendants - before.descendants
    
    analyzerLog("SEQUENCE", "📊 Изменения общих показателей:", {
        ChildrenDiff = string.format("%+d", childrenDiff),
        DescendantsDiff = string.format("%+d", descendantsDiff),
        TimeDiff = string.format("%.3f сек", after.relativeTime - before.relativeTime)
    })
    
    -- Сравнение структуры
    local allTypes = {}
    for className, _ in pairs(before.structure) do allTypes[className] = true end
    for className, _ in pairs(after.structure) do allTypes[className] = true end
    
    analyzerLog("SEQUENCE", "🔄 Изменения структуры:")
    for className, _ in pairs(allTypes) do
        local beforeCount = before.structure[className] or 0
        local afterCount = after.structure[className] or 0
        local diff = afterCount - beforeCount
        
        if diff ~= 0 then
            analyzerLog("DETAIL", string.format("  %s: %+d (было %d, стало %d)", 
                className, diff, beforeCount, afterCount))
        end
    end
    
    return {
        childrenDiff = childrenDiff,
        descendantsDiff = descendantsDiff,
        timeDiff = after.relativeTime - before.relativeTime,
        structureChanges = {}
    }
end

-- 🔍 МОНИТОРИНГ ДОБАВЛЕНИЯ ОБЪЕКТОВ
local function monitorObjectAddition(model)
    analyzerLog("MONITOR", "👁️ МОНИТОРИНГ ДОБАВЛЕНИЯ ОБЪЕКТОВ: " .. model.Name)
    
    local stepCounter = 0
    local lastSnapshot = createStructureSnapshot(model, "initial")
    AssemblyData.baseSnapshot = lastSnapshot
    
    -- Мониторинг добавления потомков
    local connection = model.DescendantAdded:Connect(function(obj)
        stepCounter = stepCounter + 1
        local stepName = string.format("step_%d", stepCounter)
        
        analyzerLog("ADDITION", string.format("➕ ШАГ %d: Добавлен объект %s", stepCounter, obj.Name), {
            ClassName = obj.ClassName,
            Parent = obj.Parent and obj.Parent.Name or "nil",
            RelativeTime = string.format("%.3f сек", tick() - AssemblyData.startTime)
        })
        
        -- Создаем снимок после добавления
        wait(0.01) -- Небольшая задержка для стабилизации
        local currentSnapshot = createStructureSnapshot(model, stepName)
        
        -- Сравниваем с предыдущим снимком
        local comparison = compareSnapshots(lastSnapshot, currentSnapshot)
        
        -- Сохраняем шаг сборки
        table.insert(AssemblyData.assemblySteps, {
            step = stepCounter,
            object = obj,
            snapshot = currentSnapshot,
            comparison = comparison,
            timestamp = tick(),
            relativeTime = tick() - AssemblyData.startTime
        })
        
        lastSnapshot = currentSnapshot
        
        -- Если добавлений много, создаем финальный снимок через 5 секунд
        if stepCounter == 1 then
            spawn(function()
                wait(5)
                if model.Parent then
                    local finalSnapshot = createStructureSnapshot(model, "final")
                    local finalComparison = compareSnapshots(AssemblyData.baseSnapshot, finalSnapshot)
                    
                    analyzerLog("CRITICAL", "🔥 ИТОГОВЫЕ ИЗМЕНЕНИЯ:", {
                        TotalSteps = stepCounter,
                        ChildrenIncrease = string.format("+%d (с %d до %d)", 
                            finalComparison.childrenDiff, 
                            AssemblyData.baseSnapshot.children, 
                            finalSnapshot.children),
                        DescendantsIncrease = string.format("+%d (с %d до %d)", 
                            finalComparison.descendantsDiff, 
                            AssemblyData.baseSnapshot.descendants, 
                            finalSnapshot.descendants),
                        TotalTime = string.format("%.3f сек", finalSnapshot.relativeTime)
                    })
                    
                    analyzerLog("CRITICAL", "🔧 АНАЛИЗ СБОРКИ ЗАВЕРШЕН!")
                    connection:Disconnect()
                end
            end)
        end
    end)
    
    return connection
end

-- 🔍 ПОИСК БАЗОВОЙ МОДЕЛИ В REPLICATEDSTORAGE
local function findBaseModel(petName)
    analyzerLog("ASSEMBLY", "🔍 ПОИСК БАЗОВОЙ МОДЕЛИ: " .. petName)
    
    local skins = ReplicatedStorage:FindFirstChild("Skins")
    if not skins then
        analyzerLog("ERROR", "❌ Папка Skins не найдена в ReplicatedStorage")
        return nil
    end
    
    -- Поиск по точному имени
    local baseModel = skins:FindFirstChild(petName)
    if baseModel and baseModel:IsA("Model") then
        analyzerLog("SUCCESS", "✅ БАЗОВАЯ МОДЕЛЬ НАЙДЕНА!", {
            Name = baseModel.Name,
            Path = baseModel:GetFullName(),
            Children = #baseModel:GetChildren(),
            Descendants = #baseModel:GetDescendants()
        })
        
        -- Создаем снимок базовой модели
        createStructureSnapshot(baseModel, "base")
        return baseModel
    end
    
    analyzerLog("ERROR", "❌ Базовая модель не найдена: " .. petName)
    return nil
end

-- 🎯 ГЛАВНАЯ ФУНКЦИЯ АНАЛИЗА СБОРКИ
local function startAssemblyAnalysis()
    analyzerLog("ASSEMBLY", "🚀 ЗАПУСК АНАЛИЗА СБОРКИ МОДЕЛИ")
    analyzerLog("ASSEMBLY", "🎯 Отслеживание превращения базовой модели в полную")
    
    AssemblyData.isMonitoring = true
    AssemblyData.startTime = tick()
    
    -- Мониторинг появления модели в Visuals
    local visuals = Workspace:FindFirstChild("Visuals")
    if not visuals then
        analyzerLog("ERROR", "❌ Папка Visuals не найдена в Workspace")
        return
    end
    
    analyzerLog("MONITOR", "👁️ Мониторинг появления модели в Visuals...")
    
    local visualsConnection = visuals.ChildAdded:Connect(function(obj)
        if obj:IsA("Model") then
            local name = obj.Name:lower()
            if name == "dog" or name == "bunny" or name == "golden lab" or 
               name == "cat" or name == "rabbit" or name == "puppy" or
               name == "goldenlab" or name:find("lab") then
                
                analyzerLog("CRITICAL", "🎯 ЦЕЛЕВАЯ МОДЕЛЬ ОБНАРУЖЕНА: " .. obj.Name)
                AssemblyData.targetModel = obj
                
                -- Ищем базовую модель для сравнения
                local baseModel = findBaseModel(obj.Name)
                
                -- Запускаем мониторинг сборки
                local monitorConnection = monitorObjectAddition(obj)
                
                -- Отключаем мониторинг Visuals
                visualsConnection:Disconnect()
                
                analyzerLog("ASSEMBLY", "✅ Анализ сборки активен!")
                analyzerLog("ASSEMBLY", "📊 Отслеживание каждого добавления объекта...")
            end
        end
    end)
    
    analyzerLog("ASSEMBLY", "✅ Анализатор сборки готов!")
    analyzerLog("ASSEMBLY", "🥚 ОТКРОЙТЕ ЯЙЦО ДЛЯ АНАЛИЗА!")
end

-- 📋 ГЕНЕРАЦИЯ ОТЧЕТА СБОРКИ
local function generateAssemblyReport()
    analyzerLog("CRITICAL", "📋 === ОТЧЕТ АНАЛИЗА СБОРКИ ===")
    
    if not AssemblyData.targetModel then
        analyzerLog("ERROR", "❌ Целевая модель не найдена")
        return
    end
    
    analyzerLog("INFO", string.format("🎯 Проанализированная модель: %s", AssemblyData.targetModel.Name))
    analyzerLog("INFO", string.format("👣 Всего шагов сборки: %d", #AssemblyData.assemblySteps))
    
    if AssemblyData.baseSnapshot then
        analyzerLog("INFO", string.format("📦 Базовая структура: %d частей", AssemblyData.baseSnapshot.children))
    end
    
    -- Показываем ключевые шаги
    if #AssemblyData.assemblySteps > 0 then
        analyzerLog("CRITICAL", "🔥 КЛЮЧЕВЫЕ ШАГИ СБОРКИ:")
        for i, step in ipairs(AssemblyData.assemblySteps) do
            if i <= 10 then -- Показываем первые 10 шагов
                analyzerLog("STEP", string.format("👣 Шаг %d: %s (%s)", 
                    step.step, step.object.Name, step.object.ClassName), {
                    Time = string.format("%.3f сек", step.relativeTime),
                    Parent = step.object.Parent and step.object.Parent.Name or "nil"
                })
            end
        end
        
        if #AssemblyData.assemblySteps > 10 then
            analyzerLog("INFO", string.format("... и еще %d шагов", #AssemblyData.assemblySteps - 10))
        end
    end
    
    analyzerLog("CRITICAL", "🔧 АНАЛИЗ СБОРКИ ЗАВЕРШЕН!")
end

-- Создаем GUI
local function createAssemblyGUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "ScriptAssemblyAnalyzerGUI"
    screenGui.Parent = player:WaitForChild("PlayerGui")
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 380, 0, 140)
    frame.Position = UDim2.new(1, -400, 0, 10)
    frame.BackgroundColor3 = Color3.new(0.02, 0.1, 0.05)
    frame.BorderSizePixel = 0
    frame.Parent = screenGui
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 30)
    title.BackgroundColor3 = Color3.new(0.1, 1, 0.5)
    title.BorderSizePixel = 0
    title.Text = "🔧 SCRIPT ASSEMBLY ANALYZER"
    title.TextColor3 = Color3.new(0, 0, 0)
    title.TextScaled = true
    title.Font = Enum.Font.SourceSansBold
    title.Parent = frame
    
    local startBtn = Instance.new("TextButton")
    startBtn.Size = UDim2.new(1, -20, 0, 40)
    startBtn.Position = UDim2.new(0, 10, 0, 40)
    startBtn.BackgroundColor3 = Color3.new(0.1, 1, 0.5)
    startBtn.BorderSizePixel = 0
    startBtn.Text = "🔧 АНАЛИЗ СБОРКИ"
    startBtn.TextColor3 = Color3.new(0, 0, 0)
    startBtn.TextScaled = true
    startBtn.Font = Enum.Font.SourceSansBold
    startBtn.Parent = frame
    
    local reportBtn = Instance.new("TextButton")
    reportBtn.Size = UDim2.new(1, -20, 0, 30)
    reportBtn.Position = UDim2.new(0, 10, 0, 90)
    reportBtn.BackgroundColor3 = Color3.new(0.5, 0.8, 0.6)
    reportBtn.BorderSizePixel = 0
    reportBtn.Text = "📋 ОТЧЕТ СБОРКИ"
    reportBtn.TextColor3 = Color3.new(0, 0, 0)
    reportBtn.TextScaled = true
    reportBtn.Font = Enum.Font.SourceSans
    reportBtn.Parent = frame
    
    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(1, -20, 0, 20)
    status.Position = UDim2.new(0, 10, 0, 125)
    status.BackgroundTransparency = 1
    status.Text = "Готов к анализу сборки"
    status.TextColor3 = Color3.new(1, 1, 1)
    status.TextScaled = true
    status.Font = Enum.Font.SourceSans
    status.Parent = frame
    
    startBtn.MouseButton1Click:Connect(function()
        status.Text = "🔧 Анализ активен!"
        status.TextColor3 = Color3.new(0.1, 1, 0.5)
        startBtn.Text = "✅ АНАЛИЗ АКТИВЕН"
        startBtn.BackgroundColor3 = Color3.new(0.5, 0.5, 0.5)
        startBtn.Active = false
        
        startAssemblyAnalysis()
    end)
    
    reportBtn.MouseButton1Click:Connect(function()
        generateAssemblyReport()
    end)
end

-- Запускаем
local consoleTextLabel = createAnalyzerConsole()
createAssemblyGUI()

analyzerLog("ASSEMBLY", "✅ ScriptAssemblyAnalyzer готов!")
analyzerLog("ASSEMBLY", "🔧 Анализ динамической сборки модели питомца")
analyzerLog("ASSEMBLY", "🎯 Отслеживание превращения 3→18 частей")
analyzerLog("ASSEMBLY", "🚀 Нажмите 'АНАЛИЗ СБОРКИ' для запуска!")
