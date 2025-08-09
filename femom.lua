-- 🔥 ULTIMATE SHOVEL REPLACER v1.0
-- Идеальная замена Shovel на питомца с live анимацией
-- Объединяет лучшие части DirectShovelFix.lua + PetScaler_v3.465.lua

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer

print("🔥 === ULTIMATE SHOVEL REPLACER v1.0 ===")
print("=" .. string.rep("=", 50))

-- Конфигурация
local CONFIG = {
    SCALE_FACTOR = 1.0,
    INTERPOLATION_SPEED = 0.3,
    MAX_DISTANCE_FROM_ROOT = 50,
    POSITION_THRESHOLD = 0.01,
    ROTATION_THRESHOLD = 0.01,
    HAND_PET_CHECK_INTERVAL = 0.5
}

-- Глобальные переменные
local savedPetModel = nil
local currentTool = nil
local animationConnection = nil
local lastHandPetCheck = 0
local handPetModel = nil
local handPetParts = {}
local previousCFrameStates = {}

-- === ФУНКЦИИ ПОИСКА И АНАЛИЗА ===

-- Функция поиска питомца в руках игрока
local function findHandHeldPet()
    local character = player.Character
    if not character then return nil, nil end
    
    local tool = character:FindFirstChildOfClass("Tool")
    if not tool then return nil, nil end
    
    -- Проверяем что это питомец (содержит "Dragonfly" или "KG]")
    if tool.Name:find("Dragonfly") or tool.Name:find("KG]") then
        local handle = tool:FindFirstChild("Handle")
        if handle then
            -- Ищем модель питомца внутри Tool
            for _, child in pairs(tool:GetChildren()) do
                if child:IsA("Model") and child ~= handle then
                    return child, tool
                end
            end
            
            -- Если модель не найдена, создаем из Handle
            local petModel = Instance.new("Model")
            petModel.Name = "PetModel"
            petModel.Parent = tool
            handle.Parent = petModel
            petModel.PrimaryPart = handle
            
            return petModel, tool
        end
    end
    
    return nil, nil
end

-- Функция получения анимируемых частей из Tool
local function getAnimatedPartsFromTool(petModel)
    if not petModel then return {} end
    
    local parts = {}
    for _, obj in pairs(petModel:GetDescendants()) do
        if obj:IsA("BasePart") then
            table.insert(parts, obj)
        end
    end
    
    return parts
end

