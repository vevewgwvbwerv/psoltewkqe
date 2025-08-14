-- Pet Structure Analyzer v4.0 - СОВРЕМЕННЫЙ АНАЛИЗАТОР СТРУКТУРЫ ПИТОМЦЕВ
-- Сканирует UUID питомцев рядом с игроком и сохраняет их полную структуру
-- Motor6D, Meshes, Attachments, Animations, Parts - все данные для воссоздания

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Глобальные переменные
local gui = nil
local autoStartMonitoring = false -- конфиг: автоскан при запуске отключен
local consoleOutput = {}
local petDatabase = {} -- База данных отсканированных питомцев
local scriptRunning = true
local connections = {}

print("🚀 Pet Structure Analyzer v4.0 - Запуск современного анализатора...")

-- Функция проверки UUID имени
local function isUUIDName(name)
    if not name then return false end
    return name:find("%{") and name:find("%}") and name:find("%-")
end

-- Функция логирования с современным форматированием
local function logEvent(eventType, message, data)
    local timestamp = os.date("%H:%M:%S")
    local logMessage = string.format("[%s] %s: %s", timestamp, eventType, message or "")
    
    print(logMessage)
    table.insert(consoleOutput, logMessage)
    
    if data then
        for key, value in pairs(data) do
            local detailMsg = string.format("  • %s: %s", key, tostring(value))
            print(detailMsg)
            table.insert(consoleOutput, detailMsg)
        end
    end
    
    -- Ограничиваем размер лога (последние 200 строк)
    if #consoleOutput > 200 then
        table.remove(consoleOutput, 1)
    end
    
    -- Обновляем GUI если он существует
    if gui and gui.Parent then
        local success = pcall(function()
            local consoleFrame = gui:FindFirstChild("ConsoleFrame", true)
            local consoleText = gui:FindFirstChild("ConsoleText", true)
            if consoleText and consoleFrame then
                -- Показываем все сообщения
                local displayText = table.concat(consoleOutput, "\n")
                consoleText.Text = displayText
                
                -- Обновляем размер canvas для прокрутки
                local textHeight = consoleText.TextBounds.Y
                consoleFrame.CanvasSize = UDim2.new(0, 0, 0, math.max(textHeight + 100, 1000))
                
                -- Автоскролл вниз к последним сообщениям
                consoleFrame.CanvasPosition = Vector2.new(0, math.max(0, textHeight - consoleFrame.AbsoluteSize.Y + 100))
            end
        end)
    end
end

-- === ПРЕДВАРИТЕЛЬНОЕ ОБЪЯВЛЕНИЕ ФУНКЦИЙ ДЛЯ GUI ===

-- Функция поиска и сканирования UUID питомцев рядом с игроком (ПЕРЕНЕСЕНА СЮДА)
local function findAndScanNearbyUUIDPets()
    if not scriptRunning then return end
    
    logEvent("🔍 SEARCH", "Searching for UUID pets near player...")
    
    local playerChar = player.Character
    if not playerChar or not playerChar:FindFirstChild("HumanoidRootPart") then
        logEvent("❌ ERROR", "Player character or HumanoidRootPart not found")
        return
    end
    
    local playerPosition = playerChar.HumanoidRootPart.Position
    local foundPets = {}
    local searchRadius = 100 -- 100 стадов радиус поиска
    
    -- Ищем UUID модели в Workspace
    for _, obj in pairs(Workspace:GetDescendants()) do
        if not scriptRunning then break end
        
        if obj:IsA("Model") and isUUIDName(obj.Name) then
            local success, modelCFrame = pcall(function() 
                return obj:GetModelCFrame() 
            end)
            
            if success then
                local distance = (modelCFrame.Position - playerPosition).Magnitude
                
                if distance <= searchRadius then
                    table.insert(foundPets, {
                        model = obj,
                        distance = distance,
                        name = obj.Name
                    })
                end
            end
        end
    end
    
    -- Сортируем по расстоянию
    table.sort(foundPets, function(a, b) return a.distance < b.distance end)
    
    logEvent("🎯 SEARCH_RESULT", "Found " .. #foundPets .. " UUID pets within " .. searchRadius .. " studs")
    
    -- Сканируем найденных питомцев (синхронно, чтобы база заполнилась до завершения функции)
    for i, petInfo in ipairs(foundPets) do
        if not scriptRunning then break end
        
        logEvent("🔬 SCANNING", "Pet " .. i .. "/" .. #foundPets, {
            Name = petInfo.name,
            Distance = string.format("%.1f studs", petInfo.distance)
        })
        
        if scanUUIDPet then
            local success, err = pcall(scanUUIDPet, petInfo.model)
            if success then
                logEvent("✅ SCAN_SUCCESS", "Pet scanned successfully", { PetName = petInfo.name })
            else
                logEvent("❌ SCAN_ERROR", "Failed to scan pet: " .. tostring(err), { PetName = petInfo.name })
            end
        else
            logEvent("⚠️ SCAN_SKIP", "scanUUIDPet function not available yet", { PetName = petInfo.name })
        end
        
        wait(0.05)
    end
    
    -- Подсчитываем размер базы данных правильно
    local databaseSize = 0
    for _ in pairs(petDatabase) do
        databaseSize = databaseSize + 1
    end
    
    logEvent("✅ SCAN_COMPLETE", "All nearby UUID pets scanned successfully", {
        TotalScanned = #foundPets,
        DatabaseSize = databaseSize
    })
