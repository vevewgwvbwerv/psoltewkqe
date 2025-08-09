-- 🎮 DirectShovelFix v7 - СОБСТВЕННЫЙ АНИМАЦИОННЫЙ ДВИЖОК
-- Поскольку LocalScript не перезапускается, создаем свой движок анимации
-- Управляем Motor6D напрямую через RunService

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer

print("🎮 === DirectShovelFix v7 - CUSTOM ANIMATION ENGINE ===")

-- Глобальные переменные
local petTool = nil
local savedPetData = {}
local animationConnection = nil
local animatedTool = nil
local motor6DList = {}

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

-- Поиск инструмента для замены (УЛУЧШЕННЫЙ)
local function findToolToReplace()
    local character = player.Character
    if not character then return nil end
    
    print("🔍 Поиск инструмента для замены...")
    
    -- Сначала ищем все инструменты
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
    
    -- Ищем НЕ питомца (без [KG])
    for _, tool in pairs(allTools) do
        if not string.find(tool.Name, "%[") and not string.find(tool.Name, "KG%]") then
            print("✅ Найден инструмент для замены: " .. tool.Name)
            return tool
        end
    end
    
    -- Если не нашли, берем ЛЮБОЙ инструмент кроме сохраненного питомца
    for _, tool in pairs(allTools) do
        if tool ~= petTool then
            print("⚠️ Используем любой доступный инструмент: " .. tool.Name)
            return tool
        end
    end
    
    print("❌ Подходящий инструмент для замены не найден")
    return nil
end