-- Функция поиска соответствующей части в копии
local function findCorrespondingPart(copyModel, partName)
    if not copyModel then return nil end
    
    for _, obj in pairs(copyModel:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name == partName then
            return obj
        end
    end
    
    return nil
end

-- Функция масштабирования CFrame
local function scaleCFrame(originalCFrame, scaleFactor)
    if scaleFactor == 1.0 then
        return originalCFrame
    end
    
    local position = originalCFrame.Position * scaleFactor
    local rotation = originalCFrame - originalCFrame.Position
    
    return CFrame.new(position) * rotation
end

-- === ФУНКЦИИ СОЗДАНИЯ И УПРАВЛЕНИЯ TOOL ===

-- Функция сохранения питомца
local function savePetModel()
    print("\n🔍 === ПОИСК И СОХРАНЕНИЕ ПИТОМЦА ===")
    
    -- Ищем питомца в Visuals
    local visuals = Workspace:FindFirstChild("Visuals")
    if not visuals then
        print("❌ Workspace.Visuals не найден!")
        return false
    end
    
    local foundPet = nil
    for _, child in pairs(visuals:GetChildren()) do
        if child:IsA("Model") and (child.Name:find("Dragonfly") or child.Name:find("KG]")) then
            foundPet = child
            break
        end
    end
    
    if not foundPet then
        print("❌ Питомец не найден в Visuals!")
        return false
    end
    
    -- Создаем глубокую копию питомца
    savedPetModel = foundPet:Clone()
    savedPetModel.Name = foundPet.Name .. "_SAVED"
    savedPetModel.Parent = nil -- Храним в памяти
    
    print("✅ Питомец сохранен:", foundPet.Name)
    print("📦 Частей в модели:", #savedPetModel:GetDescendants())
    
    return true
end

-- Функция создания Tool из сохраненного питомца
local function createPetTool()
    if not savedPetModel then
        print("❌ Питомец не сохранен! Сначала сохраните питомца.")
        return nil
    end
    
    print("\n🔧 === СОЗДАНИЕ PET TOOL ===")
    
    -- Создаем новый Tool
    local newTool = Instance.new("Tool")
    newTool.Name = savedPetModel.Name:gsub("_SAVED", "")
    newTool.RequiresHandle = true
    newTool.CanBeDropped = false
    
    -- Создаем Handle
    local handle = Instance.new("Part")
    handle.Name = "Handle"
    handle.Size = Vector3.new(1, 1, 1)
    handle.Material = Enum.Material.Neon
    handle.BrickColor = BrickColor.new("Bright green")
    handle.Shape = Enum.PartType.Ball
    handle.Anchored = false
    handle.CanCollide = false
    handle.TopSurface = Enum.SurfaceType.Smooth
    handle.BottomSurface = Enum.SurfaceType.Smooth
    handle.Parent = newTool
    
    -- Клонируем модель питомца в Tool
    local petCopy = savedPetModel:Clone()
    petCopy.Name = "PetModel"
    petCopy.Parent = newTool
    
    -- Настраиваем все части питомца
    for _, part in pairs(petCopy:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Anchored = false
            part.CanCollide = false
            
            -- Создаем Weld для крепления к Handle
            local weld = Instance.new("WeldConstraint")
            weld.Part0 = handle
            weld.Part1 = part
            weld.Parent = handle
        end
    end
    
    print("✅ Pet Tool создан:", newTool.Name)
    return newTool
end

-- Функция замены Shovel на Pet Tool
local function replaceShovelWithPet()
    print("\n🔄 === ЗАМЕНА SHOVEL НА PET TOOL ===")
    
    local character = player.Character
    if not character then
        print("❌ Персонаж не найден!")
        return false
    end
    
    -- Ищем Shovel в руках
    local shovelTool = character:FindFirstChildOfClass("Tool")
    if not shovelTool or not shovelTool.Name:find("Shovel") then
        print("❌ Shovel не найден в руках!")
        return false
    end
    
    -- Создаем Pet Tool
    local petTool = createPetTool()
    if not petTool then
        print("❌ Не удалось создать Pet Tool!")
        return false
    end
    
    -- Удаляем Shovel и добавляем Pet Tool
    shovelTool:Destroy()
    
    -- Добавляем Pet Tool в Backpack, затем экипируем
    petTool.Parent = player.Backpack
    wait(0.1)
    
    -- Принудительно экипируем Tool
    character.Humanoid:EquipTool(petTool)
    
    currentTool = petTool
    print("✅ Shovel заменен на Pet Tool!")
    
    return true
end

-- === СИСТЕМА LIVE АНИМАЦИИ ===

-- Функция запуска live анимации
local function startLiveAnimation()
    if animationConnection then
        animationConnection:Disconnect()
    end
    
    print("\n🎬 === ЗАПУСК LIVE АНИМАЦИИ ===")
    
    animationConnection = RunService.Heartbeat:Connect(function()
        local currentTime = tick()
        
        -- Проверяем наличие Tool в руках
        if not currentTool or not currentTool.Parent then
            return
        end
        
        local petModel = currentTool:FindFirstChild("PetModel")
        if not petModel then
            return
        end
        
        -- Периодически ищем питомца в руках для копирования анимации
        if currentTime - lastHandPetCheck >= CONFIG.HAND_PET_CHECK_INTERVAL then
            local foundPetModel, foundTool = findHandHeldPet()
            
            if foundPetModel ~= handPetModel then
                handPetModel = foundPetModel
                handPetParts = getAnimatedPartsFromTool(handPetModel)
                
                if handPetModel then
                    print("🎯 Найден питомец для копирования анимации:", foundTool and foundTool.Name or "Неизвестный")
                    
                    -- Инициализируем отслеживание CFrame
                    previousCFrameStates = {}
                    for _, part in ipairs(handPetParts) do
                        if part and part.Parent then
                            previousCFrameStates[part.Name] = part.CFrame
                        end
                    end
                end
            end
            
            lastHandPetCheck = currentTime
        end
        
        -- Live копирование CFrame состояний
        if handPetModel and #handPetParts > 0 then
            for _, handPart in ipairs(handPetParts) do
                if handPart and handPart.Parent then
                    local partName = handPart.Name
                    local currentCFrame = handPart.CFrame
                    
                    -- Проверяем изменилось ли CFrame состояние
                    local hasChanged = false
                    if previousCFrameStates[partName] then
                        local prevCFrame = previousCFrameStates[partName]
                        local positionDiff = (currentCFrame.Position - prevCFrame.Position).Magnitude
                        local rotationDiff = math.abs(currentCFrame.LookVector:Dot(prevCFrame.LookVector) - 1)
                        
                        if positionDiff > CONFIG.POSITION_THRESHOLD or rotationDiff > CONFIG.ROTATION_THRESHOLD then
                            hasChanged = true
                        end
                    end
                    
                    -- Обновляем предыдущее состояние
                    previousCFrameStates[partName] = currentCFrame
                    
                    -- Находим соответствующую часть в Pet Tool и применяем CFrame
                    local copyPart = findCorrespondingPart(petModel, partName)
                    if copyPart and hasChanged then
                        local success, errorMsg = pcall(function()
                            -- Масштабирование и применение CFrame
                            local scaledCFrame = scaleCFrame(currentCFrame, CONFIG.SCALE_FACTOR)
                            
                            -- Проверка безопасности CFrame
                            local handle = currentTool:FindFirstChild("Handle")
                            if handle then
                                local distanceFromHandle = (scaledCFrame.Position - handle.Position).Magnitude
                                if distanceFromHandle > CONFIG.MAX_DISTANCE_FROM_ROOT then
                                    -- Ограничиваем расстояние от Handle
                                    local direction = (scaledCFrame.Position - handle.Position).Unit
                                    local limitedPosition = handle.Position + direction * CONFIG.MAX_DISTANCE_FROM_ROOT
                                    scaledCFrame = CFrame.new(limitedPosition) * (scaledCFrame - scaledCFrame.Position)
                                end
                            end
                            
                            -- Проверяем что CFrame не является NaN или бесконечностью
                            if scaledCFrame.Position.X == scaledCFrame.Position.X and 
                               math.abs(scaledCFrame.Position.X) ~= math.huge and
                               math.abs(scaledCFrame.Position.Y) ~= math.huge and
                               math.abs(scaledCFrame.Position.Z) ~= math.huge then
                                
                                -- Применяем с интерполяцией для плавности
                                if not copyPart.Anchored and copyPart.Parent then
                                    copyPart.CFrame = copyPart.CFrame:Lerp(scaledCFrame, CONFIG.INTERPOLATION_SPEED)
                                end
                            end
                        end)
                        
                        if not success then
                            print("❌ Ошибка при применении CFrame", partName, ":", errorMsg)
                        end
                    end
                end
            end
        end
    end)
    
    print("✅ Live анимация запущена!")
end

-- Функция остановки live анимации
local function stopLiveAnimation()
    if animationConnection then
        animationConnection:Disconnect()
        animationConnection = nil
        print("⏹️ Live анимация остановлена")
    end
end

-- === ГЛАВНЫЕ ФУНКЦИИ ===

-- Главная функция
local function main()
    print("\n🚀 === ЗАПУСК ULTIMATE SHOVEL REPLACER ===")
    
    -- Шаг 1: Сохраняем питомца
    if not savePetModel() then
        print("❌ Не удалось сохранить питомца!")
        return false
    end
    
    -- Шаг 2: Заменяем Shovel на Pet Tool
    if not replaceShovelWithPet() then
        print("❌ Не удалось заменить Shovel!")
        return false
    end
    
    -- Шаг 3: Запускаем live анимацию
    wait(1) -- Даем время Tool появиться в руках
    startLiveAnimation()
    
    print("🎉 === УСПЕХ! ===")
    print("✅ Shovel заменен на анимированного питомца!")
    print("✅ Live анимация запущена!")
    print("🔥 Питомец в руке теперь живой и анимированный!")
    
    return true
end

-- === СОЗДАНИЕ GUI ===

local function createGUI()
    local playerGui = player:WaitForChild("PlayerGui")
    
    -- Удаляем старый GUI
    local oldGui = playerGui:FindFirstChild("UltimateShovelReplacerGUI")
    if oldGui then
        oldGui:Destroy()
    end
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "UltimateShovelReplacerGUI"
    screenGui.Parent = playerGui
    
    local frame = Instance.new("Frame")
    frame.Name = "MainFrame"
    frame.Size = UDim2.new(0, 300, 0, 120)
    frame.Position = UDim2.new(0, 50, 0, 50)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    frame.BorderSizePixel = 2
    frame.BorderColor3 = Color3.fromRGB(255, 0, 0)
    frame.Parent = screenGui
    
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 0, 30)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    title.BorderSizePixel = 0
    title.Text = "🔥 ULTIMATE SHOVEL REPLACER"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 14
    title.Font = Enum.Font.SourceSansBold
    title.Parent = frame
    
    local replaceBtn = Instance.new("TextButton")
    replaceBtn.Name = "ReplaceButton"
    replaceBtn.Size = UDim2.new(0, 280, 0, 35)
    replaceBtn.Position = UDim2.new(0, 10, 0, 40)
    replaceBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    replaceBtn.BorderSizePixel = 0
    replaceBtn.Text = "🔄 ЗАМЕНИТЬ SHOVEL НА ПИТОМЦА"
    replaceBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
    replaceBtn.TextSize = 14
    replaceBtn.Font = Enum.Font.SourceSansBold
    replaceBtn.Parent = frame
    
    local stopBtn = Instance.new("TextButton")
    stopBtn.Name = "StopButton"
    stopBtn.Size = UDim2.new(0, 280, 0, 35)
    stopBtn.Position = UDim2.new(0, 10, 0, 80)
    stopBtn.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
    stopBtn.BorderSizePixel = 0
    stopBtn.Text = "⏹️ ОСТАНОВИТЬ АНИМАЦИЮ"
    stopBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
    stopBtn.TextSize = 14
    stopBtn.Font = Enum.Font.SourceSansBold
    stopBtn.Parent = frame
    
    -- События кнопок
    replaceBtn.MouseButton1Click:Connect(function()
        replaceBtn.Text = "⏳ Заменяю..."
        replaceBtn.BackgroundColor3 = Color3.fromRGB(255, 165, 0)
        
        spawn(function()
            main()
            
            wait(2)
            replaceBtn.Text = "🔄 ЗАМЕНИТЬ SHOVEL НА ПИТОМЦА"
            replaceBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        end)
    end)
    
    stopBtn.MouseButton1Click:Connect(function()
        stopLiveAnimation()
        stopBtn.Text = "✅ АНИМАЦИЯ ОСТАНОВЛЕНА"
        stopBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
        
        wait(2)
        stopBtn.Text = "⏹️ ОСТАНОВИТЬ АНИМАЦИЮ"
        stopBtn.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
    end)
    
    print("🖥️ Ultimate Shovel Replacer GUI создан!")
end

-- === ЗАПУСК ===

createGUI()
print("=" .. string.rep("=", 50))
print("💡 ULTIMATE SHOVEL REPLACER:")
print("   1. Сохраняет питомца из Visuals")
print("   2. Создает анимированный Pet Tool")
print("   3. Заменяет Shovel на Pet Tool")
print("   4. Запускает live анимацию")
print("🎯 Нажмите зеленую кнопку для запуска!")
print("=" .. string.rep("=", 50))