end

-- Функция воссоздания ближайшего питомца из базы (ПЕРЕНЕСЕНА СЮДА)
local function recreateNearestPet()
    if not scriptRunning then return end
    
    -- Подсчитываем размер базы данных правильно
    local databaseSize = 0
    for _ in pairs(petDatabase) do
        databaseSize = databaseSize + 1
    end
    
    if databaseSize == 0 then
        logEvent("⚠️ RECREATE_WARNING", "Pet database is empty! Scan some pets first.", {
            DatabaseSize = databaseSize
        })
        return
    end
    
    logEvent("📊 DATABASE_STATUS", "Database contains pets", {
        DatabaseSize = databaseSize
    })
    
    -- Находим первого питомца в базе
    local petName = next(petDatabase)
    
    -- Позиция рядом с игроком
    local playerChar = player.Character
    if not playerChar or not playerChar:FindFirstChild("HumanoidRootPart") then
        logEvent("❌ RECREATE_ERROR", "Player character not found")
        return
    end
    
    local playerPos = playerChar.HumanoidRootPart.Position
    local spawnPos = playerPos + Vector3.new(5, 0, 5) -- 5 стадов от игрока
    
    logEvent("🚀 RECREATE_ATTEMPT", "Attempting to recreate pet", {
        PetName = petName,
        SpawnPosition = tostring(spawnPos)
    })
    
    -- Вызываем функцию воссоздания (будет объявлена позже)
    if recreatePetFromDatabase then
        local recreatedPet = recreatePetFromDatabase(petName, spawnPos)
        
        if recreatedPet then
            logEvent("🎉 RECREATE_COMPLETE", "Pet successfully recreated from database!")
            return recreatedPet
        else
            logEvent("❌ RECREATE_FAILED", "Failed to recreate pet from database")
            return nil
        end
    else
        logEvent("❌ RECREATE_ERROR", "Recreation function not available yet")
        return nil
    end
end