-- Сохранение данных питомца с Motor6D
local function savePetWithMotor6D()
    print("\n💾 === СОХРАНЕНИЕ ПИТОМЦА + MOTOR6D ===")
    
    petTool = findPetInHands()
    if not petTool then
        print("❌ Питомец в руках не найден!")
        return false
    end
    
    print("✅ Найден питомец: " .. petTool.Name)
    
    -- Сохраняем базовые свойства
    savedPetData = {
        name = petTool.Name,
        requiresHandle = petTool.RequiresHandle,
        canBeDropped = petTool.CanBeDropped,
        manualActivationOnly = petTool.ManualActivationOnly,
        children = {},
        motor6DData = {}
    }
    
    -- Сохраняем все дочерние объекты
    for _, child in pairs(petTool:GetChildren()) do
        table.insert(savedPetData.children, child)
    end
    
    -- Сохраняем данные Motor6D И CFrame для анимации
    savedPetData.cframeData = {}
    
    local function collectMotor6DAndCFrame(parent, path)
        path = path or ""
        for _, child in pairs(parent:GetChildren()) do
            -- Сохраняем Motor6D
            if child:IsA("Motor6D") then
                local motorData = {
                    name = child.Name,
                    path = path,
                    part0Name = child.Part0 and child.Part0.Name or nil,
                    part1Name = child.Part1 and child.Part1.Name or nil,
                    originalC0 = child.C0,
                    originalC1 = child.C1,
                    currentC0 = child.C0,
                    currentC1 = child.C1
                }
                table.insert(savedPetData.motor6DData, motorData)
                print("🔧 Сохранен Motor6D: " .. child.Name)
            end
            
            -- Сохраняем CFrame всех BasePart (КЛЮЧЕВЫЕ АНИМАЦИОННЫЕ ДАННЫЕ!)
            if child:IsA("BasePart") then
                local cframeData = {
                    name = child.Name,
                    path = path,
                    originalCFrame = child.CFrame,
                    originalPosition = child.Position,
                    originalRotation = child.Rotation,
                    currentCFrame = child.CFrame
                }
                table.insert(savedPetData.cframeData, cframeData)
                print("📐 Сохранен CFrame: " .. child.Name)
            end
            
            collectMotor6DAndCFrame(child, path .. "/" .. child.Name)
        end
    end
    
    collectMotor6DAndCFrame(petTool)
    
    print("📊 Сохранено объектов: " .. #savedPetData.children)
    print("🔧 Сохранено Motor6D: " .. #savedPetData.motor6DData)
    print("📐 Сохранено CFrame: " .. #savedPetData.cframeData)
    
    return true
end

-- Создание собственного анимационного движка
local function createCustomAnimationEngine(tool)
    print("\n🎮 === СОЗДАНИЕ СОБСТВЕННОГО АНИМАЦИОННОГО ДВИЖКА ===")
    
    -- Останавливаем предыдущую анимацию
    if animationConnection then
        animationConnection:Disconnect()
        animationConnection = nil
    end
    
    motor6DList = {}
    
    -- Собираем все Motor6D и BasePart из нового инструмента
    local basePartList = {}
    
    local function collectNewComponents(parent)
        for _, child in pairs(parent:GetChildren()) do
            if child:IsA("Motor6D") then
                table.insert(motor6DList, child)
                print("🔧 Найден Motor6D для анимации: " .. child.Name)
            elseif child:IsA("BasePart") then
                table.insert(basePartList, child)
                print("📐 Найден BasePart для анимации: " .. child.Name)
            end
            collectNewComponents(child)
        end
    end
    
    collectNewComponents(tool)
    
    if #motor6DList == 0 then
        print("❌ Motor6D не найдены для анимации!")
        return false
    end
    
    print("✅ Найдено Motor6D для анимации: " .. #motor6DList)
    
    -- Создаем анимационный цикл
    local startTime = tick()
    animatedTool = tool
    
    animationConnection = RunService.Heartbeat:Connect(function()
        local currentTime = tick() - startTime
        
        -- КОМПЛЕКСНАЯ АНИМАЦИЯ: Motor6D + CFrame
        
        -- Анимация Motor6D
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
                    local wave1 = math.sin(currentTime * 2 + i) * 0.15
                    local wave2 = math.cos(currentTime * 1.5 + i) * 0.1
                    
                    local newC0 = savedMotor.originalC0 * CFrame.Angles(wave1, wave2, wave1 * 0.5)
                    motor6D.C0 = newC0
                    
                    local newC1 = savedMotor.originalC1 * CFrame.Angles(wave2 * 0.5, wave1 * 0.3, wave2)
                    motor6D.C1 = newC1
                end
            end
        end
        
        -- АНИМАЦИЯ CFRAME (КЛЮЧЕВАЯ ЧАСТЬ!)
        for i, basePart in pairs(basePartList) do
            if basePart and basePart.Parent then
                local savedCFrame = nil
                for _, savedData in pairs(savedPetData.cframeData) do
                    if savedData.name == basePart.Name then
                        savedCFrame = savedData
                        break
                    end
                end
                
                if savedCFrame then
                    -- Создаем плавную анимацию CFrame
                    local wave3 = math.sin(currentTime * 1.8 + i) * 0.2
                    local wave4 = math.cos(currentTime * 2.2 + i) * 0.15
                    
                    -- Применяем анимацию к CFrame
                    local animatedCFrame = savedCFrame.originalCFrame * CFrame.Angles(wave3 * 0.1, wave4 * 0.1, wave3 * 0.05)
                    animatedCFrame = animatedCFrame + Vector3.new(0, math.sin(currentTime * 3 + i) * 0.02, 0)
                    
                    basePart.CFrame = animatedCFrame
                end
            end
        end
    end)
    
    print("✅ Анимационный движок запущен!")
    print("🎮 Питомец должен анимироваться!")
    
    return true
end

-- Основная функция замены с собственной анимацией
local function replaceWithCustomAnimation()
    print("\n🔄 === ЗАМЕНА С СОБСТВЕННОЙ АНИМАЦИЕЙ ===")
    
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
    
    -- Шаг 1: Меняем свойства
    toolToReplace.Name = savedPetData.name
    toolToReplace.RequiresHandle = savedPetData.requiresHandle
    toolToReplace.CanBeDropped = savedPetData.canBeDropped
    toolToReplace.ManualActivationOnly = savedPetData.manualActivationOnly
    print("📝 Свойства обновлены")
    
    -- Шаг 2: Очищаем содержимое
    for _, child in pairs(toolToReplace:GetChildren()) do
        child:Destroy()
    end
    wait(0.1)
    print("🗑️ Содержимое очищено")
    
    -- Шаг 3: Копируем все содержимое
    for _, child in pairs(savedPetData.children) do
        if child and child.Parent then
            local copy = child:Clone()
            copy.Parent = toolToReplace
            print("📋 Скопировано: " .. child.Name .. " (" .. child.ClassName .. ")")
        end
    end
    
    wait(0.3) -- Даем время на инициализацию
    
    -- Шаг 4: ЗАПУСКАЕМ СОБСТВЕННЫЙ АНИМАЦИОННЫЙ ДВИЖОК
    print("\n🎯 === ЗАПУСК СОБСТВЕННОГО АНИМАЦИОННОГО ДВИЖКА ===")
    local success = createCustomAnimationEngine(toolToReplace)
    
    if success then
        print("✅ УСПЕХ! Собственный анимационный движок запущен!")
        print("🎮 Питомец должен анимироваться собственным движком!")
    else
        print("⚠️ Проблемы с запуском анимационного движка")
    end
    
    print("\n🎯 === РЕЗУЛЬТАТ ===")
    print("✅ Инструмент заменен на: " .. toolToReplace.Name)
    print("🎮 Анимация: Собственный движок")
    
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
    screenGui.Name = "DirectShovelFixV7"
    screenGui.Parent = player:WaitForChild("PlayerGui")
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 500, 0, 250)
    frame.Position = UDim2.new(0.5, -250, 0.5, -125)
    frame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
    frame.BorderSizePixel = 0
    frame.Parent = screenGui
    
    -- Заголовок
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundTransparency = 1
    title.Text = "🎮 DirectShovelFix v7 - Custom Animation"
    title.TextColor3 = Color3.new(1, 1, 1)
    title.TextScaled = true
    title.Font = Enum.Font.GothamBold
    title.Parent = frame
    
    -- Кнопка сохранения
    local saveBtn = Instance.new("TextButton")
    saveBtn.Size = UDim2.new(0.45, 0, 0, 50)
    saveBtn.Position = UDim2.new(0.025, 0, 0, 50)
    saveBtn.BackgroundColor3 = Color3.new(0.2, 0.6, 0.2)
    saveBtn.Text = "💾 СОХРАНИТЬ\nПИТОМЦА"
    saveBtn.TextColor3 = Color3.new(1, 1, 1)
    saveBtn.TextScaled = true
    saveBtn.Font = Enum.Font.Gotham
    saveBtn.Parent = frame
    
    -- Кнопка замены
    local replaceBtn = Instance.new("TextButton")
    replaceBtn.Size = UDim2.new(0.45, 0, 0, 50)
    replaceBtn.Position = UDim2.new(0.525, 0, 0, 50)
    replaceBtn.BackgroundColor3 = Color3.new(0.8, 0.2, 0.2)
    replaceBtn.Text = "🎮 ЗАМЕНИТЬ\n+ АНИМАЦИЯ"
    replaceBtn.TextColor3 = Color3.new(1, 1, 1)
    replaceBtn.TextScaled = true
    replaceBtn.Font = Enum.Font.Gotham
    replaceBtn.Parent = frame
    
    -- Кнопка остановки анимации
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
    infoLabel.Size = UDim2.new(0.95, 0, 0, 80)
    infoLabel.Position = UDim2.new(0.025, 0, 0, 150)
    infoLabel.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
    infoLabel.Text = "НОВЫЙ ПОДХОД: Собственный анимационный движок!\n1. Возьмите питомца → СОХРАНИТЬ\n2. Возьмите любой инструмент → ЗАМЕНИТЬ\n3. Наслаждайтесь анимацией!"
    infoLabel.TextColor3 = Color3.new(1, 1, 1)
    infoLabel.TextScaled = true
    infoLabel.Font = Enum.Font.Gotham
    infoLabel.Parent = frame
    
    -- Кнопка закрытия
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0.45, 0, 0, 15)
    closeBtn.Position = UDim2.new(0.525, 0, 0, 235)
    closeBtn.BackgroundColor3 = Color3.new(0.6, 0.1, 0.1)
    closeBtn.Text = "❌ ЗАКРЫТЬ"
    closeBtn.TextColor3 = Color3.new(1, 1, 1)
    closeBtn.TextScaled = true
    closeBtn.Font = Enum.Font.Gotham
    closeBtn.Parent = frame
    
    -- Обработчики событий
    saveBtn.MouseButton1Click:Connect(savePetWithMotor6D)
    replaceBtn.MouseButton1Click:Connect(replaceWithCustomAnimation)
    stopBtn.MouseButton1Click:Connect(stopAnimation)
    closeBtn.MouseButton1Click:Connect(function()
        stopAnimation()
        screenGui:Destroy()
    end)
    
    print("🎮 GUI создан! Новый подход: собственный анимационный движок!")
end

-- Запуск
createGUI()
