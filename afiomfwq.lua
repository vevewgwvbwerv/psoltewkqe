-- 🎯 DirectShovelFix v9 - АНИМАЦИЯ ТОЛЬКО TOOL (НЕ ИГРОКА!)
-- РЕШЕНИЕ: Строго ограничиваем анимацию только объектами внутри Tool
-- НЕ затрагиваем Motor6D и BasePart игрока!

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

print("🎯 === DirectShovelFix v9 - TOOL ONLY ANIMATION ===")

-- Глобальные переменные
local petTool = nil
local savedPetData = {}
local animationConnection = nil
local animatedTool = nil
local toolMotor6DList = {} -- ТОЛЬКО Motor6D из Tool!
local toolBasePartList = {} -- ТОЛЬКО BasePart из Tool!
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

-- Сохранение данных питомца
local function savePetWithGripData()
    print("\n💾 === СОХРАНЕНИЕ ПИТОМЦА + GRIP ДАННЫХ ===")
    
    petTool = findPetInHands()
    if not petTool then
        print("❌ Питомец в руках не найден!")
        return false
    end
    
    print("✅ Найден питомец: " .. petTool.Name)
    
    -- Сохраняем RightGrip данные
    local character = player.Character
    if character then
        local rightArm = character:FindFirstChild("Right Arm") or character:FindFirstChild("RightHand")
        if rightArm then
            local rightGrip = rightArm:FindFirstChild("RightGrip")
            if rightGrip then
                savedGripData = {
                    C0 = rightGrip.C0,
                    C1 = rightGrip.C1
                }
                print("🤏 Сохранены данные RightGrip!")
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
        cframeData = {}
    }
    
    -- Сохраняем все дочерние объекты
    for _, child in pairs(petTool:GetChildren()) do
        table.insert(savedPetData.children, child)
    end
    
    -- СТРОГО: Сохраняем анимационные данные ТОЛЬКО из Tool
    local function collectToolAnimationData(parent, path, toolRef)
        path = path or ""
        for _, child in pairs(parent:GetChildren()) do
            if child:IsA("Motor6D") then
                local motorData = {
                    name = child.Name,
                    path = path,
                    toolReference = toolRef, -- Ссылка на Tool для проверки
                    originalC0 = child.C0,
                    originalC1 = child.C1
                }
                table.insert(savedPetData.motor6DData, motorData)
                print("🔧 Сохранен Motor6D из Tool: " .. child.Name)
            elseif child:IsA("BasePart") then
                local cframeData = {
                    name = child.Name,
                    path = path,
                    toolReference = toolRef, -- Ссылка на Tool для проверки
                    originalCFrame = child.CFrame
                }
                table.insert(savedPetData.cframeData, cframeData)
                print("📐 Сохранен CFrame из Tool: " .. child.Name)
            end
            collectToolAnimationData(child, path .. "/" .. child.Name, toolRef)
        end
    end
    
    collectToolAnimationData(petTool, "", petTool)
    
    print("📊 Сохранено объектов: " .. #savedPetData.children)
    print("🔧 Сохранено Motor6D из Tool: " .. #savedPetData.motor6DData)
    print("📐 Сохранено CFrame из Tool: " .. #savedPetData.cframeData)
    
    return true
end

-- Создание анимационного движка СТРОГО для Tool
local function createToolOnlyAnimationEngine(tool)
    print("\n🎮 === АНИМАЦИОННЫЙ ДВИЖОК СТРОГО ДЛЯ TOOL ===")
    
    -- Останавливаем предыдущую анимацию
    if animationConnection then
        animationConnection:Disconnect()
        animationConnection = nil
    end
    
    toolMotor6DList = {}
    toolBasePartList = {}
    
    -- КРИТИЧЕСКИ ВАЖНО: Собираем компоненты СТРОГО из указанного Tool
    local function collectToolComponents(parent, depth)
        depth = depth or 0
        local indent = string.rep("  ", depth)
        
        for _, child in pairs(parent:GetChildren()) do
            if child:IsA("Motor6D") then
                -- ПРОВЕРЯЕМ: Motor6D действительно принадлежит Tool
                local isFromTool = false
                local checkParent = child.Parent
                while checkParent do
                    if checkParent == tool then
                        isFromTool = true
                        break
                    end
                    checkParent = checkParent.Parent
                end
                
                if isFromTool then
                    table.insert(toolMotor6DList, child)
                    print(indent .. "🔧 Motor6D из Tool: " .. child.Name .. " (Путь: " .. child:GetFullName() .. ")")
                else
                    print(indent .. "❌ ПРОПУЩЕН Motor6D из Character: " .. child.Name)
                end
                
            elseif child:IsA("BasePart") and child.Name ~= "Handle" then
                -- ПРОВЕРЯЕМ: BasePart действительно принадлежит Tool
                local isFromTool = false
                local checkParent = child.Parent
                while checkParent do
                    if checkParent == tool then
                        isFromTool = true
                        break
                    end
                    checkParent = checkParent.Parent
                end
                
                if isFromTool then
                    table.insert(toolBasePartList, child)
                    print(indent .. "📐 BasePart из Tool: " .. child.Name .. " (Путь: " .. child:GetFullName() .. ")")
                else
                    print(indent .. "❌ ПРОПУЩЕН BasePart из Character: " .. child.Name)
                end
            end
            
            collectToolComponents(child, depth + 1)
        end
    end
    
    -- Собираем ТОЛЬКО из Tool
    print("🔍 Сбор компонентов СТРОГО из Tool: " .. tool.Name)
    collectToolComponents(tool)
    
    print("✅ Найдено для анимации В TOOL:")
    print("   🔧 Motor6D: " .. #toolMotor6DList)
    print("   📐 BasePart: " .. #toolBasePartList)
    
    if #toolMotor6DList == 0 and #toolBasePartList == 0 then
        print("❌ Компоненты для анимации в Tool не найдены!")
        return false
    end
    
    -- Запускаем анимацию ТОЛЬКО для Tool компонентов
    local startTime = tick()
    animatedTool = tool
    
    animationConnection = RunService.Heartbeat:Connect(function()
        local currentTime = tick() - startTime
        
        -- Анимируем ТОЛЬКО Motor6D из Tool
        for i, motor6D in pairs(toolMotor6DList) do
            if motor6D and motor6D.Parent then
                -- Проверяем, что Motor6D все еще принадлежит нашему Tool
                local stillInTool = false
                local checkParent = motor6D.Parent
                while checkParent do
                    if checkParent == tool then
                        stillInTool = true
                        break
                    end
                    checkParent = checkParent.Parent
                end
                
                if stillInTool then
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
        end
        
        -- Анимируем ТОЛЬКО BasePart из Tool (кроме Handle!)
        for i, basePart in pairs(toolBasePartList) do
            if basePart and basePart.Parent and basePart.Name ~= "Handle" then
                -- Проверяем, что BasePart все еще принадлежит нашему Tool
                local stillInTool = false
                local checkParent = basePart.Parent
                while checkParent do
                    if checkParent == tool then
                        stillInTool = true
                        break
                    end
                    checkParent = checkParent.Parent
                end
                
                if stillInTool then
                    local savedCFrame = nil
                    for _, savedData in pairs(savedPetData.cframeData) do
                        if savedData.name == basePart.Name then
                            savedCFrame = savedData
                            break
                        end
                    end
                    
                    if savedCFrame then
                        -- Легкая анимация относительно Handle (чтобы оставаться в руке)
                        local wave3 = math.sin(currentTime * 1.8 + i) * 0.02
                        local wave4 = math.cos(currentTime * 2.2 + i) * 0.015
                        
                        -- НЕ перемещаем в мировых координатах, анимируем относительно
                        local handle = tool:FindFirstChild("Handle")
                        if handle then
                            local relativeOffset = CFrame.Angles(wave3, wave4, wave3 * 0.5)
                            -- Анимируем относительно Handle, а не абсолютно
                            basePart.CFrame = handle.CFrame * relativeOffset
                        end
                    end
                end
            end
        end
    end)
    
    print("✅ Анимационный движок запущен ТОЛЬКО для Tool!")
    print("🎯 Игрок НЕ должен анимироваться!")
    
    return true
end

-- Восстановление положения в руке
local function restoreHandGrip(tool)
    print("\n🤏 === ВОССТАНОВЛЕНИЕ ПОЛОЖЕНИЯ В РУКЕ ===")
    
    local character = player.Character
    if not character then return false end
    
    local rightArm = character:FindFirstChild("Right Arm") or character:FindFirstChild("RightHand")
    if not rightArm then return false end
    
    local handle = tool:FindFirstChild("Handle")
    if not handle then return false end
    
    -- Ждем RightGrip
    local rightGrip = rightArm:FindFirstChild("RightGrip")
    local attempts = 0
    while not rightGrip and attempts < 10 do
        wait(0.1)
        rightGrip = rightArm:FindFirstChild("RightGrip")
        attempts = attempts + 1
    end
    
    if rightGrip and savedGripData then
        rightGrip.C0 = savedGripData.C0
        rightGrip.C1 = savedGripData.C1
        print("✅ RightGrip восстановлен!")
    end
    
    return true
end

-- Основная функция замены
local function replaceWithToolOnlyAnimation()
    print("\n🔄 === ЗАМЕНА С АНИМАЦИЕЙ ТОЛЬКО TOOL ===")
    
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
    
    -- Шаг 2: Очищаем содержимое
    for _, child in pairs(toolToReplace:GetChildren()) do
        child:Destroy()
    end
    wait(0.1)
    
    -- Шаг 3: Копируем содержимое
    for _, child in pairs(savedPetData.children) do
        if child and child.Parent then
            local copy = child:Clone()
            copy.Parent = toolToReplace
            print("📋 Скопировано в Tool: " .. child.Name)
        end
    end
    
    wait(0.2)
    
    -- Шаг 4: Переэкипировка
    print("🔄 Переэкипировка...")
    toolToReplace.Parent = player.Backpack
    wait(0.2)
    toolToReplace.Parent = player.Character
    wait(0.3)
    
    -- Шаг 5: Восстанавливаем положение в руке
    restoreHandGrip(toolToReplace)
    
    -- Шаг 6: Запускаем анимацию СТРОГО для Tool
    print("\n🎯 === ЗАПУСК АНИМАЦИИ СТРОГО ДЛЯ TOOL ===")
    local success = createToolOnlyAnimationEngine(toolToReplace)
    
    if success then
        print("✅ УСПЕХ! Анимация ТОЛЬКО для питомца в Tool!")
        print("🎯 Игрок НЕ должен анимироваться!")
        print("🤏 Питомец анимируется в руке!")
    else
        print("⚠️ Проблемы с анимацией Tool")
    end
    
    return true
end

-- Остановка анимации
local function stopAnimation()
    if animationConnection then
        animationConnection:Disconnect()
        animationConnection = nil
        print("🛑 Анимация остановлена")
    end
end

-- Создание GUI
local function createGUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "DirectShovelFixV9"
    screenGui.Parent = player:WaitForChild("PlayerGui")
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 520, 0, 300)
    frame.Position = UDim2.new(0.5, -260, 0.5, -150)
    frame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
    frame.BorderSizePixel = 0
    frame.Parent = screenGui
    
    -- Заголовок
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundTransparency = 1
    title.Text = "🎯 DirectShovelFix v9 - Tool Only Animation"
    title.TextColor3 = Color3.new(1, 1, 1)
    title.TextScaled = true
    title.Font = Enum.Font.GothamBold
    title.Parent = frame
    
    -- Кнопка сохранения
    local saveBtn = Instance.new("TextButton")
    saveBtn.Size = UDim2.new(0.45, 0, 0, 60)
    saveBtn.Position = UDim2.new(0.025, 0, 0, 50)
    saveBtn.BackgroundColor3 = Color3.new(0.2, 0.6, 0.2)
    saveBtn.Text = "💾 СОХРАНИТЬ\nПИТОМЦА"
    saveBtn.TextColor3 = Color3.new(1, 1, 1)
    saveBtn.TextScaled = true
    saveBtn.Font = Enum.Font.Gotham
    saveBtn.Parent = frame
    
    -- Кнопка замены
    local replaceBtn = Instance.new("TextButton")
    replaceBtn.Size = UDim2.new(0.45, 0, 0, 60)
    replaceBtn.Position = UDim2.new(0.525, 0, 0, 50)
    replaceBtn.BackgroundColor3 = Color3.new(0.8, 0.2, 0.2)
    replaceBtn.Text = "🎯 ЗАМЕНИТЬ\nTOOL ONLY"
    replaceBtn.TextColor3 = Color3.new(1, 1, 1)
    replaceBtn.TextScaled = true
    replaceBtn.Font = Enum.Font.Gotham
    replaceBtn.Parent = frame
    
    -- Кнопка остановки
    local stopBtn = Instance.new("TextButton")
    stopBtn.Size = UDim2.new(0.45, 0, 0, 30)
    stopBtn.Position = UDim2.new(0.025, 0, 0, 120)
    stopBtn.BackgroundColor3 = Color3.new(0.6, 0.3, 0.1)
    stopBtn.Text = "🛑 ОСТАНОВИТЬ"
    stopBtn.TextColor3 = Color3.new(1, 1, 1)
    stopBtn.TextScaled = true
    stopBtn.Font = Enum.Font.Gotham
    stopBtn.Parent = frame
    
    -- Информационная панель
    local infoLabel = Instance.new("TextLabel")
    infoLabel.Size = UDim2.new(0.95, 0, 0, 120)
    infoLabel.Position = UDim2.new(0.025, 0, 0, 160)
    infoLabel.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
    infoLabel.Text = "🎯 РЕШЕНИЕ: Анимация ТОЛЬКО для Tool!\n\nПроблема: анимация применялась к игроку\nРешение: строгая проверка принадлежности к Tool\n\n1. Сохранить питомца\n2. Заменить с анимацией ТОЛЬКО Tool\n3. Игрок НЕ анимируется!"
    infoLabel.TextColor3 = Color3.new(1, 1, 1)
    infoLabel.TextScaled = true
    infoLabel.Font = Enum.Font.Gotham
    infoLabel.Parent = frame
    
    -- Кнопка закрытия
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0.45, 0, 0, 15)
    closeBtn.Position = UDim2.new(0.525, 0, 0, 285)
    closeBtn.BackgroundColor3 = Color3.new(0.6, 0.1, 0.1)
    closeBtn.Text = "❌ ЗАКРЫТЬ"
    closeBtn.TextColor3 = Color3.new(1, 1, 1)
    closeBtn.TextScaled = true
    closeBtn.Font = Enum.Font.Gotham
    closeBtn.Parent = frame
    
    -- Обработчики событий
    saveBtn.MouseButton1Click:Connect(savePetWithGripData)
    replaceBtn.MouseButton1Click:Connect(replaceWithToolOnlyAnimation)
    stopBtn.MouseButton1Click:Connect(stopAnimation)
    closeBtn.MouseButton1Click:Connect(function()
        stopAnimation()
        screenGui:Destroy()
    end)
    
    print("🎮 GUI создан! Строгая анимация только для Tool!")
end

-- Запуск
createGUI()