-- Создание современного GUI
local function createModernGUI()
    print("🎨 Создание современного GUI...")
    
    -- Удаляем старый GUI
    local oldGui = playerGui:FindFirstChild("PetStructureAnalyzerGUI")
    if oldGui then
        oldGui:Destroy()
    end
    
    -- Создаем новый GUI
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "PetStructureAnalyzerGUI"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- Главное окно (МОБИЛЬНО-АДАПТИВНОЕ)
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0.9, 0, 0.8, 0) -- 90% ширины, 80% высоты экрана
    mainFrame.Position = UDim2.new(0.05, 0, 0.1, 0) -- Центрируем с отступами
    mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35) -- Темно-серый фон
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui
    
    -- Современная рамка с градиентом
    local uiCorner = Instance.new("UICorner")
    uiCorner.CornerRadius = UDim.new(0, 12)
    uiCorner.Parent = mainFrame
    
    local uiStroke = Instance.new("UIStroke")
    uiStroke.Color = Color3.fromRGB(0, 150, 255)
    uiStroke.Thickness = 2
    uiStroke.Parent = mainFrame
    
    -- Заголовок с современным дизайном (КОМПАКТНЫЙ)
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "TitleLabel"
    titleLabel.Size = UDim2.new(1, 0, 0, 35) -- Уменьшен с 50 до 35
    titleLabel.Position = UDim2.new(0, 0, 0, 0)
    titleLabel.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
    titleLabel.BorderSizePixel = 0
    titleLabel.Text = "🔬 Pet Analyzer v4.0" -- Короче для мобильного
    titleLabel.TextColor3 = Color3.new(1, 1, 1)
    titleLabel.TextScaled = true
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.Parent = mainFrame
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 12)
    titleCorner.Parent = titleLabel
    
    -- Консоль с современным дизайном (МОБИЛЬНО-АДАПТИВНАЯ)
    local consoleFrame = Instance.new("ScrollingFrame")
    consoleFrame.Name = "ConsoleFrame"
    consoleFrame.Size = UDim2.new(1, -10, 1, -80) -- Компактнее для мобильного
    consoleFrame.Position = UDim2.new(0, 5, 0, 40) -- Ближе к заголовку
    consoleFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20) -- Очень темный фон
    consoleFrame.BorderSizePixel = 0
    consoleFrame.ScrollBarThickness = 8 -- Тоньше для мобильного
    consoleFrame.ScrollBarImageColor3 = Color3.fromRGB(0, 150, 255)
    consoleFrame.CanvasSize = UDim2.new(0, 0, 0, 2000)
    consoleFrame.Parent = mainFrame
    
    local consoleCorner = Instance.new("UICorner")
    consoleCorner.CornerRadius = UDim.new(0, 8)
    consoleCorner.Parent = consoleFrame
    
    local consoleStroke = Instance.new("UIStroke")
    consoleStroke.Color = Color3.fromRGB(50, 50, 60)
    consoleStroke.Thickness = 1
    consoleStroke.Parent = consoleFrame
    
    local consoleText = Instance.new("TextLabel")
    consoleText.Name = "ConsoleText"
    consoleText.Size = UDim2.new(1, -15, 0, 2000)
    consoleText.Position = UDim2.new(0, 8, 0, 5)
    consoleText.BackgroundTransparency = 1
    consoleText.Text = "🔬 Pet Analyzer Console Ready...\n⚡ Waiting for UUID pets to analyze..."
    consoleText.TextColor3 = Color3.fromRGB(0, 255, 150) -- Яркий зеленый
    consoleText.TextScaled = false
    consoleText.TextSize = 12 -- Меньше для мобильного
    consoleText.Font = Enum.Font.RobotoMono -- Моноширинный шрифт для кода
    consoleText.TextXAlignment = Enum.TextXAlignment.Left
    consoleText.TextYAlignment = Enum.TextYAlignment.Top
    consoleText.TextWrapped = true
    consoleText.Parent = consoleFrame
    
    -- Панель кнопок (МОБИЛЬНО-АДАПТИВНАЯ)
    local buttonPanel = Instance.new("Frame")
    buttonPanel.Name = "ButtonPanel"
    buttonPanel.Size = UDim2.new(1, -10, 0, 35) -- Компактнее: высота 35 вместо 50
    buttonPanel.Position = UDim2.new(0, 5, 1, -40) -- Ближе к краю
    buttonPanel.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    buttonPanel.BorderSizePixel = 0
    buttonPanel.Parent = mainFrame
    
    local panelCorner = Instance.new("UICorner")
    panelCorner.CornerRadius = UDim.new(0, 8)
    panelCorner.Parent = buttonPanel
    
    -- Создание современной кнопки
    local function createModernButton(name, text, color, position, size)
        local button = Instance.new("TextButton")
        button.Name = name
        button.Size = size
        button.Position = position
        button.BackgroundColor3 = color
        button.BorderSizePixel = 0
        button.Text = text
        button.TextColor3 = Color3.new(1, 1, 1)
        button.TextScaled = true
        button.Font = Enum.Font.GothamBold
        button.Parent = buttonPanel
        
        local buttonCorner = Instance.new("UICorner")
        buttonCorner.CornerRadius = UDim.new(0, 6)
        buttonCorner.Parent = button
        
        local buttonStroke = Instance.new("UIStroke")
        buttonStroke.Color = Color3.fromRGB(255, 255, 255)
        buttonStroke.Thickness = 1
        buttonStroke.Transparency = 0.8
        buttonStroke.Parent = button
        
        -- Эффект наведения
        button.MouseEnter:Connect(function()
            button.BackgroundColor3 = Color3.new(
                math.min(color.R + 0.1, 1),
                math.min(color.G + 0.1, 1),
                math.min(color.B + 0.1, 1)
            )
            buttonStroke.Transparency = 0.5
        end)
        
        button.MouseLeave:Connect(function()
            button.BackgroundColor3 = color
            buttonStroke.Transparency = 0.8
        end)
        
        return button
    end
    
    -- Кнопки с современным дизайном (6 кнопок)
    local scanButton = createModernButton("ScanButton", "🔍 SCAN PETS", 
        Color3.fromRGB(0, 150, 255), UDim2.new(0, 2, 0, 5), UDim2.new(0.15, 0, 1, -10))
    
    local createButton = createModernButton("CreateButton", "🚀 CREATE PET", 
        Color3.fromRGB(255, 0, 150), UDim2.new(0.16, 0, 0, 5), UDim2.new(0.15, 0, 1, -10))
    
    local copyButton = createModernButton("CopyButton", "📋 COPY CONSOLE", 
        Color3.fromRGB(255, 150, 0), UDim2.new(0.32, 0, 0, 5), UDim2.new(0.15, 0, 1, -10))
    
    local clearButton = createModernButton("ClearButton", "🗑️ CLEAR LOG", 
        Color3.fromRGB(255, 100, 100), UDim2.new(0.48, 0, 0, 5), UDim2.new(0.15, 0, 1, -10))
    
    local exportButton = createModernButton("ExportButton", "💾 EXPORT DATA", 
        Color3.fromRGB(100, 255, 100), UDim2.new(0.64, 0, 0, 5), UDim2.new(0.15, 0, 1, -10))
    
    local closeButton = createModernButton("CloseButton", "❌ CLOSE", 
        Color3.fromRGB(200, 50, 50), UDim2.new(0.8, 0, 0, 5), UDim2.new(0.18, 0, 1, -10))
    
    -- События кнопок (ПОДКЛЮЧЕНЫ К РЕАЛЬНЫМ ФУНКЦИЯМ)
    scanButton.MouseButton1Click:Connect(function()
        logEvent("🔍 SCAN", "Starting pet structure scan...")
        scanButton.Text = "⏳ SCANNING..."
        
        findAndScanNearbyUUIDPets()
        
        scanButton.Text = "🔍 SCAN PETS"
    end)
    
    createButton.MouseButton1Click:Connect(function()
        logEvent("🚀 CREATE", "Attempting to create pet from database...")
        createButton.Text = "⏳ CREATING..."
        
        spawn(function()
            local createdPet = recreateNearestPet()
            if createdPet then
                createButton.Text = "✅ CREATED!"
                spawn(function()
                    wait(2)
                    createButton.Text = "🚀 CREATE PET"
                end)
            else
                createButton.Text = "❌ FAILED!"
                spawn(function()
                    wait(2)
                    createButton.Text = "🚀 CREATE PET"
                end)
            end
        end)
    end)
    
    copyButton.MouseButton1Click:Connect(function()
        logEvent("📋 COPY", "Preparing console text for manual copy...")
        copyButton.Text = "⏳ PREPARING..."
        
        local screenGui = gui or playerGui:FindFirstChild("PetStructureAnalyzerGUI")
        if not screenGui then
            copyButton.Text = "📋 COPY CONSOLE"
            return
        end
        
        -- Создаем/показываем окно копирования с TextBox
        local copyFrame = screenGui:FindFirstChild("CopyDialog")
        if not copyFrame then
            copyFrame = Instance.new("Frame")
            copyFrame.Name = "CopyDialog"
            copyFrame.Size = UDim2.new(0.8, 0, 0.6, 0)
            copyFrame.Position = UDim2.new(0.1, 0, 0.2, 0)
            copyFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
            copyFrame.BorderSizePixel = 0
            copyFrame.Parent = screenGui
            
            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 10)
            corner.Parent = copyFrame
            
            local title = Instance.new("TextLabel")
            title.Name = "Title"
            title.Size = UDim2.new(1, -10, 0, 30)
            title.Position = UDim2.new(0, 5, 0, 5)
            title.BackgroundTransparency = 1
            title.Text = "📋 Console Export (Ctrl+A then Ctrl+C)"
            title.TextColor3 = Color3.fromRGB(255, 255, 255)
            title.Font = Enum.Font.GothamBold
            title.TextSize = 16
            title.TextXAlignment = Enum.TextXAlignment.Left
            title.Parent = copyFrame
            
            local textBox = Instance.new("TextBox")
            textBox.Name = "CopyText"
            textBox.Size = UDim2.new(1, -10, 1, -50)
            textBox.Position = UDim2.new(0, 5, 0, 40)
            textBox.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
            textBox.TextColor3 = Color3.fromRGB(200, 255, 200)
            textBox.ClearTextOnFocus = false
            textBox.MultiLine = true
            textBox.TextXAlignment = Enum.TextXAlignment.Left
            textBox.TextYAlignment = Enum.TextYAlignment.Top
            textBox.TextWrapped = false
            textBox.Font = Enum.Font.RobotoMono
            textBox.TextSize = 12
            textBox.Parent = copyFrame
            
            local closeBtn = Instance.new("TextButton")
            closeBtn.Name = "Close"
            closeBtn.Size = UDim2.new(0, 100, 0, 30)
            closeBtn.Position = UDim2.new(1, -110, 1, -40)
            closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
            closeBtn.TextColor3 = Color3.new(1, 1, 1)
            closeBtn.Text = "Close"
            closeBtn.Font = Enum.Font.GothamBold
            closeBtn.TextSize = 14
            closeBtn.Parent = copyFrame
            
            closeBtn.MouseButton1Click:Connect(function()
                copyFrame.Visible = false
            end)
        end
        
        -- Обновляем текст и фокус
        local textBox = copyFrame:FindFirstChild("CopyText")
        local data = table.concat(consoleOutput, "\n")
        textBox.Text = data
        copyFrame.Visible = true
        
        textBox:CaptureFocus()
        textBox.SelectionStart = 1
        textBox.CursorPosition = #data + 1
        
        copyButton.Text = "📋 COPY CONSOLE"
        logEvent("✅ COPY_READY", "Text ready in CopyDialog; use Ctrl+A then Ctrl+C")
    end)
    
    clearButton.MouseButton1Click:Connect(function()
        logEvent("🗑️ CLEAR", "Clearing console log...")
        consoleOutput = {}
        consoleText.Text = "🔬 Console cleared!\n⚡ Ready for new analysis..."
        clearButton.Text = "✅ CLEARED"
        
        spawn(function()
            wait(1)
            clearButton.Text = "🗑️ CLEAR LOG"
        end)
    end)
    
    exportButton.MouseButton1Click:Connect(function()
        logEvent("💾 EXPORT", "Exporting pet database...")
        exportButton.Text = "⏳ EXPORTING..."
        
        spawn(function()
            exportPetDatabase()
            exportButton.Text = "💾 EXPORT DATA"
        end)
    end)
    
    closeButton.MouseButton1Click:Connect(function()
        logEvent("❌ SYSTEM", "COMPLETE SHUTDOWN - Pet Structure Analyzer terminating...")
        
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
        
        print("🔴 Pet Structure Analyzer ПОЛНОСТЬЮ ВЫКЛЮЧЕН!")
        print("🔌 Все соединения отключены")
        print("💀 Скрипт УБИТ навсегда")
        
        -- ПРИНУДИТЕЛЬНАЯ ОСТАНОВКА СКРИПТА
        spawn(function()
            wait(0.1)
            error("🔴 PET STRUCTURE ANALYZER TERMINATED BY USER - COMPLETE SHUTDOWN 💀")
        end)
    end)
    
    -- Добавляем в PlayerGui
    screenGui.Parent = playerGui
    gui = screenGui
    
    print("✅ Современный GUI создан успешно!")
    logEvent("🎨 SYSTEM", "Modern GUI created with enhanced console and buttons")
    
    return screenGui
