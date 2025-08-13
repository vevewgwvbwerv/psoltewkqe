-- 🔍 PET CREATION ANALYZER v1.0
-- Анализирует процесс создания визуального питомца
-- Отслеживает: Backpack → Handle → Позиционирование

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local backpack = player.Backpack
local playerGui = player:WaitForChild("PlayerGui")

print("🔍 === PET CREATION ANALYZER v1.0 ===")
print("🎯 Отслеживаем: Backpack → Handle → Позиционирование")

-- === СИСТЕМЫ ЛОГИРОВАНИЯ ===
local analysisLog = {}
local petCreationEvents = {}
local currentHandleTool = nil

-- Функция логирования
local function log(category, message, data)
    local entry = {
        time = tick(),
        category = category,
        message = message,
        data = data or {}
    }
    table.insert(analysisLog, entry)
    print(string.format("[%.3f] [%s] %s", entry.time, category, message))
    if data and next(data) then
        for key, value in pairs(data) do
            print(string.format("  └─ %s: %s", key, tostring(value)))
        end
    end
end

-- Функция анализа Tool
local function analyzeTool(tool)
    if not tool or not tool:IsA("Tool") then return nil end
    
    local info = {
        name = tool.Name,
        parent = tool.Parent and tool.Parent.Name or "nil",
        handle = nil
    }
    
    local handle = tool:FindFirstChild("Handle")
    if handle and handle:IsA("BasePart") then
        info.handle = {
            size = tostring(handle.Size),
            position = tostring(handle.Position),
            cframe = tostring(handle.CFrame),
            anchored = handle.Anchored,
            transparency = handle.Transparency
        }
        
        -- Анализируем Mesh
        for _, child in pairs(handle:GetChildren()) do
            if child:IsA("SpecialMesh") then
                info.handle.mesh = {
                    meshId = child.MeshId,
                    textureId = child.TextureId,
                    scale = tostring(child.Scale)
                }
            end
        end
    end
    
    return info
end

-- === МОНИТОРИНГ BACKPACK ===
log("SYSTEM", "🎒 Запуск мониторинга Backpack")

backpack.ChildAdded:Connect(function(child)
    if child:IsA("Tool") then
        wait(0.1)
        local toolInfo = analyzeTool(child)
        log("BACKPACK", "✅ НОВЫЙ TOOL: " .. child.Name, toolInfo)
        
        -- Проверяем питомца
        if child.Name:find("KG") or child.Name:find("Dragonfly") or 
           child.Name:find("%{") or child.Name:find("Pet") then
            log("PET_DETECTION", "🐾 ПИТОМЕЦ В BACKPACK: " .. child.Name, toolInfo)
            table.insert(petCreationEvents, {
                timestamp = tick(),
                phase = "BACKPACK_ADDED",
                petName = child.Name,
                toolInfo = toolInfo
            })
        end
        
        -- Отслеживаем когда покидает Backpack
        child.AncestryChanged:Connect(function()
            if child.Parent ~= backpack then
                log("BACKPACK", "📤 Tool покинул Backpack: " .. child.Name, {
                    newParent = child.Parent and child.Parent.Name or "nil"
                })
            end
        end)
    end
end)

-- === МОНИТОРИНГ HANDLE ===
log("SYSTEM", "🤲 Запуск мониторинга Handle")

