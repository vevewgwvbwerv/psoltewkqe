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

-- Функция запуска live анимации - КОПИРУЕМ С VISUALS
local function startLiveAnimation()
    if animationConnection then
        animationConnection:Disconnect()
    end
    
    print("\n🎬 === ЗАПУСК LIVE АНИМАЦИИ ===")
    print("📋 Копируем анимацию с питомца в Visuals")
    
    animationConnection = RunService.Heartbeat:Connect(function()
        -- Проверяем наличие Tool в руках
        if not currentTool or not currentTool.Parent then
            return
        end
        
        local petModel = currentTool:FindFirstChild("PetModel")
        if not petModel then
            return
        end
        
        -- Ищем питомца в Visuals для копирования анимации
        local visuals = Workspace:FindFirstChild("Visuals")
        if not visuals then
            return
        end
        
        local visualsPet = nil
        for _, child in pairs(visuals:GetChildren()) do
            if child:IsA("Model") and (child.Name:find("Dragonfly") or child.Name:find("KG]")) then
                visualsPet = child
                break
            end
        end
        
        if not visualsPet then
            return
        end
        
        -- Получаем части питомца из Visuals
        local visualsParts = {}
        for _, obj in pairs(visualsPet:GetDescendants()) do
            if obj:IsA("BasePart") then
                table.insert(visualsParts, obj)
            end
        end
        
        -- Live копирование CFrame состояний с питомца в Visuals
        if visualsPet and #visualsParts > 0 then
            for _, visualsPart in ipairs(visualsParts) do
                if visualsPart and visualsPart.Parent then
                    local partName = visualsPart.Name
                    local currentCFrame = visualsPart.CFrame
                    
                    -- Находим соответствующую часть в Pet Tool и применяем CFrame
                    local copyPart = findCorrespondingPart(petModel, partName)
                    if copyPart then
                        local success, errorMsg = pcall(function()
                            -- Применяем CFrame с интерполяцией для плавности
                            if not copyPart.Anchored and copyPart.Parent then
                                copyPart.CFrame = copyPart.CFrame:Lerp(currentCFrame, CONFIG.INTERPOLATION_SPEED)
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

-- Главная функция - ПРОСТАЯ ЛОГИКА
local function main()
    print("\n🚀 === ЗАПУСК ULTIMATE SHOVEL REPLACER ===")
    
    local character = player.Character
    if not character then
        print("❌ Персонаж не найден!")
        return false
    end
    
    -- Проверяем что в руках Shovel
    local currentTool = character:FindFirstChildOfClass("Tool")
    if not currentTool or not currentTool.Name:find("Shovel") then
        print("❌ Возьмите Shovel в руки перед запуском!")
        return false
    end
    
    -- Шаг 1: Сохраняем питомца из Visuals
    if not savePetModel() then
        print("❌ Питомец не найден в Visuals! Сначала получите питомца из яйца.")
        return false
    end
    
    -- Шаг 2: Заменяем Shovel на Pet Tool
    if not replaceShovelWithPet() then
        print("❌ Не удалось заменить Shovel!")
        return false
    end
    
    -- Шаг 3: Запускаем анимацию (копируем с питомца в Visuals)
    wait(1)
    startLiveAnimation()
    
    print("🎉 === УСПЕХ! ===")
    print("✅ Shovel заменен на питомца!")
    print("✅ Анимация копируется с питомца в Visuals!")
    print("🔥 Теперь у вас живой питомец в руке!")
    
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
    frame.Size = UDim2.new(0, 350, 0, 200)
    frame.Position = UDim2.new(0, 50, 0, 50)
    frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    frame.BorderSizePixel = 2
    frame.BorderColor3 = Color3.fromRGB(0, 255, 0)
    frame.Parent = screenGui
    
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 0, 40)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    title.BorderSizePixel = 0
    title.Text = "🔥 ЗАМЕНА SHOVEL НА ПИТОМЦА"
    title.TextColor3 = Color3.fromRGB(0, 0, 0)
    title.TextSize = 16
    title.Font = Enum.Font.SourceSansBold
    title.Parent = frame
    
    local instructions = Instance.new("TextLabel")
    instructions.Name = "Instructions"
    instructions.Size = UDim2.new(1, -20, 0, 80)
    instructions.Position = UDim2.new(0, 10, 0, 50)
    instructions.BackgroundTransparency = 1
    instructions.Text = "ИНСТРУКЦИЯ:\n1. Получите питомца из яйца\n2. Возьмите Shovel в руки\n3. Нажмите кнопку ниже"
    instructions.TextColor3 = Color3.fromRGB(255, 255, 255)
    instructions.TextSize = 14
    instructions.Font = Enum.Font.SourceSans
    instructions.TextWrapped = true
    instructions.TextYAlignment = Enum.TextYAlignment.Top
    instructions.Parent = frame
    
    local replaceBtn = Instance.new("TextButton")
    replaceBtn.Name = "ReplaceButton"
    replaceBtn.Size = UDim2.new(0, 330, 0, 40)
    replaceBtn.Position = UDim2.new(0, 10, 0, 140)
    replaceBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
    replaceBtn.BorderSizePixel = 0
    replaceBtn.Text = "🚀 ЗАМЕНИТЬ SHOVEL НА ПИТОМЦА!"
    replaceBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    replaceBtn.TextSize = 16
    replaceBtn.Font = Enum.Font.SourceSansBold
    replaceBtn.Parent = frame
    
    -- События кнопок
    replaceBtn.MouseButton1Click:Connect(function()
        replaceBtn.Text = "⏳ Заменяю..."
        replaceBtn.BackgroundColor3 = Color3.fromRGB(255, 165, 0)
        
        spawn(function()
            local success = main()
            
            wait(1)
            if success then
                replaceBtn.Text = "✅ УСПЕШНО ЗАМЕНЕНО!"
                replaceBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
            else
                replaceBtn.Text = "❌ ОШИБКА! Проверьте инструкцию"
                replaceBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
            end
            
            wait(3)
            replaceBtn.Text = "🚀 ЗАМЕНИТЬ SHOVEL НА ПИТОМЦА!"
            replaceBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
        end)
    end)
    
    print("🖥️ Ultimate Shovel Replacer GUI создан!")
end

-- === ЗАПУСК ===

createGUI()
print("=" .. string.rep("=", 50))
print("💡 ПРОСТАЯ ИНСТРУКЦИЯ:")
print("   1. Получите питомца из яйца (он появится в Visuals)")
print("   2. Возьмите Shovel в руки")
print("   3. Нажмите зеленую кнопку в GUI")
print("   4. Shovel заменится на живого питомца!")
print("🎯 Анимация копируется с питомца в Visuals!")
print("=" .. string.rep("=", 50))