end

-- === СИСТЕМА СКАНИРОВАНИЯ СТРУКТУРЫ ПИТОМЦЕВ ===

-- Функция глубокого сканирования Motor6D
local function scanMotor6D(model)
    local motors = {}
    local motorCount = 0
    
    for _, obj in pairs(model:GetDescendants()) do
        if obj:IsA("Motor6D") then
            motorCount = motorCount + 1
            local motorData = {
                name = obj.Name,
                part0 = obj.Part0 and obj.Part0.Name or "nil",
                part1 = obj.Part1 and obj.Part1.Name or "nil",
                c0 = obj.C0,
                c1 = obj.C1,
                parent = obj.Parent and obj.Parent.Name or "nil"
            }
            table.insert(motors, motorData)
        end
    end
    
    return motors, motorCount
end

-- Функция сканирования Mesh данных
local function scanMeshData(model)
    local meshes = {}
    local meshCount = 0
    
    for _, obj in pairs(model:GetDescendants()) do
        if obj:IsA("MeshPart") then
            meshCount = meshCount + 1
            local meshData = {
                type = "MeshPart",
                name = obj.Name,
                meshId = obj.MeshId,
                textureId = obj.TextureID,
                size = obj.Size,
                material = obj.Material.Name,
                color = obj.Color,
                parent = obj.Parent and obj.Parent.Name or "nil"
            }
            table.insert(meshes, meshData)
        elseif obj:IsA("SpecialMesh") then
            meshCount = meshCount + 1
            local meshData = {
                type = "SpecialMesh",
                name = obj.Name,
                meshId = obj.MeshId,
                textureId = obj.TextureId,
                meshType = obj.MeshType.Name,
                scale = obj.Scale,
                parent = obj.Parent and obj.Parent.Name or "nil"
            }
            table.insert(meshes, meshData)
        end
    end
    
    return meshes, meshCount