local function monitorCharacter(char)
    if not char then return end
    
    char.ChildAdded:Connect(function(child)
        if child:IsA("Tool") then
            wait(0.1)
            currentHandleTool = child
            local analysis = analyzeTool(child)
            
            log("HANDLE", "⚡ TOOL ЭКИПИРОВАН: " .. child.Name, analysis)
            
            -- Проверяем питомца
            if child.Name:find("KG") or child.Name:find("Dragonfly") or 
               child.Name:find("%{") or child.Name:find("Pet") then
                
                log("PET_DETECTION", "🐾 ПИТОМЕЦ В РУКЕ: " .. child.Name, analysis)
                
                table.insert(petCreationEvents, {
                    timestamp = tick(),
                    phase = "HANDLE_EQUIPPED",
                    petName = child.Name,
                    analysis = analysis
                })
                
                -- Анализируем позиционирование
                local handle = child:FindFirstChild("Handle")
                if handle then
                    local torso = char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
                    if torso then
                        local relativePos = torso.CFrame:PointToObjectSpace(handle.Position)
                        log("POSITION", "📍 Относительная позиция Handle", {
                            relativePosition = tostring(relativePos),
                            handleCFrame = tostring(handle.CFrame)
                        })
                    end
                end
                
                -- Анализируем RightGrip
                local rightArm = char:FindFirstChild("Right Arm") or char:FindFirstChild("RightHand")
                if rightArm then
                    local rightGrip = rightArm:FindFirstChild("RightGrip")
                    if rightGrip then
                        log("GRIP", "🔗 RightGrip найден", {
                            c0 = tostring(rightGrip.C0),
                            c1 = tostring(rightGrip.C1),
                            part0 = rightGrip.Part0 and rightGrip.Part0.Name or "nil",
                            part1 = rightGrip.Part1 and rightGrip.Part1.Name or "nil"
                        })
                    end
                end
            end
        end
    end)
    
    char.ChildRemoved:Connect(function(child)
        if child:IsA("Tool") and child == currentHandleTool then
            log("HANDLE", "📤 TOOL СНЯТ: " .. child.Name)
            currentHandleTool = nil
        end
    end)
end

if character then
    monitorCharacter(character)
end

player.CharacterAdded:Connect(monitorCharacter)

-- === ФУНКЦИЯ ОТЧЕТА ===
local function generateReport()
    print("\n" .. "=" .. string.rep("=", 50))
    print("📊 === ОТЧЕТ О СОЗДАНИИ ПИТОМЦА ===")
    print("=" .. string.rep("=", 50))
    
    if #petCreationEvents == 0 then
        print("❌ Событий создания питомца не обнаружено")
        return
    end
    
    for i, event in ipairs(petCreationEvents) do
        print(string.format("\n🔸 Событие %d: %s", i, event.phase))
        print(string.format("   ⏰ Время: %.3f", event.timestamp))
        print(string.format("   🐾 Питомец: %s", event.petName))
        
        if event.toolInfo and event.toolInfo.handle then
            print("   📦 Handle Info:")
            print(string.format("      Size: %s", event.toolInfo.handle.size))
            print(string.format("      Position: %s", event.toolInfo.handle.position))
        end
    end
    
    print("\n" .. "=" .. string.rep("=", 50))
end

