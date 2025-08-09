-- 🤏 DirectShovelFix v8 - АНИМАЦИЯ + ЗАКРЕПЛЕНИЕ В РУКЕ
-- Решает проблему: анимация работает, но питомец не в руке
-- Добавляет восстановление Handle и правильное закрепление в руке

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

print("🤏 === DirectShovelFix v8 - ANIMATION + HAND GRIP ===")

-- Глобальные переменные
local petTool = nil
local savedPetData = {}
local animationConnection = nil
local animatedTool = nil
local motor6DList = {}
local basePartList = {}
local savedGripData = nil

-- Поиск питомца в руках
local function findPetInHands()
    local character = player.Character
    if not character then return nil end
    
    for _, tool in pairs(character:GetChildren()) do
        if tool:IsA("Tool") and string.find(tool.Name, "%[") and string.find(tool.Name, "KG%]") then
            return tool
        end
    end
    return nil
end

-- Поиск инструмента для замены
local function findToolToReplace()
    local character = player.Character
    if not character then return nil end
    
    print("🔍 Поиск инструмента для замены...")
    
    local allTools = {}
    for _, tool in pairs(character:GetChildren()) do
        if tool:IsA("Tool") then
            table.insert(allTools, tool)
            print("   Найден инструмент: " .. tool.Name)
        end
    end
    
    if #allTools == 0 then
        print("❌ Инструменты в руках не найдены!")
        return nil
    end
    
    -- Ищем НЕ питомца
    for _, tool in pairs(allTools) do
        if not string.find(tool.Name, "%[") and not string.find(tool.Name, "KG%]") then
            print("✅ Найден инструмент для замены: " .. tool.Name)
            return tool
        end
    end
    
    -- Запасной вариант
    for _, tool in pairs(allTools) do
        if tool ~= petTool then
            print("⚠️ Используем любой доступный инструмент: " .. tool.Name)
            return tool
        end
    end
    
    print("❌ Подходящий инструмент для замены не найден")
    return nil
end