end

-- Функция сканирования Attachments
local function scanAttachments(model)
    local attachments = {}
    local attachmentCount = 0
    
    for _, obj in pairs(model:GetDescendants()) do
        if obj:IsA("Attachment") then
            attachmentCount = attachmentCount + 1
            local attachmentData = {
                name = obj.Name,
                cframe = obj.CFrame,
                worldCFrame = obj.WorldCFrame,
                parent = obj.Parent and obj.Parent.Name or "nil",
                visible = obj.Visible
            }
            table.insert(attachments, attachmentData)
        end
    end
    
    return attachments, attachmentCount
end

-- Функция поиска Animation ID в скриптах
local function scanAnimations(model)
    local animations = {}
    local animationCount = 0
    
    for _, obj in pairs(model:GetDescendants()) do
        if obj:IsA("Animation") then
            animationCount = animationCount + 1
            local animData = {
                name = obj.Name,
                animationId = obj.AnimationId,
                parent = obj.Parent and obj.Parent.Name or "nil"
            }
            table.insert(animations, animData)
        elseif obj:IsA("LocalScript") or obj:IsA("Script") then
            -- Ищем Animation ID в коде скриптов
            local success, source = pcall(function() return obj.Source end)
            if success and source then
                for animId in source:gmatch("rbxassetid://(%d+)") do
                    animationCount = animationCount + 1
                    local animData = {
                        name = "Found in " .. obj.Name,
                        animationId = "rbxassetid://" .. animId,
                        parent = obj.Name,
                        source = "script"
                    }
                    table.insert(animations, animData)
                end
            end
        end
    end
    
    return animations, animationCount
end

-- Функция сканирования базовых частей модели
local function scanBaseParts(model)
    local parts = {}
    local partCount = 0
    
    for _, obj in pairs(model:GetDescendants()) do
        if obj:IsA("BasePart") then
            partCount = partCount + 1
            local partData = {
                name = obj.Name,
                className = obj.ClassName,
                size = obj.Size,
                material = obj.Material.Name,
                color = obj.Color,
                transparency = obj.Transparency,
                canCollide = obj.CanCollide,
                anchored = obj.Anchored,
                cframe = obj.CFrame,
                parent = obj.Parent and obj.Parent.Name or "nil"
            }
            table.insert(parts, partData)
        end
    end
    
    return parts, partCount
end

