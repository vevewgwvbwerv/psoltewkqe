-- Pet Creation Analyzer v3.0 - ПОЛНОСТЬЮ ИСПРАВЛЕННАЯ ВЕРСИЯ
-- Упрощенный анализатор без сложных функций, вызывающих ошибки

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Глобальные переменные
local gui = nil
local consoleOutput = {}
local petEvents = {}
local scriptRunning = true
local connections = {} -- Храним все соединения для отключения

print("🚀 Pet Creation Analyzer v3.0 - Запуск...")

-- Функция проверки питомца (КАК В FutureBestVisual.lua)
local function isPetTool(name)
    if not name then return false end
    -- Проверяем паттерны из FutureBestVisual.lua:
    return name:find("KG") or name:find("Dragonfly") or 
           (name:find("%{") and name:find("%}")) or
           (name:find("%[") and name:find("%]") and name:find("Age"))
end

-- Функция проверки UUID имени (ТОЧНАЯ КАК В FutureBestVisual)
local function isUUIDName(name)
    if not name then return false end
    -- UUID формат: {xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx}
    return name:find("%{") and name:find("%}") and name:find("%-")
end

-- Функция проверки любых фигурных скобок
local function hasCurlyBraces(name)
    if not name then return false end
    return name:find("{") and name:find("}")
end

-- Простая функция логирования
local function logEvent(eventType, petName, details)
    local timestamp = os.date("%H:%M:%S")
    local logMessage = string.format("[%s] %s: %s", timestamp, eventType, petName or "Unknown")
    
    print(logMessage)
    table.insert(consoleOutput, logMessage)
    
    if details then
        for key, value in pairs(details) do
            local detailMsg = string.format("  %s: %s", key, tostring(value))
            print(detailMsg)
            table.insert(consoleOutput, detailMsg)
        end
    end
    
    -- Ограничиваем размер лога
    if #consoleOutput > 50 then
        table.remove(consoleOutput, 1)
    end
    
    -- Обновляем GUI если он существует
    if gui and gui.Parent then
        local success = pcall(function()
            local consoleFrame = gui:FindFirstChild("ConsoleFrame", true)
            local consoleText = gui:FindFirstChild("ConsoleText", true)
            if consoleText and consoleFrame then
                -- Показываем все сообщения (не ограничиваем)
                local displayText = ""
                for i = 1, #consoleOutput do
                    displayText = displayText .. consoleOutput[i] .. "\n"
                end
                consoleText.Text = displayText
                
                -- Обновляем размер canvas для прокрутки
                local textHeight = consoleText.TextBounds.Y
                consoleFrame.CanvasSize = UDim2.new(0, 0, 0, math.max(textHeight + 50, 1000))
                
                -- Автоскролл вниз к последнему сообщению
                consoleFrame.CanvasPosition = Vector2.new(0, math.max(0, textHeight - consoleFrame.AbsoluteSize.Y + 50))
            end
        end)
    end
end

