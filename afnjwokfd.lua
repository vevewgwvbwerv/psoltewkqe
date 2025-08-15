-- 🔍 PET ANALYZER - Анализатор питомцев для Grow a Garden
-- Анализирует UUID питомцев рядом с игроком и показывает детальную информацию

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

print("🔍 === PET ANALYZER - Анализатор питомцев ===")

-- Конфигурация
local CONFIG = {
    SEARCH_RADIUS = 100,
    MAX_ANALYZED_PETS = 10
}

-- Хранилище проанализированных питомцев
local analyzedPets = {}

-- === ФУНКЦИИ ПОИСКА UUID ПИТОМЦЕВ (ИЗ FutureBestVisual.lua) ===

-- Функция проверки визуальных элементов питомца
local function hasPetVisuals(model)
    local visualCount = 0
    
    for _, obj in pairs(model:GetDescendants()) do
        if obj:IsA("MeshPart") or obj:IsA("SpecialMesh") then
            visualCount = visualCount + 1
        elseif obj:IsA("Part") then
            local hasDecal = obj:FindFirstChildOfClass("Decal")
            local hasTexture = obj:FindFirstChildOfClass("Texture")
            if hasDecal or hasTexture or obj.Material ~= Enum.Material.Plastic then
                visualCount = visualCount + 1
            end
        elseif obj:IsA("UnionOperation") then
            visualCount = visualCount + 1
        end
    end
    
    if visualCount == 0 then
        local partCount = 0
        for _, obj in pairs(model:GetDescendants()) do
            if obj:IsA("BasePart") then
                partCount = partCount + 1
            end
        end
        if partCount >= 2 then
            visualCount = partCount
        end
    end
    
    return visualCount > 0
end

-- Функция поиска ближайшего UUID питомца (СКОПИРОВАНО ИЗ FutureBestVisual.lua)
local function findClosestUUIDPet()
    print("🔍 Поиск UUID моделей питомцев...")
    
    local playerChar = player.Character
    if not playerChar then
        return nil
    end

    local hrp = playerChar:FindFirstChild("HumanoidRootPart")
    if not hrp then
        return nil
    end

    local playerPos = hrp.Position
    local foundPets = {}
    
    -- ТОЧНАЯ КОПИЯ ЛОГИКИ ИЗ FutureBestVisual.lua
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and obj.Name:find("%{") and obj.Name:find("%}") then
            local success, modelCFrame = pcall(function() return obj:GetModelCFrame() end)
            if success then
                local distance = (modelCFrame.Position - playerPos).Magnitude
                if distance <= CONFIG.SEARCH_RADIUS then
                    if hasPetVisuals(obj) then
                        table.insert(foundPets, {
                            model = obj,
                            distance = distance
                        })
                    end
                end
            end
        end
    end
    
    if #foundPets == 0 then
        return nil
    end
    
    -- Сортируем по расстоянию и берем ближайшего
    table.sort(foundPets, function(a, b) return a.distance < b.distance end)
    local closestPet = foundPets[1]
    
    print("🎯 Найден ближайший UUID питомец:", closestPet.model.Name)
    
    return closestPet.model
end

-- === ФУНКЦИИ АНАЛИЗА ПИТОМЦА ===