-- Главная функция сканирования UUID питомца
local function scanUUIDPet(petModel)
    logEvent("🔬 DEEP_SCAN", "Starting deep structure analysis", {
        PetName = petModel.Name,
        PetClass = petModel.ClassName
    })
    
    local petData = {
        name = petModel.Name,
        className = petModel.ClassName,
        primaryPart = petModel.PrimaryPart and petModel.PrimaryPart.Name or "nil",
        scanTime = os.date("%Y-%m-%d %H:%M:%S"),
        position = (function()
            local ok, cf = pcall(function()
                return petModel:GetModelCFrame()
            end)
            if ok and cf then
                return cf.Position
            end
            local pp = petModel.PrimaryPart
            return pp and pp.Position or Vector3.new()
        end)()
    }
    
    -- Сканируем Motor6D
    logEvent("🔧 MOTOR6D_SCAN", "Scanning Motor6D joints...")
    petData.motors, petData.motorCount = scanMotor6D(petModel)
    logEvent("🔧 MOTOR6D_RESULT", "Found " .. petData.motorCount .. " Motor6D joints")
    
    -- Сканируем Meshes
    logEvent("🎨 MESH_SCAN", "Scanning mesh data...")
    petData.meshes, petData.meshCount = scanMeshData(petModel)
    logEvent("🎨 MESH_RESULT", "Found " .. petData.meshCount .. " mesh components")
    
    -- Сканируем Attachments
    logEvent("📎 ATTACHMENT_SCAN", "Scanning attachments...")
    petData.attachments, petData.attachmentCount = scanAttachments(petModel)
    logEvent("📎 ATTACHMENT_RESULT", "Found " .. petData.attachmentCount .. " attachments")
    
    -- Сканируем Animations
    logEvent("🎭 ANIMATION_SCAN", "Scanning animations...")
    petData.animations, petData.animationCount = scanAnimations(petModel)
    logEvent("🎭 ANIMATION_RESULT", "Found " .. petData.animationCount .. " animation references")
    
    -- Сканируем BaseParts
    logEvent("🧱 PARTS_SCAN", "Scanning base parts...")
    petData.parts, petData.partCount = scanBaseParts(petModel)
    logEvent("🧱 PARTS_RESULT", "Found " .. petData.partCount .. " base parts")
    
    -- Сохраняем в базу данных
    petDatabase[petModel.Name] = petData
    
    logEvent("💾 SAVE_COMPLETE", "Pet structure saved to database", {
        TotalMotors = petData.motorCount,
        TotalMeshes = petData.meshCount,
        TotalAttachments = petData.attachmentCount,
        TotalAnimations = petData.animationCount,
        TotalParts = petData.partCount
    })
    
    return petData
end



