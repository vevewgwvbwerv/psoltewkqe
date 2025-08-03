-- PetScaler v2.5 - НЕЗАВИСИМАЯ КОПИЯ С ТОЛЬКО IDLE АНИМАЦИЕЙ
-- Создает полностью независимую копию питомца которая ТОЛЬКО в idle анимации

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

print("🔥 === PET SCALER v2.5 - НЕЗАВИСИМАЯ КОПИЯ С IDLE ===")
print("=" .. string.rep("=", 70))

-- Конфигурация для независимой копии
local CONFIG = {
    SCALE_FACTOR = 1.0,  -- Оригинальный размер (не увеличиваем)
    TWEEN_TIME = 3,      -- Время масштабирования
    SEARCH_RADIUS = 50,  -- Радиус поиска питомца
    IDLE_RECORD_TIME = 3, -- Время записи idle поз
    IDLE_FPS = 60        -- FPS записи idle
}

-- === БАЗОВЫЕ ФУНКЦИИ ===

-- Получение всех частей модели
local function getAllParts(model)
    local parts = {}
    for _, obj in pairs(model:GetDescendants()) do
        if obj:IsA("BasePart") then
            table.insert(parts, obj)
        end
    end
    return parts
end

-- Получение всех Motor6D
local function getMotor6Ds(model)
    local motors = {}
    for _, obj in pairs(model:GetDescendants()) do
        if obj:IsA("Motor6D") then
            table.insert(motors, obj)
        end
    end
    return motors
end

-- Глубокое копирование модели
local function deepCopyModel(original)
    if not original then
        print("❌ Оригинальная модель не найдена!")
        return nil
    end
    
    print("📋 Создание глубокой копии модели...")
    
    local success, copy = pcall(function()
        return original:Clone()
    end)
    
    if not success or not copy then
        print("❌ Ошибка при копировании модели!")
        return nil
    end
    
    -- Позиционирование копии рядом с оригиналом
    local originalCFrame = original:GetModelCFrame()
    local offset = Vector3.new(10, 0, 0) -- Смещение на 10 стадов вправо
    
    copy:SetPrimaryPartCFrame(originalCFrame + offset)
    copy.Parent = Workspace
    copy.Name = original.Name .. "_IndependentCopy"
    
    print("✅ Копия создана:", copy.Name)
    return copy
end

