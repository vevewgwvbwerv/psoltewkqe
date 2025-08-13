-- SIMPLE PET ANALYZER v2.0
-- Анализатор питомцев с GUI консолью и мониторингом workspace

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local backpack = player.Backpack
local playerGui = player:WaitForChild("PlayerGui")

print("=== SIMPLE PET ANALYZER v2.0 STARTED ===")
print("Monitoring backpack, hands and workspace for pets...")

-- Переменные для хранения данных
local petEvents = {}
local currentTool = nil
local consoleOutput = {}
local gui = nil
local recentRemoteCalls = {}
local remoteConnections = {}

-- Функция логирования с GUI консолью
local function logEvent(eventType, petName, details)
    local event = {
        time = tick(),
        type = eventType,
        pet = petName,
        details = details or {}
    }
    table.insert(petEvents, event)
    
    local logMessage = string.format("[%.2f] %s: %s", event.time, eventType, petName)
    print(logMessage)
    
    -- Добавляем в GUI консоль
    table.insert(consoleOutput, logMessage)
    if details then
        for key, value in pairs(details) do
            local detailMsg = string.format("  %s: %s", key, tostring(value))
            print(detailMsg)
            table.insert(consoleOutput, detailMsg)
        end
    end
    
    -- Ограничиваем размер консоли
    if #consoleOutput > 100 then
        table.remove(consoleOutput, 1)
    end
    
    -- Обновляем GUI консоль если существует
    updateGUIConsole()
end

