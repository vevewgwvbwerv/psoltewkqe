-- 🎯 PET CREATOR - Генератор питомцев по данным
-- Создает новую модель питомца с UUID именем на основе данных из PetGenerator.lua
-- Размещает питомца рядом с игроком в Workspace

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer

print("🎯 === PET CREATOR - ГЕНЕРАТОР ПИТОМЦЕВ ===")
print("=" .. string.rep("=", 50))

-- Данные питомца из PetGenerator.lua
local PET_DATA = {
    ["PrimaryPart"] = "RootPart",
    ["ModelSize"] = Vector3.new(4.72, 5.18, 4.13),
    ["ModelPosition"] = Vector3.new(-220.71, 2.29, -105.54),
    ["TotalParts"] = 15,
    ["TotalMeshes"] = 1,
    ["TotalMotor6D"] = 14,
    ["TotalHumanoids"] = 0,
    ["TotalAttachments"] = 0,
    ["TotalScripts"] = 0,
    
    ["Meshes"] = {
        [1] = {name = "MouthEnd", type = "MeshPart", parent = "MODEL", meshId = "rbxassetid://134824845323237"}
    },

    ["Motor6D"] = {
        [1] = {name = "Mouth", part0 = "Jaw", part1 = "Mouth"},
        [2] = {name = "MouthEnd", part0 = "Jaw", part1 = "MouthEnd"},
        [3] = {name = "Head", part0 = "Torso", part1 = "Head"},
        [4] = {name = "BackLegL", part0 = "Torso", part1 = "BackLegL"},
        [5] = {name = "FrontLegL", part0 = "Torso", part1 = "FrontLegL"},
        [6] = {name = "FrontLegR", part0 = "Torso", part1 = "FrontLegR"},
        [7] = {name = "BackLegR", part0 = "Torso", part1 = "BackLegR"},
        [8] = {name = "Tail", part0 = "Torso", part1 = "Tail"},
        [9] = {name = "RightEye", part0 = "Head", part1 = "RightEye"},
        [10] = {name = "LeftEye", part0 = "Head", part1 = "LeftEye"},
        [11] = {name = "LeftEar", part0 = "Head", part1 = "LeftEar"},
        [12] = {name = "RightEar", part0 = "Head", part1 = "RightEar"},
        [13] = {name = "Jaw", part0 = "Head", part1 = "Jaw"},
        [14] = {name = "Torso", part0 = "RootPart", part1 = "Torso"}
    },

    ["Parts"] = {
        [1] = {
            name = "RightEar", 
            type = "UnionOperation", 
            size = Vector3.new(1.40, 0.96, 1.13), 
            material = "Plastic",
            color = Color3.new(0.580, 0.400, 0.298),
            brickColor = "Red flip/flop",
            transparency = 0.00,
            canCollide = false,
            position = Vector3.new(-220.51, 3.72, -103.38),
            rotation = Vector3.new(158.17, 59.10, -42.23),
            reflectance = 0.00
        },
        [2] = {
            name = "LeftEar", 
            type = "UnionOperation", 
            size = Vector3.new(0.70, 0.96, 1.53), 
            material = "Plastic",
            color = Color3.new(0.580, 0.400, 0.298),
            brickColor = "Red flip/flop",
            transparency = 0.00,
            canCollide = false,
            position = Vector3.new(-218.55, 3.53, -105.31),
            rotation = Vector3.new(118.48, 2.91, -49.54),
            reflectance = 0.00
        },
        [3] = {
            name = "Jaw", 
            type = "UnionOperation", 
            size = Vector3.new(0.32, 1.12, 1.45), 
            material = "Plastic",
            color = Color3.new(0.973, 0.973, 0.973),
            brickColor = "Institutional white",
            transparency = 0.00,
            canCollide = false,
            position = Vector3.new(-219.26, 2.20, -104.01),
            rotation = Vector3.new(-8.63, -42.87, -18.80),
            reflectance = 0.00
        },
        [4] = {
            name = "Mouth", 
            type = "UnionOperation", 
            size = Vector3.new(0.64, 0.08, 0.40), 
            material = "Plastic",
            color = Color3.new(0.106, 0.165, 0.208),
            brickColor = "Black",
            transparency = 0.00,
            canCollide = false,
            position = Vector3.new(-219.12, 2.15, -103.88),
            rotation = Vector3.new(171.37, 42.87, -71.20),
            reflectance = 0.00
        },
        [5] = {
            name = "Torso", 
            type = "Part", 
            size = Vector3.new(0.80, 2.25, 2.25), 
            material = "Plastic",
            color = Color3.new(0.973, 0.973, 0.973),
            brickColor = "Institutional white",
            transparency = 0.00,
            canCollide = false,
            position = Vector3.new(-220.58, 1.72, -105.26),
            rotation = Vector3.new(-179.60, 43.61, -77.00),
            reflectance = 0.00
        },
        [6] = {
            name = "Head", 
            type = "Part", 
            size = Vector3.new(2.25, 2.25, 2.57), 
            material = "Plastic",
            color = Color3.new(0.973, 0.973, 0.973),
            brickColor = "Institutional white",
            transparency = 0.00,
            canCollide = false,
            position = Vector3.new(-219.97, 3.10, -104.79),
            rotation = Vector3.new(173.90, 43.85, -66.68),
            reflectance = 0.00
        },
        [7] = {
            name = "Tail", 
            type = "Part", 
            size = Vector3.new(0.64, 2.49, 0.64), 
            material = "Plastic",
            color = Color3.new(0.580, 0.400, 0.298),
            brickColor = "Red flip/flop",
            transparency = 0.00,
            canCollide = false,
            position = Vector3.new(-221.65, 1.70, -106.50),
            rotation = Vector3.new(-174.88, 59.86, -59.07),
            reflectance = 0.00
        },
        [8] = {
            name = "LeftEye", 
            type = "Part", 
            size = Vector3.new(0.56, 0.08, 0.32), 
            material = "Plastic",
            color = Color3.new(0.106, 0.165, 0.208),
            brickColor = "Black",
            transparency = 0.00,
            canCollide = false,
            position = Vector3.new(-218.65, 2.84, -104.48),
            rotation = Vector3.new(173.90, 43.85, -66.68),
            reflectance = 0.00
        },
        [9] = {
            name = "RightEye", 
            type = "Part", 
            size = Vector3.new(0.56, 0.08, 0.32), 
            material = "Plastic",
            color = Color3.new(0.106, 0.165, 0.208),
            brickColor = "Black",
            transparency = 0.00,
            canCollide = false,
            position = Vector3.new(-219.65, 2.95, -103.44),
            rotation = Vector3.new(173.90, 43.85, -66.68),
            reflectance = 0.00
        },
        [10] = {
            name = "BackLegL", 
            type = "UnionOperation", 
            size = Vector3.new(1.28, 1.61, 1.28), 
            material = "Plastic",
            color = Color3.new(0.973, 0.973, 0.973),
            brickColor = "Institutional white",
            transparency = 0.00,
            canCollide = false,
            position = Vector3.new(-220.76, 1.03, -106.50),
            rotation = Vector3.new(175.44, 38.20, -40.66),
            reflectance = 0.00
        },
        [11] = {
            name = "BackLegR", 
            type = "UnionOperation", 
            size = Vector3.new(1.28, 1.61, 1.28), 
            material = "Plastic",
            color = Color3.new(0.973, 0.973, 0.973),
            brickColor = "Institutional white",
            transparency = 0.00,
            canCollide = false,
            position = Vector3.new(-221.59, 0.87, -105.22),
            rotation = Vector3.new(-178.52, 57.17, -83.61),
            reflectance = 0.00
        },
        [12] = {
            name = "FrontLegR", 
            type = "UnionOperation", 
            size = Vector3.new(1.28, 1.28, 0.96), 
            material = "Plastic",
            color = Color3.new(0.973, 0.973, 0.973),
            brickColor = "Institutional white",
            transparency = 0.00,
            canCollide = false,
            position = Vector3.new(-220.58, 0.87, -104.34),
            rotation = Vector3.new(174.59, 50.40, -63.12),
            reflectance = 0.00
        },
        [13] = {
            name = "FrontLegL", 
            type = "UnionOperation", 
            size = Vector3.new(1.28, 1.28, 0.96), 
            material = "Plastic",
            color = Color3.new(0.973, 0.973, 0.973),
            brickColor = "Institutional white",
            transparency = 0.00,
            canCollide = false,
            position = Vector3.new(-219.19, 0.80, -104.97),
            rotation = Vector3.new(-172.38, 45.08, -116.32),
            reflectance = 0.00
        },
        [14] = {
            name = "RootPart", 
            type = "Part", 
            size = Vector3.new(0.80, 2.25, 2.25), 
            material = "Plastic",
            color = Color3.new(0.973, 0.973, 0.973),
            brickColor = "Institutional white",
            transparency = 1.00,
            canCollide = false,
            position = Vector3.new(-220.58, 1.91, -105.26),
            rotation = Vector3.new(180.00, 46.31, -90.00),
            reflectance = 0.00
        },
        [15] = {
            name = "ColourSpot", 
            type = "Part", 
            size = Vector3.new(1.03, 0.74, 1.00), 
            material = "Plastic",
            color = Color3.new(0.580, 0.400, 0.298),
            brickColor = "Red flip/flop",
            transparency = 0.00,
            canCollide = false,
            position = Vector3.new(-218.73, 3.37, -104.73),
            rotation = Vector3.new(-6.11, -43.85, 66.68),
            reflectance = 0.00
        }
    }
}

