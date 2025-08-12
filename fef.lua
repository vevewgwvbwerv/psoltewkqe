-- 🥚 ULTIMATE EGG REPLICATION DIAGNOSTIC v3.0
-- Полный анализ для создания 1:1 копии яйца со всеми механиками

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

print("🔥 === ULTIMATE EGG REPLICATION DIAGNOSTIC v3.0 ===")
print("🎯 Цель: Собрать ВСЕ данные для 1:1 репликации яйца")

-- Структура для хранения ВСЕХ данных
local UltimateEggData = {
    eggModel = nil,
    structure = {},
    proximityPrompt = nil,
    scripts = {},
    remotes = {},
    sounds = {},
    realTimeData = {
        petSpawns = {},
        soundPlays = {},
        effects = {}
    },
    connections = {}
}

-- Функция поиска яйца
local function findTargetEgg()
    local playerChar = player.Character
    if not playerChar or not playerChar:FindFirstChild("HumanoidRootPart") then
        return nil
    end
    
    local playerPos = playerChar.HumanoidRootPart.Position
    
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and obj.Name:lower():find("egg") then
            local distance = (obj:GetModelCFrame().Position - playerPos).Magnitude
            if distance <= 100 then
                local hasPrompt = obj:FindFirstChildOfClass("ProximityPrompt", true)
                if hasPrompt then
                    return obj
                end
            end
        end
    end
    return nil
end