-- Функция обновления GUI консоли (ИСПРАВЛЕННАЯ)
local function updateGUIConsole()
    if gui and gui:FindFirstChild("MainFrame") then
        local mainFrame = gui:FindFirstChild("MainFrame")
        if mainFrame then
            local consoleFrame = mainFrame:FindFirstChild("ConsoleFrame")
            if consoleFrame then
                local consoleText = consoleFrame:FindFirstChild("ConsoleText")
                if consoleText then
                    local displayText = ""
                    local startIndex = math.max(1, #consoleOutput - 15) -- Показываем последние 15 строк
                    for i = startIndex, #consoleOutput do
                        displayText = displayText .. consoleOutput[i] .. "\n"
                    end
                    consoleText.Text = displayText
                    
                    -- Обновляем размер canvas для скроллинга
                    local textHeight = consoleText.TextBounds.Y
                    consoleFrame.CanvasSize = UDim2.new(0, 0, 0, math.max(textHeight + 20, consoleFrame.AbsoluteSize.Y))
                    
                    -- Автоскролл вниз
                    consoleFrame.CanvasPosition = Vector2.new(0, math.max(0, textHeight - consoleFrame.AbsoluteSize.Y))
                end
            end
        end
    end
end

-- Функция анализа Tool (РАСШИРЕННАЯ)
local function analyzeTool(tool)
    if not tool then return {} end
    
    local data = {
        name = tool.Name,
        className = tool.ClassName,
        canBeDropped = tool.CanBeDropped,
        enabled = tool.Enabled,
        requiresHandle = tool.RequiresHandle,
        toolTip = tool.ToolTip
    }
    
    -- Анализируем все дочерние объекты
    data.children = {}
    for _, child in pairs(tool:GetChildren()) do
        table.insert(data.children, {
            name = child.Name,
            className = child.ClassName
        })
    end
    
    local handle = tool:FindFirstChild("Handle")
    if handle then
        data.handleSize = tostring(handle.Size)
        data.handlePosition = tostring(handle.Position)
        data.handleCFrame = tostring(handle.CFrame)
        data.handleMaterial = handle.Material.Name
        data.handleAnchored = handle.Anchored
        data.handleCanCollide = handle.CanCollide
        data.handleTransparency = handle.Transparency
        data.handleBrickColor = tostring(handle.BrickColor)
        data.handleColor = tostring(handle.Color)
        
        -- Детальный анализ всех объектов в Handle
        data.handleChildren = {}
        for _, child in pairs(handle:GetChildren()) do
            local childData = {
                name = child.Name,
                className = child.ClassName
            }
            
            if child:IsA("SpecialMesh") then
                childData.meshType = child.MeshType.Name
                childData.meshId = child.MeshId
                childData.textureId = child.TextureId
                childData.meshScale = tostring(child.Scale)
                childData.meshOffset = tostring(child.Offset)
            elseif child:IsA("Attachment") then
                childData.position = tostring(child.Position)
                childData.orientation = tostring(child.Orientation)
                childData.cframe = tostring(child.CFrame)
            elseif child:IsA("Weld") or child:IsA("WeldConstraint") or child:IsA("Motor6D") then
                childData.part0 = child.Part0 and child.Part0.Name or "nil"
                childData.part1 = child.Part1 and child.Part1.Name or "nil"
                if child:IsA("Motor6D") then
                    childData.c0 = tostring(child.C0)
                    childData.c1 = tostring(child.C1)
                    childData.transform = tostring(child.Transform)
                end
            elseif child:IsA("Sound") then
                childData.soundId = child.SoundId
                childData.volume = child.Volume
                childData.pitch = child.Pitch
            end
            
            table.insert(data.handleChildren, childData)
        end
    end
    
    return data
end

-- Проверка является ли Tool питомцем
local function isPet(tool)
    if not tool then return false end
    local name = tool.Name
    return name:find("KG") or name:find("Dragonfly") or 
           name:find("{") or name:find("Pet") or name:find("pet")
end

-- Функция анализа источника появления питомца
local function analyzeToolSource(tool)
    local sourceData = {
        creationTime = tick(),
        stackTrace = debug.traceback("Tool creation source:", 2)
    }
    
    -- Получаем недавние RemoteEvent вызовы (последние 10 секунд)
    local recentCalls = getRecentRemoteCalls(10)
    sourceData.recentRemoteCalls = {}
    
    for _, call in ipairs(recentCalls) do
        table.insert(sourceData.recentRemoteCalls, {
            name = call.remoteName,
            path = call.remotePath,
            timeDiff = string.format("%.2f", sourceData.creationTime - call.time),
            argsCount = call.argsCount,
            firstArg = call.args[1] and tostring(call.args[1]) or "nil"
        })
    end
    
    -- Анализируем доступные RemoteEvent/Function
    local success, remoteEvents = pcall(function()
        local events = {}
        for _, obj in pairs(game.ReplicatedStorage:GetDescendants()) do
            if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                table.insert(events, {
                    name = obj.Name,
                    path = obj:GetFullName()
                })
            end
        end
        return events
    end)
    
    if success then
        sourceData.availableRemotes = remoteEvents
    end
    
    -- Проверяем StarterPack
    local starterPack = game.StarterPack:GetChildren()
    sourceData.starterPackTools = {}
    for _, obj in pairs(starterPack) do
        if obj:IsA("Tool") then
            table.insert(sourceData.starterPackTools, obj.Name)
        end
    end
    
    -- Анализ вероятного источника
    sourceData.likelySource = "Unknown"
    if #sourceData.recentRemoteCalls > 0 then
        local mostRecent = sourceData.recentRemoteCalls[#sourceData.recentRemoteCalls]
        if tonumber(mostRecent.timeDiff) < 2 then -- Если RemoteEvent был менее 2 секунд назад
            sourceData.likelySource = "RemoteEvent: " .. mostRecent.name
        end
    end
    
    return sourceData
end

-- Мониторинг Backpack с анализом источника
backpack.ChildAdded:Connect(function(child)
    if child:IsA("Tool") then
        wait(0.1)
        if isPet(child) then
            local data = analyzeTool(child)
            local sourceData = analyzeToolSource(child)
            
            -- Объединяем данные
            for key, value in pairs(sourceData) do
                data["source_" .. key] = value
            end
            
            logEvent("BACKPACK_ADDED", child.Name, data)
            
            -- Дополнительный анализ: откуда мог появиться Tool
            logEvent("SOURCE_ANALYSIS", child.Name, {
                possibleSources = {
                    "RemoteEvent from server",
                    "StarterPack clone", 
                    "Script creation",
                    "Game service call"
                },
                toolParent = child.Parent and child.Parent.Name or "nil",
                toolArchivable = child.Archivable,
                toolClassName = child.ClassName
            })
        end
    end
end)

-- Мониторинг появления питомца в Workspace
local function monitorWorkspacePets()
    logEvent("SYSTEM", "Запуск мониторинга Workspace для UUID питомцев")
    
    Workspace.ChildAdded:Connect(function(child)
        if child:IsA("Model") then
            wait(0.1) -- Даем время на загрузку
            
            -- Проверяем UUID имя в фигурных скобках
            if child.Name:find("{") and child.Name:find("}") then
                local playerPos = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                if playerPos then
                    local distance = (child:GetModelCFrame().Position - playerPos.Position).Magnitude
                    if distance < 50 then -- В радиусе 50 studs от игрока
                        logEvent("WORKSPACE_PET_SPAWNED", child.Name, {
                            distance = string.format("%.2f", distance),
                            position = tostring(child:GetModelCFrame().Position),
                            primaryPart = child.PrimaryPart and child.PrimaryPart.Name or "nil"
                        })
                        
                        -- Анализируем структуру питомца в workspace
                        local petData = {
                            name = child.Name,
                            className = child.ClassName,
                            children = {}
                        }
                        
                        for _, obj in pairs(child:GetChildren()) do
                            table.insert(petData.children, {
                                name = obj.Name,
                                className = obj.ClassName,
                                size = obj:IsA("BasePart") and tostring(obj.Size) or "N/A"
                            })
                        end
                        
                        logEvent("WORKSPACE_PET_ANALYSIS", child.Name, petData)
                    end
                end
            end
        end
    end)
end

-- Мониторинг Character
local function monitorCharacter(char)
    if not char then return end
    
    char.ChildAdded:Connect(function(child)
        if child:IsA("Tool") then
            wait(0.1)
            currentTool = child
            
            if isPet(child) then
                local data = analyzeTool(child)
                
                -- Дополнительный анализ позиции в руке
                local handle = child:FindFirstChild("Handle")
                if handle then
                    local torso = char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
                    if torso then
                        local relativePos = torso.CFrame:PointToObjectSpace(handle.Position)
                        data.relativeToTorso = tostring(relativePos)
                    end
                    
                    -- Анализ RightGrip
                    local rightArm = char:FindFirstChild("Right Arm") or char:FindFirstChild("RightHand")
                    if rightArm then
                        local rightGrip = rightArm:FindFirstChild("RightGrip")
                        if rightGrip then
                            data.rightGripC0 = tostring(rightGrip.C0)
                            data.rightGripC1 = tostring(rightGrip.C1)
                        end
                    end
                end
                
                logEvent("HAND_EQUIPPED", child.Name, data)
            end
        end
    end)
    
    char.ChildRemoved:Connect(function(child)
        if child:IsA("Tool") and child == currentTool then
            if isPet(child) then
                logEvent("HAND_REMOVED", child.Name)
                -- После снятия питомца с руки запускаем мониторинг workspace на 10 секунд
                spawn(function()
                    logEvent("SYSTEM", "Мониторинг workspace после снятия питомца (10 сек)")
                    wait(10)
                    logEvent("SYSTEM", "Мониторинг workspace завершен")
                end)
            end
            currentTool = nil
        end
    end)
end

-- Запуск мониторинга
if character then
    monitorCharacter(character)
end

player.CharacterAdded:Connect(monitorCharacter)

-- Функция создания детального отчета
local function generateDetailedReport()
    local reportText = string.rep("=", 60) .. "\n"
    reportText = reportText .. "=== DETAILED PET ANALYSIS REPORT ===\n"
    reportText = reportText .. "Total events: " .. #petEvents .. "\n"
    reportText = reportText .. string.rep("=", 60) .. "\n\n"
    
    for i, event in ipairs(petEvents) do
        reportText = reportText .. string.format("[%d] %s - %s (%.2f)\n", i, event.type, event.pet, event.time)
        reportText = reportText .. string.rep("-", 40) .. "\n"
        
        local details = event.details
        
        -- Основные свойства Tool
        if details.className then
            reportText = reportText .. "  Tool Class: " .. details.className .. "\n"
        end
        if details.canBeDropped ~= nil then
            reportText = reportText .. "  Can Be Dropped: " .. tostring(details.canBeDropped) .. "\n"
        end
        
        -- Handle данные
        if details.handleSize then
            reportText = reportText .. "  Handle Properties:\n"
            reportText = reportText .. "    Size: " .. details.handleSize .. "\n"
            reportText = reportText .. "    Position: " .. details.handlePosition .. "\n"
            reportText = reportText .. "    Material: " .. (details.handleMaterial or "N/A") .. "\n"
        end
        
        -- Handle дочерние объекты
        if details.handleChildren and #details.handleChildren > 0 then
            reportText = reportText .. "  Handle Children:\n"
            for _, child in ipairs(details.handleChildren) do
                reportText = reportText .. string.format("    - %s (%s)\n", child.name, child.className)
                if child.meshId then
                    reportText = reportText .. "      Mesh ID: " .. child.meshId .. "\n"
                    reportText = reportText .. "      Mesh Scale: " .. (child.meshScale or "N/A") .. "\n"
                end
            end
        end
        
        -- Позиционирование в руке
        if details.relativeToTorso then
            reportText = reportText .. "  Hand Positioning:\n"
            reportText = reportText .. "    Relative to Torso: " .. details.relativeToTorso .. "\n"
        end
        
        if details.rightGripC0 then
            reportText = reportText .. "  RightGrip Connection:\n"
            reportText = reportText .. "    C0: " .. details.rightGripC0 .. "\n"
            reportText = reportText .. "    C1: " .. details.rightGripC1 .. "\n"
        end
        
        reportText = reportText .. "\n"
    end
    
    reportText = reportText .. string.rep("=", 60) .. "\n"
    reportText = reportText .. "=== END DETAILED REPORT ===\n"
    reportText = reportText .. string.rep("=", 60) .. "\n"
    
    return reportText
end

-- Создание GUI (ИСПРАВЛЕННАЯ ВЕРСИЯ)
local function createGUI()
    print("🔧 Создание GUI - начало")
    
    -- Удаляем старый GUI
    local oldGui = playerGui:FindFirstChild("PetAnalyzerGUI")
    if oldGui then
        oldGui:Destroy()
        wait(0.1)
    end
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "PetAnalyzerGUI"
    screenGui.ResetOnSpawn = false
    screenGui.DisplayOrder = 10
    print("🔧 ScreenGui создан")
    
    -- Главное окно - УПРОЩЕННАЯ ВЕРСИЯ
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 500, 0, 350)
    mainFrame.Position = UDim2.new(0.5, -250, 0.5, -175) -- Центрируем
    mainFrame.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
    mainFrame.BorderSizePixel = 3
    mainFrame.BorderColor3 = Color3.new(0, 0.6, 1)
    mainFrame.Active = true
    mainFrame.Draggable = true
    print("🔧 MainFrame создан")
    
    -- Заголовок
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "TitleLabel"
    titleLabel.Size = UDim2.new(1, 0, 0, 40)
    titleLabel.Position = UDim2.new(0, 0, 0, 0)
    titleLabel.BackgroundColor3 = Color3.new(0, 0.6, 1)
    titleLabel.BorderSizePixel = 0
    titleLabel.Text = "Pet Creation Analyzer v2.0 - WORKING"
    titleLabel.TextColor3 = Color3.new(1, 1, 1)
    titleLabel.TextSize = 18
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.TextStrokeTransparency = 0
    titleLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
    titleLabel.Parent = mainFrame
    print("🔧 TitleLabel создан")
    
    -- Консоль
    local consoleFrame = Instance.new("ScrollingFrame")
    consoleFrame.Name = "ConsoleFrame"
    consoleFrame.Size = UDim2.new(1, -20, 1, -120)
    consoleFrame.Position = UDim2.new(0, 10, 0, 50)
    consoleFrame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
    consoleFrame.BorderSizePixel = 2
    consoleFrame.BorderColor3 = Color3.new(0.4, 0.4, 0.4)
    consoleFrame.ScrollBarThickness = 10
    consoleFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    consoleFrame.Parent = mainFrame
    print("🔧 ConsoleFrame создан")
    
    local consoleText = Instance.new("TextLabel")
    consoleText.Name = "ConsoleText"
    consoleText.Size = UDim2.new(1, -20, 1, 0)
    consoleText.Position = UDim2.new(0, 10, 0, 0)
    consoleText.BackgroundTransparency = 1
    consoleText.Text = "Pet Analyzer Console Ready...\nWaiting for pet events..."
    consoleText.TextColor3 = Color3.new(0, 1, 0)
    consoleText.TextSize = 14
    consoleText.Font = Enum.Font.Code
    consoleText.TextXAlignment = Enum.TextXAlignment.Left
    consoleText.TextYAlignment = Enum.TextYAlignment.Top
    consoleText.TextWrapped = true
    consoleText.Parent = consoleFrame
    print("🔧 ConsoleText создан")
    
    -- Кнопки
    local reportButton = Instance.new("TextButton")
    reportButton.Name = "ReportButton"
    reportButton.Size = UDim2.new(0, 140, 0, 35)
    reportButton.Position = UDim2.new(0, 10, 1, -45)
    reportButton.BackgroundColor3 = Color3.new(0, 0.7, 0)
    reportButton.BorderSizePixel = 2
    reportButton.BorderColor3 = Color3.new(0, 1, 0)
    reportButton.Text = "GENERATE REPORT"
    reportButton.TextColor3 = Color3.new(1, 1, 1)
    reportButton.TextSize = 14
    reportButton.Font = Enum.Font.SourceSansBold
    reportButton.TextStrokeTransparency = 0
    reportButton.TextStrokeColor3 = Color3.new(0, 0, 0)
    reportButton.Parent = mainFrame
    print("🔧 ReportButton создан")
    
    local clearButton = Instance.new("TextButton")
    clearButton.Name = "ClearButton"
    clearButton.Size = UDim2.new(0, 120, 0, 35)
    clearButton.Position = UDim2.new(0, 160, 1, -45)
    clearButton.BackgroundColor3 = Color3.new(0.8, 0.4, 0)
    clearButton.BorderSizePixel = 2
    clearButton.BorderColor3 = Color3.new(1, 0.6, 0)
    clearButton.Text = "CLEAR LOG"
    clearButton.TextColor3 = Color3.new(1, 1, 1)
    clearButton.TextSize = 14
    clearButton.Font = Enum.Font.SourceSansBold
    clearButton.TextStrokeTransparency = 0
    clearButton.TextStrokeColor3 = Color3.new(0, 0, 0)
    clearButton.Parent = mainFrame
    print("🔧 ClearButton создан")
    
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 100, 0, 35)
    closeButton.Position = UDim2.new(1, -110, 1, -45)
    closeButton.BackgroundColor3 = Color3.new(0.8, 0, 0)
    closeButton.BorderSizePixel = 2
    closeButton.BorderColor3 = Color3.new(1, 0, 0)
    closeButton.Text = "CLOSE"
    closeButton.TextColor3 = Color3.new(1, 1, 1)
    closeButton.TextSize = 14
    closeButton.Font = Enum.Font.SourceSansBold
    closeButton.TextStrokeTransparency = 0
    closeButton.TextStrokeColor3 = Color3.new(0, 0, 0)
    closeButton.Parent = mainFrame
    print("🔧 CloseButton создан")
    
    -- Добавляем в PlayerGui ТОЛЬКО ПОСЛЕ создания всех элементов
    screenGui.Parent = playerGui
    print("🔧 GUI добавлен в PlayerGui")
    
    -- События кнопок
    reportButton.MouseButton1Click:Connect(function()
        print("🖱️ Report button clicked!")
        reportButton.Text = "GENERATING..."
        reportButton.BackgroundColor3 = Color3.new(0.5, 0.5, 0)
        
        spawn(function()
            wait(0.5)
            local report = generateDetailedReport()
            print(report)
            logEvent("SYSTEM", "Detailed report generated")
            reportButton.Text = "GENERATE REPORT"
            reportButton.BackgroundColor3 = Color3.new(0, 0.7, 0)
        end)
    end)
    
    clearButton.MouseButton1Click:Connect(function()
        print("🖱️ Clear button clicked!")
        clearButton.Text = "CLEARING..."
        clearButton.BackgroundColor3 = Color3.new(0.4, 0.2, 0)
        
        spawn(function()
            petEvents = {}
            consoleOutput = {}
            consoleText.Text = "Pet Analyzer Console Ready...\nLog cleared!"
            logEvent("SYSTEM", "Analysis log cleared")
            wait(1)
            clearButton.Text = "CLEAR LOG"
            clearButton.BackgroundColor3 = Color3.new(0.8, 0.4, 0)
        end)
    end)
    
    closeButton.MouseButton1Click:Connect(function()
        print("🖱️ Close button clicked!")
        screenGui:Destroy()
        gui = nil
    end)
    
    gui = screenGui
    print("🔧 GUI создание завершено успешно!")
    return screenGui