-- Умное управление Anchored состояниями
local function smartAnchoredManagement(parts)
    print("🧠 Настройка Anchored состояний для анимации...")
    
    local rootPart = nil
    
    -- Находим главную часть (HumanoidRootPart или Torso)
    for _, part in pairs(parts) do
        if part.Name == "HumanoidRootPart" or part.Name == "Torso" then
            rootPart = part
            break
        end
    end
    
    -- Настраиваем Anchored состояния
    for _, part in pairs(parts) do
        if part == rootPart then
            part.Anchored = true  -- Только главная часть закреплена
            print("⚓ Главная часть закреплена:", part.Name)
        else
            part.Anchored = false -- Остальные части свободны для анимации
        end
    end
    
    print("✅ Anchored состояния настроены для", #parts, "частей")
    return rootPart
end

-- === ФУНКЦИИ ДЛЯ НЕЗАВИСИМОЙ IDLE АНИМАЦИИ ===

-- Функция проверки магического idle момента
local function isMagicalIdleMoment(petModel)
    if not petModel or not petModel.Parent then
        return false
    end
    
    -- Проверяем что питомец стоит на месте
    local rootPart = petModel:FindFirstChild("HumanoidRootPart") or petModel:FindFirstChild("Torso")
    if not rootPart then
        return false
    end
    
    -- Проверяем скорость - должна быть близка к нулю
    local velocity = rootPart.AssemblyLinearVelocity
    if velocity.Magnitude > 0.5 then
        return false
    end
    
    -- Проверяем что есть Humanoid и он не движется
    local humanoid = petModel:FindFirstChildOfClass("Humanoid")
    if humanoid and humanoid.MoveDirection.Magnitude > 0.1 then
        return false
    end
    
    return true
end

-- Функция записи idle поз
local function recordIdlePoses(petModel)
    print("📸 Запись idle поз Motor6D...")
    
    local motors = getMotor6Ds(petModel)
    if #motors == 0 then
        print("❌ Motor6D не найдены для записи!")
        return nil, nil
    end
    
    local idlePoses = {}
    
    -- Записываем текущие позы всех Motor6D
    for _, motor in pairs(motors) do
        if motor and motor.Parent then
            idlePoses[motor.Name] = {
                C0 = motor.C0,
                C1 = motor.C1,
                Transform = motor.Transform
            }
        end
    end
    
    print("✅ Записано idle поз:", #motors)
    return idlePoses, motors
end

-- Функция создания независимой idle анимации
local function createIndependentIdleAnimation(copyModel, idlePoses, originalMotors)
    print("🎭 Создание независимой idle анимации...")
    
    if not idlePoses or not originalMotors then
        print("❌ Нет данных idle поз!")
        return nil
    end
    
    local copyMotors = getMotor6Ds(copyModel)
    if #copyMotors == 0 then
        print("❌ Motor6D не найдены в копии!")
        return nil
    end
    
    print("🔧 Найдено Motor6D в копии:", #copyMotors)
    
    -- КРИТИЧНО: Отключаем все анимационные системы копии
    for _, obj in pairs(copyModel:GetDescendants()) do
        if obj:IsA("Humanoid") then
            obj:Destroy()  -- Удаляем Humanoid - никакой AI!
            print("💀 Humanoid удален из копии - никакой AI!")
        end
        if obj:IsA("Animator") then
            obj:Destroy()  -- Удаляем Animator - никаких анимаций!
            print("🎬 Animator удален из копии - никаких анимаций!")
        end
        if obj:IsA("AnimationController") then
            obj:Destroy()  -- Удаляем AnimationController
            print("🎮 AnimationController удален из копии!")
        end
    end
    
    -- Применяем idle позы к копии
    local appliedCount = 0
    for _, motor in pairs(copyMotors) do
        if motor and motor.Parent and idlePoses[motor.Name] then
            local pose = idlePoses[motor.Name]
            motor.C0 = pose.C0
            motor.C1 = pose.C1
            if pose.Transform then
                motor.Transform = pose.Transform
            end
            appliedCount = appliedCount + 1
        end
    end
    
    print("✅ Применено idle поз:", appliedCount)
    
    -- Запускаем постоянное применение idle поз (зацикливание)
    local idleConnection = RunService.Heartbeat:Connect(function()
        for _, motor in pairs(copyMotors) do
            if motor and motor.Parent and idlePoses[motor.Name] then
                local pose = idlePoses[motor.Name]
                motor.C0 = pose.C0
                motor.C1 = pose.C1
                if pose.Transform then
                    motor.Transform = pose.Transform
                end
            end
        end
    end)
    
    print("🔄 Независимая idle анимация запущена!")
    return idleConnection
end

-- Поиск питомца с фигурными скобками
local function findPetWithBraces()
    print("🔍 Поиск питомцев с фигурными скобками...")
    
    local foundPets = {}
    
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and obj.Name:find("%{") and obj.Name:find("%}") then
            table.insert(foundPets, obj)
        end
    end
    
    if #foundPets == 0 then
        print("❌ Питомцы не найдены!")
        return nil
    end
    
    local targetPet = foundPets[1]
    print("🎯 Выбран питомец:", targetPet.Name)
    
    return targetPet
end

-- === ГЛАВНАЯ ФУНКЦИЯ ===

local function main()
    print("\n🚀 === ЗАПУСК PETSCALER v2.5 - НЕЗАВИСИМАЯ КОПИЯ ===")
    
    -- Шаг 1: Поиск питомца с фигурными скобками
    print("\n🔍 === ПОИСК ПИТОМЦА ===")
    
    local petModel = findPetWithBraces()
    if not petModel then
        print("❌ Питомец не найден!")
        return
    end
    
    -- Шаг 2: Автоматический поиск idle момента
    print("\n🌟 === ПОИСК IDLE МОМЕНТА ===")
    print("💡 Дождись когда питомец встанет в idle позу...")
    
    -- Используем простой подход без Promise
    local idleData = nil
    local searchStartTime = tick()
    local lastCheckTime = 0
    
    local searchConnection
    searchConnection = RunService.Heartbeat:Connect(function()
        local now = tick()
        
        if now - lastCheckTime >= 0.1 then
            lastCheckTime = now
            
            if isMagicalIdleMoment(petModel) then
                print("🌟 МАГИЧЕСКИЙ IDLE МОМЕНТ НАЙДЕН!")
                searchConnection:Disconnect()
                
                local idlePoses, motors = recordIdlePoses(petModel)
                if idlePoses then
                    idleData = {poses = idlePoses, motors = motors}
                end
                return
            end
            
            -- Показываем прогресс каждые 10 секунд
            if math.floor(now - searchStartTime) % 10 == 0 and (now - searchStartTime) % 10 < 0.1 then
                print(string.format("🔍 Поиск idle момента... %.0f сек", now - searchStartTime))
            end
            
            if now - searchStartTime >= 60 then
                searchConnection:Disconnect()
                print("⏰ Время поиска idle момента истекло!")
                return
            end
        end
    end)
    
    -- Ждем результат поиска
    while not idleData and searchConnection.Connected do
        wait(0.1)
    end
    
    if not idleData then
        print("❌ Не удалось найти idle момент!")
        print("💡 Попробуй еще раз когда питомец будет стоять спокойно")
        return
    end
    
    -- Шаг 3: Создание независимой копии
    print("\n📋 === СОЗДАНИЕ НЕЗАВИСИМОЙ КОПИИ ===")
    local petCopy = deepCopyModel(petModel)
    
    if not petCopy then
        print("❌ Не удалось создать копию!")
        return
    end
    
    -- Шаг 4: Настройка Anchored для анимации
    print("\n🧠 === НАСТРОЙКА ANCHORED ДЛЯ АНИМАЦИИ ===")
    local copyParts = getAllParts(petCopy)
    local rootPart = smartAnchoredManagement(copyParts)
    
    -- Шаг 5: Запуск независимой idle анимации
    print("\n🎭 === ЗАПУСК НЕЗАВИСИМОЙ IDLE АНИМАЦИИ ===")
    
    local idleConnection = createIndependentIdleAnimation(petCopy, idleData.poses, idleData.motors)
    
    if idleConnection then
        print("🎉 === УСПЕХ! ===")
        print("✅ Независимая копия создана")
        print("✅ Только idle анимация запущена")
        print("🚫 Копия НЕ копирует движения оригинала")
        print("💀 Humanoid удален - копия полностью независима")
        print("🔄 Копия будет ТОЛЬКО в idle - никакой ходьбы!")
        
        -- Автоматическая остановка через 5 минут
        spawn(function()
            wait(300)
            idleConnection:Disconnect()
            print("⏹️ Независимая idle анимация остановлена через 5 минут")
        end)
    else
        print("⚠️ Копия создана, но idle анимация не запустилась")
        print("💡 Возможно проблема с Motor6D или idle позами")
    end
end

-- === GUI ===

local function createGUI()
    local playerGui = player:WaitForChild("PlayerGui")
    
    -- Удаляем старое GUI если есть
    local oldGui = playerGui:FindFirstChild("PetScalerV25GUI")
    if oldGui then
        oldGui:Destroy()
    end
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "PetScalerV25GUI"
    screenGui.Parent = playerGui
    
    local frame = Instance.new("Frame")
    frame.Name = "MainFrame"
    frame.Size = UDim2.new(0, 280, 0, 80)
    frame.Position = UDim2.new(0, 50, 0, 150)
    frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    frame.BorderSizePixel = 2
    frame.BorderColor3 = Color3.fromRGB(0, 255, 255) -- Циановая рамка
    frame.Parent = screenGui
    
    local button = Instance.new("TextButton")
    button.Name = "IndependentIdleButton"
    button.Size = UDim2.new(0, 260, 0, 40)
    button.Position = UDim2.new(0, 10, 0, 20)
    button.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
    button.BorderSizePixel = 0
    button.Text = "🎭 PetScaler v2.5 - Независимая IDLE"
    button.TextColor3 = Color3.fromRGB(0, 0, 0)
    button.TextSize = 13
    button.Font = Enum.Font.SourceSansBold
    button.Parent = frame
    
    button.MouseButton1Click:Connect(function()
        button.Text = "⏳ Ищу idle момент..."
        button.BackgroundColor3 = Color3.fromRGB(255, 165, 0)
        
        spawn(function()
            main()
            
            wait(3)
            button.Text = "🎭 PetScaler v2.5 - Независимая IDLE"
            button.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
        end)
    end)
    
    button.MouseEnter:Connect(function()
        if button.BackgroundColor3 == Color3.fromRGB(0, 255, 255) then
            button.BackgroundColor3 = Color3.fromRGB(0, 220, 220)
        end
    end)
    
    button.MouseLeave:Connect(function()
        if button.BackgroundColor3 == Color3.fromRGB(0, 220, 220) then
            button.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
        end
    end)
    
    print("🖥️ PetScaler v2.5 GUI создан!")
end

-- Запуск
createGUI()

print("=" .. string.rep("=", 70))
print("💡 PETSCALER v2.5 - НЕЗАВИСИМАЯ КОПИЯ С IDLE:")
print("   1. Автоматически ищет idle момент оригинала")
print("   2. Записывает только idle позы Motor6D")
print("   3. Создает независимую копию (без Humanoid)")
print("   4. Копия ТОЛЬКО в idle - никакой ходьбы!")
print("   5. НЕ копирует движения оригинала")
print("🎯 Нажмите циановую кнопку для запуска!")
print("=" .. string.rep("=", 70))