-- Анализ структуры яйца
local function analyzeStructure(eggModel)
    print("\n🔍 === АНАЛИЗ СТРУКТУРЫ ===")
    
    local structure = {
        name = eggModel.Name,
        parts = {},
        meshes = {},
        effects = {}
    }
    
    for _, obj in pairs(eggModel:GetDescendants()) do
        if obj:IsA("BasePart") then
            table.insert(structure.parts, {
                name = obj.Name,
                size = obj.Size,
                position = obj.Position,
                material = obj.Material.Name,
                color = obj.Color
            })
        elseif obj:IsA("SpecialMesh") or obj:IsA("MeshPart") then
            table.insert(structure.meshes, {
                name = obj.Name,
                meshId = obj:IsA("SpecialMesh") and obj.MeshId or obj.MeshId,
                textureId = obj:IsA("SpecialMesh") and obj.TextureId or obj.TextureId
            })
        end
    end
    
    UltimateEggData.structure = structure
    print("📦 Найдено частей:", #structure.parts)
    print("🎨 Найдено мешей:", #structure.meshes)
end

-- Анализ интерактивности
local function analyzeInteractivity(eggModel)
    print("\n🎮 === АНАЛИЗ ИНТЕРАКТИВНОСТИ ===")
    
    local proximityPrompt = eggModel:FindFirstChildOfClass("ProximityPrompt", true)
    if proximityPrompt then
        UltimateEggData.proximityPrompt = {
            actionText = proximityPrompt.ActionText,
            keyboardKeyCode = proximityPrompt.KeyboardKeyCode.Name,
            holdDuration = proximityPrompt.HoldDuration,
            maxActivationDistance = proximityPrompt.MaxActivationDistance
        }
        print("🎯 ProximityPrompt:", proximityPrompt.ActionText)
    end
end

-- Анализ скриптов
local function analyzeScripts(eggModel)
    print("\n📜 === АНАЛИЗ СКРИПТОВ ===")
    
    for _, obj in pairs(eggModel:GetDescendants()) do
        if obj:IsA("LocalScript") or obj:IsA("Script") then
            local scriptData = {
                name = obj.Name,
                type = obj.ClassName,
                enabled = obj.Enabled
            }
            
            local success, source = pcall(function()
                return obj.Source
            end)
            
            if success and source ~= "" then
                scriptData.hasSource = true
                scriptData.hasRemotes = source:find("RemoteEvent") ~= nil
                scriptData.hasAnimations = source:find("TweenService") ~= nil
                print("📝", obj.ClassName .. ":", obj.Name, "- Код доступен")
            else
                print("🔒", obj.ClassName .. ":", obj.Name, "- Код защищен")
            end
            
            table.insert(UltimateEggData.scripts, scriptData)
        end
    end
end

-- Поиск RemoteEvents
local function analyzeRemotes()
    print("\n🌐 === АНАЛИЗ СЕТЕВОЙ ЛОГИКИ ===")
    
    for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            local name = obj.Name:lower()
            if name:find("egg") or name:find("pet") or name:find("hatch") then
                table.insert(UltimateEggData.remotes, {
                    name = obj.Name,
                    type = obj.ClassName,
                    path = obj:GetFullName(),
                    isEggRelated = true
                })
                print("🥚", obj.ClassName .. ":", obj.Name, "- Связан с яйцами")
            end
        end
    end
end

-- Анализ звуков
local function analyzeSounds(eggModel)
    print("\n🔊 === АНАЛИЗ ЗВУКОВ ===")
    
    for _, obj in pairs(eggModel:GetDescendants()) do
        if obj:IsA("Sound") then
            table.insert(UltimateEggData.sounds, {
                name = obj.Name,
                soundId = obj.SoundId,
                volume = obj.Volume,
                pitch = obj.Pitch
            })
            print("🎵 Звук:", obj.Name, "ID:", obj.SoundId)
        end
    end
end

-- Мониторинг в реальном времени
local function startMonitoring()
    print("\n⚡ === МОНИТОРИНГ В РЕАЛЬНОМ ВРЕМЕНИ ===")
    
    local visualsFolder = Workspace:FindFirstChild("Visuals")
    if visualsFolder then
        local connection = visualsFolder.ChildAdded:Connect(function(child)
            if child:IsA("Model") then
                local petData = {
                    name = child.Name,
                    spawnTime = tick(),
                    position = child:GetModelCFrame().Position
                }
                
                table.insert(UltimateEggData.realTimeData.petSpawns, petData)
                print("🐾 ПИТОМЕЦ:", child.Name, "в", os.date("%H:%M:%S"))
            end
        end)
        
        table.insert(UltimateEggData.connections, connection)
    end
end

-- Основная функция диагностики
local function runUltimateDiagnostic(eggModel, statusLabel)
    print("\n🔥 === ЗАПУСК УЛЬТИМАТИВНОЙ ДИАГНОСТИКИ ===")
    
    UltimateEggData.eggModel = eggModel
    
    statusLabel.Text = "🔍 Анализирую структуру..."
    analyzeStructure(eggModel)
    
    statusLabel.Text = "🎮 Анализирую интерактивность..."
    analyzeInteractivity(eggModel)
    
    statusLabel.Text = "📜 Анализирую скрипты..."
    analyzeScripts(eggModel)
    
    statusLabel.Text = "🌐 Ищу RemoteEvents..."
    analyzeRemotes()
    
    statusLabel.Text = "🔊 Анализирую звуки..."
    analyzeSounds(eggModel)
    
    statusLabel.Text = "⚡ Запускаю мониторинг..."
    startMonitoring()
    
    statusLabel.Text = "✅ Готов! Откройте яйцо!"
    statusLabel.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    
    -- Финальный отчет через 2 минуты
    spawn(function()
        wait(120)
        
        for _, connection in pairs(UltimateEggData.connections) do
            pcall(function() connection:Disconnect() end)
        end
        
        print("\n📊 === ФИНАЛЬНЫЙ ОТЧЕТ ===")
        print("🥚 Яйцо:", UltimateEggData.eggModel.Name)
        print("📦 Частей:", #UltimateEggData.structure.parts)
        print("📜 Скриптов:", #UltimateEggData.scripts)
        print("🌐 RemoteEvents:", #UltimateEggData.remotes)
        print("🔊 Звуков:", #UltimateEggData.sounds)
        print("🐾 Питомцев заспавнилось:", #UltimateEggData.realTimeData.petSpawns)
        
        statusLabel.Text = "✅ Диагностика завершена!"
    end)
end

-- GUI
local function createGUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "UltimateEggDiagnosticGUI"
    screenGui.Parent = player:WaitForChild("PlayerGui")
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 400, 0, 250)
    mainFrame.Position = UDim2.new(0, 10, 0, 10)
    mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    mainFrame.BorderColor3 = Color3.fromRGB(255, 100, 0)
    mainFrame.BorderSizePixel = 2
    mainFrame.Parent = screenGui
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, 0, 0, 40)
    titleLabel.BackgroundColor3 = Color3.fromRGB(255, 100, 0)
    titleLabel.Text = "🔥 ULTIMATE EGG DIAGNOSTIC v3.0"
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextScaled = true
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.Parent = mainFrame
    
    local startButton = Instance.new("TextButton")
    startButton.Size = UDim2.new(0.9, 0, 0, 50)
    startButton.Position = UDim2.new(0.05, 0, 0, 50)
    startButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    startButton.Text = "🚀 ЗАПУСТИТЬ УЛЬТИМАТИВНУЮ ДИАГНОСТИКУ"
    startButton.TextColor3 = Color3.fromRGB(0, 0, 0)
    startButton.TextScaled = true
    startButton.Font = Enum.Font.SourceSansBold
    startButton.Parent = mainFrame
    
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Size = UDim2.new(0.9, 0, 0, 80)
    statusLabel.Position = UDim2.new(0.05, 0, 0, 110)
    statusLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    statusLabel.Text = "🎯 Подойдите к яйцу и нажмите кнопку\n⚡ Будет собрана ВСЯ информация для 1:1 репликации!"
    statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    statusLabel.TextScaled = true
    statusLabel.TextWrapped = true
    statusLabel.Parent = mainFrame
    
    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.new(0.9, 0, 0, 30)
    closeButton.Position = UDim2.new(0.05, 0, 0, 200)
    closeButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    closeButton.Text = "❌ ЗАКРЫТЬ"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.TextScaled = true
    closeButton.Parent = mainFrame
    
    startButton.MouseButton1Click:Connect(function()
        local eggModel = findTargetEgg()
        if eggModel then
            runUltimateDiagnostic(eggModel, statusLabel)
        else
            statusLabel.Text = "❌ Яйцо не найдено! Подойдите ближе"
            statusLabel.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        end
    end)
    
    closeButton.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)
end

createGUI()
print("🎮 ULTIMATE GUI создан! Готов к полному анализу!")