-- Сохранение данных питомца + GRIP данных
local function savePetWithGripData()
    print("\n💾 === СОХРАНЕНИЕ ПИТОМЦА + GRIP ДАННЫХ ===")
    
    petTool = findPetInHands()
    if not petTool then
        print("❌ Питомец в руках не найден!")
        return false
    end
    
    print("✅ Найден питомец: " .. petTool.Name)
    
    -- КРИТИЧЕСКИ ВАЖНО: Сохраняем данные о том, как питомец держится в руке
    local character = player.Character
    if character then
        local rightArm = character:FindFirstChild("Right Arm") or character:FindFirstChild("RightHand")
        if rightArm then
            local rightGrip = rightArm:FindFirstChild("RightGrip")
            if rightGrip then
                savedGripData = {
                    C0 = rightGrip.C0,
                    C1 = rightGrip.C1,
                    Part0Name = rightGrip.Part0 and rightGrip.Part0.Name or nil,
                    Part1Name = rightGrip.Part1 and rightGrip.Part1.Name or nil
                }
                print("🤏 Сохранены данные RightGrip!")
                print("   C0: " .. tostring(rightGrip.C0))
                print("   C1: " .. tostring(rightGrip.C1))
            else
                print("⚠️ RightGrip не найден")
            end
        end
    end
    
    -- Сохраняем базовые свойства
    savedPetData = {
        name = petTool.Name,
        requiresHandle = petTool.RequiresHandle,
        canBeDropped = petTool.CanBeDropped,
        manualActivationOnly = petTool.ManualActivationOnly,
        children = {},
        motor6DData = {},
        cframeData = {},
        handleData = nil
    }
    
    -- ВАЖНО: Сохраняем данные Handle
    local handle = petTool:FindFirstChild("Handle")
    if handle then
        savedPetData.handleData = {
            name = handle.Name,
            size = handle.Size,
            cframe = handle.CFrame,
            position = handle.Position,
            rotation = handle.Rotation,
            material = handle.Material,
            color = handle.Color
        }
        print("🎯 Сохранены данные Handle!")
    end
    
    -- Сохраняем все дочерние объекты
    for _, child in pairs(petTool:GetChildren()) do
        table.insert(savedPetData.children, child)
    end
    
    -- Сохраняем Motor6D и CFrame данные
    local function collectAllAnimationData(parent, path)
        path = path or ""
        for _, child in pairs(parent:GetChildren()) do
            if child:IsA("Motor6D") then
                local motorData = {
                    name = child.Name,
                    path = path,
                    part0Name = child.Part0 and child.Part0.Name or nil,
                    part1Name = child.Part1 and child.Part1.Name or nil,
                    originalC0 = child.C0,
                    originalC1 = child.C1
                }
                table.insert(savedPetData.motor6DData, motorData)
                print("🔧 Сохранен Motor6D: " .. child.Name)
            elseif child:IsA("BasePart") then
                local cframeData = {
                    name = child.Name,
                    path = path,
                    originalCFrame = child.CFrame,
                    originalPosition = child.Position
                }
                table.insert(savedPetData.cframeData, cframeData)
                print("📐 Сохранен CFrame: " .. child.Name)
            end
            collectAllAnimationData(child, path .. "/" .. child.Name)
        end
    end
    
    collectAllAnimationData(petTool)
    
    print("📊 Сохранено объектов: " .. #savedPetData.children)
    print("🔧 Сохранено Motor6D: " .. #savedPetData.motor6DData)
    print("📐 Сохранено CFrame: " .. #savedPetData.cframeData)
    
    return true
end

-- Восстановление правильного положения в руке
local function restoreHandGrip(tool)
    print("\n🤏 === ВОССТАНОВЛЕНИЕ ПОЛОЖЕНИЯ В РУКЕ ===")
    
    local character = player.Character
    if not character then
        print("❌ Персонаж не найден!")
        return false
    end
    
    local rightArm = character:FindFirstChild("Right Arm") or character:FindFirstChild("RightHand")
    if not rightArm then
        print("❌ Правая рука не найдена!")
        return false
    end
    
    local handle = tool:FindFirstChild("Handle")
    if not handle then
        print("❌ Handle не найден в инструменте!")
        return false
    end
    
    -- Ждем появления RightGrip
    local rightGrip = rightArm:FindFirstChild("RightGrip")
    local attempts = 0
    while not rightGrip and attempts < 10 do
        wait(0.1)
        rightGrip = rightArm:FindFirstChild("RightGrip")
        attempts = attempts + 1
    end
    
    if rightGrip and savedGripData then
        print("🤏 Восстанавливаю положение RightGrip...")
        rightGrip.C0 = savedGripData.C0
        rightGrip.C1 = savedGripData.C1
        print("✅ RightGrip восстановлен!")
    else
        print("⚠️ RightGrip не найден или данные не сохранены")
        
        -- Создаем стандартное положение для питомца в руке
        if rightGrip then
            rightGrip.C0 = CFrame.new(0, -1, -0.5) * CFrame.Angles(math.rad(-90), 0, 0)
            rightGrip.C1 = CFrame.new(0, 0, 0)
            print("🔧 Применено стандартное положение в руке")
        end
    end
    
    return true
end

-- Создание анимационного движка с правильным положением в руке
local function createAnimationEngineWithGrip(tool)
    print("\n🎮 === АНИМАЦИОННЫЙ ДВИЖОК + ПОЛОЖЕНИЕ В РУКЕ ===")
    
    -- Останавливаем предыдущую анимацию
    if animationConnection then
        animationConnection:Disconnect()
        animationConnection = nil
    end
    
    motor6DList = {}
    basePartList = {}
    
    -- Собираем компоненты для анимации
    local function collectComponents(parent)
        for _, child in pairs(parent:GetChildren()) do
            if child:IsA("Motor6D") then
                table.insert(motor6DList, child)
            elseif child:IsA("BasePart") and child.Name ~= "Handle" then -- НЕ анимируем Handle!
                table.insert(basePartList, child)
            end
            collectComponents(child)
        end
    end
    
    collectComponents(tool)
    
    print("✅ Найдено для анимации:")
    print("   🔧 Motor6D: " .. #motor6DList)
    print("   📐 BasePart: " .. #basePartList)
    
    -- СНАЧАЛА восстанавливаем положение в руке
    restoreHandGrip(tool)
    
    wait(0.2) -- Даем время на закрепление
    
    -- Запускаем анимацию (БЕЗ Handle - он должен оставаться в руке!)
    local startTime = tick()
    animatedTool = tool
    
    animationConnection = RunService.Heartbeat:Connect(function()
        local currentTime = tick() - startTime
        
        -- Анимируем только Motor6D (НЕ Handle!)
        for i, motor6D in pairs(motor6DList) do
            if motor6D and motor6D.Parent then
                local savedMotor = nil
                for _, savedData in pairs(savedPetData.motor6DData) do
                    if savedData.name == motor6D.Name then
                        savedMotor = savedData
                        break
                    end
                end
                
                if savedMotor then
                    local wave1 = math.sin(currentTime * 2 + i) * 0.1
                    local wave2 = math.cos(currentTime * 1.5 + i) * 0.08
                    
                    local newC0 = savedMotor.originalC0 * CFrame.Angles(wave1, wave2, wave1 * 0.5)
                    motor6D.C0 = newC0
                    
                    local newC1 = savedMotor.originalC1 * CFrame.Angles(wave2 * 0.5, wave1 * 0.3, wave2)
                    motor6D.C1 = newC1
                end
            end
        end
        
        -- Анимируем BasePart (кроме Handle!)
        for i, basePart in pairs(basePartList) do
            if basePart and basePart.Parent and basePart.Name ~= "Handle" then
                local savedCFrame = nil
                for _, savedData in pairs(savedPetData.cframeData) do
                    if savedData.name == basePart.Name then
                        savedCFrame = savedData
                        break
                    end
                end
                
                if savedCFrame then
                    -- Легкая анимация относительно сохраненной позиции
                    local wave3 = math.sin(currentTime * 1.8 + i) * 0.05
                    local wave4 = math.cos(currentTime * 2.2 + i) * 0.03
                    
                    local animatedCFrame = savedCFrame.originalCFrame * CFrame.Angles(wave3, wave4, wave3 * 0.5)
                    basePart.CFrame = animatedCFrame
                end
            end
        end
    end)
    
    print("✅ Анимационный движок запущен!")
    print("🤏 Питомец должен быть в руке с анимацией!")
    
    return true
end

-- Основная функция замены с закреплением в руке
local function replaceWithHandGrip()
    print("\n🔄 === ЗАМЕНА С ЗАКРЕПЛЕНИЕМ В РУКЕ ===")
    
    if not petTool or #savedPetData.children == 0 then
        print("❌ Сначала сохраните данные питомца!")
        return false
    end
    
    local toolToReplace = findToolToReplace()
    if not toolToReplace then
        print("❌ Инструмент для замены не найден!")
        return false
    end
    
    print("✅ Заменяем: " .. toolToReplace.Name)
    
    -- Шаг 1: Меняем свойства Tool
    toolToReplace.Name = savedPetData.name
    toolToReplace.RequiresHandle = savedPetData.requiresHandle
    toolToReplace.CanBeDropped = savedPetData.canBeDropped
    toolToReplace.ManualActivationOnly = savedPetData.manualActivationOnly
    print("📝 Свойства Tool обновлены")
    
    -- Шаг 2: Очищаем содержимое
    for _, child in pairs(toolToReplace:GetChildren()) do
        child:Destroy()
    end
    wait(0.1)
    print("🗑️ Содержимое очищено")
    
    -- Шаг 3: Копируем все содержимое питомца
    for _, child in pairs(savedPetData.children) do
        if child and child.Parent then
            local copy = child:Clone()
            copy.Parent = toolToReplace
            print("📋 Скопировано: " .. child.Name .. " (" .. child.ClassName .. ")")
        end
    end
    
    wait(0.2) -- Даем время на инициализацию
    
    -- Шаг 4: КРИТИЧЕСКИ ВАЖНО - Восстанавливаем Handle данные
    local newHandle = toolToReplace:FindFirstChild("Handle")
    if newHandle and savedPetData.handleData then
        print("🎯 Восстанавливаю данные Handle...")
        newHandle.Size = savedPetData.handleData.size
        newHandle.Material = savedPetData.handleData.material
        newHandle.Color = savedPetData.handleData.color
        print("✅ Handle данные восстановлены!")
    end
    
    -- Шаг 5: Переэкипировка для правильного закрепления
    print("🔄 Переэкипировка для закрепления в руке...")
    toolToReplace.Parent = player.Backpack
    wait(0.2)
    toolToReplace.Parent = player.Character
    wait(0.3)
    
    -- Шаг 6: Запускаем анимационный движок с закреплением в руке
    print("\n🎮 === ЗАПУСК АНИМАЦИИ В РУКЕ ===")
    local success = createAnimationEngineWithGrip(toolToReplace)
    
    if success then
        print("✅ УСПЕХ! Питомец анимируется в руке!")
        print("🤏 Проверьте - питомец должен быть в правой руке с анимацией!")
    else
        print("⚠️ Проблемы с анимацией в руке")
    end
    
    return true
end

-- Остановка анимации
local function stopAnimation()
    if animationConnection then
        animationConnection:Disconnect()
        animationConnection = nil
        print("🛑 Анимационный движок остановлен")
    end
end

-- Создание GUI
local function createGUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "DirectShovelFixV8"
    screenGui.Parent = player:WaitForChild("PlayerGui")
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 500, 0, 280)
    frame.Position = UDim2.new(0.5, -250, 0.5, -140)
    frame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
    frame.BorderSizePixel = 0
    frame.Parent = screenGui
    
    -- Заголовок
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundTransparency = 1
    title.Text = "🤏 DirectShovelFix v8 - Animation + Hand Grip"
    title.TextColor3 = Color3.new(1, 1, 1)
    title.TextScaled = true
    title.Font = Enum.Font.GothamBold
    title.Parent = frame
    
    -- Кнопка сохранения
    local saveBtn = Instance.new("TextButton")
    saveBtn.Size = UDim2.new(0.45, 0, 0, 50)
    saveBtn.Position = UDim2.new(0.025, 0, 0, 50)
    saveBtn.BackgroundColor3 = Color3.new(0.2, 0.6, 0.2)
    saveBtn.Text = "💾 СОХРАНИТЬ\n+ GRIP ДАННЫЕ"
    saveBtn.TextColor3 = Color3.new(1, 1, 1)
    saveBtn.TextScaled = true
    saveBtn.Font = Enum.Font.Gotham
    saveBtn.Parent = frame
    
    -- Кнопка замены
    local replaceBtn = Instance.new("TextButton")
    replaceBtn.Size = UDim2.new(0.45, 0, 0, 50)
    replaceBtn.Position = UDim2.new(0.525, 0, 0, 50)
    replaceBtn.BackgroundColor3 = Color3.new(0.8, 0.2, 0.2)
    replaceBtn.Text = "🤏 ЗАМЕНИТЬ\n+ В РУКЕ"
    replaceBtn.TextColor3 = Color3.new(1, 1, 1)
    replaceBtn.TextScaled = true
    replaceBtn.Font = Enum.Font.Gotham
    replaceBtn.Parent = frame
    
    -- Кнопка остановки
    local stopBtn = Instance.new("TextButton")
    stopBtn.Size = UDim2.new(0.45, 0, 0, 30)
    stopBtn.Position = UDim2.new(0.025, 0, 0, 110)
    stopBtn.BackgroundColor3 = Color3.new(0.6, 0.3, 0.1)
    stopBtn.Text = "🛑 ОСТАНОВИТЬ АНИМАЦИЮ"
    stopBtn.TextColor3 = Color3.new(1, 1, 1)
    stopBtn.TextScaled = true
    stopBtn.Font = Enum.Font.Gotham
    stopBtn.Parent = frame
    
    -- Информационная панель
    local infoLabel = Instance.new("TextLabel")
    infoLabel.Size = UDim2.new(0.95, 0, 0, 100)
    infoLabel.Position = UDim2.new(0.025, 0, 0, 150)
    infoLabel.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
    infoLabel.Text = "РЕШЕНИЕ ПРОБЛЕМЫ: Анимация + Закрепление в руке!\n\n1. Возьмите питомца в руки → СОХРАНИТЬ + GRIP\n2. Возьмите любой инструмент → ЗАМЕНИТЬ + В РУКЕ\n3. Питомец будет анимироваться В РУКЕ!"
    infoLabel.TextColor3 = Color3.new(1, 1, 1)
    infoLabel.TextScaled = true
    infoLabel.Font = Enum.Font.Gotham
    infoLabel.Parent = frame
    
    -- Кнопка закрытия
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0.45, 0, 0, 20)
    closeBtn.Position = UDim2.new(0.525, 0, 0, 255)
    closeBtn.BackgroundColor3 = Color3.new(0.6, 0.1, 0.1)
    closeBtn.Text = "❌ ЗАКРЫТЬ"
    closeBtn.TextColor3 = Color3.new(1, 1, 1)
    closeBtn.TextScaled = true
    closeBtn.Font = Enum.Font.Gotham
    closeBtn.Parent = frame
    
    -- Обработчики событий
    saveBtn.MouseButton1Click:Connect(savePetWithGripData)
    replaceBtn.MouseButton1Click:Connect(replaceWithHandGrip)
    stopBtn.MouseButton1Click:Connect(stopAnimation)
    closeBtn.MouseButton1Click:Connect(function()
        stopAnimation()
        screenGui:Destroy()
    end)
    
    print("🎮 GUI создан! Новое решение: анимация + закрепление в руке!")
end

-- Запуск
createGUI()