end

-- Функция мониторинга RemoteEvent вызовов
local function monitorRemoteEvents()
    logEvent("SYSTEM", "Запуск мониторинга RemoteEvent вызовов")
    
    local function hookRemoteEvent(remote)
        if remoteConnections[remote] then return end
        
        local connection = remote.OnClientEvent:Connect(function(...)
            local args = {...}
            local remoteCall = {
                time = tick(),
                remoteName = remote.Name,
                remotePath = remote:GetFullName(),
                args = args,
                argsCount = #args
            }
            
            table.insert(recentRemoteCalls, remoteCall)
            
            -- Ограничиваем размер лога
            if #recentRemoteCalls > 50 then
                table.remove(recentRemoteCalls, 1)
            end
            
            logEvent("REMOTE_EVENT", remote.Name, {
                path = remote:GetFullName(),
                argsCount = #args,
                firstArg = args[1] and tostring(args[1]) or "nil"
            })
        end)
        
        remoteConnections[remote] = connection
    end
    
    local function hookRemoteFunction(remote)
        if remoteConnections[remote] then return end
        
        -- Хукаем InvokeServer если возможно
        local originalInvoke = remote.InvokeServer
        remote.InvokeServer = function(self, ...)
            local args = {...}
            local remoteCall = {
                time = tick(),
                remoteName = remote.Name,
                remotePath = remote:GetFullName(),
                args = args,
                argsCount = #args,
                type = "InvokeServer"
            }
            
            table.insert(recentRemoteCalls, remoteCall)
            
            if #recentRemoteCalls > 50 then
                table.remove(recentRemoteCalls, 1)
            end
            
            logEvent("REMOTE_FUNCTION", remote.Name, {
                path = remote:GetFullName(),
                argsCount = #args,
                firstArg = args[1] and tostring(args[1]) or "nil"
            })
            
            return originalInvoke(self, ...)
        end
        
        remoteConnections[remote] = true
    end
    
    -- Сканируем существующие RemoteEvent/Function
    for _, obj in pairs(game.ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") then
            hookRemoteEvent(obj)
        elseif obj:IsA("RemoteFunction") then
            hookRemoteFunction(obj)
        end
    end
    
    -- Отслеживаем новые RemoteEvent/Function
    game.ReplicatedStorage.DescendantAdded:Connect(function(obj)
        if obj:IsA("RemoteEvent") then
            hookRemoteEvent(obj)
        elseif obj:IsA("RemoteFunction") then
            hookRemoteFunction(obj)
        end
    end)
end

-- Функция получения недавних RemoteEvent вызовов
local function getRecentRemoteCalls(timeWindow)
    timeWindow = timeWindow or 5 -- последние 5 секунд
    local currentTime = tick()
    local recentCalls = {}
    
    for _, call in ipairs(recentRemoteCalls) do
        if currentTime - call.time <= timeWindow then
            table.insert(recentCalls, call)
        end
    end
    
    return recentCalls
end

-- Запуск системы
createGUI()
monitorWorkspacePets()
monitorRemoteEvents()

if character then
    monitorCharacter(character)
end

player.CharacterAdded:Connect(monitorCharacter)

logEvent("SYSTEM", "Pet Analyzer v2.0 started successfully")
logEvent("SYSTEM", "Monitoring: Backpack, Hands, Workspace UUID pets, RemoteEvents")
logEvent("SYSTEM", "Create a pet and take it in your hands to start analysis")
