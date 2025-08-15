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
                soundId = obj.SoundId or "",
                volume = obj.Volume
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
        analysis.primaryPart or "None",
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
    
    -- Добавляем информацию о частях (показываем все)
    for i, part in ipairs(analysis.parts) do
        text = text .. string.format('\n        [%d] = {name = "%s", class = "%s", size = Vector3.new(%.2f, %.2f, %.2f), material = "%s"},', i, part.name, part.className, part.size.X, part.size.Y, part.size.Z, part.material)
    end
    
    text = text .. "\n    }"
    
    -- Добавляем информацию о Motor6D только если есть данные
    if #analysis.motor6ds > 0 then
        text = text .. ",\n    \n    [\"Motor6D\"] = {"
        for i, motor in ipairs(analysis.motor6ds) do
            text = text .. string.format('\n        [%d] = {name = "%s", part0 = "%s", part1 = "%s"},', i, motor.name, motor.part0, motor.part1)
        end
        text = text .. "\n    }"
    end
    
    -- Добавляем информацию о Humanoids только если есть данные
    if #analysis.humanoids > 0 then
        text = text .. ",\n    \n    [\"Humanoids\"] = {"
        for i, humanoid in ipairs(analysis.humanoids) do
            text = text .. string.format('\n        [%d] = {name = "%s", health = %.1f, walkSpeed = %.1f, rigType = "%s"},', i, humanoid.name, humanoid.health, humanoid.walkSpeed, humanoid.rigType)
        end
        text = text .. "\n    }"
    end
    
    -- Добавляем информацию об Attachments только если есть данные
    if #analysis.attachments > 0 then
        text = text .. ",\n    \n    [\"Attachments\"] = {"
        for i, attachment in ipairs(analysis.attachments) do
            text = text .. string.format('\n        [%d] = {name = "%s", parent = "%s"},', i, attachment.name, attachment.parent)
        end
        text = text .. "\n    }"
    end
    
    -- Добавляем информацию о Scripts только если есть данные
    if #analysis.scripts > 0 then
        text = text .. ",\n    \n    [\"Scripts\"] = {"
        for i, script in ipairs(analysis.scripts) do
            text = text .. string.format('\n        [%d] = {name = "%s", type = "%s"},', i, script.name, script.className)
        end
        text = text .. "\n    }"
    end
    
    text = text .. "\n}"
    
    return text
end

-- === GUI СИСТЕМА ===

local mainGui = nil
local petListFrame = nil
local detailNotebook = nil
local analyzedPets = {}

-- Функция создания закругленных углов
local function addRoundedCorners(frame, cornerRadius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, cornerRadius or 8)
    corner.Parent = frame
end

-- Функция добавления возможности перетаскивания
local function makeDraggable(frame)
    local UserInputService = game:GetService("UserInputService")
    local dragging = false
    local dragStart = nil
    local startPos = nil
    
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)
    
    frame.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    frame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

