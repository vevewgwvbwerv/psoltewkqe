-- FullModelHunter.lua
-- ОХОТНИК ЗА ПОЛНОЙ МОДЕЛЬЮ: Ищет источник УЖЕ ГОТОВОЙ модели питомца
-- Фокус на поиске модели с 18 частями и 14 Motor6D, а не базовой модели

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ServerStorage = game:GetService("ServerStorage")
local StarterGui = game:GetService("StarterGui")
local StarterPack = game:GetService("StarterPack")
local StarterPlayer = game:GetService("StarterPlayer")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

print("🔍 === FULL MODEL HUNTER ===")
print("🎯 Цель: Найти источник ПОЛНОЙ модели питомца (18 частей, 14 Motor6D)")
print("=" .. string.rep("=", 60))

-- 📊 ДАННЫЕ ОХОТНИКА ПОЛНОЙ МОДЕЛИ
local FullHunterData = {
    targetStructure = {
        children = 18,
        descendants = 34,
        motor6ds = 14,
        baseParts = 16
    },
    foundSources = {},
    perfectMatches = {},
    closeMatches = {},
    targetModel = nil,
    isHunting = false
}

-- 🖥️ КОНСОЛЬ ОХОТНИКА
local HunterConsole = nil
local ConsoleLines = {}
local MaxLines = 120

