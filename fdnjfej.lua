-- VisualsToToolTransformAnalyzer.lua
-- АНАЛИЗАТОР ПРЕВРАЩЕНИЯ: Отслеживает превращение модели из Visuals в Tool в руках игрока
-- Анализирует процесс: Visuals (19 частей) → PlayerCharacter Tool (3 части, 15 Motor6D)

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer

print("🔄 === VISUALS TO TOOL TRANSFORM ANALYZER ===")
print("🎯 Цель: Отследить превращение модели Visuals → Tool в руках")
print("=" .. string.rep("=", 70))

-- 📊 ДАННЫЕ АНАЛИЗАТОРА ПРЕВРАЩЕНИЯ
local TransformData = {
    visualsModel = nil,
    playerTool = nil,
    worldModel = nil,
    transformSequence = {},
    snapshots = {},
    isAnalyzing = false,
    startTime = 0,
    connections = {},
    transformStages = {
        "VISUALS_APPEARED",
        "VISUALS_DISAPPEARED", 
        "TOOL_CREATED",
        "TOOL_EQUIPPED",
        "WORLD_MODEL_CREATED"
    }
}

-- 🖥️ КОНСОЛЬ АНАЛИЗАТОРА
local TransformConsole = nil
local ConsoleLines = {}
local MaxLines = 180