-- === GUI ===
local function createGUI()
    local success, errorMsg = pcall(function()
        local oldGui = playerGui:FindFirstChild("PetAnalyzerGUI")
        if oldGui then oldGui:Destroy() end
        
        local screenGui = Instance.new("ScreenGui")
        screenGui.Name = "PetAnalyzerGUI"
        screenGui.ResetOnSpawn = false
        screenGui.Parent = playerGui
        
        -- Главная рамка
        local mainFrame = Instance.new("Frame")
        mainFrame.Name = "MainFrame"
        mainFrame.Size = UDim2.new(0, 350, 0, 300)
        mainFrame.Position = UDim2.new(0, 10, 0, 10)
        mainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        mainFrame.BorderSizePixel = 2
        mainFrame.BorderColor3 = Color3.fromRGB(0, 150, 255)
        mainFrame.Parent = screenGui
        
        -- Заголовок
        local titleFrame = Instance.new("Frame")
        titleFrame.Name = "TitleFrame"
        titleFrame.Size = UDim2.new(1, 0, 0, 50)
        titleFrame.Position = UDim2.new(0, 0, 0, 0)
        titleFrame.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
        titleFrame.BorderSizePixel = 0
        titleFrame.Parent = mainFrame
        
        local titleLabel = Instance.new("TextLabel")
        titleLabel.Name = "TitleLabel"
        titleLabel.Size = UDim2.new(1, -10, 1, -10)
        titleLabel.Position = UDim2.new(0, 5, 0, 5)
        titleLabel.BackgroundTransparency = 1
        titleLabel.Text = "🔍 Pet Creation Analyzer v1.0"
        titleLabel.TextColor3 = Color3.white
        titleLabel.TextSize = 18
        titleLabel.Font = Enum.Font.SourceSansBold
        titleLabel.TextXAlignment = Enum.TextXAlignment.Center
        titleLabel.Parent = titleFrame
        
        -- Статус
        local statusLabel = Instance.new("TextLabel")
        statusLabel.Name = "StatusLabel"
        statusLabel.Size = UDim2.new(1, -20, 0, 25)
        statusLabel.Position = UDim2.new(0, 10, 0, 60)
        statusLabel.BackgroundTransparency = 1
        statusLabel.Text = "✅ Анализатор активен - ожидание питомца..."
        statusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
        statusLabel.TextSize = 14
        statusLabel.Font = Enum.Font.SourceSans
        statusLabel.TextXAlignment = Enum.TextXAlignment.Left
        statusLabel.Parent = mainFrame
        
        -- Счетчики
        local logCountLabel = Instance.new("TextLabel")
        logCountLabel.Name = "LogCountLabel"
        logCountLabel.Size = UDim2.new(1, -20, 0, 20)
        logCountLabel.Position = UDim2.new(0, 10, 0, 90)
        logCountLabel.BackgroundTransparency = 1
        logCountLabel.Text = "📝 Записей в логе: 0"
        logCountLabel.TextColor3 = Color3.white
        logCountLabel.TextSize = 12
        logCountLabel.Font = Enum.Font.SourceSans
        logCountLabel.TextXAlignment = Enum.TextXAlignment.Left
        logCountLabel.Parent = mainFrame
        
        local petCountLabel = Instance.new("TextLabel")
        petCountLabel.Name = "PetCountLabel"
        petCountLabel.Size = UDim2.new(1, -20, 0, 20)
        petCountLabel.Position = UDim2.new(0, 10, 0, 115)
        petCountLabel.BackgroundTransparency = 1
        petCountLabel.Text = "🐾 События питомцев: 0"
        petCountLabel.TextColor3 = Color3.white
        petCountLabel.TextSize = 12
        petCountLabel.Font = Enum.Font.SourceSans
        petCountLabel.TextXAlignment = Enum.TextXAlignment.Left
        petCountLabel.Parent = mainFrame
        
        local currentToolLabel = Instance.new("TextLabel")
        currentToolLabel.Name = "CurrentToolLabel"
        currentToolLabel.Size = UDim2.new(1, -20, 0, 20)
        currentToolLabel.Position = UDim2.new(0, 10, 0, 140)
        currentToolLabel.BackgroundTransparency = 1
        currentToolLabel.Text = "🤲 В руке: Нет"
        currentToolLabel.TextColor3 = Color3.white
        currentToolLabel.TextSize = 12
        currentToolLabel.Font = Enum.Font.SourceSans
        currentToolLabel.TextXAlignment = Enum.TextXAlignment.Left
        currentToolLabel.Parent = mainFrame
        
        -- Кнопка создания отчета
        local reportButton = Instance.new("TextButton")
        reportButton.Name = "ReportButton"
        reportButton.Size = UDim2.new(1, -20, 0, 35)
        reportButton.Position = UDim2.new(0, 10, 0, 170)
        reportButton.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
        reportButton.BorderSizePixel = 1
        reportButton.BorderColor3 = Color3.fromRGB(0, 255, 0)
        reportButton.Text = "📊 Создать отчет о питомце"
        reportButton.TextColor3 = Color3.white
        reportButton.TextSize = 14
        reportButton.Font = Enum.Font.SourceSansBold
        reportButton.Parent = mainFrame
        
        -- Кнопка очистки лога
        local clearButton = Instance.new("TextButton")
        clearButton.Name = "ClearButton"
        clearButton.Size = UDim2.new(0.48, 0, 0, 30)
        clearButton.Position = UDim2.new(0, 10, 0, 215)
        clearButton.BackgroundColor3 = Color3.fromRGB(200, 100, 0)
        clearButton.BorderSizePixel = 1
        clearButton.BorderColor3 = Color3.fromRGB(255, 150, 0)
        clearButton.Text = "🗑️ Очистить"
        clearButton.TextColor3 = Color3.white
        clearButton.TextSize = 12
        clearButton.Font = Enum.Font.SourceSansBold
        clearButton.Parent = mainFrame
        
        -- Кнопка закрытия
        local closeButton = Instance.new("TextButton")
        closeButton.Name = "CloseButton"
        closeButton.Size = UDim2.new(0.48, 0, 0, 30)
        closeButton.Position = UDim2.new(0.52, 0, 0, 215)
        closeButton.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
        closeButton.BorderSizePixel = 1
        closeButton.BorderColor3 = Color3.fromRGB(255, 0, 0)
        closeButton.Text = "❌ Закрыть"
        closeButton.TextColor3 = Color3.white
        closeButton.TextSize = 12
        closeButton.Font = Enum.Font.SourceSansBold
        closeButton.Parent = mainFrame
        
        -- Информационная панель
        local infoLabel = Instance.new("TextLabel")
        infoLabel.Name = "InfoLabel"
        infoLabel.Size = UDim2.new(1, -20, 0, 40)
        infoLabel.Position = UDim2.new(0, 10, 0, 250)
        infoLabel.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        infoLabel.BorderSizePixel = 1
        infoLabel.BorderColor3 = Color3.fromRGB(100, 100, 100)
        infoLabel.Text = "💡 Создайте питомца и возьмите в руки\nдля начала анализа"
        infoLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        infoLabel.TextSize = 11
        infoLabel.Font = Enum.Font.SourceSans
        infoLabel.TextXAlignment = Enum.TextXAlignment.Center
        infoLabel.TextYAlignment = Enum.TextYAlignment.Center
        infoLabel.Parent = mainFrame
        
        -- === ОБРАБОТЧИКИ СОБЫТИЙ ===
        reportButton.MouseButton1Click:Connect(function()
            reportButton.Text = "⏳ Создание отчета..."
            reportButton.BackgroundColor3 = Color3.fromRGB(100, 100, 0)
            
            spawn(function()
                wait(0.5)
                generateReport()
                reportButton.Text = "📊 Создать отчет о питомце"
                reportButton.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
            end)
        end)
        
        clearButton.MouseButton1Click:Connect(function()
            clearButton.Text = "⏳ Очистка..."
            clearButton.BackgroundColor3 = Color3.fromRGB(100, 50, 0)
            
            spawn(function()
                analysisLog = {}
                petCreationEvents = {}
                log("SYSTEM", "🗑️ Лог очищен")
                wait(1)
                clearButton.Text = "🗑️ Очистить"
                clearButton.BackgroundColor3 = Color3.fromRGB(200, 100, 0)
            end)
        end)
        
        closeButton.MouseButton1Click:Connect(function()
            screenGui:Destroy()
        end)
        
        -- === ОБНОВЛЕНИЕ ИНТЕРФЕЙСА ===
        spawn(function()
            while screenGui and screenGui.Parent do
                wait(1)
                
                -- Обновляем счетчики
                if logCountLabel and logCountLabel.Parent then
                    logCountLabel.Text = "📝 Записей в логе: " .. #analysisLog
                end
                
                if petCountLabel and petCountLabel.Parent then
                    petCountLabel.Text = "🐾 События питомцев: " .. #petCreationEvents
                end
                
                if currentToolLabel and currentToolLabel.Parent then
                    if currentHandleTool then
                        currentToolLabel.Text = "🤲 В руке: " .. currentHandleTool.Name
                        currentToolLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
                    else
                        currentToolLabel.Text = "🤲 В руке: Нет"
                        currentToolLabel.TextColor3 = Color3.white
                    end
                end
                
                -- Обновляем статус
                if statusLabel and statusLabel.Parent then
                    if #petCreationEvents > 0 then
                        statusLabel.Text = "✅ Анализатор активен - найдено событий: " .. #petCreationEvents
                        statusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
                    else
                        statusLabel.Text = "⏳ Анализатор активен - ожидание питомца..."
                        statusLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
                    end
                end
            end
        end)
        
        log("GUI", "✅ GUI интерфейс создан успешно")
        return true
    end)
    
    if not success then
        log("GUI", "❌ Ошибка создания GUI: " .. tostring(errorMsg))
        return false
    end
    
    return true
end

createGUI()

log("SYSTEM", "✅ Pet Creation Analyzer запущен!")
log("SYSTEM", "💡 Создайте питомца и возьмите его в руки для анализа")