-- Функция экспорта базы данных питомцев
local function exportPetDatabase()
    if not scriptRunning then return end
    
    logEvent("💾 EXPORT_START", "Starting pet database export...")
    
    if next(petDatabase) == nil then
        logEvent("⚠️ EXPORT_WARNING", "Pet database is empty! Scan some pets first.")
        return
    end
    
    local exportData = {
        exportTime = os.date("%Y-%m-%d %H:%M:%S"),
        totalPets = 0,
        pets = {}
    }
    
    -- Подсчитываем и экспортируем каждого питомца
    for petName, petData in pairs(petDatabase) do
        exportData.totalPets = exportData.totalPets + 1
        exportData.pets[petName] = petData
        
        logEvent("📦 EXPORTING", "Pet: " .. petName, {
            Motors = petData.motorCount or 0,
            Meshes = petData.meshCount or 0,
            Parts = petData.partCount or 0,
            Attachments = petData.attachmentCount or 0,
            Animations = petData.animationCount or 0
        })
    end
    
    -- Выводим полный экспорт в консоль
    logEvent("💾 EXPORT_DATA", "=== PET DATABASE EXPORT START ===")
    logEvent("📊 EXPORT_SUMMARY", "Total pets in database: " .. exportData.totalPets)
    logEvent("📅 EXPORT_TIME", "Export time: " .. exportData.exportTime)
    
    -- Детальный экспорт каждого питомца
    for petName, petData in pairs(exportData.pets) do
        logEvent("🐾 PET_EXPORT", "=== " .. petName .. " ===")
        logEvent("📋 PET_INFO", "Class: " .. (petData.className or "Unknown"))
        logEvent("📍 PET_POSITION", "Position: " .. tostring(petData.position or "Unknown"))
        logEvent("🕒 PET_SCAN_TIME", "Scanned: " .. (petData.scanTime or "Unknown"))
        
        -- Motor6D данные
        if petData.motors and #petData.motors > 0 then
            logEvent("🔧 MOTORS", "Motor6D joints (" .. #petData.motors .. "):")
            for i, motor in ipairs(petData.motors) do
                logEvent("🔧 MOTOR_" .. i, motor.name .. " [" .. motor.part0 .. " -> " .. motor.part1 .. "]")
            end
        end
        
        -- Mesh данные
        if petData.meshes and #petData.meshes > 0 then
            logEvent("🎨 MESHES", "Mesh components (" .. #petData.meshes .. "):")
            for i, mesh in ipairs(petData.meshes) do
                logEvent("🎨 MESH_" .. i, mesh.name .. " [" .. mesh.type .. "] ID: " .. (mesh.meshId or "none"))
            end
        end
        
        -- Attachment данные
        if petData.attachments and #petData.attachments > 0 then
            logEvent("📎 ATTACHMENTS", "Attachments (" .. #petData.attachments .. "):")
            for i, att in ipairs(petData.attachments) do
                logEvent("📎 ATT_" .. i, att.name .. " [" .. att.parent .. "]")
            end
        end
        
        -- Animation данные
        if petData.animations and #petData.animations > 0 then
            logEvent("🎭 ANIMATIONS", "Animations (" .. #petData.animations .. "):")
            for i, anim in ipairs(petData.animations) do
                logEvent("🎭 ANIM_" .. i, anim.name .. " ID: " .. (anim.animationId or "none"))
            end
        end
        
        logEvent("🐾 PET_END", "=== END " .. petName .. " ===")
    end
    
    logEvent("💾 EXPORT_DATA", "=== PET DATABASE EXPORT END ===")
    logEvent("✅ EXPORT_COMPLETE", "Database export completed successfully!", {
        TotalPetsExported = exportData.totalPets,
        ExportTime = exportData.exportTime
    })
    
    -- Также выводим в print для удобного копирования
    print("=== PET STRUCTURE DATABASE EXPORT ===")
    print("Export Time: " .. exportData.exportTime)
    print("Total Pets: " .. exportData.totalPets)
    print("")
    
    for petName, petData in pairs(exportData.pets) do
        print("PET: " .. petName)
        print("  Class: " .. (petData.className or "Unknown"))
        print("  Motors: " .. (petData.motorCount or 0))
        print("  Meshes: " .. (petData.meshCount or 0))
        print("  Parts: " .. (petData.partCount or 0))
        print("  Attachments: " .. (petData.attachmentCount or 0))
        print("  Animations: " .. (petData.animationCount or 0))
        print("")
    end
    
    print("=== END EXPORT ===")
end

-- === СИСТЕМА ВОССОЗДАНИЯ ПИТОМЦЕВ ИЗ БАЗЫ ДАННЫХ ===

-- Функция создания BasePart из данных
local function createPartFromData(partData)
    local part = Instance.new(partData.className or "Part")
    part.Name = partData.name
    part.Size = partData.size
    part.CFrame = partData.cframe
    part.Color = partData.color
    part.Transparency = partData.transparency or 0
    part.CanCollide = partData.canCollide
    part.Anchored = partData.anchored
    
    -- Устанавливаем материал
    local success = pcall(function()
        part.Material = Enum.Material[partData.material]
    end)
    if not success then
        part.Material = Enum.Material.Plastic
    end
    
    return part
end

-- Функция создания Mesh из данных
local function createMeshFromData(meshData, parent)
    if meshData.type == "MeshPart" then
        -- Для MeshPart устанавливаем MeshId и TextureId
        if parent:IsA("MeshPart") then
            parent.MeshId = meshData.meshId or ""
            parent.TextureID = meshData.textureId or ""
        end
    elseif meshData.type == "SpecialMesh" then
        local mesh = Instance.new("SpecialMesh")
        mesh.Name = meshData.name
        mesh.MeshId = meshData.meshId or ""
        mesh.TextureId = meshData.textureId or ""
        mesh.Scale = meshData.scale or Vector3.new(1, 1, 1)
        
        -- Устанавливаем тип меша
        local success = pcall(function()
            mesh.MeshType = Enum.MeshType[meshData.meshType]
        end)
        if not success then
            mesh.MeshType = Enum.MeshType.FileMesh
        end
        
        mesh.Parent = parent
        return mesh
    end
end

-- Функция создания Motor6D из данных
local function createMotorFromData(motorData, model)
    local motor = Instance.new("Motor6D")
    motor.Name = motorData.name
    motor.C0 = motorData.c0
    motor.C1 = motorData.c1
    
    -- Находим части для соединения
    local part0 = model:FindFirstChild(motorData.part0)
    local part1 = model:FindFirstChild(motorData.part1)
    
    if part0 and part1 then
        motor.Part0 = part0
        motor.Part1 = part1
        motor.Parent = part0
        return motor
    else
        motor:Destroy()
        return nil
    end
end

-- Функция создания Attachment из данных
local function createAttachmentFromData(attachmentData, parent)
    local attachment = Instance.new("Attachment")
    attachment.Name = attachmentData.name
    attachment.CFrame = attachmentData.cframe
    attachment.Visible = attachmentData.visible or false
    attachment.Parent = parent
    return attachment
end

-- ГЛАВНАЯ ФУНКЦИЯ ВОССОЗДАНИЯ ПИТОМЦА
local function recreatePetFromDatabase(petName, position)
    if not petDatabase[petName] then
        logEvent("❌ RECREATE_ERROR", "Pet not found in database: " .. petName)
        return nil
    end
    
    local petData = petDatabase[petName]
    logEvent("🔧 RECREATE_START", "Recreating pet from database", {
        PetName = petName,
        TotalParts = petData.partCount or 0,
        TotalMotors = petData.motorCount or 0,
        TotalMeshes = petData.meshCount or 0
    })
    
    -- Создаем основную модель
    local model = Instance.new("Model")
    model.Name = petName .. "_RECREATED"
    
    local partsCreated = 0
    local motorsCreated = 0
    local meshesCreated = 0
    local attachmentsCreated = 0
    
    -- Создаем все части
    if petData.parts then
        for _, partData in ipairs(petData.parts) do
            local success, part = pcall(function()
                return createPartFromData(partData)
            end)
            
            if success and part then
                part.Parent = model
                partsCreated = partsCreated + 1
                
                -- Устанавливаем PrimaryPart если это первая часть или указанная
                if not model.PrimaryPart or partData.name == petData.primaryPart then
                    model.PrimaryPart = part
                end
            end
        end
    end
    
    -- Создаем Meshes
    if petData.meshes then
        for _, meshData in ipairs(petData.meshes) do
            local parentPart = model:FindFirstChild(meshData.parent)
            if parentPart then
                local success = pcall(function()
                    createMeshFromData(meshData, parentPart)
                end)
                if success then
                    meshesCreated = meshesCreated + 1
                end
            end
        end
    end
    
    -- Создаем Attachments
    if petData.attachments then
        for _, attachmentData in ipairs(petData.attachments) do
            local parentPart = model:FindFirstChild(attachmentData.parent)
            if parentPart then
                local success = pcall(function()
                    createAttachmentFromData(attachmentData, parentPart)
                end)
                if success then
                    attachmentsCreated = attachmentsCreated + 1
                end
            end
        end
    end
    
    -- Создаем Motor6D соединения (САМОЕ ВАЖНОЕ ДЛЯ АНИМАЦИЙ!)
    if petData.motors then
        for _, motorData in ipairs(petData.motors) do
            local success, motor = pcall(function()
                return createMotorFromData(motorData, model)
            end)
            
            if success and motor then
                motorsCreated = motorsCreated + 1
            end
        end
    end
    
    -- Позиционируем модель
    if position and model.PrimaryPart then
        pcall(function()
            if model.PivotTo then
                model:PivotTo(CFrame.new(position))
            else
                model:SetPrimaryPartCFrame(CFrame.new(position))
            end
        end)
    end
    
    -- Размещаем в Workspace
    model.Parent = Workspace
    
    logEvent("✅ RECREATE_SUCCESS", "Pet recreated successfully!", {
        PartsCreated = partsCreated,
        MotorsCreated = motorsCreated,
        MeshesCreated = meshesCreated,
        AttachmentsCreated = attachmentsCreated,
        ModelName = model.Name
    })
    
    return model
end

-- (удалено дублирующееся определение recreateNearestPet)

-- === ИНИЦИАЛИЗАЦИЯ И АВТОЗАПУСК ===

-- Функция автоматического мониторинга workspace
local function startAutoMonitoring()
    if not scriptRunning then return end
    
    logEvent("🔄 AUTO_MONITOR", "Starting automatic UUID pet monitoring...")
    
    -- Мониторинг появления новых моделей в workspace
    local workspaceConnection = Workspace.ChildAdded:Connect(function(child)
        if not scriptRunning then return end
        
        if child:IsA("Model") and isUUIDName(child.Name) then
            logEvent("🆕 NEW_UUID_PET", "New UUID pet detected: " .. child.Name)
            
            -- Небольшая задержка для полной загрузки модели
            spawn(function()
                wait(0.5)
                if child.Parent and scriptRunning then
                    local playerChar = player.Character
                    if playerChar and playerChar:FindFirstChild("HumanoidRootPart") then
                        local success, modelCFrame = pcall(function() return child:GetModelCFrame() end)
                        if success then
                            local distance = (modelCFrame.Position - playerChar.HumanoidRootPart.Position).Magnitude
                            if distance <= 100 then
                                logEvent("🔬 AUTO_SCAN", "Auto-scanning new UUID pet within range", {
                                    Name = child.Name,
                                    Distance = string.format("%.1f studs", distance)
                                })
                                local ok, err = pcall(function()
                                    scanUUIDPet(child)
                                end)
                                if not ok then
                                    logEvent("❌ AUTO_SCAN_ERROR", tostring(err) or "unknown error")
                                end
                            end
                        else
                            logEvent("❌ MODEL_CFRAME_ERROR", tostring(modelCFrame) or "unknown error")
                        end
                    end
                end
            end)
        end
    end)
    
    table.insert(connections, workspaceConnection)
    
    -- Периодическое сканирование (каждые 30 секунд)
    local periodicConnection = spawn(function()
        while scriptRunning do
            wait(30)
            if scriptRunning then
                logEvent("🔄 PERIODIC_SCAN", "Periodic UUID pet scan...")
                findAndScanNearbyUUIDPets()
            end
        end
    end)
    
    table.insert(connections, periodicConnection)
    
    logEvent("✅ AUTO_MONITOR_STARTED", "Automatic monitoring activated", {
        WorkspaceMonitoring = "ON",
        PeriodicScanning = "30 seconds",
        AutoScanRadius = "100 studs"
    })
end

-- (удалено дублирующееся определение startSystem)

-- Запуск системы (КАК В РАБОЧЕМ СКРИПТЕ)
local function startSystem()
    print("🚀 Запуск Pet Structure Analyzer v4.0...")
    
    -- Создаем GUI
    gui = createModernGUI()
    
    if not gui then
        print("❌ Ошибка создания GUI!")
        return
    end
    
    -- Автоскан при запуске отключен по запросу пользователя
    if autoStartMonitoring then
        startAutoMonitoring()
    else
        logEvent("🛑 AUTO_SCAN_DISABLED", "Auto-scan at startup is disabled")
    end
    
    logEvent("🎉 SYSTEM_READY", "Pet Structure Analyzer v4.0 is fully operational!", {
        GUI = "Modern interface loaded",
        AutoMonitoring = "Active",
        Database = "Ready for pet data",
        Status = "ONLINE"
    })
    
    print("✅ Pet Structure Analyzer v4.0 READY!")
    print("🔬 Modern GUI loaded with enhanced scanning capabilities")
    print("🤖 Automatic monitoring: ON")
    print("📊 Database system: READY")
    print("🎯 Scan radius: 100 studs")
    print("⚡ Ready to analyze UUID pet structures!")
end

-- === АВТОЗАПУСК СИСТЕМЫ ===
print("🌟 Pet Structure Analyzer v4.0 - MODERN EDITION")
print("🔬 Advanced UUID Pet Structure Scanner")
print("💫 Developed for deep pet analysis and recreation")
print("")

-- Запускаем систему (КАК В РАБОЧЕМ СКРИПТЕ)
startSystem()

print("📝 Часть 5 завершена: Инициализация и автозапуск")
print("🎉 PET STRUCTURE ANALYZER v4.0 ПОЛНОСТЬЮ ГОТОВ!")