-- === ФУНКЦИЯ ГЕНЕРАЦИИ UUID ===
local function generateUUID()
    local template = "xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx"
    return string.gsub(template, '[xy]', function (c)
        local v = (c == 'x') and math.random(0, 0xf) or math.random(8, 0xb)
        return string.format('%x', v)
    end)
end

-- === ФУНКЦИЯ ПОЛУЧЕНИЯ ПОЗИЦИИ ИГРОКА ===
local function getPlayerPosition()
    local playerChar = player.Character
    if not playerChar then
        print("❌ Персонаж игрока не найден!")
        return nil
    end

    local hrp = playerChar:FindFirstChild("HumanoidRootPart")
    if not hrp then
        print("❌ HumanoidRootPart не найден!")
        return nil
    end

    return hrp.Position
end

-- === ФУНКЦИЯ СОЗДАНИЯ ЧАСТИ ===
local function createPart(partData, model, modelCenter)
    local part = nil
    
    -- Создаем нужный тип части
    if partData.type == "Part" then
        part = Instance.new("Part")
    elseif partData.type == "UnionOperation" then
        -- Для UnionOperation создаем обычный Part (так как UnionOperation нельзя создать через скрипт)
        part = Instance.new("Part")
        part.Shape = Enum.PartType.Block
    elseif partData.type == "MeshPart" then
        part = Instance.new("MeshPart")
        -- Устанавливаем MeshId если есть в данных мешей
        for _, meshData in pairs(PET_DATA.Meshes) do
            if meshData.name == partData.name then
                part.MeshId = meshData.meshId
                break
            end
        end
    else
        print("⚠️ Неизвестный тип части:", partData.type)
        part = Instance.new("Part")
    end
    
    -- Настраиваем свойства части
    part.Name = partData.name
    part.Size = partData.size
    part.Material = Enum.Material[partData.material] or Enum.Material.Plastic
    part.Color = partData.color
    part.BrickColor = BrickColor.new(partData.brickColor)
    part.Transparency = partData.transparency
    part.CanCollide = partData.canCollide
    part.Reflectance = partData.reflectance
    
    -- ИСПРАВЛЕНО: Вычисляем относительную позицию от центра модели
    local relativePosition = partData.position - modelCenter
    
    -- Создаем CFrame с относительной позицией и поворотом
    local rotationCFrame = CFrame.Angles(
        math.rad(partData.rotation.X),
        math.rad(partData.rotation.Y),
        math.rad(partData.rotation.Z)
    )
    
    -- Устанавливаем CFrame относительно центра (0,0,0)
    part.CFrame = CFrame.new(relativePosition) * rotationCFrame
    
    part.Parent = model
    
    print("✅ Создана часть:", partData.name, "(" .. partData.type .. ") - относительная позиция:", relativePosition)
    return part
