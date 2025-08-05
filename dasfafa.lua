-- Pet Spawn & Movement Analyzer
-- Анализирует поведение питомца при спавне и движении
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer or Players:GetPlayers()[1]

-- Очистка предыдущего GUI
if CoreGui:FindFirstChild("PetAnalyzer_GUI") then 
    CoreGui.PetAnalyzer_GUI:Destroy() 
end

-- Хранилище данных
local analyzedPet = nil
local isAnalyzing = false
local positionHistory = {}
local movementDetected = false
local spawnTime = 0

-- GUI Setup
local gui = Instance.new("ScreenGui")
gui.Name = "PetAnalyzer_GUI"
gui.Parent = CoreGui
gui.ResetOnSpawn = false

local mainFrame = Instance.new("Frame", gui)
mainFrame.Size = UDim2.new(0, 300, 0, 200)
mainFrame.Position = UDim2.new(0.7, 0, 0.1, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
mainFrame.BorderColor3 = Color3.fromRGB(255, 100, 0)
mainFrame.BorderSizePixel = 2
mainFrame.Active = true
mainFrame.Draggable = true

local titleLabel = Instance.new("TextLabel", mainFrame)
titleLabel.Size = UDim2.new(1, 0, 0.2, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "🔬 Pet Spawn Analyzer"
titleLabel.TextColor3 = Color3.fromRGB(255, 150, 0)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextScaled = true

local startBtn = Instance.new("TextButton", mainFrame)
startBtn.Size = UDim2.new(1, -10, 0, 30)
startBtn.Position = UDim2.new(0, 5, 0.25, 0)
startBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 0)
startBtn.TextColor3 = Color3.new(1, 1, 1)
startBtn.Font = Enum.Font.GothamBold
startBtn.TextSize = 14
startBtn.Text = "🎯 Start Analysis"

local statusLabel = Instance.new("TextLabel", mainFrame)
statusLabel.Size = UDim2.new(1, -10, 0, 25)
statusLabel.Position = UDim2.new(0, 5, 0.45, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Status: Ready"
statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextSize = 12
statusLabel.TextXAlignment = Enum.TextXAlignment.Left

local logLabel = Instance.new("TextLabel", mainFrame)
logLabel.Size = UDim2.new(1, -10, 0.4, 0)
logLabel.Position = UDim2.new(0, 5, 0.6, 0)
logLabel.BackgroundTransparency = 1
logLabel.Text = "Logs will appear here..."
logLabel.TextColor3 = Color3.fromRGB(150, 255, 150)
logLabel.Font = Enum.Font.Code
logLabel.TextSize = 10
logLabel.TextXAlignment = Enum.TextXAlignment.Left
logLabel.TextYAlignment = Enum.TextYAlignment.Top
logLabel.TextWrapped = true

-- КОПИРУЕМ ЛОГИКУ ПОИСКА ПИТОМЦА ИЗ PetScaler_v3.221.lua
local function findAndAnalyzePet()
    print("🔍 Поиск питомца для анализа...")
    
    local foundPets = {}
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then 
        print("❌ Персонаж не найден!")
        return nil 
    end
    
    local playerPosition = character.HumanoidRootPart.Position
    
    -- Поиск в Workspace
    for _, obj in pairs(Workspace:GetChildren()) do
        if obj:IsA("Model") and obj ~= character then
            local distance = 0
            local meshes = {}
            
            -- Проверяем наличие MeshPart
            for _, child in pairs(obj:GetDescendants()) do
                if child:IsA("MeshPart") then
                    table.insert(meshes, child)
                    if child.Position then
                        distance = (child.Position - playerPosition).Magnitude
                    end
                end
            end
            
            -- Критерии для питомца
            if #meshes >= 3 and distance > 0 and distance < 50 then
                local hasHumanoid = obj:FindFirstChild("Humanoid")
                local hasRootPart = obj:FindFirstChild("RootPart") or obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Torso")
                
                if hasRootPart then
                    table.insert(foundPets, {
                        model = obj,
                        distance = distance,
                        meshes = meshes,
                        hasHumanoid = hasHumanoid ~= nil
                    })
                end
            end
        end
    end
    
    if #foundPets == 0 then
        print("❌ Питомцы не найдены!")
        return nil
    end
    
    -- Сортируем по расстоянию
    table.sort(foundPets, function(a, b) return a.distance < b.distance end)
    
    local targetPet = foundPets[1]
    print("🎯 Выбран питомец для анализа:", targetPet.model.Name)
    print("📊 Расстояние:", targetPet.distance)
    print("📊 MeshParts:", #targetPet.meshes)
    print("📊 Humanoid:", targetPet.hasHumanoid)
    
    return targetPet.model
end

-- Анализ позиции и состояния питомца
local function analyzePetState(pet, phase)
    if not pet or not pet.PrimaryPart then return end
    
    local rootPart = pet.PrimaryPart
    local position = rootPart.Position
    local cframe = rootPart.CFrame
    local upVector = cframe.UpVector
    local lookVector = cframe.LookVector
    
    local logText = string.format(
        "[%s] Pos: %.2f,%.2f,%.2f | Up: %.2f,%.2f,%.2f | Look: %.2f,%.2f,%.2f",
        phase,
        position.X, position.Y, position.Z,
        upVector.X, upVector.Y, upVector.Z,
        lookVector.X, lookVector.Y, lookVector.Z
    )
    
    print("📊", logText)
    
    -- Обновляем GUI
    local currentLog = logLabel.Text
    if currentLog == "Logs will appear here..." then
        logLabel.Text = logText
    else
        logLabel.Text = currentLog .. "\n" .. logText
    end
    
    -- Сохраняем в историю
    table.insert(positionHistory, {
        phase = phase,
        position = position,
        upVector = upVector,
        lookVector = lookVector,
        time = tick()
    })
    
    return {
        position = position,
        upVector = upVector,
        lookVector = lookVector
    }
end

-- Основная функция анализа
local function startAnalysis()
    if isAnalyzing then return end
    
    isAnalyzing = true
    statusLabel.Text = "Status: Searching for pet..."
    logLabel.Text = "Logs will appear here..."
    positionHistory = {}
    movementDetected = false
    
    -- Находим питомца
    analyzedPet = findAndAnalyzePet()
    if not analyzedPet then
        statusLabel.Text = "Status: No pet found!"
        isAnalyzing = false
        return
    end
    
    statusLabel.Text = "Status: Analyzing " .. analyzedPet.Name
    spawnTime = tick()
    
    -- Анализ при спавне
    analyzePetState(analyzedPet, "SPAWN")
    
    -- Мониторинг движения
    local lastPosition = analyzedPet.PrimaryPart.Position
    local connection
    
    connection = RunService.Heartbeat:Connect(function()
        if not analyzedPet or not analyzedPet.Parent or not analyzedPet.PrimaryPart then
            connection:Disconnect()
            statusLabel.Text = "Status: Pet disappeared"
            isAnalyzing = false
            return
        end
        
        local currentPosition = analyzedPet.PrimaryPart.Position
        local distanceMoved = (currentPosition - lastPosition).Magnitude
        
        -- Детектируем движение
        if distanceMoved > 0.1 and not movementDetected then
            movementDetected = true
            analyzePetState(analyzedPet, "FIRST_MOVE")
            print("🚶 Первое движение обнаружено!")
            
            -- Анализируем через небольшие интервалы после движения
            task.wait(0.5)
            analyzePetState(analyzedPet, "AFTER_MOVE_0.5s")
            
            task.wait(1)
            analyzePetState(analyzedPet, "AFTER_MOVE_1.5s")
            
            task.wait(2)
            analyzePetState(analyzedPet, "FINAL_STATE")
            
            statusLabel.Text = "Status: Analysis complete!"
            print("✅ Анализ завершен!")
            
            -- Выводим сводку
            print("\n📋 === СВОДКА АНАЛИЗА ===")
            for i, record in ipairs(positionHistory) do
                print(string.format("%d. %s - Y: %.2f, UpY: %.2f", 
                    i, record.phase, record.position.Y, record.upVector.Y))
            end
            
            connection:Disconnect()
            isAnalyzing = false
        end
        
        lastPosition = currentPosition
    end)
end

-- Кнопка запуска
startBtn.MouseButton1Click:Connect(function()
    startAnalysis()
end)

print("🔬 Pet Spawn Analyzer готов к работе!")
print("📋 Нажмите 'Start Analysis' чтобы начать анализ питомца")