-- Создание консоли
local function createTransformConsole()
    if TransformConsole then TransformConsole:Destroy() end
    
    TransformConsole = Instance.new("ScreenGui")
    TransformConsole.Name = "VisualsToToolTransformConsole"
    TransformConsole.Parent = player:WaitForChild("PlayerGui")
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 1050, 0, 850)
    frame.Position = UDim2.new(0, 10, 0, 10)
    frame.BackgroundColor3 = Color3.new(0.1, 0.02, 0.05)
    frame.BorderSizePixel = 3
    frame.BorderColor3 = Color3.new(1, 0.2, 0.5)
    frame.Parent = TransformConsole
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 35)
    title.BackgroundColor3 = Color3.new(1, 0.2, 0.5)
    title.BorderSizePixel = 0
    title.Text = "🔄 VISUALS → TOOL TRANSFORM ANALYZER"
    title.TextColor3 = Color3.new(1, 1, 1)
    title.TextScaled = true
    title.Font = Enum.Font.SourceSansBold
    title.Parent = frame
    
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Size = UDim2.new(1, -10, 1, -45)
    scrollFrame.Position = UDim2.new(0, 5, 0, 40)
    scrollFrame.BackgroundColor3 = Color3.new(0.05, 0.01, 0.02)
    scrollFrame.BorderSizePixel = 0
    scrollFrame.ScrollBarThickness = 15
    scrollFrame.Parent = frame
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, -10, 1, 0)
    textLabel.Position = UDim2.new(0, 5, 0, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = "🔄 Анализатор превращения готов к работе..."
    textLabel.TextColor3 = Color3.new(1, 0.9, 0.95)
    textLabel.TextSize = 10
    textLabel.Font = Enum.Font.SourceSans
    textLabel.TextXAlignment = Enum.TextXAlignment.Left
    textLabel.TextYAlignment = Enum.TextYAlignment.Top
    textLabel.TextWrapped = true
    textLabel.Parent = scrollFrame
    
    return textLabel
end

-- Функция логирования анализатора
local function transformLog(category, message, data)
    local timestamp = os.date("%H:%M:%S.") .. string.format("%03d", (tick() % 1) * 1000)
    local relativeTime = TransformData.startTime > 0 and string.format("(+%.3f)", tick() - TransformData.startTime) or ""
    
    local prefixes = {
        TRANSFORM = "🔄", VISUALS = "🎭", TOOL = "🔧", PLAYER = "👤",
        WORLD = "🌍", STAGE = "📍", SNAPSHOT = "📸", COMPARE = "⚖️",
        CRITICAL = "🔥", SUCCESS = "✅", ERROR = "❌", INFO = "ℹ️", 
        DETAIL = "📝", SEQUENCE = "🔄", CREATION = "⚡", DISAPPEAR = "💨"
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
    if TransformConsole then
        local textLabel = TransformConsole:FindFirstChild("Frame"):FindFirstChild("ScrollingFrame"):FindFirstChild("TextLabel")
        if textLabel then
            textLabel.Text = table.concat(ConsoleLines, "\n")
            local scrollFrame = textLabel.Parent
            scrollFrame.CanvasSize = UDim2.new(0, 0, 0, textLabel.TextBounds.Y + 10)
            scrollFrame.CanvasPosition = Vector2.new(0, scrollFrame.CanvasSize.Y.Offset)
        end
    end
    
    print(logLine)
end

-- 📸 СОЗДАНИЕ ДЕТАЛЬНОГО СНИМКА ОБЪЕКТА
local function createDetailedSnapshot(obj, snapshotName, stage)
    if not obj or not obj.Parent then
        return nil
    end
    
    local snapshot = {
        name = snapshotName,
        stage = stage,
        timestamp = tick(),
        relativeTime = tick() - TransformData.startTime,
        object = {
            name = obj.Name,
            className = obj.ClassName,
            parent = obj.Parent and obj.Parent.Name or "nil",
            fullPath = obj:GetFullName()
        },
        structure = {
            children = #obj:GetChildren(),
            descendants = #obj:GetDescendants()
        },
        components = {},
        properties = {}
    }
    
    -- Анализ компонентов
    local componentCounts = {}
    local importantObjects = {}
    
    for _, child in pairs(obj:GetDescendants()) do
        local className = child.ClassName
        componentCounts[className] = (componentCounts[className] or 0) + 1
        
        -- Сохраняем важные объекты
        if className == "Motor6D" or className == "Weld" or className == "WeldConstraint" or 
           className == "Handle" or className == "Tool" or className == "Animator" then
            table.insert(importantObjects, {
                name = child.Name,
                className = className,
                parent = child.Parent and child.Parent.Name or "nil"
            })
        end
    end
    
    snapshot.components = componentCounts
    snapshot.importantObjects = importantObjects
    
    -- Анализ свойств для Tool
    if obj:IsA("Tool") then
        snapshot.properties = {
            RequiresHandle = obj.RequiresHandle,
            CanBeDropped = obj.CanBeDropped,
            ManualActivationOnly = obj.ManualActivationOnly,
            Enabled = obj.Enabled
        }
        
        -- Поиск Handle
        local handle = obj:FindFirstChild("Handle")
        if handle then
            snapshot.handle = {
                name = handle.Name,
                className = handle.ClassName,
                size = tostring(handle.Size),
                material = tostring(handle.Material),
                shape = tostring(handle.Shape)
            }
        end
    end
    
    transformLog("SNAPSHOT", string.format("📸 СНИМОК: %s (%s)", snapshotName, stage), {
        Object = obj.Name,
        Path = obj:GetFullName(),
        Children = snapshot.structure.children,
        Descendants = snapshot.structure.descendants,
        RelativeTime = string.format("%.3f сек", snapshot.relativeTime)
    })
    
    -- Показываем компоненты
    for className, count in pairs(componentCounts) do
        if count > 0 then
            transformLog("DETAIL", string.format("  %s: %d", className, count))
        end
    end
    
    -- Показываем важные объекты
    if #importantObjects > 0 then
        transformLog("DETAIL", "  Важные объекты:")
        for _, obj in ipairs(importantObjects) do
            transformLog("DETAIL", string.format("    %s (%s) в %s", obj.name, obj.className, obj.parent))
        end
    end
    
    return snapshot
end

-- ⚖️ СРАВНЕНИЕ СНИМКОВ
local function compareSnapshots(before, after, comparisonName)
    if not before or not after then return end
    
    transformLog("COMPARE", string.format("⚖️ СРАВНЕНИЕ: %s", comparisonName))
    transformLog("COMPARE", string.format("  %s → %s", before.name, after.name))
    
    local childrenDiff = after.structure.children - before.structure.children
    local descendantsDiff = after.structure.descendants - before.structure.descendants
    local timeDiff = after.relativeTime - before.relativeTime
    
    transformLog("COMPARE", "📊 Изменения структуры:", {
        ChildrenDiff = string.format("%+d (%d → %d)", childrenDiff, before.structure.children, after.structure.children),
        DescendantsDiff = string.format("%+d (%d → %d)", descendantsDiff, before.structure.descendants, after.structure.descendants),
        TimeDiff = string.format("%.3f сек", timeDiff)
    })
    
    -- Сравнение компонентов
    local allComponents = {}
    for className, _ in pairs(before.components) do allComponents[className] = true end
    for className, _ in pairs(after.components) do allComponents[className] = true end
    
    transformLog("COMPARE", "🔧 Изменения компонентов:")
    for className, _ in pairs(allComponents) do
        local beforeCount = before.components[className] or 0
        local afterCount = after.components[className] or 0
        local diff = afterCount - beforeCount
        
        if diff ~= 0 then
            transformLog("DETAIL", string.format("  %s: %+d (%d → %d)", className, diff, beforeCount, afterCount))
        end
    end
end

-- 🎭 МОНИТОРИНГ VISUALS
local function monitorVisuals()
    transformLog("VISUALS", "🎭 МОНИТОРИНГ VISUALS")
    
    local visuals = Workspace:FindFirstChild("Visuals")
    if not visuals then
        transformLog("ERROR", "❌ Папка Visuals не найдена")
        return
    end
    
    -- Мониторинг появления модели в Visuals
    local visualsAddedConnection = visuals.ChildAdded:Connect(function(obj)
        if obj:IsA("Model") then
            local name = obj.Name:lower()
            if name == "dog" or name == "bunny" or name == "golden lab" or 
               name == "cat" or name == "rabbit" or name == "puppy" or
               name == "goldenlab" or name:find("lab") then
                
                transformLog("STAGE", "📍 ЭТАП: VISUALS_APPEARED")
                transformLog("VISUALS", string.format("🎭 МОДЕЛЬ В VISUALS: %s", obj.Name))
                
                TransformData.visualsModel = obj
                local visualsSnapshot = createDetailedSnapshot(obj, "visuals_model", "VISUALS_APPEARED")
                TransformData.snapshots["visuals"] = visualsSnapshot
                
                table.insert(TransformData.transformSequence, {
                    stage = "VISUALS_APPEARED",
                    timestamp = tick(),
                    relativeTime = tick() - TransformData.startTime,
                    object = obj,
                    snapshot = visualsSnapshot
                })
            end
        end
    end)
    
    -- Мониторинг исчезновения модели из Visuals
    local visualsRemovedConnection = visuals.ChildRemoved:Connect(function(obj)
        if obj == TransformData.visualsModel then
            transformLog("STAGE", "📍 ЭТАП: VISUALS_DISAPPEARED")
            transformLog("DISAPPEAR", string.format("💨 МОДЕЛЬ ИСЧЕЗЛА ИЗ VISUALS: %s", obj.Name))
            
            table.insert(TransformData.transformSequence, {
                stage = "VISUALS_DISAPPEARED",
                timestamp = tick(),
                relativeTime = tick() - TransformData.startTime,
                object = obj
            })
        end
    end)
    
    table.insert(TransformData.connections, visualsAddedConnection)
    table.insert(TransformData.connections, visualsRemovedConnection)
end

-- 👤 МОНИТОРИНГ ПЕРСОНАЖА ИГРОКА
local function monitorPlayerCharacter()
    transformLog("PLAYER", "👤 МОНИТОРИНГ ПЕРСОНАЖА ИГРОКА")
    
    local function setupCharacterMonitoring(character)
        if not character then return end
        
        transformLog("PLAYER", "👤 Настройка мониторинга персонажа: " .. character.Name)
        
        -- Мониторинг появления Tool в персонаже
        local characterAddedConnection = character.ChildAdded:Connect(function(obj)
            if obj:IsA("Tool") then
                local name = obj.Name:lower()
                if name:find("bunny") or name:find("dog") or name:find("lab") or 
                   name:find("cat") or name:find("rabbit") or name:find("kg") or name:find("age") then
                    
                    transformLog("STAGE", "📍 ЭТАП: TOOL_CREATED")
                    transformLog("TOOL", string.format("🔧 TOOL СОЗДАН В ПЕРСОНАЖЕ: %s", obj.Name))
                    
                    TransformData.playerTool = obj
                    local toolSnapshot = createDetailedSnapshot(obj, "player_tool", "TOOL_CREATED")
                    TransformData.snapshots["tool"] = toolSnapshot
                    
                    table.insert(TransformData.transformSequence, {
                        stage = "TOOL_CREATED",
                        timestamp = tick(),
                        relativeTime = tick() - TransformData.startTime,
                        object = obj,
                        snapshot = toolSnapshot
                    })
                    
                    -- Сравниваем с моделью из Visuals
                    if TransformData.snapshots["visuals"] then
                        compareSnapshots(TransformData.snapshots["visuals"], toolSnapshot, "VISUALS → TOOL")
                    end
                    
                    -- Мониторинг экипировки Tool
                    obj.Equipped:Connect(function()
                        transformLog("STAGE", "📍 ЭТАП: TOOL_EQUIPPED")
                        transformLog("TOOL", string.format("🔧 TOOL ЭКИПИРОВАН: %s", obj.Name))
                        
                        table.insert(TransformData.transformSequence, {
                            stage = "TOOL_EQUIPPED",
                            timestamp = tick(),
                            relativeTime = tick() - TransformData.startTime,
                            object = obj
                        })
                    end)
                    
                    obj.Unequipped:Connect(function()
                        transformLog("TOOL", string.format("🔧 TOOL СНЯТ: %s", obj.Name))
                    end)
                end
            end
        end)
        
        table.insert(TransformData.connections, characterAddedConnection)
    end
    
    -- Настройка для текущего персонажа
    if player.Character then
        setupCharacterMonitoring(player.Character)
    end
    
    -- Настройка для будущих персонажей
    local characterAddedConnection = player.CharacterAdded:Connect(function(character)
        setupCharacterMonitoring(character)
    end)
    
    table.insert(TransformData.connections, characterAddedConnection)
end

-- 🌍 МОНИТОРИНГ МИРА ИГРОКА
local function monitorPlayerWorld()
    transformLog("WORLD", "🌍 МОНИТОРИНГ МИРА ИГРОКА")
    
    -- Мониторинг появления модели в мире игрока
    local workspaceConnection = Workspace.ChildAdded:Connect(function(obj)
        if obj:IsA("Model") and obj.Name:find(player.Name) then
            -- Мониторим содержимое папки игрока
            local playerFolderConnection = obj.ChildAdded:Connect(function(child)
                if child:IsA("Model") then
                    local name = child.Name:lower()
                    if name:find("bunny") or name:find("dog") or name:find("lab") or 
                       name:find("cat") or name:find("rabbit") or name:find("kg") or name:find("age") then
                        
                        transformLog("STAGE", "📍 ЭТАП: WORLD_MODEL_CREATED")
                        transformLog("WORLD", string.format("🌍 МОДЕЛЬ В МИРЕ: %s", child.Name))
                        
                        TransformData.worldModel = child
                        local worldSnapshot = createDetailedSnapshot(child, "world_model", "WORLD_MODEL_CREATED")
                        TransformData.snapshots["world"] = worldSnapshot
                        
                        table.insert(TransformData.transformSequence, {
                            stage = "WORLD_MODEL_CREATED",
                            timestamp = tick(),
                            relativeTime = tick() - TransformData.startTime,
                            object = child,
                            snapshot = worldSnapshot
                        })
                        
                        -- Сравниваем с Tool
                        if TransformData.snapshots["tool"] then
                            compareSnapshots(TransformData.snapshots["tool"], worldSnapshot, "TOOL → WORLD")
                        end
                    end
                end
            end)
            
            table.insert(TransformData.connections, playerFolderConnection)
        end
    end)
    
    table.insert(TransformData.connections, workspaceConnection)
end

-- 🚀 ЗАПУСК АНАЛИЗА ПРЕВРАЩЕНИЯ
local function startTransformAnalysis()
    transformLog("TRANSFORM", "🚀 ЗАПУСК АНАЛИЗА ПРЕВРАЩЕНИЯ")
    transformLog("TRANSFORM", "🎯 Отслеживание: Visuals → Tool → World")
    
    TransformData.isAnalyzing = true
    TransformData.startTime = tick()
    
    -- Запускаем все мониторы
    monitorVisuals()
    monitorPlayerCharacter()
    monitorPlayerWorld()
    
    transformLog("TRANSFORM", "✅ Анализ превращения активен!")
    transformLog("TRANSFORM", "🥚 ОТКРОЙТЕ ЯЙЦО ДЛЯ АНАЛИЗА ПРЕВРАЩЕНИЯ!")
end

-- 📋 ГЕНЕРАЦИЯ ОТЧЕТА О ПРЕВРАЩЕНИИ
local function generateTransformReport()
    transformLog("CRITICAL", "📋 === ОТЧЕТ О ПРЕВРАЩЕНИИ ===")
    
    transformLog("INFO", string.format("🔄 Всего этапов превращения: %d", #TransformData.transformSequence))
    
    if #TransformData.transformSequence > 0 then
        transformLog("CRITICAL", "🔄 ПОСЛЕДОВАТЕЛЬНОСТЬ ПРЕВРАЩЕНИЯ:")
        
        for i, stage in ipairs(TransformData.transformSequence) do
            transformLog("SEQUENCE", string.format("🔄 %d. %s", i, stage.stage), {
                Object = stage.object and stage.object.Name or "nil",
                Time = string.format("%.3f сек", stage.relativeTime)
            })
        end
    end
    
    -- Сравнение всех снимков
    if TransformData.snapshots["visuals"] and TransformData.snapshots["tool"] then
        transformLog("CRITICAL", "🔥 КЛЮЧЕВОЕ СРАВНЕНИЕ: VISUALS → TOOL")
        compareSnapshots(TransformData.snapshots["visuals"], TransformData.snapshots["tool"], "ПОЛНОЕ ПРЕВРАЩЕНИЕ")
    end
    
    if TransformData.snapshots["tool"] and TransformData.snapshots["world"] then
        transformLog("CRITICAL", "🔥 КЛЮЧЕВОЕ СРАВНЕНИЕ: TOOL → WORLD")
        compareSnapshots(TransformData.snapshots["tool"], TransformData.snapshots["world"], "РАЗМЕЩЕНИЕ В МИРЕ")
    end
    
    transformLog("CRITICAL", "🔄 АНАЛИЗ ПРЕВРАЩЕНИЯ ЗАВЕРШЕН!")
end

-- 🛑 ОСТАНОВКА АНАЛИЗА
local function stopTransformAnalysis()
    transformLog("TRANSFORM", "🛑 ОСТАНОВКА АНАЛИЗА ПРЕВРАЩЕНИЯ")
    
    for _, connection in ipairs(TransformData.connections) do
        if connection then
            connection:Disconnect()
        end
    end
    
    TransformData.connections = {}
    TransformData.isAnalyzing = false
    
    transformLog("TRANSFORM", "✅ Анализ остановлен")
end

-- Создаем GUI
local function createTransformGUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "VisualsToToolTransformGUI"
    screenGui.Parent = player:WaitForChild("PlayerGui")
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 420, 0, 200)
    frame.Position = UDim2.new(1, -440, 0, 10)
    frame.BackgroundColor3 = Color3.new(0.1, 0.02, 0.05)
    frame.BorderSizePixel = 0
    frame.Parent = screenGui
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 30)
    title.BackgroundColor3 = Color3.new(1, 0.2, 0.5)
    title.BorderSizePixel = 0
    title.Text = "🔄 VISUALS → TOOL ANALYZER"
    title.TextColor3 = Color3.new(1, 1, 1)
    title.TextScaled = true
    title.Font = Enum.Font.SourceSansBold
    title.Parent = frame
    
    local startBtn = Instance.new("TextButton")
    startBtn.Size = UDim2.new(1, -20, 0, 40)
    startBtn.Position = UDim2.new(0, 10, 0, 40)
    startBtn.BackgroundColor3 = Color3.new(1, 0.2, 0.5)
    startBtn.BorderSizePixel = 0
    startBtn.Text = "🔄 АНАЛИЗ ПРЕВРАЩЕНИЯ"
    startBtn.TextColor3 = Color3.new(1, 1, 1)
    startBtn.TextScaled = true
    startBtn.Font = Enum.Font.SourceSansBold
    startBtn.Parent = frame
    
    local reportBtn = Instance.new("TextButton")
    reportBtn.Size = UDim2.new(0.48, 0, 0, 30)
    reportBtn.Position = UDim2.new(0, 10, 0, 90)
    reportBtn.BackgroundColor3 = Color3.new(0.6, 0.1, 0.3)
    reportBtn.BorderSizePixel = 0
    reportBtn.Text = "📋 ОТЧЕТ"
    reportBtn.TextColor3 = Color3.new(1, 1, 1)
    reportBtn.TextScaled = true
    reportBtn.Font = Enum.Font.SourceSans
    reportBtn.Parent = frame
    
    local stopBtn = Instance.new("TextButton")
    stopBtn.Size = UDim2.new(0.48, 0, 0, 30)
    stopBtn.Position = UDim2.new(0.52, 0, 0, 90)
    stopBtn.BackgroundColor3 = Color3.new(0.6, 0.1, 0.1)
    stopBtn.BorderSizePixel = 0
    stopBtn.Text = "🛑 СТОП"
    stopBtn.TextColor3 = Color3.new(1, 1, 1)
    stopBtn.TextScaled = true
    stopBtn.Font = Enum.Font.SourceSans
    stopBtn.Parent = frame
    
    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(1, -20, 0, 70)
    status.Position = UDim2.new(0, 10, 0, 130)
    status.BackgroundTransparency = 1
    status.Text = "Готов к анализу превращения\nVisuals → Tool → World\nОткройте яйцо для анализа"
    status.TextColor3 = Color3.new(1, 1, 1)
    status.TextScaled = true
    status.Font = Enum.Font.SourceSans
    status.Parent = frame
    
    startBtn.MouseButton1Click:Connect(function()
        status.Text = "🔄 Анализ активен!\nОтслеживание превращения..."
        status.TextColor3 = Color3.new(1, 0.2, 0.5)
        startBtn.Text = "✅ АНАЛИЗ АКТИВЕН"
        startBtn.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
        startBtn.Active = false
        
        startTransformAnalysis()
    end)
    
    reportBtn.MouseButton1Click:Connect(function()
        generateTransformReport()
    end)
    
    stopBtn.MouseButton1Click:Connect(function()
        stopTransformAnalysis()
        status.Text = "🛑 Анализ остановлен"
        status.TextColor3 = Color3.new(1, 0.5, 0.5)
        startBtn.Text = "🔄 АНАЛИЗ ПРЕВРАЩЕНИЯ"
        startBtn.BackgroundColor3 = Color3.new(1, 0.2, 0.5)
        startBtn.Active = true
    end)
end

-- Запускаем
local consoleTextLabel = createTransformConsole()
createTransformGUI()

transformLog("TRANSFORM", "✅ VisualsToToolTransformAnalyzer готов!")
transformLog("TRANSFORM", "🔄 Анализатор превращения модели")
transformLog("TRANSFORM", "🎯 Отслеживание: Visuals → Tool → World")
transformLog("TRANSFORM", "📊 Детальное сравнение структур")
transformLog("TRANSFORM", "🚀 Нажмите 'АНАЛИЗ ПРЕВРАЩЕНИЯ' для запуска!")