-- Функция подробного анализа модели питомца
local function analyzePetModel(model)
    print("🔬 Анализирую модель:", model.Name)
    
    local analysis = {
        uuid = model.Name,
        meshCount = 0,
        motor6dCount = 0,
        humanoidCount = 0,
        cframeCount = 0,
        partCount = 0,
        attachmentCount = 0,
        scriptCount = 0,
        soundCount = 0,
        
        -- Детальная информация
        meshes = {},
        motor6ds = {},
        humanoids = {},
        parts = {},
        attachments = {},
        scripts = {},
        sounds = {},
        
        -- Дополнительная информация
        primaryPart = model.PrimaryPart and model.PrimaryPart.Name or "None",
        modelSize = nil,
        modelPosition = nil
    }
    
    -- Получаем позицию модели
    local success, modelCFrame = pcall(function() return model:GetModelCFrame() end)
    if success then
        analysis.modelPosition = {
            X = math.floor(modelCFrame.Position.X * 100) / 100,
            Y = math.floor(modelCFrame.Position.Y * 100) / 100,
            Z = math.floor(modelCFrame.Position.Z * 100) / 100
        }
    end
    
    -- Получаем размер модели
    local success2, modelSize = pcall(function() return model:GetModelSize() end)
    if success2 then
        analysis.modelSize = {
            X = math.floor(modelSize.X * 100) / 100,
            Y = math.floor(modelSize.Y * 100) / 100,
            Z = math.floor(modelSize.Z * 100) / 100
        }
    end
    
    -- Анализируем все объекты в модели
    for _, obj in pairs(model:GetDescendants()) do
        -- MeshPart и SpecialMesh
        if obj:IsA("MeshPart") then
            analysis.meshCount = analysis.meshCount + 1
            table.insert(analysis.meshes, {
                name = obj.Name,
                type = "MeshPart",
                meshId = obj.MeshId or "",
                size = obj.Size,
                material = obj.Material.Name
            })
        elseif obj:IsA("SpecialMesh") then
            analysis.meshCount = analysis.meshCount + 1
            table.insert(analysis.meshes, {
                name = obj.Name,
                type = "SpecialMesh",
                meshId = obj.MeshId or "",
                textureId = obj.TextureId or "",
                meshType = obj.MeshType.Name
            })
        end
        
        -- Motor6D
        if obj:IsA("Motor6D") then
            analysis.motor6dCount = analysis.motor6dCount + 1
            table.insert(analysis.motor6ds, {
                name = obj.Name,
                part0 = obj.Part0 and obj.Part0.Name or "None",
                part1 = obj.Part1 and obj.Part1.Name or "None"
            })
        end
        
        -- Humanoid
        if obj:IsA("Humanoid") then
            analysis.humanoidCount = analysis.humanoidCount + 1
            table.insert(analysis.humanoids, {
                name = obj.Name,
                health = obj.Health,
                walkSpeed = obj.WalkSpeed,
                rigType = obj.RigType.Name
            })
        end
        
        -- BasePart
        if obj:IsA("BasePart") then
            analysis.partCount = analysis.partCount + 1
            table.insert(analysis.parts, {
                name = obj.Name,
                className = obj.ClassName,
                size = obj.Size,
                position = obj.Position,
                material = obj.Material.Name
            })
        end
        
        -- Attachment
        if obj:IsA("Attachment") then
            analysis.attachmentCount = analysis.attachmentCount + 1
            table.insert(analysis.attachments, {
                name = obj.Name,
                parent = obj.Parent and obj.Parent.Name or "None"
            })
        end
        
        -- Script
        if obj:IsA("Script") or obj:IsA("LocalScript") then
            analysis.scriptCount = analysis.scriptCount + 1
            table.insert(analysis.scripts, {
                name = obj.Name,
                className = obj.ClassName
            })
        end
        
        -- Sound
        if obj:IsA("Sound") then
            analysis.soundCount = analysis.soundCount + 1
            table.insert(analysis.sounds, {
                name = obj.Name,
                soundId = obj.SoundId or ""
            })
        end
    end
    
    analysis.cframeCount = analysis.partCount
    
    return analysis
end

