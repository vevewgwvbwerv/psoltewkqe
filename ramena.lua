-- UniversalSourceHunter.lua
-- УНИВЕРСАЛЬНЫЙ ОХОТНИК ЗА ИСТОЧНИКАМИ: Ищет ВЕЗДЕ и ПО ВСЕМ КРИТЕРИЯМ
-- Находит источник временной модели в любом месте игры

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ServerStorage = game:GetService("ServerStorage")
local StarterGui = game:GetService("StarterGui")
local StarterPack = game:GetService("StarterPack")
local StarterPlayer = game:GetService("StarterPlayer")

local player = Players.LocalPlayer

print("🎯 === UNIVERSAL SOURCE HUNTER ===")
print("🔍 Цель: Найти источник временной модели ВЕЗДЕ")
print("=" .. string.rep("=", 60))

-- 📊 ДАННЫЕ ОХОТНИКА
local HunterData = {
    tempModel = nil,
    allSources = {},
    bestMatches = {},
    searchLocations = {},
    isHunting = false
}

-- 🖥️ КОНСОЛЬ ОХОТНИКА
local HunterConsole = nil
local ConsoleLines = {}
local MaxLines = 80

-- Создание консоли
local function createHunterConsole()
    if HunterConsole then HunterConsole:Destroy() end
    
    HunterConsole = Instance.new("ScreenGui")
    HunterConsole.Name = "UniversalSourceHunterConsole"
    HunterConsole.Parent = player:WaitForChild("PlayerGui")
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 700, 0, 500)
    frame.Position = UDim2.new(0, 10, 0, 10)
    frame.BackgroundColor3 = Color3.new(0.1, 0.02, 0.02)
    frame.BorderSizePixel = 3
    frame.BorderColor3 = Color3.new(1, 0.2, 0.2)
    frame.Parent = HunterConsole
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 35)
    title.BackgroundColor3 = Color3.new(1, 0.2, 0.2)
    title.BorderSizePixel = 0
    title.Text = "🎯 UNIVERSAL SOURCE HUNTER"
    title.TextColor3 = Color3.new(1, 1, 1)
    title.TextScaled = true
    title.Font = Enum.Font.SourceSansBold
    title.Parent = frame
    
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Size = UDim2.new(1, -10, 1, -45)
    scrollFrame.Position = UDim2.new(0, 5, 0, 40)
    scrollFrame.BackgroundColor3 = Color3.new(0.05, 0.01, 0.01)
    scrollFrame.BorderSizePixel = 0
    scrollFrame.ScrollBarThickness = 10
    scrollFrame.Parent = frame
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, -10, 1, 0)
    textLabel.Position = UDim2.new(0, 5, 0, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = "🎯 Универсальный охотник готов..."
    textLabel.TextColor3 = Color3.new(1, 0.9, 0.9)
    textLabel.TextSize = 11
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
        HUNTER = "🎯", SEARCH = "🔍", FOUND = "🎯", MATCH = "✅", 
        LOCATION = "📍", ANALYSIS = "📊", CRITICAL = "🔥", ERROR = "❌"
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

-- 🔍 УНИВЕРСАЛЬНЫЙ ПОИСК ВО ВСЕХ ЛОКАЦИЯХ
local function searchAllLocations()
    hunterLog("HUNTER", "🔍 УНИВЕРСАЛЬНЫЙ ПОИСК ВО ВСЕХ ЛОКАЦИЯХ")
    
    local locations = {
        {name = "ReplicatedStorage", service = ReplicatedStorage},
        {name = "ReplicatedFirst", service = ReplicatedFirst},
        {name = "Workspace", service = Workspace},
        {name = "StarterGui", service = StarterGui},
        {name = "StarterPack", service = StarterPack},
        {name = "StarterPlayer", service = StarterPlayer}
    }
    
    -- Попытка получить ServerStorage (может не работать для клиента)
    local success, serverStorage = pcall(function() return game:GetService("ServerStorage") end)
    if success and serverStorage then
        table.insert(locations, {name = "ServerStorage", service = serverStorage})
    end
    
    local totalFound = 0
    
    for _, location in ipairs(locations) do
        hunterLog("LOCATION", "📍 Поиск в " .. location.name .. "...")
        local foundInLocation = 0
        
        local success, result = pcall(function()
            for _, obj in pairs(location.service:GetDescendants()) do
                if obj:IsA("Model") or obj:IsA("Tool") then
                    local name = obj.Name:lower()
                    
                    -- Расширенный поиск по ключевым словам
                    if name:find("dog") or name:find("bunny") or name:find("lab") or
                       name:find("cat") or name:find("rabbit") or name:find("puppy") or
                       name:find("pet") or name:find("animal") or name:find("golden") or
                       name == "dog" or name == "bunny" or name == "golden lab" then
                        
                        local sourceData = {
                            object = obj,
                            name = obj.Name,
                            path = obj:GetFullName(),
                            location = location.name,
                            children = #obj:GetChildren(),
                            descendants = #obj:GetDescendants(),
                            className = obj.ClassName
                        }
                        
                        HunterData.allSources[obj:GetFullName()] = sourceData
                        foundInLocation = foundInLocation + 1
                        totalFound = totalFound + 1
                        
                        hunterLog("FOUND", "🎯 ИСТОЧНИК НАЙДЕН!", {
                            Name = obj.Name,
                            Location = location.name,
                            Path = obj:GetFullName(),
                            Children = #obj:GetChildren(),
                            ClassName = obj.ClassName
                        })
                    end
                end
            end
        end)
        
        if not success then
            hunterLog("ERROR", "❌ Ошибка доступа к " .. location.name .. ": " .. tostring(result))
        else
            hunterLog("LOCATION", string.format("📍 В %s найдено: %d источников", location.name, foundInLocation))
        end
    end
    
    hunterLog("HUNTER", string.format("🎯 ВСЕГО НАЙДЕНО: %d потенциальных источников", totalFound))
    return totalFound
end

-- 📊 ПРОДВИНУТЫЙ АНАЛИЗ СОВПАДЕНИЙ
local function advancedMatchAnalysis(tempModel)
    hunterLog("ANALYSIS", "📊 ПРОДВИНУТЫЙ АНАЛИЗ СОВПАДЕНИЙ для: " .. tempModel.Name)
    
    local tempStructure = {
        name = tempModel.Name:lower(),
        children = #tempModel:GetChildren(),
        descendants = #tempModel:GetDescendants(),
        className = tempModel.ClassName
    }
    
    -- Детальная структура временной модели
    local tempDetails = {}
    for _, obj in pairs(tempModel:GetDescendants()) do
        tempDetails[obj.ClassName] = (tempDetails[obj.ClassName] or 0) + 1
    end
    
    hunterLog("ANALYSIS", "📊 Структура временной модели:", tempDetails)
    
    local matches = {}
    
    for sourcePath, sourceData in pairs(HunterData.allSources) do
        local score = 0
        local reasons = {}
        
        -- 1. Точное совпадение имени (максимальный приоритет)
        if sourceData.name:lower() == tempStructure.name then
            score = score + 1000
            table.insert(reasons, "Точное имя")
        elseif sourceData.name:lower():find(tempStructure.name) then
            score = score + 500
            table.insert(reasons, "Частичное имя")
        elseif tempStructure.name:find(sourceData.name:lower()) then
            score = score + 300
            table.insert(reasons, "Содержит имя")
        end
        
        -- 2. Совпадение количества детей
        if sourceData.children == tempStructure.children then
            score = score + 200
            table.insert(reasons, "Точные дети")
        elseif math.abs(sourceData.children - tempStructure.children) <= 2 then
            score = score + 100
            table.insert(reasons, "Близкие дети")
        end
        
        -- 3. Совпадение количества потомков
        if sourceData.descendants == tempStructure.descendants then
            score = score + 150
            table.insert(reasons, "Точные потомки")
        elseif math.abs(sourceData.descendants - tempStructure.descendants) <= 5 then
            score = score + 50
            table.insert(reasons, "Близкие потомки")
        end
        
        -- 4. Совпадение типа класса
        if sourceData.className == tempStructure.className then
            score = score + 50
            table.insert(reasons, "Тип класса")
        end
        
        -- 5. Детальное сравнение структуры
        local sourceDetails = {}
        local success, result = pcall(function()
            for _, obj in pairs(sourceData.object:GetDescendants()) do
                sourceDetails[obj.ClassName] = (sourceDetails[obj.ClassName] or 0) + 1
            end
        end)
        
        if success then
            local structureScore = 0
            for className, count in pairs(tempDetails) do
                if sourceDetails[className] and sourceDetails[className] == count then
                    structureScore = structureScore + 10
                elseif sourceDetails[className] and math.abs(sourceDetails[className] - count) <= 1 then
                    structureScore = structureScore + 5
                end
            end
            score = score + structureScore
            if structureScore > 50 then
                table.insert(reasons, "Структура совпадает")
            end
        end
        
        if score > 0 then
            matches[sourcePath] = {
                source = sourceData,
                score = score,
                reasons = reasons,
                confidence = score > 1000 and "ОЧЕНЬ ВЫСОКАЯ" or 
                           (score > 500 and "ВЫСОКАЯ" or 
                           (score > 200 and "СРЕДНЯЯ" or "НИЗКАЯ"))
            }
        end
    end
    
    -- Сортируем по score
    local sortedMatches = {}
    for path, match in pairs(matches) do
        table.insert(sortedMatches, {path = path, match = match})
    end
    
    table.sort(sortedMatches, function(a, b) return a.match.score > b.match.score end)
    
    hunterLog("ANALYSIS", string.format("📊 Найдено %d совпадений", #sortedMatches))
    
    -- Показываем топ-5 совпадений
    for i = 1, math.min(5, #sortedMatches) do
        local item = sortedMatches[i]
        hunterLog("MATCH", string.format("✅ СОВПАДЕНИЕ #%d: %s", i, item.match.source.name), {
            Path = item.path,
            Location = item.match.source.location,
            Score = item.match.score,
            Confidence = item.match.confidence,
            Reasons = table.concat(item.match.reasons, ", ")
        })
    end
    
    HunterData.bestMatches = sortedMatches
    return sortedMatches
end

-- 🎯 ГЛАВНАЯ ФУНКЦИЯ ОХОТЫ
local function startUniversalHunt()
    hunterLog("HUNTER", "🎯 ЗАПУСК УНИВЕРСАЛЬНОЙ ОХОТЫ")
    hunterLog("HUNTER", "🔍 Поиск источника временной модели ВЕЗДЕ")
    
    HunterData.isHunting = true
    
    -- Фаза 1: Поиск во всех локациях
    local totalSources = searchAllLocations()
    
    if totalSources == 0 then
        hunterLog("ERROR", "❌ НИ ОДНОГО ИСТОЧНИКА НЕ НАЙДЕНО!")
        return
    end
    
    -- Фаза 2: Мониторинг временной модели
    hunterLog("HUNTER", "🔍 Мониторинг временной модели...")
    
    local modelConnection = Workspace.DescendantAdded:Connect(function(obj)
        if obj:IsA("Model") then
            local name = obj.Name:lower()
            if name == "dog" or name == "bunny" or name == "golden lab" or 
               name == "cat" or name == "rabbit" or name == "puppy" then
                
                hunterLog("FOUND", "🎯 ВРЕМЕННАЯ МОДЕЛЬ ЗАХВАЧЕНА: " .. obj.Name)
                HunterData.tempModel = obj
                
                -- Продвинутый анализ совпадений
                local matches = advancedMatchAnalysis(obj)
                
                if #matches > 0 then
                    local best = matches[1]
                    hunterLog("CRITICAL", "🔥 ЛУЧШИЙ ИСТОЧНИК НАЙДЕН!", {
                        Source = best.match.source.name,
                        Path = best.path,
                        Location = best.match.source.location,
                        Score = best.match.score,
                        Confidence = best.match.confidence
                    })
                else
                    hunterLog("ERROR", "❌ НИ ОДНОГО ПОДХОДЯЩЕГО ИСТОЧНИКА НЕ НАЙДЕНО")
                end
                
                -- Отключаем охоту
                modelConnection:Disconnect()
                HunterData.isHunting = false
                hunterLog("HUNTER", "🎯 ОХОТА ЗАВЕРШЕНА!")
            end
        end
    end)
    
    hunterLog("HUNTER", "✅ Универсальная охота активна!")
    hunterLog("HUNTER", "🥚 ОТКРОЙТЕ ЯЙЦО ДЛЯ ЗАХВАТА!")
end

-- Создаем GUI
local function createHunterGUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "UniversalSourceHunterGUI"
    screenGui.Parent = player:WaitForChild("PlayerGui")
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 300, 0, 120)
    frame.Position = UDim2.new(1, -320, 0, 270)
    frame.BackgroundColor3 = Color3.new(0.1, 0.02, 0.02)
    frame.BorderSizePixel = 0
    frame.Parent = screenGui
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 30)
    title.BackgroundColor3 = Color3.new(1, 0.2, 0.2)
    title.BorderSizePixel = 0
    title.Text = "🎯 SOURCE HUNTER"
    title.TextColor3 = Color3.new(1, 1, 1)
    title.TextScaled = true
    title.Font = Enum.Font.SourceSansBold
    title.Parent = frame
    
    local startBtn = Instance.new("TextButton")
    startBtn.Size = UDim2.new(1, -20, 0, 40)
    startBtn.Position = UDim2.new(0, 10, 0, 40)
    startBtn.BackgroundColor3 = Color3.new(1, 0.2, 0.2)
    startBtn.BorderSizePixel = 0
    startBtn.Text = "🎯 НАЧАТЬ ОХОТУ"
    startBtn.TextColor3 = Color3.new(1, 1, 1)
    startBtn.TextScaled = true
    startBtn.Font = Enum.Font.SourceSansBold
    startBtn.Parent = frame
    
    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(1, -20, 0, 30)
    status.Position = UDim2.new(0, 10, 0, 90)
    status.BackgroundTransparency = 1
    status.Text = "Готов к универсальной охоте"
    status.TextColor3 = Color3.new(1, 1, 1)
    status.TextScaled = true
    status.Font = Enum.Font.SourceSans
    status.Parent = frame
    
    startBtn.MouseButton1Click:Connect(function()
        status.Text = "🎯 Охота активна!"
        status.TextColor3 = Color3.new(1, 0.2, 0.2)
        startBtn.Text = "✅ ОХОТА АКТИВНА"
        startBtn.BackgroundColor3 = Color3.new(0.5, 0.5, 0.5)
        startBtn.Active = false
        
        startUniversalHunt()
    end)
end

-- Запускаем
local consoleTextLabel = createHunterConsole()
createHunterGUI()

hunterLog("HUNTER", "✅ UniversalSourceHunter готов!")
hunterLog("HUNTER", "🎯 Универсальная охота за источником временной модели")
hunterLog("HUNTER", "🔍 Поиск ВЕЗДЕ: ReplicatedStorage, Workspace, StarterGui и др.")
hunterLog("HUNTER", "🚀 Нажмите 'НАЧАТЬ ОХОТУ' и откройте яйцо!")