-- Создание консоли
local function createHunterConsole()
    if HunterConsole then HunterConsole:Destroy() end
    
    HunterConsole = Instance.new("ScreenGui")
    HunterConsole.Name = "FullModelHunterConsole"
    HunterConsole.Parent = player:WaitForChild("PlayerGui")
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 900, 0, 700)
    frame.Position = UDim2.new(0, 10, 0, 10)
    frame.BackgroundColor3 = Color3.new(0.1, 0.05, 0.02)
    frame.BorderSizePixel = 3
    frame.BorderColor3 = Color3.new(1, 0.5, 0.1)
    frame.Parent = HunterConsole
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 35)
    title.BackgroundColor3 = Color3.new(1, 0.5, 0.1)
    title.BorderSizePixel = 0
    title.Text = "🔍 FULL MODEL HUNTER"
    title.TextColor3 = Color3.new(0, 0, 0)
    title.TextScaled = true
    title.Font = Enum.Font.SourceSansBold
    title.Parent = frame
    
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Size = UDim2.new(1, -10, 1, -45)
    scrollFrame.Position = UDim2.new(0, 5, 0, 40)
    scrollFrame.BackgroundColor3 = Color3.new(0.05, 0.02, 0.01)
    scrollFrame.BorderSizePixel = 0
    scrollFrame.ScrollBarThickness = 15
    scrollFrame.Parent = frame
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, -10, 1, 0)
    textLabel.Position = UDim2.new(0, 5, 0, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = "🔍 Охотник за полной моделью готов..."
    textLabel.TextColor3 = Color3.new(1, 0.9, 0.8)
    textLabel.TextSize = 10
    textLabel.Font = Enum.Font.SourceSans
    textLabel.TextXAlignment = Enum.TextXAlignment.Left
    textLabel.TextYAlignment = Enum.TextYAlignment.Top
    textLabel.TextWrapped = true
    textLabel.Parent = scrollFrame
    
    return textLabel
end

-- Функция логирования охотника
local function hunterLog(category, message, data)
    local timestamp = os.date("%H:%M:%S.") .. string.format("%03d", (tick() % 1) * 1000)
    
    local prefixes = {
        HUNTER = "🔍", SEARCH = "🔎", FOUND = "🎯", PERFECT = "💎",
        CLOSE = "🔶", ANALYSIS = "📊", CRITICAL = "🔥", SUCCESS = "✅", 
        ERROR = "❌", INFO = "ℹ️", DETAIL = "📝", LOCATION = "📍"
    }
    
    local logLine = string.format("[%s] %s %s", timestamp, prefixes[category] or "ℹ️", message)
    
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
    if HunterConsole then
        local textLabel = HunterConsole:FindFirstChild("Frame"):FindFirstChild("ScrollingFrame"):FindFirstChild("TextLabel")
        if textLabel then
            textLabel.Text = table.concat(ConsoleLines, "\n")
            local scrollFrame = textLabel.Parent
            scrollFrame.CanvasSize = UDim2.new(0, 0, 0, textLabel.TextBounds.Y + 10)
            scrollFrame.CanvasPosition = Vector2.new(0, scrollFrame.CanvasSize.Y.Offset)
        end
    end
    
    print(logLine)
end

-- 📊 АНАЛИЗ СТРУКТУРЫ МОДЕЛИ
local function analyzeModelStructure(model)
    local structure = {
        children = #model:GetChildren(),
        descendants = #model:GetDescendants(),
        baseParts = 0,
        motor6ds = 0,
        meshParts = 0,
        scripts = 0,
        animators = 0,
        unionOperations = 0,
        weldConstraints = 0,
        highlights = 0
    }
    
    for _, obj in pairs(model:GetDescendants()) do
        if obj:IsA("BasePart") then
            structure.baseParts = structure.baseParts + 1
        elseif obj:IsA("Motor6D") then
            structure.motor6ds = structure.motor6ds + 1
        elseif obj:IsA("MeshPart") then
            structure.meshParts = structure.meshParts + 1
        elseif obj:IsA("Script") or obj:IsA("LocalScript") then
            structure.scripts = structure.scripts + 1
        elseif obj:IsA("Animator") then
            structure.animators = structure.animators + 1
        elseif obj:IsA("UnionOperation") then
            structure.unionOperations = structure.unionOperations + 1
        elseif obj:IsA("WeldConstraint") then
            structure.weldConstraints = structure.weldConstraints + 1
        elseif obj:IsA("Highlight") then
            structure.highlights = structure.highlights + 1
        end
    end
    
    return structure
end

-- 🎯 ПРОВЕРКА СООТВЕТСТВИЯ ЦЕЛЕВОЙ СТРУКТУРЕ
local function checkStructureMatch(structure, modelName, modelPath)
    local target = FullHunterData.targetStructure
    
    -- Точное совпадение (идеальное)
    if structure.children == target.children and 
       structure.motor6ds == target.motor6ds and
       structure.baseParts == target.baseParts then
        
        FullHunterData.perfectMatches[modelPath] = {
            model = modelName,
            path = modelPath,
            structure = structure,
            matchType = "PERFECT"
        }
        
        hunterLog("PERFECT", "💎 ИДЕАЛЬНОЕ СОВПАДЕНИЕ НАЙДЕНО!", {
            Model = modelName,
            Path = modelPath,
            Children = structure.children,
            Motor6Ds = structure.motor6ds,
            BaseParts = structure.baseParts,
            MatchType = "PERFECT"
        })
        
        return "PERFECT"
    end
    
    -- Близкое совпадение
    local childrenDiff = math.abs(structure.children - target.children)
    local motor6dDiff = math.abs(structure.motor6ds - target.motor6ds)
    local partsDiff = math.abs(structure.baseParts - target.baseParts)
    
    if childrenDiff <= 3 and motor6dDiff <= 3 and partsDiff <= 3 then
        FullHunterData.closeMatches[modelPath] = {
            model = modelName,
            path = modelPath,
            structure = structure,
            matchType = "CLOSE",
            differences = {
                children = childrenDiff,
                motor6ds = motor6dDiff,
                baseParts = partsDiff
            }
        }
        
        hunterLog("CLOSE", "🔶 БЛИЗКОЕ СОВПАДЕНИЕ НАЙДЕНО!", {
            Model = modelName,
            Path = modelPath,
            Children = string.format("%d (diff: %d)", structure.children, childrenDiff),
            Motor6Ds = string.format("%d (diff: %d)", structure.motor6ds, motor6dDiff),
            BaseParts = string.format("%d (diff: %d)", structure.baseParts, partsDiff),
            MatchType = "CLOSE"
        })
        
        return "CLOSE"
    end
    
    return "NO_MATCH"
end

-- 🔎 ГЛУБОКИЙ ПОИСК ВО ВСЕХ СЕРВИСАХ
local function deepSearchAllServices()
    hunterLog("HUNTER", "🔍 ГЛУБОКИЙ ПОИСК ПОЛНОЙ МОДЕЛИ ВО ВСЕХ СЕРВИСАХ")
    
    local services = {
        {name = "ReplicatedStorage", service = ReplicatedStorage},
        {name = "ReplicatedFirst", service = ReplicatedFirst},
        {name = "Workspace", service = Workspace},
        {name = "StarterGui", service = StarterGui},
        {name = "StarterPack", service = StarterPack},
        {name = "StarterPlayer", service = StarterPlayer}
    }
    
    -- Попытка получить ServerStorage
    local success, serverStorage = pcall(function() return game:GetService("ServerStorage") end)
    if success and serverStorage then
        table.insert(services, {name = "ServerStorage", service = serverStorage})
    end
    
    local totalFound = 0
    local perfectCount = 0
    local closeCount = 0
    
    for _, serviceData in ipairs(services) do
        hunterLog("LOCATION", "📍 Поиск в " .. serviceData.name .. "...")
        local foundInService = 0
        
        local success, result = pcall(function()
            for _, obj in pairs(serviceData.service:GetDescendants()) do
                if obj:IsA("Model") then
                    local name = obj.Name:lower()
                    
                    -- Расширенный поиск по именам питомцев
                    if name:find("dog") or name:find("bunny") or name:find("lab") or
                       name:find("cat") or name:find("rabbit") or name:find("puppy") or
                       name:find("pet") or name:find("animal") or name:find("golden") or
                       name == "dog" or name == "bunny" or name == "golden lab" or
                       name == "goldenlab" then
                        
                        local structure = analyzeModelStructure(obj)
                        local matchType = checkStructureMatch(structure, obj.Name, obj:GetFullName())
                        
                        FullHunterData.foundSources[obj:GetFullName()] = {
                            model = obj,
                            name = obj.Name,
                            path = obj:GetFullName(),
                            location = serviceData.name,
                            structure = structure,
                            matchType = matchType
                        }
                        
                        foundInService = foundInService + 1
                        totalFound = totalFound + 1
                        
                        if matchType == "PERFECT" then
                            perfectCount = perfectCount + 1
                        elseif matchType == "CLOSE" then
                            closeCount = closeCount + 1
                        else
                            hunterLog("FOUND", "🎯 Модель найдена: " .. obj.Name, {
                                Location = serviceData.name,
                                Path = obj:GetFullName(),
                                Children = structure.children,
                                Motor6Ds = structure.motor6ds,
                                BaseParts = structure.baseParts,
                                Match = "NO_MATCH"
                            })
                        end
                    end
                end
            end
        end)
        
        if not success then
            hunterLog("ERROR", "❌ Ошибка доступа к " .. serviceData.name .. ": " .. tostring(result))
        else
            hunterLog("LOCATION", string.format("📍 В %s найдено: %d моделей", serviceData.name, foundInService))
        end
    end
    
    hunterLog("HUNTER", string.format("🔍 ИТОГИ ПОИСКА: %d моделей найдено", totalFound))
    hunterLog("HUNTER", string.format("💎 Идеальных совпадений: %d", perfectCount))
    hunterLog("HUNTER", string.format("🔶 Близких совпадений: %d", closeCount))
    
    return {total = totalFound, perfect = perfectCount, close = closeCount}
end

-- 📊 СРАВНЕНИЕ С ЦЕЛЕВОЙ МОДЕЛЬЮ
local function compareWithTarget(targetModel)
    hunterLog("ANALYSIS", "📊 СРАВНЕНИЕ С ЦЕЛЕВОЙ МОДЕЛЬЮ: " .. targetModel.Name)
    
    FullHunterData.targetModel = targetModel
    local targetStructure = analyzeModelStructure(targetModel)
    
    hunterLog("ANALYSIS", "📊 Структура целевой модели:", targetStructure)
    
    -- Обновляем целевую структуру на основе реальной модели
    FullHunterData.targetStructure = targetStructure
    
    -- Ищем точные совпадения среди найденных источников
    local exactMatches = {}
    
    for path, sourceData in pairs(FullHunterData.foundSources) do
        local source = sourceData.structure
        
        if source.children == targetStructure.children and
           source.motor6ds == targetStructure.motor6ds and
           source.baseParts == targetStructure.baseParts then
            
            exactMatches[path] = sourceData
            
            hunterLog("SUCCESS", "✅ ТОЧНОЕ СОВПАДЕНИЕ С ЦЕЛЕВОЙ МОДЕЛЬЮ!", {
                Source = sourceData.name,
                Location = sourceData.location,
                Path = path,
                Children = source.children,
                Motor6Ds = source.motor6ds,
                BaseParts = source.baseParts
            })
        end
    end
    
    if next(exactMatches) then
        hunterLog("CRITICAL", string.format("🔥 НАЙДЕНО %d ТОЧНЫХ СОВПАДЕНИЙ!", #exactMatches))
        return exactMatches
    else
        hunterLog("ERROR", "❌ НИ ОДНОГО ТОЧНОГО СОВПАДЕНИЯ НЕ НАЙДЕНО")
        return {}
    end
end

-- 📋 ГЕНЕРАЦИЯ ОТЧЕТА ОХОТЫ
local function generateHuntingReport()
    hunterLog("CRITICAL", "📋 === ОТЧЕТ ОХОТЫ ЗА ПОЛНОЙ МОДЕЛЬЮ ===")
    
    hunterLog("INFO", string.format("🔍 Всего найдено моделей: %d", #FullHunterData.foundSources))
    hunterLog("INFO", string.format("💎 Идеальных совпадений: %d", #FullHunterData.perfectMatches))
    hunterLog("INFO", string.format("🔶 Близких совпадений: %d", #FullHunterData.closeMatches))
    
    -- Показываем лучшие совпадения
    if next(FullHunterData.perfectMatches) then
        hunterLog("CRITICAL", "🔥 ИДЕАЛЬНЫЕ СОВПАДЕНИЯ:")
        for path, match in pairs(FullHunterData.perfectMatches) do
            hunterLog("PERFECT", string.format("💎 %s", match.model), {
                Path = path,
                Children = match.structure.children,
                Motor6Ds = match.structure.motor6ds,
                BaseParts = match.structure.baseParts
            })
        end
    end
    
    if next(FullHunterData.closeMatches) then
        hunterLog("CRITICAL", "🔥 БЛИЗКИЕ СОВПАДЕНИЯ:")
        for path, match in pairs(FullHunterData.closeMatches) do
            hunterLog("CLOSE", string.format("🔶 %s", match.model), {
                Path = path,
                ChildrenDiff = match.differences.children,
                Motor6DsDiff = match.differences.motor6ds,
                PartsDiff = match.differences.baseParts
            })
        end
    end
    
    hunterLog("CRITICAL", "🔍 ОХОТА ЗА ПОЛНОЙ МОДЕЛЬЮ ЗАВЕРШЕНА!")
end

-- 🚀 ГЛАВНАЯ ФУНКЦИЯ ОХОТЫ
local function startFullModelHunt()
    hunterLog("HUNTER", "🚀 ЗАПУСК ОХОТЫ ЗА ПОЛНОЙ МОДЕЛЬЮ")
    hunterLog("HUNTER", "🎯 Цель: Найти источник модели с 18 частями и 14 Motor6D")
    
    FullHunterData.isHunting = true
    
    -- Глубокий поиск во всех сервисах
    local searchResults = deepSearchAllServices()
    
    if searchResults.total == 0 then
        hunterLog("ERROR", "❌ НИ ОДНОЙ МОДЕЛИ НЕ НАЙДЕНО!")
        return
    end
    
    -- Мониторинг появления целевой модели в Visuals
    local visuals = Workspace:FindFirstChild("Visuals")
    if visuals then
        hunterLog("SUCCESS", "✅ Мониторинг Visuals для сравнения...")
        
        local visualsConnection = visuals.ChildAdded:Connect(function(obj)
            if obj:IsA("Model") then
                local name = obj.Name:lower()
                if name == "dog" or name == "bunny" or name == "golden lab" or 
                   name == "cat" or name == "rabbit" or name == "puppy" or
                   name == "goldenlab" or name:find("lab") then
                    
                    hunterLog("FOUND", "🎯 ЦЕЛЕВАЯ МОДЕЛЬ В VISUALS: " .. obj.Name)
                    
                    -- Сравниваем с найденными источниками
                    local exactMatches = compareWithTarget(obj)
                    
                    -- Генерируем отчет
                    generateHuntingReport()
                    
                    -- Отключаем мониторинг
                    visualsConnection:Disconnect()
                    FullHunterData.isHunting = false
                end
            end
        end)
    else
        -- Если нет Visuals, просто генерируем отчет
        generateHuntingReport()
        FullHunterData.isHunting = false
    end
    
    hunterLog("HUNTER", "✅ Охота за полной моделью активна!")
    hunterLog("HUNTER", "🥚 ОТКРОЙТЕ ЯЙЦО ДЛЯ СРАВНЕНИЯ!")
end

-- Создаем GUI
local function createHunterGUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "FullModelHunterGUI"
    screenGui.Parent = player:WaitForChild("PlayerGui")
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 350, 0, 120)
    frame.Position = UDim2.new(1, -370, 0, 10)
    frame.BackgroundColor3 = Color3.new(0.1, 0.05, 0.02)
    frame.BorderSizePixel = 0
    frame.Parent = screenGui
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 30)
    title.BackgroundColor3 = Color3.new(1, 0.5, 0.1)
    title.BorderSizePixel = 0
    title.Text = "🔍 FULL MODEL HUNTER"
    title.TextColor3 = Color3.new(0, 0, 0)
    title.TextScaled = true
    title.Font = Enum.Font.SourceSansBold
    title.Parent = frame
    
    local startBtn = Instance.new("TextButton")
    startBtn.Size = UDim2.new(1, -20, 0, 40)
    startBtn.Position = UDim2.new(0, 10, 0, 40)
    startBtn.BackgroundColor3 = Color3.new(1, 0.5, 0.1)
    startBtn.BorderSizePixel = 0
    startBtn.Text = "🔍 ОХОТА ЗА ПОЛНОЙ МОДЕЛЬЮ"
    startBtn.TextColor3 = Color3.new(0, 0, 0)
    startBtn.TextScaled = true
    startBtn.Font = Enum.Font.SourceSansBold
    startBtn.Parent = frame
    
    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(1, -20, 0, 30)
    status.Position = UDim2.new(0, 10, 0, 90)
    status.BackgroundTransparency = 1
    status.Text = "Готов к охоте за полной моделью"
    status.TextColor3 = Color3.new(1, 1, 1)
    status.TextScaled = true
    status.Font = Enum.Font.SourceSans
    status.Parent = frame
    
    startBtn.MouseButton1Click:Connect(function()
        status.Text = "🔍 Охота активна!"
        status.TextColor3 = Color3.new(1, 0.5, 0.1)
        startBtn.Text = "✅ ОХОТА АКТИВНА"
        startBtn.BackgroundColor3 = Color3.new(0.5, 0.5, 0.5)
        startBtn.Active = false
        
        startFullModelHunt()
    end)
end

-- Запускаем
local consoleTextLabel = createHunterConsole()
createHunterGUI()

hunterLog("HUNTER", "✅ FullModelHunter готов!")
hunterLog("HUNTER", "🔍 Охота за источником ПОЛНОЙ модели питомца")
hunterLog("HUNTER", "🎯 Цель: 18 частей, 14 Motor6D, 34 потомка")
hunterLog("HUNTER", "🚀 Нажмите 'ОХОТА ЗА ПОЛНОЙ МОДЕЛЬЮ' для поиска!")
