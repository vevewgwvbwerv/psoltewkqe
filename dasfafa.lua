-- TempModelDeepAnalyzer.lua
-- ГЛУБОКИЙ АНАЛИЗАТОР ВРЕМЕННОЙ МОДЕЛИ: Находит источник и анализирует ВСЁ
-- Определяет: откуда создается, каким скриптом, из какого шаблона, все свойства

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

print("🔬 === TEMP MODEL DEEP ANALYZER ===")
print("🎯 Цель: Найти ИСТОЧНИК временной модели и проанализировать ВСЁ")
print("=" .. string.rep("=", 60))

-- 📊 ДАННЫЕ ГЛУБОКОГО АНАЛИЗА
local DeepAnalysisData = {
    tempModel = nil,
    sourceModel = nil,
    creationScript = nil,
    modelProperties = {},
    sourceLocation = nil,
    connectionChain = {},
    isAnalyzing = false
}

-- 🖥️ КОНСОЛЬ ГЛУБОКОГО АНАЛИЗА
local AnalyzerConsole = nil
local ConsoleLines = {}
local MaxLines = 100

-- Создание консоли
local function createAnalyzerConsole()
    if AnalyzerConsole then AnalyzerConsole:Destroy() end
    
    AnalyzerConsole = Instance.new("ScreenGui")
    AnalyzerConsole.Name = "TempModelDeepAnalyzerConsole"
    AnalyzerConsole.Parent = player:WaitForChild("PlayerGui")
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 800, 0, 600)
    frame.Position = UDim2.new(0, 10, 0, 10)
    frame.BackgroundColor3 = Color3.new(0.02, 0.02, 0.1)
    frame.BorderSizePixel = 3
    frame.BorderColor3 = Color3.new(0.8, 0.4, 0.1)
    frame.Parent = AnalyzerConsole
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 35)
    title.BackgroundColor3 = Color3.new(0.8, 0.4, 0.1)
    title.BorderSizePixel = 0
    title.Text = "🔬 TEMP MODEL DEEP ANALYZER"
    title.TextColor3 = Color3.new(1, 1, 1)
    title.TextScaled = true
    title.Font = Enum.Font.SourceSansBold
    title.Parent = frame
    
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Size = UDim2.new(1, -10, 1, -45)
    scrollFrame.Position = UDim2.new(0, 5, 0, 40)
    scrollFrame.BackgroundColor3 = Color3.new(0.01, 0.01, 0.05)
    scrollFrame.BorderSizePixel = 0
    scrollFrame.ScrollBarThickness = 10
    scrollFrame.Parent = frame
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, -10, 1, 0)
    textLabel.Position = UDim2.new(0, 5, 0, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = "🔬 Глубокий анализатор готов..."
    textLabel.TextColor3 = Color3.new(1, 0.9, 0.9)
    textLabel.TextSize = 11
    textLabel.Font = Enum.Font.SourceSans
    textLabel.TextXAlignment = Enum.TextXAlignment.Left
    textLabel.TextYAlignment = Enum.TextYAlignment.Top
    textLabel.TextWrapped = true
    textLabel.Parent = scrollFrame
    
    return textLabel
end

-- Функция глубокого логирования
local function deepLog(category, message, data)
    local timestamp = os.date("%H:%M:%S.") .. string.format("%03d", (tick() % 1) * 1000)
    local prefixes = {
        ANALYZER = "🔬", SOURCE = "📦", SCRIPT = "📜", PROPERTY = "🔧",
        STRUCTURE = "🏗️", CONNECTION = "🔗", FOUND = "🎯", CRITICAL = "🔥",
        SUCCESS = "✅", ERROR = "❌", INFO = "ℹ️", DEEP = "🕳️"
    }
    
    local logLine = string.format("[%s] %s %s", timestamp, prefixes[category] or "ℹ️", message)
    
    if data and next(data) then
        for key, value in pairs(data) do
            logLine = logLine .. string.format("\n    %s: %s", key, tostring(value))
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

-- 🔍 ПОИСК ИСТОЧНИКОВ В REPLICATEDSTORAGE
local function findPotentialSources()
    deepLog("SOURCE", "🔍 Поиск потенциальных источников в ReplicatedStorage...")
    
    local sources = {}
    
    -- Поиск в ReplicatedStorage
    for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("Model") then
            local name = obj.Name:lower()
            if name == "dog" or name == "bunny" or name == "golden lab" or 
               name == "cat" or name == "rabbit" or name == "puppy" or
               name:find("pet") then
                
                sources[obj:GetFullName()] = {
                    object = obj,
                    name = obj.Name,
                    path = obj:GetFullName(),
                    children = #obj:GetChildren(),
                    className = obj.ClassName
                }
                
                deepLog("FOUND", "🎯 ПОТЕНЦИАЛЬНЫЙ ИСТОЧНИК НАЙДЕН!", {
                    Name = obj.Name,
                    Path = obj:GetFullName(),
                    Children = #obj:GetChildren()
                })
            end
        end
    end
    
    deepLog("SOURCE", string.format("📊 Найдено %d потенциальных источников", #sources))
    return sources
end

-- 🔍 ПОИСК СКРИПТОВ СОЗДАНИЯ
local function findCreationScripts()
    deepLog("SCRIPT", "📜 Поиск скриптов создания моделей...")
    
    local scripts = {}
    
    -- Поиск в workspace
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Script") or obj:IsA("LocalScript") then
            local scriptName = obj.Name:lower()
            if scriptName:find("pet") or scriptName:find("egg") or scriptName:find("spawn") or 
               scriptName:find("create") or scriptName:find("model") or scriptName:find("clone") then
                
                scripts[obj:GetFullName()] = {
                    script = obj,
                    name = obj.Name,
                    path = obj:GetFullName(),
                    parent = obj.Parent and obj.Parent.Name or "NIL"
                }
                
                deepLog("SCRIPT", "📜 ПОДОЗРИТЕЛЬНЫЙ СКРИПТ!", {
                    Name = obj.Name,
                    Path = obj:GetFullName(),
                    Parent = obj.Parent and obj.Parent.Name or "NIL"
                })
            end
        end
    end
    
    return scripts
end

-- 🔬 ГЛУБОКИЙ АНАЛИЗ ВРЕМЕННОЙ МОДЕЛИ
local function deepAnalyzeTempModel(model)
    deepLog("ANALYZER", "🔬 ГЛУБОКИЙ АНАЛИЗ ВРЕМЕННОЙ МОДЕЛИ: " .. model.Name)
    
    DeepAnalysisData.tempModel = model
    
    -- Базовые свойства
    local properties = {
        Name = model.Name,
        ClassName = model.ClassName,
        Parent = model.Parent and model.Parent.Name or "NIL",
        Position = model.PrimaryPart and tostring(model.PrimaryPart.Position) or "NIL",
        PrimaryPart = model.PrimaryPart and model.PrimaryPart.Name or "NIL",
        Children = #model:GetChildren(),
        Descendants = #model:GetDescendants()
    }
    
    DeepAnalysisData.modelProperties = properties
    
    deepLog("PROPERTY", "📊 Базовые свойства модели:", properties)
    
    -- Анализ структуры
    local structure = {
        BaseParts = 0,
        MeshParts = 0,
        Motor6Ds = 0,
        Welds = 0,
        Scripts = 0,
        Animators = 0,
        Attachments = 0,
        Decals = 0
    }
    
    local partDetails = {}
    local motor6dDetails = {}
    local scriptDetails = {}
    
    for _, obj in pairs(model:GetDescendants()) do
        if obj:IsA("BasePart") then
            structure.BaseParts = structure.BaseParts + 1
            table.insert(partDetails, {
                Name = obj.Name,
                Size = tostring(obj.Size),
                Material = tostring(obj.Material),
                Anchored = obj.Anchored
            })
        elseif obj:IsA("MeshPart") then
            structure.MeshParts = structure.MeshParts + 1
        elseif obj:IsA("Motor6D") then
            structure.Motor6Ds = structure.Motor6Ds + 1
            table.insert(motor6dDetails, {
                Name = obj.Name,
                Part0 = obj.Part0 and obj.Part0.Name or "NIL",
                Part1 = obj.Part1 and obj.Part1.Name or "NIL"
            })
        elseif obj:IsA("Weld") then
            structure.Welds = structure.Welds + 1
        elseif obj:IsA("Script") or obj:IsA("LocalScript") then
            structure.Scripts = structure.Scripts + 1
            table.insert(scriptDetails, {
                Name = obj.Name,
                ClassName = obj.ClassName,
                Parent = obj.Parent and obj.Parent.Name or "NIL"
            })
        elseif obj:IsA("Animator") then
            structure.Animators = structure.Animators + 1
        elseif obj:IsA("Attachment") then
            structure.Attachments = structure.Attachments + 1
        elseif obj:IsA("Decal") then
            structure.Decals = structure.Decals + 1
        end
    end
    
    deepLog("STRUCTURE", "🏗️ Детальная структура модели:", structure)
    
    -- Детали частей
    if #partDetails > 0 then
        deepLog("DEEP", "🕳️ ДЕТАЛИ ЧАСТЕЙ:")
        for i, part in ipairs(partDetails) do
            deepLog("DEEP", string.format("  Часть %d: %s", i, part.Name), part)
        end
    end
    
    -- Детали Motor6D
    if #motor6dDetails > 0 then
        deepLog("DEEP", "🕳️ ДЕТАЛИ MOTOR6D:")
        for i, motor in ipairs(motor6dDetails) do
            deepLog("DEEP", string.format("  Motor6D %d: %s", i, motor.Name), motor)
        end
    end
    
    -- Детали скриптов
    if #scriptDetails > 0 then
        deepLog("DEEP", "🕳️ СКРИПТЫ В МОДЕЛИ:")
        for i, script in ipairs(scriptDetails) do
            deepLog("DEEP", string.format("  Скрипт %d: %s", i, script.Name), script)
        end
    end
end

-- 🔗 ПОИСК СВЯЗИ С ИСТОЧНИКОМ
local function findSourceConnection(tempModel, sources)
    deepLog("CONNECTION", "🔗 Поиск связи с источником...")
    
    local bestMatch = nil
    local bestScore = 0
    
    for sourcePath, sourceData in pairs(sources) do
        local score = 0
        
        -- Совпадение имени
        if sourceData.name:lower() == tempModel.Name:lower() then
            score = score + 100
        elseif sourceData.name:lower():find(tempModel.Name:lower()) then
            score = score + 50
        end
        
        -- Совпадение количества детей
        local tempChildren = #tempModel:GetChildren()
        local sourceChildren = sourceData.children
        if tempChildren == sourceChildren then
            score = score + 30
        elseif math.abs(tempChildren - sourceChildren) <= 2 then
            score = score + 10
        end
        
        -- Совпадение структуры
        local tempStructure = {}
        for _, obj in pairs(tempModel:GetDescendants()) do
            tempStructure[obj.ClassName] = (tempStructure[obj.ClassName] or 0) + 1
        end
        
        local sourceStructure = {}
        for _, obj in pairs(sourceData.object:GetDescendants()) do
            sourceStructure[obj.ClassName] = (sourceStructure[obj.ClassName] or 0) + 1
        end
        
        local structureMatch = 0
        for className, count in pairs(tempStructure) do
            if sourceStructure[className] and sourceStructure[className] == count then
                structureMatch = structureMatch + 1
            end
        end
        
        score = score + structureMatch * 5
        
        deepLog("CONNECTION", string.format("🔗 Анализ источника: %s (Score: %d)", sourceData.name, score), {
            NameMatch = sourceData.name:lower() == tempModel.Name:lower(),
            ChildrenMatch = tempChildren == sourceChildren,
            StructureMatch = structureMatch
        })
        
        if score > bestScore then
            bestScore = score
            bestMatch = sourceData
        end
    end
    
    if bestMatch then
        DeepAnalysisData.sourceModel = bestMatch.object
        DeepAnalysisData.sourceLocation = bestMatch.path
        
        deepLog("SUCCESS", "✅ ИСТОЧНИК НАЙДЕН!", {
            Source = bestMatch.name,
            Path = bestMatch.path,
            Score = bestScore,
            Confidence = bestScore > 100 and "ВЫСОКАЯ" or (bestScore > 50 and "СРЕДНЯЯ" or "НИЗКАЯ")
        })
        
        return bestMatch
    else
        deepLog("ERROR", "❌ Источник не найден или совпадение слишком слабое")
        return nil
    end
end

-- 📊 СРАВНИТЕЛЬНЫЙ АНАЛИЗ
local function compareWithSource(tempModel, sourceModel)
    if not sourceModel then
        deepLog("ERROR", "❌ Нет источника для сравнения")
        return
    end
    
    deepLog("ANALYZER", "📊 СРАВНИТЕЛЬНЫЙ АНАЛИЗ: Временная модель VS Источник")
    
    -- Сравнение базовых свойств
    local comparison = {
        Name = {
            Temp = tempModel.Name,
            Source = sourceModel.Name,
            Match = tempModel.Name == sourceModel.Name
        },
        Children = {
            Temp = #tempModel:GetChildren(),
            Source = #sourceModel:GetChildren(),
            Match = #tempModel:GetChildren() == #sourceModel:GetChildren()
        },
        Descendants = {
            Temp = #tempModel:GetDescendants(),
            Source = #sourceModel:GetDescendants(),
            Match = #tempModel:GetDescendants() == #sourceModel:GetDescendants()
        }
    }
    
    deepLog("ANALYZER", "📊 Сравнение свойств:", comparison)
    
    -- Сравнение структуры
    local tempStructure = {}
    local sourceStructure = {}
    
    for _, obj in pairs(tempModel:GetDescendants()) do
        tempStructure[obj.ClassName] = (tempStructure[obj.ClassName] or 0) + 1
    end
    
    for _, obj in pairs(sourceModel:GetDescendants()) do
        sourceStructure[obj.ClassName] = (sourceStructure[obj.ClassName] or 0) + 1
    end
    
    deepLog("ANALYZER", "📊 Структура временной модели:", tempStructure)
    deepLog("ANALYZER", "📊 Структура источника:", sourceStructure)
    
    -- Различия
    local differences = {}
    for className, count in pairs(tempStructure) do
        if not sourceStructure[className] then
            differences[className] = string.format("Только в временной: %d", count)
        elseif sourceStructure[className] ~= count then
            differences[className] = string.format("Временная: %d, Источник: %d", count, sourceStructure[className])
        end
    end
    
    for className, count in pairs(sourceStructure) do
        if not tempStructure[className] then
            differences[className] = string.format("Только в источнике: %d", count)
        end
    end
    
    if next(differences) then
        deepLog("CRITICAL", "🔥 РАЗЛИЧИЯ ОБНАРУЖЕНЫ:", differences)
    else
        deepLog("SUCCESS", "✅ СТРУКТУРЫ ИДЕНТИЧНЫ!")
    end
end

-- 📋 ГЕНЕРАЦИЯ ИТОГОВОГО ОТЧЕТА
local function generateDeepReport()
    deepLog("CRITICAL", "📋 === ИТОГОВЫЙ ГЛУБОКИЙ ОТЧЕТ ===")
    
    if DeepAnalysisData.tempModel then
        deepLog("SUCCESS", "✅ ВРЕМЕННАЯ МОДЕЛЬ ПРОАНАЛИЗИРОВАНА: " .. DeepAnalysisData.tempModel.Name)
    end
    
    if DeepAnalysisData.sourceModel then
        deepLog("SUCCESS", "✅ ИСТОЧНИК НАЙДЕН: " .. DeepAnalysisData.sourceLocation)
    else
        deepLog("ERROR", "❌ ИСТОЧНИК НЕ НАЙДЕН")
    end
    
    if DeepAnalysisData.modelProperties then
        deepLog("INFO", "📊 Свойства модели записаны")
    end
    
    deepLog("CRITICAL", "🔬 ГЛУБОКИЙ АНАЛИЗ ЗАВЕРШЕН!")
end

-- 🚀 ГЛАВНАЯ ФУНКЦИЯ ГЛУБОКОГО АНАЛИЗА
local function startDeepAnalysis()
    deepLog("ANALYZER", "🚀 ЗАПУСК ГЛУБОКОГО АНАЛИЗА")
    deepLog("ANALYZER", "🎯 Цель: Найти источник временной модели и проанализировать всё")
    
    DeepAnalysisData.isAnalyzing = true
    
    -- Фаза 1: Поиск источников
    local sources = findPotentialSources()
    
    -- Фаза 2: Поиск скриптов
    local scripts = findCreationScripts()
    
    -- Фаза 3: Мониторинг временной модели
    deepLog("ANALYZER", "🔍 Мониторинг появления временной модели...")
    
    local modelConnection = Workspace.DescendantAdded:Connect(function(obj)
        if obj:IsA("Model") then
            local name = obj.Name:lower()
            if name == "dog" or name == "bunny" or name == "golden lab" or 
               name == "cat" or name == "rabbit" or name == "puppy" then
                
                deepLog("FOUND", "🎯 ВРЕМЕННАЯ МОДЕЛЬ ОБНАРУЖЕНА: " .. obj.Name)
                
                -- Глубокий анализ
                deepAnalyzeTempModel(obj)
                
                -- Поиск связи с источником
                local sourceMatch = findSourceConnection(obj, sources)
                
                -- Сравнительный анализ
                if sourceMatch then
                    compareWithSource(obj, sourceMatch.object)
                end
                
                -- Генерация отчета
                generateDeepReport()
                
                -- Отключаем мониторинг
                modelConnection:Disconnect()
                DeepAnalysisData.isAnalyzing = false
            end
        end
    end)
    
    deepLog("ANALYZER", "✅ Глубокий анализ активен!")
    deepLog("ANALYZER", "🥚 ОТКРОЙТЕ ЯЙЦО ДЛЯ АНАЛИЗА!")
    
    -- Автоостановка через 2 минуты
    spawn(function()
        wait(120)
        if modelConnection then
            modelConnection:Disconnect()
        end
        deepLog("ANALYZER", "⏰ Анализ завершен по таймауту")
    end)
end

-- Создаем GUI
local function createAnalyzerGUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "TempModelDeepAnalyzerGUI"
    screenGui.Parent = player:WaitForChild("PlayerGui")
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 350, 0, 120)
    frame.Position = UDim2.new(1, -370, 0, 140)
    frame.BackgroundColor3 = Color3.new(0.1, 0.05, 0.02)
    frame.BorderSizePixel = 0
    frame.Parent = screenGui
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 30)
    title.BackgroundColor3 = Color3.new(0.8, 0.4, 0.1)
    title.BorderSizePixel = 0
    title.Text = "🔬 DEEP ANALYZER"
    title.TextColor3 = Color3.new(1, 1, 1)
    title.TextScaled = true
    title.Font = Enum.Font.SourceSansBold
    title.Parent = frame
    
    local startBtn = Instance.new("TextButton")
    startBtn.Size = UDim2.new(1, -20, 0, 40)
    startBtn.Position = UDim2.new(0, 10, 0, 40)
    startBtn.BackgroundColor3 = Color3.new(0.8, 0.4, 0.1)
    startBtn.BorderSizePixel = 0
    startBtn.Text = "🚀 ГЛУБОКИЙ АНАЛИЗ"
    startBtn.TextColor3 = Color3.new(1, 1, 1)
    startBtn.TextScaled = true
    startBtn.Font = Enum.Font.SourceSansBold
    startBtn.Parent = frame
    
    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(1, -20, 0, 30)
    status.Position = UDim2.new(0, 10, 0, 90)
    status.BackgroundTransparency = 1
    status.Text = "Готов к глубокому анализу"
    status.TextColor3 = Color3.new(1, 1, 1)
    status.TextScaled = true
    status.Font = Enum.Font.SourceSans
    status.Parent = frame
    
    startBtn.MouseButton1Click:Connect(function()
        status.Text = "🔬 Анализ активен!"
        status.TextColor3 = Color3.new(1, 0.4, 0.1)
        startBtn.Text = "✅ АНАЛИЗ АКТИВЕН"
        startBtn.BackgroundColor3 = Color3.new(0.5, 0.5, 0.5)
        startBtn.Active = false
        
        startDeepAnalysis()
    end)
end

-- Запускаем
local consoleTextLabel = createAnalyzerConsole()
createAnalyzerGUI()

deepLog("ANALYZER", "✅ TempModelDeepAnalyzer готов!")
deepLog("ANALYZER", "🔬 Глубокий анализ источника временной модели")
deepLog("ANALYZER", "🚀 Нажмите 'ГЛУБОКИЙ АНАЛИЗ' и откройте яйцо!")