end

-- === ФУНКЦИЯ СОЗДАНИЯ MOTOR6D СОЕДИНЕНИЙ ===
local function createMotor6D(motorData, model)
    local motor = Instance.new("Motor6D")
    motor.Name = motorData.name
    
    -- Находим части для соединения
    local part0 = model:FindFirstChild(motorData.part0)
    local part1 = model:FindFirstChild(motorData.part1)
    
    if part0 and part1 then
        motor.Part0 = part0
        motor.Part1 = part1
        motor.Parent = part0 -- Motor6D обычно находится в Part0
        
        print("✅ Создан Motor6D:", motorData.name, "(" .. motorData.part0 .. " -> " .. motorData.part1 .. ")")
        return motor
    else
        print("❌ Не найдены части для Motor6D:", motorData.name)
        if not part0 then print("  - Не найден Part0:", motorData.part0) end
        if not part1 then print("  - Не найден Part1:", motorData.part1) end
        motor:Destroy()
        return nil
    end
end

-- === ФУНКЦИЯ ПОЗИЦИОНИРОВАНИЯ МОДЕЛИ РЯДОМ С ИГРОКОМ ===
local function positionModelNearPlayer(model, playerPosition)
    if not model.PrimaryPart then
        print("❌ PrimaryPart не установлен!")
        return false
    end
    
    -- Позиционируем модель рядом с игроком (5 единиц справа)
    local targetPosition = playerPosition + Vector3.new(5, 0, 0)
    
    -- Устанавливаем позицию PrimaryPart в целевую позицию
    model:SetPrimaryPartCFrame(CFrame.new(targetPosition))
    
    print("📍 Модель позиционирована рядом с игроком")
    print("  Позиция игрока:", playerPosition)
    print("  Позиция модели:", targetPosition)
    
    return true
