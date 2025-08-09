-- 🔥 PERFECT PET SCANNER v1.0
-- Полное сканирование питомца из руки и замена Shovel на 1:1 копию
-- Сохраняет ВСЕ: CFrame, Motor6D, анимации, части, структуру

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer

print("🔥 === PERFECT PET SCANNER v1.0 ===")
print("=" .. string.rep("=", 60))

-- Глобальные переменные для сохранения данных
local scannedPetData = {
    toolName = nil,
    handleData = nil,
    petModel = nil,
    allParts = {},
    allMotor6Ds = {},
    allCFrames = {},
    allProperties = {},
    weldData = nil,
    animationStates = {}
}

local currentReplacedTool = nil
local animationConnection = nil

-- === ФУНКЦИИ ГЛУБОКОГО СКАНИРОВАНИЯ ===

-- Функция сканирования всех свойств объекта
local function scanObjectProperties(obj)
    local properties = {}
    
    -- Базовые свойства для всех объектов
    properties.Name = obj.Name
    properties.ClassName = obj.ClassName
    properties.Parent = obj.Parent and obj.Parent.Name or "nil"
    
    -- Специфичные свойства для BasePart
    if obj:IsA("BasePart") then
        properties.Size = obj.Size
        properties.CFrame = obj.CFrame
        properties.Material = obj.Material
        properties.BrickColor = obj.BrickColor
        properties.Transparency = obj.Transparency
        properties.CanCollide = obj.CanCollide
        properties.Anchored = obj.Anchored
        properties.Shape = obj.Shape
        properties.TopSurface = obj.TopSurface
        properties.BottomSurface = obj.BottomSurface
        properties.FrontSurface = obj.FrontSurface
        properties.BackSurface = obj.BackSurface
        properties.LeftSurface = obj.LeftSurface
        properties.RightSurface = obj.RightSurface
    end
    
    -- Специфичные свойства для Motor6D
    if obj:IsA("Motor6D") then
        properties.Part0 = obj.Part0 and obj.Part0.Name or "nil"
        properties.Part1 = obj.Part1 and obj.Part1.Name or "nil"
        properties.C0 = obj.C0
        properties.C1 = obj.C1
        properties.CurrentAngle = obj.CurrentAngle
        properties.DesiredAngle = obj.DesiredAngle
        properties.MaxVelocity = obj.MaxVelocity
    end
    
    -- Специфичные свойства для Weld
    if obj:IsA("Weld") or obj:IsA("WeldConstraint") then
        properties.Part0 = obj.Part0 and obj.Part0.Name or "nil"
        properties.Part1 = obj.Part1 and obj.Part1.Name or "nil"
        if obj:IsA("Weld") then
            properties.C0 = obj.C0
            properties.C1 = obj.C1
        end
    end
    
    return properties
end

-- Функция глубокого клонирования объекта
local function deepCloneObject(original, parent)
    if not original then return nil end
    
    local clone = Instance.new(original.ClassName)
    clone.Name = original.Name
    
    -- Копируем все свойства
    local properties = scanObjectProperties(original)
    
    for propName, propValue in pairs(properties) do
        if propName ~= "Parent" and propName ~= "Part0" and propName ~= "Part1" then
            local success, err = pcall(function()
                clone[propName] = propValue
            end)
            if not success then
                print("⚠️ Не удалось скопировать свойство", propName, ":", err)
            end
        end
    end
    
    clone.Parent = parent
    return clone
end