-- Функция генерации детального текста
local function generateDetailText(analysis)
    local text = string.format([[%s = {
    ["PrimaryPart"] = "%s",
    ["ModelSize"] = %s,
    ["ModelPosition"] = %s,
    ["TotalParts"] = %d,
    ["TotalMeshes"] = %d,
    ["TotalMotor6D"] = %d,
    ["TotalHumanoids"] = %d,
    ["TotalAttachments"] = %d,
    ["TotalScripts"] = %d,
    ["TotalSounds"] = %d,
    
    ["Meshes"] = {]], 
        analysis.uuid,
        analysis.primaryPart,
        analysis.modelSize and string.format("Vector3.new(%.2f, %.2f, %.2f)", analysis.modelSize.X, analysis.modelSize.Y, analysis.modelSize.Z) or "nil",
        analysis.modelPosition and string.format("Vector3.new(%.2f, %.2f, %.2f)", analysis.modelPosition.X, analysis.modelPosition.Y, analysis.modelPosition.Z) or "nil",
        analysis.partCount,
        analysis.meshCount,
        analysis.motor6dCount,
        analysis.humanoidCount,
        analysis.attachmentCount,
        analysis.scriptCount,
        analysis.soundCount
    )
    
    -- Добавляем информацию о мешах
    for i, mesh in ipairs(analysis.meshes) do
        text = text .. string.format('\n        [%d] = {name = "%s", type = "%s", meshId = "%s"},', i, mesh.name, mesh.type, mesh.meshId)
    end
    
    text = text .. "\n    },\n    \n    [\"Motor6D\"] = {"
    
    -- Добавляем информацию о Motor6D
    for i, motor in ipairs(analysis.motor6ds) do
        text = text .. string.format('\n        [%d] = {name = "%s", part0 = "%s", part1 = "%s"},', i, motor.name, motor.part0, motor.part1)
    end
    
    text = text .. "\n    },\n    \n    [\"Parts\"] = {"
    
    -- Добавляем информацию о частях
    for i, part in ipairs(analysis.parts) do
        if i <= 10 then -- Ограничиваем для читаемости
            text = text .. string.format('\n        [%d] = {name = "%s", class = "%s", material = "%s"},', i, part.name, part.className, part.material)
        end
    end
    
    if #analysis.parts > 10 then
        text = text .. string.format("\n        -- ... и еще %d частей", #analysis.parts - 10)
    end
    
    text = text .. "\n    }\n}"
    
    return text
end

-- === GUI СИСТЕМА ===

local mainGui = nil
local petListFrame = nil
local detailNotebook = nil

-- Функция создания карточки питомца
local function createPetCard(analysis)
    if not petListFrame then
        print("❌ petListFrame не инициализирован!")
        return
    end
    
    local cardFrame = Instance.new("Frame")
    cardFrame.Name = "PetCard_" .. #analyzedPets
    cardFrame.Size = UDim2.new(1, -10, 0, 80)
    cardFrame.BackgroundColor3 = Color3.fromRGB(65, 65, 65)
    cardFrame.BorderSizePixel = 1
    cardFrame.BorderColor3 = Color3.fromRGB(85, 85, 85)
    cardFrame.Parent = petListFrame
    
    local uuidTextBox = Instance.new("TextBox")
    uuidTextBox.Name = "UUIDTextBox"
    uuidTextBox.Size = UDim2.new(1, -10, 0, 25)
    uuidTextBox.Position = UDim2.new(0, 5, 0, 5)
    uuidTextBox.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    uuidTextBox.BorderSizePixel = 1
    uuidTextBox.BorderColor3 = Color3.fromRGB(100, 100, 100)
    uuidTextBox.Text = analysis.uuid
    uuidTextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    uuidTextBox.TextSize = 12
    uuidTextBox.Font = Enum.Font.SourceSans
    uuidTextBox.ClearTextOnFocus = false
    uuidTextBox.Parent = cardFrame
    
    local infoLabel = Instance.new("TextLabel")
    infoLabel.Name = "InfoLabel"
    infoLabel.Size = UDim2.new(1, -10, 0, 20)
    infoLabel.Position = UDim2.new(0, 5, 0, 35)
    infoLabel.BackgroundTransparency = 1
    infoLabel.Text = string.format("%d meshid, %d humanoid, %d motor6d, %d parts", 
        analysis.meshCount, analysis.humanoidCount, analysis.motor6dCount, analysis.partCount)
    infoLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    infoLabel.TextSize = 11
    infoLabel.Font = Enum.Font.SourceSans
    infoLabel.TextXAlignment = Enum.TextXAlignment.Left
    infoLabel.Parent = cardFrame
    
    local detailButton = Instance.new("TextButton")
    detailButton.Name = "DetailButton"
    detailButton.Size = UDim2.new(1, -10, 0, 15)
    detailButton.Position = UDim2.new(0, 5, 0, 60)
    detailButton.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
    detailButton.BorderSizePixel = 0
    detailButton.Text = "📋 Открыть детальный блокнот"
    detailButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    detailButton.TextSize = 10
    detailButton.Font = Enum.Font.SourceSans
    detailButton.Parent = cardFrame
    
    detailButton.MouseButton1Click:Connect(function()
        openDetailNotebook(analysis)
    end)
    
    petListFrame.CanvasSize = UDim2.new(0, 0, 0, #analyzedPets * 85)
end

-- Функция создания детального блокнота
local function openDetailNotebook(analysis)
    if detailNotebook then
        detailNotebook:Destroy()
    end
    
    detailNotebook = Instance.new("Frame")
    detailNotebook.Name = "DetailNotebook"
    detailNotebook.Size = UDim2.new(0, 600, 0, 700)
    detailNotebook.Position = UDim2.new(0, 500, 0, 50)
    detailNotebook.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    detailNotebook.BorderSizePixel = 2
    detailNotebook.BorderColor3 = Color3.fromRGB(70, 70, 70)
    detailNotebook.Parent = mainGui
    
    local notebookTitle = Instance.new("TextLabel")
    notebookTitle.Size = UDim2.new(1, 0, 0, 40)
    notebookTitle.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    notebookTitle.BorderSizePixel = 0
    notebookTitle.Text = "📋 ДЕТАЛЬНЫЙ АНАЛИЗ: " .. analysis.uuid
    notebookTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    notebookTitle.TextSize = 14
    notebookTitle.Font = Enum.Font.SourceSansBold
    notebookTitle.Parent = detailNotebook
    
    local contentFrame = Instance.new("ScrollingFrame")
    contentFrame.Size = UDim2.new(1, -10, 1, -90)
    contentFrame.Position = UDim2.new(0, 5, 0, 45)
    contentFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    contentFrame.BorderSizePixel = 1
    contentFrame.BorderColor3 = Color3.fromRGB(70, 70, 70)
    contentFrame.ScrollBarThickness = 8
    contentFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
    contentFrame.Parent = detailNotebook
    
    local detailText = generateDetailText(analysis)
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, -10, 0, 0)
    textLabel.Position = UDim2.new(0, 5, 0, 5)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = detailText
    textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    textLabel.TextSize = 11
    textLabel.Font = Enum.Font.SourceSans
    textLabel.TextXAlignment = Enum.TextXAlignment.Left
    textLabel.TextYAlignment = Enum.TextYAlignment.Top
    textLabel.TextWrapped = true
    textLabel.Parent = contentFrame
    
    local textBounds = textLabel.TextBounds
    textLabel.Size = UDim2.new(1, -10, 0, textBounds.Y + 20)
    contentFrame.CanvasSize = UDim2.new(0, 0, 0, textBounds.Y + 50)
    
    local buttonFrame = Instance.new("Frame")
    buttonFrame.Size = UDim2.new(1, 0, 0, 40)
    buttonFrame.Position = UDim2.new(0, 0, 1, -40)
    buttonFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    buttonFrame.BorderSizePixel = 0
    buttonFrame.Parent = detailNotebook
    
    local copyButton = Instance.new("TextButton")
    copyButton.Size = UDim2.new(0, 150, 0, 30)
    copyButton.Position = UDim2.new(0, 10, 0, 5)
    copyButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
    copyButton.BorderSizePixel = 0
    copyButton.Text = "📋 СКОПИРОВАТЬ"
    copyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    copyButton.TextSize = 12
    copyButton.Font = Enum.Font.SourceSansBold
    copyButton.Parent = buttonFrame
    
    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.new(0, 150, 0, 30)
    closeButton.Position = UDim2.new(1, -160, 0, 5)
    closeButton.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
    closeButton.BorderSizePixel = 0
    closeButton.Text = "❌ ЗАКРЫТЬ"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.TextSize = 12
    closeButton.Font = Enum.Font.SourceSansBold
    closeButton.Parent = buttonFrame
    
    copyButton.MouseButton1Click:Connect(function()
        copyButton.Text = "✅ СКОПИРОВАНО"
        copyButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
        print("📋 Информация о питомце:")
        print(detailText)
        
        wait(1)
        copyButton.Text = "📋 СКОПИРОВАТЬ"
        copyButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
    end)
    
    closeButton.MouseButton1Click:Connect(function()
        detailNotebook:Destroy()
        detailNotebook = nil
    end)
end

-- Функция создания основного GUI
local function createMainGUI()
    local playerGui = player:WaitForChild("PlayerGui")
    
    local oldGui = playerGui:FindFirstChild("PetAnalyzerGUI")
    if oldGui then
        oldGui:Destroy()
        wait(0.1)
    end
    
    mainGui = Instance.new("ScreenGui")
    mainGui.Name = "PetAnalyzerGUI"
    mainGui.Parent = playerGui
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 400, 0, 600)
    mainFrame.Position = UDim2.new(0, 50, 0, 50)
    mainFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    mainFrame.BorderSizePixel = 2
    mainFrame.BorderColor3 = Color3.fromRGB(70, 70, 70)
    mainFrame.Parent = mainGui
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "TitleLabel"
    titleLabel.Size = UDim2.new(1, 0, 0, 40)
    titleLabel.Position = UDim2.new(0, 0, 0, 0)
    titleLabel.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    titleLabel.BorderSizePixel = 0
    titleLabel.Text = "🔍 PET ANALYZER"
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextSize = 18
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.Parent = mainFrame
    
    local analyzeButton = Instance.new("TextButton")
    analyzeButton.Name = "AnalyzeButton"
    analyzeButton.Size = UDim2.new(0, 350, 0, 40)
    analyzeButton.Position = UDim2.new(0, 25, 0, 50)
    analyzeButton.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    analyzeButton.BorderSizePixel = 0
    analyzeButton.Text = "🔬 АНАЛИЗИРОВАТЬ БЛИЖАЙШЕГО ПИТОМЦА"
    analyzeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    analyzeButton.TextSize = 14
    analyzeButton.Font = Enum.Font.SourceSansBold
    analyzeButton.Parent = mainFrame
    
    petListFrame = Instance.new("ScrollingFrame")
    petListFrame.Name = "PetListFrame"
    petListFrame.Size = UDim2.new(1, -20, 1, -110)
    petListFrame.Position = UDim2.new(0, 10, 0, 100)
    petListFrame.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
    petListFrame.BorderSizePixel = 1
    petListFrame.BorderColor3 = Color3.fromRGB(70, 70, 70)
    petListFrame.ScrollBarThickness = 8
    petListFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
    petListFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    petListFrame.Parent = mainFrame
    
    local listLayout = Instance.new("UIListLayout")
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Padding = UDim.new(0, 5)
    listLayout.Parent = petListFrame
    
    -- Обработчик кнопки анализа
    analyzeButton.MouseButton1Click:Connect(function()
        analyzeButton.Text = "⏳ АНАЛИЗИРУЮ..."
        analyzeButton.BackgroundColor3 = Color3.fromRGB(255, 165, 0)
        
        spawn(function()
            local petModel = findClosestUUIDPet()
            if petModel then
                local analysis = analyzePetModel(petModel)
                
                local alreadyExists = false
                for _, existingPet in pairs(analyzedPets) do
                    if existingPet.uuid == analysis.uuid then
                        alreadyExists = true
                        break
                    end
                end
                
                if not alreadyExists and #analyzedPets < CONFIG.MAX_ANALYZED_PETS then
                    table.insert(analyzedPets, analysis)
                    createPetCard(analysis)
                end
                
                analyzeButton.Text = "✅ АНАЛИЗ ЗАВЕРШЕН"
                analyzeButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
            else
                analyzeButton.Text = "❌ ПИТОМЕЦ НЕ НАЙДЕН"
                analyzeButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
            end
            
            wait(2)
            analyzeButton.Text = "🔬 АНАЛИЗИРОВАТЬ БЛИЖАЙШЕГО ПИТОМЦА"
            analyzeButton.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
        end)
    end)
end


-- === ЗАПУСК ===

createMainGUI()
print("✅ Pet Analyzer запущен! Используйте GUI для анализа питомцев.")