-- Создание простого GUI
local function createSimpleGUI()
    print("🔧 Создание простого GUI...")
    
    -- Удаляем старый GUI
    local oldGui = playerGui:FindFirstChild("PetAnalyzerGUI")
    if oldGui then
        oldGui:Destroy()
    end
    
    -- Создаем новый GUI
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "PetAnalyzerGUI"
    screenGui.ResetOnSpawn = false
    
    -- Главное окно
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 400, 0, 300)
    mainFrame.Position = UDim2.new(0.5, -200, 0.5, -150)
    mainFrame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.2)
    mainFrame.BorderSizePixel = 3
    mainFrame.BorderColor3 = Color3.new(0, 0.5, 1)
    mainFrame.Parent = screenGui
    
    -- Заголовок
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "TitleLabel"
    titleLabel.Size = UDim2.new(1, 0, 0, 30)
    titleLabel.Position = UDim2.new(0, 0, 0, 0)
    titleLabel.BackgroundColor3 = Color3.new(0, 0.3, 0.8)
    titleLabel.BorderSizePixel = 0
    titleLabel.Text = "Pet Creation Analyzer v3.0 - WORKING"
    titleLabel.TextColor3 = Color3.new(1, 1, 1)
    titleLabel.TextScaled = true
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.Parent = mainFrame
    
    -- Консоль с прокруткой
    local consoleFrame = Instance.new("ScrollingFrame")
    consoleFrame.Name = "ConsoleFrame"
    consoleFrame.Size = UDim2.new(1, -10, 1, -80)
    consoleFrame.Position = UDim2.new(0, 5, 0, 35)
    consoleFrame.BackgroundColor3 = Color3.new(0, 0, 0)
    consoleFrame.BorderSizePixel = 2
    consoleFrame.BorderColor3 = Color3.new(0.3, 0.3, 0.3)
    consoleFrame.ScrollBarThickness = 10
    consoleFrame.ScrollBarImageColor3 = Color3.new(0, 1, 0)
    consoleFrame.CanvasSize = UDim2.new(0, 0, 0, 1000)
    consoleFrame.Parent = mainFrame
    
    local consoleText = Instance.new("TextLabel")
    consoleText.Name = "ConsoleText"
    consoleText.Size = UDim2.new(1, -15, 0, 1000)
    consoleText.Position = UDim2.new(0, 0, 0, 0)
    consoleText.BackgroundTransparency = 1
    consoleText.Text = "Pet Analyzer Console Ready...\nWaiting for pet events..."
    consoleText.TextColor3 = Color3.new(0, 1, 0)
    consoleText.TextScaled = false
    consoleText.TextSize = 12
    consoleText.Font = Enum.Font.Code
    consoleText.TextXAlignment = Enum.TextXAlignment.Left
    consoleText.TextYAlignment = Enum.TextYAlignment.Top
    consoleText.TextWrapped = true
    consoleText.Parent = consoleFrame
    
    -- Кнопка отчета
    local reportButton = Instance.new("TextButton")
    reportButton.Name = "ReportButton"
    reportButton.Size = UDim2.new(0.3, 0, 0, 30)
    reportButton.Position = UDim2.new(0.05, 0, 1, -40)
    reportButton.BackgroundColor3 = Color3.new(0, 0.7, 0)
    reportButton.BorderSizePixel = 2
    reportButton.BorderColor3 = Color3.new(0, 0, 0)
    reportButton.Text = "REPORT"
    reportButton.TextColor3 = Color3.new(1, 1, 1)
    reportButton.TextScaled = true
    reportButton.Font = Enum.Font.SourceSansBold
    reportButton.Parent = mainFrame
    
    -- Кнопка очистки
    local clearButton = Instance.new("TextButton")
    clearButton.Name = "ClearButton"
    clearButton.Size = UDim2.new(0.3, 0, 0, 30)
    clearButton.Position = UDim2.new(0.375, 0, 1, -40)
    clearButton.BackgroundColor3 = Color3.new(0.8, 0.4, 0)
    clearButton.BorderSizePixel = 2
    clearButton.BorderColor3 = Color3.new(0, 0, 0)
    clearButton.Text = "CLEAR"
    clearButton.TextColor3 = Color3.new(1, 1, 1)
    clearButton.TextScaled = true
    clearButton.Font = Enum.Font.SourceSansBold
    clearButton.Parent = mainFrame
    
    -- Кнопка закрытия
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0.25, 0, 0, 30)
    closeButton.Position = UDim2.new(0.7, 0, 1, -40)
    closeButton.BackgroundColor3 = Color3.new(0.8, 0.2, 0.2)
    closeButton.BorderSizePixel = 2
    closeButton.BorderColor3 = Color3.new(0, 0, 0)
    closeButton.Text = "CLOSE"
    closeButton.TextColor3 = Color3.new(1, 1, 1)
    closeButton.TextScaled = true
    closeButton.Font = Enum.Font.SourceSansBold
    closeButton.Parent = mainFrame
    
    -- События кнопок
    reportButton.MouseButton1Click:Connect(function()
        reportButton.Text = "GENERATING..."
        reportButton.BackgroundColor3 = Color3.new(0.5, 0.5, 0)
        
        spawn(function()
            wait(0.5)
            
            -- Генерируем детальный отчет прямо в GUI консоль
            logEvent("📊 DETAILED REPORT", "=== STARTING REPORT ===")
            logEvent("📊 STATS", "Events logged: " .. #petEvents)
            logEvent("📊 STATS", "Console lines: " .. #consoleOutput)
            
            -- Показываем последние события
            logEvent("📊 RECENT EVENTS", "Last 5 events:")
            local startIndex = math.max(1, #petEvents - 4)
            for i = startIndex, #petEvents do
                if petEvents[i] then
                    logEvent("📊 EVENT", petEvents[i].type .. ": " .. (petEvents[i].pet or "Unknown"))
                end
            end
            
            -- Ищем текущие UUID модели в workspace
            logEvent("📊 WORKSPACE SCAN", "Current UUID pets in workspace:")
            local foundUUIDPets = 0
            for _, child in pairs(Workspace:GetChildren()) do
                if child:IsA("Model") and isUUIDName(child.Name) then
                    foundUUIDPets = foundUUIDPets + 1
                    logEvent("📊 UUID PET", child.Name, {
                        Position = child.PrimaryPart and tostring(child.PrimaryPart.Position) or "Unknown"
                    })
                end
            end
            
            if foundUUIDPets == 0 then
                logEvent("📊 UUID PET", "No UUID pets found in workspace")
            end
            
            logEvent("📊 DETAILED REPORT", "=== REPORT COMPLETE ===")
            
            -- Возвращаем кнопку в нормальное состояние
            reportButton.Text = "REPORT"
            reportButton.BackgroundColor3 = Color3.new(0, 0.7, 0)
        end)
    end)
    
    clearButton.MouseButton1Click:Connect(function()
        consoleOutput = {}
        petEvents = {}
        consoleText.Text = "Console cleared!\nWaiting for new events..."
        logEvent("SYSTEM", "Console cleared")
    end)
    
    closeButton.MouseButton1Click:Connect(function()
        logEvent("SYSTEM", "COMPLETE SHUTDOWN - Pet Creation Analyzer terminating...")
        
        -- Отключаем скрипт
        scriptRunning = false
        
        -- Отключаем все соединения
        for i, connection in ipairs(connections) do
            if connection then
                pcall(function() connection:Disconnect() end)
            end
        end
        connections = {}
        
        -- Закрываем GUI
        pcall(function() screenGui:Destroy() end)
        gui = nil
        
        print("🔴 Pet Creation Analyzer ПОЛНОСТЬЮ ВЫКЛЮЧЕН!")
        print("🔌 Все соединения отключены")
        print("💀 Скрипт УБИТ навсегда")
        print("⚰️ Принудительная остановка через error()")
        
        -- ПРИНУДИТЕЛЬНАЯ ОСТАНОВКА СКРИПТА ЧЕРЕЗ ERROR
        spawn(function()
            wait(0.1)
            error("🔴 PET ANALYZER SCRIPT TERMINATED BY USER - COMPLETE SHUTDOWN 💀")
        end)
    end)
    
    -- Добавляем в PlayerGui
    screenGui.Parent = playerGui
    gui = screenGui
    
    print("✅ GUI создан успешно!")
    logEvent("SYSTEM", "GUI created successfully")
    
    return screenGui
end

-- Мониторинг Backpack
local function monitorBackpack()
    if not scriptRunning then return end
    logEvent("SYSTEM", "Starting backpack monitoring")
    
    local function onToolAdded(tool)
        if not scriptRunning then return end
        if tool:IsA("Tool") then
            local isPet = isPetTool(tool.Name)
            logEvent("🎒 BACKPACK_ADDED", tool.Name, {
                ClassName = tool.ClassName,
                Handle = tool:FindFirstChild("Handle") and "Yes" or "No",
                IsPet = isPet and "YES" or "NO"
            })
        end
    end
    
    local function onToolRemoved(tool)
        if not scriptRunning then return end
        if tool:IsA("Tool") then
            logEvent("🎒 BACKPACK_REMOVED", tool.Name, {
                IsPet = isPetTool(tool.Name) and "YES" or "NO"
            })
        end
    end
    
    -- Подключаем к текущему backpack и сохраняем соединения
    if player.Backpack then
        local conn1 = player.Backpack.ChildAdded:Connect(onToolAdded)
        local conn2 = player.Backpack.ChildRemoved:Connect(onToolRemoved)
        table.insert(connections, conn1)
        table.insert(connections, conn2)
    end
end

-- Мониторинг рук персонажа (С ПОЛНОЙ ПРОВЕРКОЙ scriptRunning)
local function monitorCharacterTools()
    if not scriptRunning then return end
    logEvent("SYSTEM", "Starting character tools monitoring with scriptRunning checks")
    
    local function monitorCharacter(character)
        if not character or not scriptRunning then return end
        
        local success1 = pcall(function()
            local conn1 = character.ChildAdded:Connect(function(child)
                if not scriptRunning then return end
                if child and child:IsA("Tool") then
                    local hasHandle = child:FindFirstChild("Handle") and "Yes" or "No"
                    local isPet = isPetTool(child.Name)
                    logEvent("🤲 HAND_EQUIPPED", child.Name, {
                        Handle = hasHandle,
                        ClassName = child.ClassName,
                        IsPet = isPet and "YES" or "NO"
                    })
                end
            end)
            table.insert(connections, conn1)
        end)
        
        local success2 = pcall(function()
            local conn2 = character.ChildRemoved:Connect(function(child)
                if not scriptRunning then return end
                if child and child:IsA("Tool") then
                    local isPet = isPetTool(child.Name)
                    logEvent("🤲 HAND_REMOVED", child.Name, {
                        ClassName = child.ClassName,
                        IsPet = isPet and "YES" or "NO"
                    })
                    
                    -- ПОИСК UUID ПИТОМЦЕВ КАК В FutureBestVisual.lua (ТОЛЬКО ДЛЯ ПИТОМЦЕВ)
                    if isPet then
                        logEvent("🔍 SEARCH_START", "Searching UUID pets like FutureBestVisual.lua")
                        
                        spawn(function()
                            local searchAttempts = 0
                            local maxAttempts = 20 -- 20 попыток по 0.5 секунды = 10 секунд
                            
                            while searchAttempts < maxAttempts and scriptRunning do
                                searchAttempts = searchAttempts + 1
                                wait(0.5)
                                
                                if not scriptRunning then break end
                            
                            -- ТОЧНАЯ КОПИЯ ЛОГИКИ ИЗ FutureBestVisual.lua
                            local foundUUIDPets = {}
                            
                            for _, obj in pairs(Workspace:GetDescendants()) do
                                if not scriptRunning then break end
                                
                                -- Проверяем модели с фигурными скобками (КАК В FutureBestVisual.lua)
                                if obj:IsA("Model") and obj.Name:find("%{") and obj.Name:find("%}") then
                                    local success, modelCFrame = pcall(function() 
                                        return obj:GetModelCFrame() 
                                    end)
                                    
                                    if success then
                                        local playerChar = player.Character
                                        if playerChar and playerChar:FindFirstChild("HumanoidRootPart") then
                                            local distance = (modelCFrame.Position - playerChar.HumanoidRootPart.Position).Magnitude
                                            
                                            -- Проверяем расстояние (как в FutureBestVisual.lua)
                                            if distance <= 100 then -- SEARCH_RADIUS из FutureBestVisual.lua
                                                -- Проверяем меши (как в FutureBestVisual.lua)
                                                local meshes = 0
                                                for _, part in pairs(obj:GetDescendants()) do
                                                    if part:IsA("MeshPart") or part:IsA("SpecialMesh") then
                                                        meshes = meshes + 1
                                                    end
                                                end
                                                
                                                table.insert(foundUUIDPets, {
                                                    model = obj,
                                                    name = obj.Name,
                                                    distance = distance,
                                                    meshes = meshes,
                                                    position = modelCFrame.Position
                                                })
                                            end
                                        end
                                    end
                                end
                            end
                            
                            -- Если нашли UUID питомцев, выбираем БЛИЖАЙШЕГО
                            if #foundUUIDPets > 0 then
                                -- Сортируем по расстоянию и берем самого близкого
                                table.sort(foundUUIDPets, function(a, b) return a.distance < b.distance end)
                                local closestPet = foundUUIDPets[1]
                                
                                logEvent("🎯 CLOSEST_UUID_PET_FOUND", closestPet.name, {
                                    SearchAttempt = tostring(searchAttempts),
                                    Distance = string.format("%.1f studs", closestPet.distance),
                                    Meshes = tostring(closestPet.meshes),
                                    Position = tostring(closestPet.position),
                                    SearchTime = string.format("%.1f seconds", searchAttempts * 0.5),
                                    TotalFound = tostring(#foundUUIDPets)
                                })
                                break -- Найден ближайший питомец, прекращаем поиск
                            end
                        end
                        
                        if searchAttempts >= maxAttempts and scriptRunning then
                            logEvent("⏰ SEARCH_COMPLETE", "UUID search completed after " .. (maxAttempts * 0.5) .. " seconds")
                        end
                        
                        if not scriptRunning then
                            print("🔴 UUID search stopped due to script shutdown")
                        end
                    end)
                    end
                end
            end)
            table.insert(connections, conn2)
        end)
        
        if not success1 then
            logEvent("⚠️ ERROR", "Failed to connect ChildAdded for character")
        end
        if not success2 then
            logEvent("⚠️ ERROR", "Failed to connect ChildRemoved for character")
        end
    end
    
    -- Мониторим текущего персонажа
    if player.Character then
        monitorCharacter(player.Character)
    end
    
    -- Мониторим новых персонажей
    player.CharacterAdded:Connect(monitorCharacter)
end

-- Мониторинг Workspace для UUID питомцев (КАК В FutureBestVisual.lua)
local function monitorWorkspacePets()
    logEvent("SYSTEM", "Starting workspace monitoring like FutureBestVisual.lua")
    
    -- Мониторим корневой Workspace
    Workspace.ChildAdded:Connect(function(child)
        if child:IsA("Model") then
            local hasUUID = isUUIDName(child.Name)
            local hasBraces = hasCurlyBraces(child.Name)
            
            if hasUUID or hasBraces then
                logEvent("🌍 WORKSPACE_ROOT_ADDED", child.Name, {
                    HasUUID = hasUUID and "YES" or "NO",
                    HasBraces = hasBraces and "YES" or "NO",
                    Position = child.PrimaryPart and tostring(child.PrimaryPart.Position) or "Unknown"
                })
            end
            
            if hasUUID then
                logEvent("🎯 UUID_PET_IN_ROOT", child.Name, {
                    Position = child.PrimaryPart and tostring(child.PrimaryPart.Position) or "Unknown"
                })
            end
        end
    end)
    
    -- Мониторим Workspace.Visuals (КАК В FutureBestVisual.lua)
    local visualsFolder = Workspace:FindFirstChild("Visuals")
    if visualsFolder then
        logEvent("SYSTEM", "Found Workspace.Visuals folder - monitoring it")
        
        visualsFolder.ChildAdded:Connect(function(child)
            if child:IsA("Model") then
                local hasUUID = isUUIDName(child.Name)
                local hasBraces = hasCurlyBraces(child.Name)
                
                if hasUUID or hasBraces then
                    logEvent("🎨 VISUALS_FOLDER_ADDED", child.Name, {
                        HasUUID = hasUUID and "YES" or "NO",
                        HasBraces = hasBraces and "YES" or "NO",
                        Position = child.PrimaryPart and tostring(child.PrimaryPart.Position) or "Unknown"
                    })
                end
                
                if hasUUID then
                    logEvent("🎯 UUID_PET_IN_VISUALS", child.Name, {
                        Position = child.PrimaryPart and tostring(child.PrimaryPart.Position) or "Unknown"
                    })
                end
            end
        end)
    else
        logEvent("SYSTEM", "No Workspace.Visuals folder found")
        
        -- Создаем мониторинг для появления Visuals папки
        Workspace.ChildAdded:Connect(function(child)
            if child.Name == "Visuals" and child:IsA("Folder") then
                logEvent("SYSTEM", "Workspace.Visuals folder appeared - setting up monitoring")
                
                child.ChildAdded:Connect(function(visualChild)
                    if visualChild:IsA("Model") and isUUIDName(visualChild.Name) then
                        logEvent("🎯 UUID_PET_IN_NEW_VISUALS", visualChild.Name, {
                            Position = visualChild.PrimaryPart and tostring(visualChild.PrimaryPart.Position) or "Unknown"
                        })
                    end
                end)
            end
        end)
    end
    
    -- Мониторим удаления
    Workspace.ChildRemoved:Connect(function(child)
        if child:IsA("Model") and (isUUIDName(child.Name) or hasCurlyBraces(child.Name)) then
            logEvent("🌍 WORKSPACE_MODEL_REMOVED", child.Name)
        end
    end)
    
    -- Периодическое сканирование workspace каждые 5 секунд (С ПРОВЕРКОЙ scriptRunning)
    spawn(function()
        while scriptRunning do
            wait(5)
            if not scriptRunning then break end
            
            local success = pcall(function()
                if not scriptRunning then return end
                
                local foundModels = 0
                for _, child in pairs(Workspace:GetChildren()) do
                    if not scriptRunning then break end
                    if child:IsA("Model") and (isUUIDName(child.Name) or hasCurlyBraces(child.Name)) then
                        foundModels = foundModels + 1
                    end
                end
                
                if foundModels > 0 and scriptRunning then
                    logEvent("🔍 PERIODIC_SCAN", "Found " .. foundModels .. " models with braces/UUID")
                    
                    -- Показываем первые 2 найденные модели
                    local count = 0
                    for _, child in pairs(Workspace:GetChildren()) do
                        if not scriptRunning then break end
                        if child:IsA("Model") and (isUUIDName(child.Name) or hasCurlyBraces(child.Name)) then
                            count = count + 1
                            if count <= 2 then
                                logEvent("🔍 FOUND_MODEL", child.Name, {
                                    IsUUID = isUUIDName(child.Name) and "YES" or "NO",
                                    Position = child.PrimaryPart and tostring(child.PrimaryPart.Position) or "Unknown"
                                })
                            end
                        end
                    end
                end
            end)
            
            if not success and scriptRunning then
                logEvent("⚠️ ERROR", "Failed periodic workspace scan")
            end
        end
        
        if not scriptRunning then
            print("🔴 Periodic scanning stopped")
        end
    end)
end

-- Запуск системы
local function startSystem()
    print("🚀 Запуск Pet Creation Analyzer v3.0...")
    
    -- Создаем GUI
    local success, error = pcall(createSimpleGUI)
    if not success then
        print("❌ Ошибка создания GUI:", error)
        return
    end
    
    -- Запускаем мониторинг
    pcall(monitorBackpack)
    pcall(monitorCharacterTools)
    pcall(monitorWorkspacePets)
    
    print("✅ Pet Creation Analyzer v3.0 запущен успешно!")
    print("📊 GUI активен, мониторинг включен")
    print("🔍 Готов к анализу питомцев!")
    
    logEvent("SYSTEM", "Pet Creation Analyzer v3.0 started successfully")
end

-- Запускаем систему
startSystem()