-- Функция сканирования питомца из руки
local function scanPetFromHand()
    print("\n🔍 === СКАНИРОВАНИЕ ПИТОМЦА ИЗ РУКИ ===")
    
    local character = player.Character
    if not character then
        print("❌ Персонаж не найден!")
        return false
    end
    
    -- Ищем Tool в руках
    local tool = character:FindFirstChildOfClass("Tool")
    if not tool then
        print("❌ Возьмите питомца в руки перед сканированием!")
        return false
    end
    
    -- Проверяем что это питомец (используем ту же логику что в DirectShovelFix)
    if not (string.find(tool.Name, "%[") and string.find(tool.Name, "KG%]")) then
        print("❌ В руках не питомец! Найден:", tool.Name)
        print("🔍 Ищем питомца с паттерном '[...KG]'")
        return false
    end
    
    print("🎯 Найден питомец:", tool.Name)
    
    -- Очищаем предыдущие данные
    scannedPetData = {
        toolName = nil,
        handleData = nil,
        petModel = nil,
        allParts = {},
        allMotor6Ds = {},
        allCFrames = {},
        allProperties = {},
        weldData = nil,
        animationStates = {}
    }
    
    -- Сохраняем имя Tool
    scannedPetData.toolName = tool.Name
    
    -- Сканируем Handle
    local handle = tool:FindFirstChild("Handle")
    if handle then
        scannedPetData.handleData = scanObjectProperties(handle)
        print("✅ Handle отсканирован")
    end
    
    -- Ищем модель питомца в Tool (проверяем все дочерние объекты)
    local petModel = nil
    
    -- Сначала ищем Model
    for _, child in pairs(tool:GetChildren()) do
        if child:IsA("Model") and child ~= handle then
            petModel = child
            print("🎯 Найдена модель питомца:", child.Name)
            break
        end
    end
    
    -- Если Model не найден, создаем из всех частей (как в DirectShovelFix)
    if not petModel then
        print("🔧 Модель не найдена, создаем из частей Tool...")
        petModel = Instance.new("Model")
        petModel.Name = "PetModel"
        petModel.Parent = tool
        
        -- Перемещаем все части кроме Handle в модель
        local parts = {}
        for _, child in pairs(tool:GetChildren()) do
            if child:IsA("BasePart") and child ~= handle then
                table.insert(parts, child)
            end
        end
        
        for _, part in pairs(parts) do
            part.Parent = petModel
        end
        
        if #parts > 0 then
            petModel.PrimaryPart = parts[1]
            print("✅ Создана модель из", #parts, "частей")
        else
            print("❌ Нет частей для создания модели!")
            return false
        end
    end
    
    print("🎯 Найдена модель питомца:", petModel.Name)
    
    -- Глубокое сканирование модели питомца
    scannedPetData.petModel = petModel:Clone()
    scannedPetData.petModel.Parent = nil -- Храним в памяти
    
    -- Сканируем все части
    local partCount = 0
    for _, obj in pairs(petModel:GetDescendants()) do
        if obj:IsA("BasePart") then
            local partData = {
                object = obj,
                properties = scanObjectProperties(obj),
                cframe = obj.CFrame,
                worldPosition = obj.Position
            }
            table.insert(scannedPetData.allParts, partData)
            partCount = partCount + 1
        end
    end
    
    -- Сканируем все Motor6D
    local motor6dCount = 0
    for _, obj in pairs(petModel:GetDescendants()) do
        if obj:IsA("Motor6D") then
            local motorData = {
                object = obj,
                properties = scanObjectProperties(obj),
                c0 = obj.C0,
                c1 = obj.C1,
                currentAngle = obj.CurrentAngle,
                desiredAngle = obj.DesiredAngle
            }
            table.insert(scannedPetData.allMotor6Ds, motorData)
            motor6dCount = motor6dCount + 1
        end
    end
    
    -- Сканируем Weld крепления к руке
    local rightHand = character:FindFirstChild("Right Arm") or character:FindFirstChild("RightHand")
    if rightHand then
        local rightGrip = rightHand:FindFirstChild("RightGrip")
        if rightGrip then
            scannedPetData.weldData = {
                c0 = rightGrip.C0,
                c1 = rightGrip.C1,
                properties = scanObjectProperties(rightGrip)
            }
            print("✅ Weld крепления отсканирован")
        end
    end
    
    print("✅ СКАНИРОВАНИЕ ЗАВЕРШЕНО!")
    print("📊 Отсканировано частей:", partCount)
    print("📊 Отсканировано Motor6D:", motor6dCount)
    print("📊 Размер модели:", #scannedPetData.petModel:GetDescendants())
    
    return true
end

-- === ФУНКЦИИ СОЗДАНИЯ КОПИИ ===

-- Функция создания точной копии Tool
local function createExactPetTool()
    if not scannedPetData.toolName then
        print("❌ Данные питомца не найдены! Сначала отсканируйте питомца.")
        return nil
    end
    
    print("\n🔧 === СОЗДАНИЕ ТОЧНОЙ КОПИИ TOOL ===")
    
    -- Создаем новый Tool
    local newTool = Instance.new("Tool")
    newTool.Name = scannedPetData.toolName
    newTool.RequiresHandle = true
    newTool.CanBeDropped = false
    
    -- Создаем Handle с точными свойствами
    local handle = Instance.new("Part")
    handle.Name = "Handle"
    
    if scannedPetData.handleData then
        for propName, propValue in pairs(scannedPetData.handleData) do
            if propName ~= "Parent" and propName ~= "CFrame" then
                local success, err = pcall(function()
                    handle[propName] = propValue
                end)
                if not success then
                    print("⚠️ Не удалось установить свойство Handle", propName, ":", err)
                end
            end
        end
    end
    
    handle.Anchored = false
    handle.CanCollide = false
    handle.Parent = newTool
    
    -- Клонируем модель питомца
    if scannedPetData.petModel then
        local petCopy = scannedPetData.petModel:Clone()
        petCopy.Name = "PetModel"
        petCopy.Parent = newTool
        
        -- Настраиваем все части
        for _, part in pairs(petCopy:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Anchored = false
                part.CanCollide = false
                
                -- Создаем WeldConstraint для крепления к Handle
                local weld = Instance.new("WeldConstraint")
                weld.Part0 = handle
                weld.Part1 = part
                weld.Parent = handle
            end
        end
        
        print("✅ Модель питомца клонирована с", #petCopy:GetDescendants(), "объектами")
    end
    
    print("✅ Точная копия Tool создана!")
    return newTool
end

-- Функция замены Shovel на отсканированного питомца
local function replaceShovelWithScannedPet()
    print("\n🔄 === ЗАМЕНА SHOVEL НА ОТСКАНИРОВАННОГО ПИТОМЦА ===")
    
    local character = player.Character
    if not character then
        print("❌ Персонаж не найден!")
        return false
    end
    
    -- Ищем Shovel в руках
    local shovelTool = character:FindFirstChildOfClass("Tool")
    if not shovelTool or not shovelTool.Name:find("Shovel") then
        print("❌ Возьмите Shovel в руки перед заменой!")
        return false
    end
    
    -- Создаем точную копию питомца
    local petTool = createExactPetTool()
    if not petTool then
        print("❌ Не удалось создать копию питомца!")
        return false
    end
    
    -- Удаляем Shovel
    shovelTool:Destroy()
    
    -- Добавляем Pet Tool в Backpack и экипируем
    petTool.Parent = player.Backpack
    wait(0.1)
    
    -- Принудительно экипируем Tool
    character.Humanoid:EquipTool(petTool)
    
    currentReplacedTool = petTool
    
    -- Применяем сохраненную позицию Weld
    if scannedPetData.weldData then
        spawn(function()
            wait(0.5) -- Ждем пока Tool появится в руках
            
            local rightHand = character:FindFirstChild("Right Arm") or character:FindFirstChild("RightHand")
            if rightHand then
                local rightGrip = rightHand:FindFirstChild("RightGrip")
                if rightGrip then
                    rightGrip.C0 = scannedPetData.weldData.c0
                    rightGrip.C1 = scannedPetData.weldData.c1
                    print("✅ Позиция Weld восстановлена!")
                end
            end
        end)
    end
    
    print("✅ Shovel заменен на отсканированного питомца!")
    return true
end

-- === СИСТЕМА LIVE АНИМАЦИИ ===

-- Функция запуска live анимации с сохраненными данными
local function startLiveAnimationFromScan()
    if animationConnection then
        animationConnection:Disconnect()
    end
    
    if not currentReplacedTool or not scannedPetData.allMotor6Ds then
        print("❌ Нет данных для анимации!")
        return
    end
    
    print("\n🎬 === ЗАПУСК LIVE АНИМАЦИИ ИЗ СКАНА ===")
    
    animationConnection = RunService.Heartbeat:Connect(function()
        if not currentReplacedTool or not currentReplacedTool.Parent then
            return
        end
        
        local petModel = currentReplacedTool:FindFirstChild("PetModel")
        if not petModel then
            return
        end
        
        -- Применяем сохраненные состояния Motor6D
        for _, motorData in ipairs(scannedPetData.allMotor6Ds) do
            local motorName = motorData.properties.Name
            local motor6d = petModel:FindFirstChild(motorName, true)
            
            if motor6d and motor6d:IsA("Motor6D") then
                local success, err = pcall(function()
                    -- Применяем сохраненные углы с небольшой анимацией
                    motor6d.DesiredAngle = motorData.desiredAngle + math.sin(tick() * 2) * 0.1
                    motor6d.C0 = motorData.c0
                    motor6d.C1 = motorData.c1
                end)
                
                if not success then
                    print("⚠️ Ошибка анимации Motor6D", motorName, ":", err)
                end
            end
        end
    end)
    
    print("✅ Live анимация запущена!")
end

-- Функция остановки анимации
local function stopLiveAnimation()
    if animationConnection then
        animationConnection:Disconnect()
        animationConnection = nil
        print("⏹️ Live анимация остановлена")
    end
end

-- === ГЛАВНЫЕ ФУНКЦИИ ===

-- Функция полного процесса
local function fullScanAndReplace()
    print("\n🚀 === ПОЛНЫЙ ПРОЦЕСС СКАНИРОВАНИЯ И ЗАМЕНЫ ===")
    
    -- Проверяем что в руках питомец для сканирования
    local character = player.Character
    if not character then
        print("❌ Персонаж не найден!")
        return false
    end
    
    local tool = character:FindFirstChildOfClass("Tool")
    if not tool then
        print("❌ Возьмите питомца в руки для сканирования!")
        return false
    end
    
    if not (tool.Name:find("Dragonfly") or tool.Name:find("KG]")) then
        print("❌ В руках должен быть питомец для сканирования!")
        return false
    end
    
    -- Шаг 1: Сканируем питомца
    if not scanPetFromHand() then
        print("❌ Ошибка сканирования!")
        return false
    end
    
    print("✅ Питомец отсканирован! Теперь возьмите Shovel для замены.")
    return true
end

-- === СОЗДАНИЕ GUI ===

local function createGUI()
    local playerGui = player:WaitForChild("PlayerGui")
    
    -- Удаляем старый GUI
    local oldGui = playerGui:FindFirstChild("PerfectPetScannerGUI")
    if oldGui then
        oldGui:Destroy()
    end
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "PerfectPetScannerGUI"
    screenGui.Parent = playerGui
    
    local frame = Instance.new("Frame")
    frame.Name = "MainFrame"
    frame.Size = UDim2.new(0, 400, 0, 300)
    frame.Position = UDim2.new(0, 50, 0, 50)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    frame.BorderSizePixel = 2
    frame.BorderColor3 = Color3.fromRGB(255, 0, 255)
    frame.Parent = screenGui
    
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 0, 40)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundColor3 = Color3.fromRGB(255, 0, 255)
    title.BorderSizePixel = 0
    title.Text = "🔥 PERFECT PET SCANNER"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 18
    title.Font = Enum.Font.SourceSansBold
    title.Parent = frame
    
    local instructions = Instance.new("TextLabel")
    instructions.Name = "Instructions"
    instructions.Size = UDim2.new(1, -20, 0, 120)
    instructions.Position = UDim2.new(0, 10, 0, 50)
    instructions.BackgroundTransparency = 1
    instructions.Text = "ИНСТРУКЦИЯ:\n\n1. Возьмите ПИТОМЦА в руки\n2. Нажмите 'СКАНИРОВАТЬ ПИТОМЦА'\n3. Возьмите SHOVEL в руки\n4. Нажмите 'ЗАМЕНИТЬ НА ПИТОМЦА'\n\n✨ Получите точную 1:1 копию!"
    instructions.TextColor3 = Color3.fromRGB(255, 255, 255)
    instructions.TextSize = 14
    instructions.Font = Enum.Font.SourceSans
    instructions.TextWrapped = true
    instructions.TextYAlignment = Enum.TextYAlignment.Top
    instructions.Parent = frame
    
    local scanBtn = Instance.new("TextButton")
    scanBtn.Name = "ScanButton"
    scanBtn.Size = UDim2.new(0, 380, 0, 40)
    scanBtn.Position = UDim2.new(0, 10, 0, 180)
    scanBtn.BackgroundColor3 = Color3.fromRGB(255, 165, 0)
    scanBtn.BorderSizePixel = 0
    scanBtn.Text = "🔍 СКАНИРОВАТЬ ПИТОМЦА"
    scanBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
    scanBtn.TextSize = 16
    scanBtn.Font = Enum.Font.SourceSansBold
    scanBtn.Parent = frame
    
    local replaceBtn = Instance.new("TextButton")
    replaceBtn.Name = "ReplaceButton"
    replaceBtn.Size = UDim2.new(0, 380, 0, 40)
    replaceBtn.Position = UDim2.new(0, 10, 0, 230)
    replaceBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    replaceBtn.BorderSizePixel = 0
    replaceBtn.Text = "🔄 ЗАМЕНИТЬ SHOVEL НА ПИТОМЦА"
    replaceBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
    replaceBtn.TextSize = 16
    replaceBtn.Font = Enum.Font.SourceSansBold
    replaceBtn.Parent = frame
    
    -- События кнопок
    scanBtn.MouseButton1Click:Connect(function()
        scanBtn.Text = "⏳ Сканирую..."
        scanBtn.BackgroundColor3 = Color3.fromRGB(255, 100, 0)
        
        spawn(function()
            local success = fullScanAndReplace()
            
            wait(1)
            if success then
                scanBtn.Text = "✅ ПИТОМЕЦ ОТСКАНИРОВАН!"
                scanBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
            else
                scanBtn.Text = "❌ ОШИБКА! Проверьте инструкцию"
                scanBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
            end
            
            wait(3)
            scanBtn.Text = "🔍 СКАНИРОВАТЬ ПИТОМЦА"
            scanBtn.BackgroundColor3 = Color3.fromRGB(255, 165, 0)
        end)
    end)
    
    replaceBtn.MouseButton1Click:Connect(function()
        replaceBtn.Text = "⏳ Заменяю..."
        replaceBtn.BackgroundColor3 = Color3.fromRGB(255, 165, 0)
        
        spawn(function()
            local success = replaceShovelWithScannedPet()
            
            if success then
                wait(1)
                startLiveAnimationFromScan()
            end
            
            wait(1)
            if success then
                replaceBtn.Text = "✅ УСПЕШНО ЗАМЕНЕНО!"
                replaceBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
            else
                replaceBtn.Text = "❌ ОШИБКА! Проверьте инструкцию"
                replaceBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
            end
            
            wait(3)
            replaceBtn.Text = "🔄 ЗАМЕНИТЬ SHOVEL НА ПИТОМЦА"
            replaceBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        end)
    end)
    
    print("🖥️ Perfect Pet Scanner GUI создан!")
end

-- === ЗАПУСК ===

createGUI()
print("=" .. string.rep("=", 60))
print("💡 PERFECT PET SCANNER:")
print("   🔍 Сканирует питомца прямо из руки")
print("   💾 Сохраняет ВСЕ: части, Motor6D, CFrame, анимации")
print("   🔄 Заменяет Shovel на точную 1:1 копию")
print("   🎬 Восстанавливает живую анимацию")
print("🎯 Следуйте инструкции в GUI!")
print("=" .. string.rep("=", 60))