-- Функция создания детального блокнота
local function openDetailNotebook(analysis)
    if detailNotebook then
        detailNotebook:Destroy()
    end
    
    detailNotebook = Instance.new("Frame")
    detailNotebook.Name = "DetailNotebook"
    detailNotebook.Size = UDim2.new(0, 600, 0, 500)  -- Компактный размер
    detailNotebook.Position = UDim2.new(0, 400, 0, 100)  -- Справа от основного окна
    detailNotebook.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    detailNotebook.BorderSizePixel = 0
    detailNotebook.ZIndex = 100
    detailNotebook.Parent = mainGui
    
    addRoundedCorners(detailNotebook, 12)
    makeDraggable(detailNotebook)
    
    local notebookTitle = Instance.new("TextLabel")
    notebookTitle.Size = UDim2.new(1, 0, 0, 50)
    notebookTitle.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    notebookTitle.BorderSizePixel = 0
    notebookTitle.Text = "📋 ДЕТАЛЬНЫЙ АНАЛИЗ: " .. analysis.uuid
    notebookTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    notebookTitle.TextSize = 16
    notebookTitle.Font = Enum.Font.SourceSansBold
    notebookTitle.TextScaled = true
    notebookTitle.ZIndex = 101
    notebookTitle.Parent = detailNotebook
    
    addRoundedCorners(notebookTitle, 12)
    
    local contentFrame = Instance.new("ScrollingFrame")
    contentFrame.Size = UDim2.new(1, -20, 1, -110)
    contentFrame.Position = UDim2.new(0, 10, 0, 55)
    contentFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    contentFrame.BorderSizePixel = 0
    contentFrame.ScrollBarThickness = 12
    contentFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
    contentFrame.ZIndex = 101
    contentFrame.Parent = detailNotebook
    
    addRoundedCorners(contentFrame, 8)
    
    local detailText = generateDetailText(analysis)
    
    -- Отладочная информация
    print("🔍 Генерирую текст для:", analysis.uuid)
    print("📊 Количество мешей:", #analysis.meshes)
    print("📊 Количество Motor6D:", #analysis.motor6ds)
    print("📊 Количество частей:", #analysis.parts)
    print("📋 Длина текста:", string.len(detailText))
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, -20, 0, 2000)  -- Большой начальный размер
    textLabel.Position = UDim2.new(0, 10, 0, 10)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = detailText
    textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    textLabel.TextSize = 11
    textLabel.Font = Enum.Font.SourceSans
    textLabel.TextXAlignment = Enum.TextXAlignment.Left
    textLabel.TextYAlignment = Enum.TextYAlignment.Top
    textLabel.TextWrapped = true
    textLabel.TextScaled = false
    textLabel.ZIndex = 102
    textLabel.Parent = contentFrame
    
    -- Ждем несколько кадров для правильного расчета
    spawn(function()
        wait(0.1)
        local textBounds = textLabel.TextBounds
        local finalHeight = math.max(textBounds.Y + 40, 200)
        textLabel.Size = UDim2.new(1, -20, 0, finalHeight)
        contentFrame.CanvasSize = UDim2.new(0, 0, 0, finalHeight + 20)
        print("📏 Размер текста:", textBounds.Y, "Итоговая высота:", finalHeight)
    end)
    
    local buttonFrame = Instance.new("Frame")
    buttonFrame.Size = UDim2.new(1, 0, 0, 50)
    buttonFrame.Position = UDim2.new(0, 0, 1, -50)
    buttonFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    buttonFrame.BorderSizePixel = 0
    buttonFrame.ZIndex = 101
    buttonFrame.Parent = detailNotebook
    
    addRoundedCorners(buttonFrame, 12)
    
    local copyButton = Instance.new("TextButton")
    copyButton.Size = UDim2.new(0.45, -5, 0, 35)
    copyButton.Position = UDim2.new(0, 10, 0, 7.5)
    copyButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
    copyButton.BorderSizePixel = 0
    copyButton.Text = "📋 СКОПИРОВАТЬ"
    copyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    copyButton.TextSize = 14
    copyButton.Font = Enum.Font.SourceSansBold
    copyButton.TextScaled = true
    copyButton.ZIndex = 102
    copyButton.Parent = buttonFrame
    
    addRoundedCorners(copyButton, 8)
    
    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.new(0.45, -5, 0, 35)
    closeButton.Position = UDim2.new(0.55, 0, 0, 7.5)
    closeButton.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
    closeButton.BorderSizePixel = 0
    closeButton.Text = "❌ ЗАКРЫТЬ"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.TextSize = 14
    closeButton.Font = Enum.Font.SourceSansBold
    closeButton.TextScaled = true
    closeButton.ZIndex = 102
    closeButton.Parent = buttonFrame
    
    addRoundedCorners(closeButton, 8)
    
    copyButton.MouseButton1Click:Connect(function()
        copyButton.Text = "✅ СКОПИРОВАНО"
        copyButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
        
        -- Копирование в буфер обмена
        pcall(function()
            if setclipboard then
                setclipboard(detailText)
            else
                -- Fallback для некоторых экзекуторов
                game:GetService("GuiService"):SetClipboard(detailText)
            end
        end)
        
        -- Дублирование в консоль на случай ошибки
        print("📋 Информация о питомце:")
        print(detailText)
        
        spawn(function()
            wait(2)
            copyButton.Text = "📋 СКОПИРОВАТЬ"
            copyButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
        end)
    end)
    
    closeButton.MouseButton1Click:Connect(function()
        detailNotebook:Destroy()
        detailNotebook = nil
    end)
end

-- Функция создания карточки питомца
local function createPetCard(analysis)
    if not petListFrame then
        print("❌ petListFrame не инициализирован!")
        return
    end
    
    local cardFrame = Instance.new("Frame")
    cardFrame.Name = "PetCard_" .. #analyzedPets
    cardFrame.Size = UDim2.new(1, -10, 0, 85)
    cardFrame.Position = UDim2.new(0, 10, 0, (#analyzedPets - 1) * 95)
    cardFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    cardFrame.BorderSizePixel = 0
    cardFrame.ZIndex = 10
    cardFrame.Parent = petListFrame
    
    addRoundedCorners(cardFrame, 8)
    
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
    
    local statsLabel = Instance.new("TextLabel")
    statsLabel.Name = "StatsLabel"
    statsLabel.Size = UDim2.new(1, -20, 0, 25)
    statsLabel.Position = UDim2.new(0, 10, 0, 25)
    statsLabel.BackgroundTransparency = 1
    statsLabel.Text = string.format("📊 Части: %d | Меши: %d | Motor6D: %d | Humanoid: %d", analysis.partCount, analysis.meshCount, analysis.motor6dCount, analysis.humanoidCount)
    statsLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    statsLabel.TextSize = 10
    statsLabel.Font = Enum.Font.SourceSans
    statsLabel.TextXAlignment = Enum.TextXAlignment.Left
    statsLabel.TextWrapped = true
    statsLabel.TextScaled = true
    statsLabel.ZIndex = 11
    statsLabel.Parent = cardFrame
    
    local detailButton = Instance.new("TextButton")
    detailButton.Name = "DetailButton"
    detailButton.Size = UDim2.new(1, -20, 0, 25)
    detailButton.Position = UDim2.new(0, 10, 0, 55)
    detailButton.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
    detailButton.BorderSizePixel = 0
    detailButton.Text = "📋 Открыть детальный блокнот"
    detailButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    detailButton.TextSize = 12
    detailButton.Font = Enum.Font.SourceSans
    detailButton.TextScaled = true
    detailButton.ZIndex = 11
    detailButton.Parent = cardFrame
    
    addRoundedCorners(detailButton, 6)
    
    detailButton.MouseButton1Click:Connect(function()
        openDetailNotebook(analysis)
    end)
    
    petListFrame.CanvasSize = UDim2.new(0, 0, 0, #analyzedPets * 95)
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
    mainGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    mainGui.Parent = playerGui
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 350, 0, 500)  -- Узкое вертикальное окно
    mainFrame.Position = UDim2.new(0, 20, 0, 50)  -- Левый верхний угол
    mainFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    mainFrame.BorderSizePixel = 0
    mainFrame.ZIndex = 5
    mainFrame.Parent = mainGui
    
    addRoundedCorners(mainFrame, 12)
    makeDraggable(mainFrame)
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "TitleLabel"
    titleLabel.Size = UDim2.new(1, 0, 0, 50)
    titleLabel.Position = UDim2.new(0, 0, 0, 0)
    titleLabel.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    titleLabel.BorderSizePixel = 0
    titleLabel.Text = "🔍 PET ANALYZER"
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextSize = 20
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.TextScaled = true
    titleLabel.ZIndex = 6
    titleLabel.Parent = mainFrame
    
    addRoundedCorners(titleLabel, 12)
    
    local analyzeButton = Instance.new("TextButton")
    analyzeButton.Name = "AnalyzeButton"
    analyzeButton.Size = UDim2.new(1, -20, 0, 50)
    analyzeButton.Position = UDim2.new(0, 10, 0, 60)
    analyzeButton.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    analyzeButton.BorderSizePixel = 0
    analyzeButton.Text = "🔬 АНАЛИЗИРОВАТЬ БЛИЖАЙШЕГО ПИТОМЦА"
    analyzeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    analyzeButton.TextSize = 16
    analyzeButton.Font = Enum.Font.SourceSansBold
    analyzeButton.TextScaled = true
    analyzeButton.ZIndex = 6
    analyzeButton.Parent = mainFrame
    
    addRoundedCorners(analyzeButton, 8)
    
    petListFrame = Instance.new("ScrollingFrame")
    petListFrame.Name = "PetListFrame"
    petListFrame.Size = UDim2.new(1, -20, 1, -130)
    petListFrame.Position = UDim2.new(0, 10, 0, 120)
    petListFrame.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
    petListFrame.BorderSizePixel = 0
    petListFrame.ScrollBarThickness = 12
    petListFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
    petListFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    petListFrame.ZIndex = 6
    petListFrame.Parent = mainFrame
    
    addRoundedCorners(petListFrame, 8)
    
    local listLayout = Instance.new("UIListLayout")
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Padding = UDim.new(0, 10)
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

-- Window close handler
Window:OnClose(function()
    analyzedPets = {}
    currentAnalysis = nil
end)

print("✅ Pet Analyzer with WindUI loaded successfully!")