end

-- === ГЛАВНАЯ ФУНКЦИЯ СОЗДАНИЯ ПИТОМЦА ===
local function createPetFromData()
    print("\n🎯 === СОЗДАНИЕ ПИТОМЦА ИЗ ДАННЫХ ===")
    
    -- Шаг 1: Генерируем UUID имя
    local uuid = generateUUID()
    local petName = "{" .. uuid .. "}"
    print("🔑 Сгенерирован UUID:", petName)
    
    -- Шаг 2: Получаем позицию игрока
    local playerPosition = getPlayerPosition()
    if not playerPosition then
        return nil
    end
    print("📍 Позиция игрока:", playerPosition)
    
    -- Шаг 3: Создаем модель
    local petModel = Instance.new("Model")
    petModel.Name = petName
    petModel.Parent = Workspace
    print("📦 Создана модель:", petName)
    
    -- Шаг 4: Создаем все части
    print("\n🧩 === СОЗДАНИЕ ЧАСТЕЙ ===")
    local createdParts = {}
    
    -- Вычисляем центр модели из оригинальных данных
    local modelCenter = PET_DATA.ModelPosition
    print("📐 Центр модели:", modelCenter)
    
    for i, partData in pairs(PET_DATA.Parts) do
        local part = createPart(partData, petModel, modelCenter)
        if part then
            createdParts[partData.name] = part
        end
    end
    
    print("✅ Создано частей:", #PET_DATA.Parts)
    
    -- Шаг 5: Устанавливаем PrimaryPart
    local primaryPart = petModel:FindFirstChild(PET_DATA.PrimaryPart)
    if primaryPart then
        petModel.PrimaryPart = primaryPart
        print("✅ PrimaryPart установлен:", PET_DATA.PrimaryPart)
    else
        print("❌ PrimaryPart не найден:", PET_DATA.PrimaryPart)
    end
    
    -- Шаг 6: Создаем Motor6D соединения
    print("\n🔗 === СОЗДАНИЕ MOTOR6D СОЕДИНЕНИЙ ===")
    local createdMotors = 0
    
    for i, motorData in pairs(PET_DATA.Motor6D) do
        local motor = createMotor6D(motorData, petModel)
        if motor then
            createdMotors = createdMotors + 1
        end
    end
    
    print("✅ Создано Motor6D соединений:", createdMotors .. "/" .. #PET_DATA.Motor6D)
    
    -- Шаг 7: Позиционируем модель рядом с игроком
    print("\n📍 === ПОЗИЦИОНИРОВАНИЕ ===")
    local positionSuccess = positionModelNearPlayer(petModel, playerPosition)
    
    if positionSuccess then
        print("\n🎉 === ПИТОМЕЦ УСПЕШНО СОЗДАН ===")
        print("✅ UUID имя:", petName)
        print("✅ Всего частей:", #PET_DATA.Parts)
        print("✅ Motor6D соединений:", createdMotors)
        print("✅ Позиция: рядом с игроком")
        print("✅ Модель размещена в Workspace")
        
        return petModel
    else
        print("❌ Ошибка позиционирования!")
        petModel:Destroy()
        return nil
    end
end

-- === СОЗДАНИЕ GUI ===
local function createGUI()
    local success, errorMsg = pcall(function()
        local playerGui = player:WaitForChild("PlayerGui")
        
        -- Удаляем старый GUI если есть
        local oldGui = playerGui:FindFirstChild("PetCreatorGUI")
        if oldGui then
            oldGui:Destroy()
            wait(0.1)
        end
        
        -- Создаем новый GUI
        local screenGui = Instance.new("ScreenGui")
        screenGui.Name = "PetCreatorGUI"
        screenGui.Parent = playerGui
        
        local frame = Instance.new("Frame")
        frame.Name = "MainFrame"
        frame.Size = UDim2.new(0, 280, 0, 80)
        frame.Position = UDim2.new(0, 50, 0, 50)
        frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        frame.BorderSizePixel = 2
        frame.BorderColor3 = Color3.fromRGB(0, 255, 255) -- Голубая рамка
        frame.Parent = screenGui
        
        -- Заголовок
        local title = Instance.new("TextLabel")
        title.Name = "Title"
        title.Size = UDim2.new(1, 0, 0, 25)
        title.Position = UDim2.new(0, 0, 0, 5)
        title.BackgroundTransparency = 1
        title.Text = "🎯 PET CREATOR"
        title.TextColor3 = Color3.fromRGB(0, 255, 255)
        title.TextSize = 14
        title.Font = Enum.Font.SourceSansBold
        title.Parent = frame
        
        -- Кнопка создания питомца
        local createButton = Instance.new("TextButton")
        createButton.Name = "CreatePetButton"
        createButton.Size = UDim2.new(0, 260, 0, 40)
        createButton.Position = UDim2.new(0, 10, 0, 30)
        createButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        createButton.BorderSizePixel = 0
        createButton.Text = "🐾 Создать питомца"
        createButton.TextColor3 = Color3.fromRGB(0, 0, 0)
        createButton.TextSize = 16
        createButton.Font = Enum.Font.SourceSansBold
        createButton.Parent = frame
        
        -- Обработчик кнопки
        createButton.MouseButton1Click:Connect(function()
            createButton.Text = "⏳ Создаю питомца..."
            createButton.BackgroundColor3 = Color3.fromRGB(255, 165, 0)
            
            spawn(function()
                local success, result = pcall(function()
                    return createPetFromData()
                end)
                
                if success and result then
                    createButton.Text = "✅ Питомец создан!"
                    createButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
                    wait(3)
                    createButton.Text = "🐾 Создать питомца"
                    createButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
                else
                    print("❌ Ошибка создания питомца:", result or "Неизвестная ошибка")
                    createButton.Text = "❌ Ошибка! Попробуйте снова"
                    createButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
                    wait(3)
                    createButton.Text = "🐾 Создать питомца"
                    createButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
                end
            end)
        end)
        
        print("✅ GUI создан успешно!")
    end)
    
    if not success then
        print("❌ Ошибка создания GUI:", errorMsg)
    end
end

-- === ЗАПУСК СКРИПТА ===
print("🚀 Запуск PET CREATOR...")
createGUI()
print("💡 Нажмите кнопку 'Создать питомца' для генерации нового питомца!")
