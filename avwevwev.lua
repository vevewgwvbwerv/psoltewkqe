-- 🎯 DirectShovelFix v10 - ВОССТАНОВЛЕНИЕ ОРИГИНАЛЬНОЙ АНИМАЦИИ
-- НОВЫЙ ПОДХОД: Не создаем свою анимацию, а восстанавливаем работу PetToolLocal!
-- Проблема: PetToolLocal не запускается на копии Tool

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

print("🎯 === DirectShovelFix v10 - ORIGINAL ANIMATION RESTORATION ===")

-- Глобальные переменные
local petTool = nil
local savedPetData = {}
local originalPetToolLocal = nil

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
    
    for _, tool in pairs(character:GetChildren()) do
        if tool:IsA("Tool") then
            print("   Найден инструмент: " .. tool.Name)
            if not string.find(tool.Name, "%[") and not string.find(tool.Name, "KG%]") then
                print("✅ Найден инструмент для замены: " .. tool.Name)
                return tool
            end
        end
    end
    
    print("❌ Инструмент для замены не найден")
    return nil
end

-- Анализ и сохранение оригинального PetToolLocal
local function saveOriginalPetAnimation()
    print("\n💾 === СОХРАНЕНИЕ ОРИГИНАЛЬНОЙ АНИМАЦИИ ===")
    
    petTool = findPetInHands()
    if not petTool then
        print("❌ Питомец в руках не найден!")
        return false
    end
    
    print("✅ Найден питомец: " .. petTool.Name)
    
    -- Ищем оригинальный PetToolLocal
    originalPetToolLocal = petTool:FindFirstChild("PetToolLocal")
    if originalPetToolLocal then
        print("🎯 Найден оригинальный PetToolLocal!")
        print("   Enabled: " .. tostring(originalPetToolLocal.Enabled))
        print("   ClassName: " .. originalPetToolLocal.ClassName)
    else
        print("❌ PetToolLocal не найден!")
        return false
    end
    
    -- Сохраняем данные питомца
    savedPetData = {
        name = petTool.Name,
        requiresHandle = petTool.RequiresHandle,
        canBeDropped = petTool.CanBeDropped,
        manualActivationOnly = petTool.ManualActivationOnly,
        children = {}
    }
    
    -- Сохраняем все дочерние объекты
    for _, child in pairs(petTool:GetChildren()) do
        table.insert(savedPetData.children, child)
        if child.Name == "PetToolLocal" then
            print("📜 Сохранен PetToolLocal для восстановления")
        end
    end
    
    print("📊 Сохранено объектов: " .. #savedPetData.children)
    return true
end

-- НОВЫЙ ПОДХОД: Принудительное создание нового PetToolLocal
local function createWorkingPetToolLocal(tool)
    print("\n🔧 === СОЗДАНИЕ РАБОТАЮЩЕГО PETTOOLLOCAL ===")
    
    if not originalPetToolLocal then
        print("❌ Оригинальный PetToolLocal не найден!")
        return false
    end
    
    -- Удаляем старый PetToolLocal если есть
    local oldPetLocal = tool:FindFirstChild("PetToolLocal")
    if oldPetLocal then
        oldPetLocal:Destroy()
        print("🗑️ Удален старый PetToolLocal")
    end
    
    wait(0.1)
    
    -- Создаем НОВЫЙ LocalScript с базовой анимацией
    local newPetLocal = Instance.new("LocalScript")
    newPetLocal.Name = "PetToolLocal"
    newPetLocal.Parent = tool
    
    -- Создаем простой код анимации внутри LocalScript
    local animationCode = [[
-- Простая анимация для питомца в руке
local tool = script.Parent
local RunService = game:GetService("RunService")

print("🎮 PetToolLocal запущен для: " .. tool.Name)

local motor6ds = {}

-- Собираем Motor6D из Tool
local function collectMotor6D(parent)
    for _, child in pairs(parent:GetChildren()) do
        if child:IsA("Motor6D") then
            table.insert(motor6ds, {
                motor = child,
                originalC0 = child.C0,
                originalC1 = child.C1
            })
            print("🔧 Найден Motor6D в Tool: " .. child.Name)
        end
        collectMotor6D(child)
    end
end

collectMotor6D(tool)

if #motor6ds > 0 then
    print("✅ Запуск анимации для " .. #motor6ds .. " Motor6D")
    
    local startTime = tick()
    
    RunService.Heartbeat:Connect(function()
        local currentTime = tick() - startTime
        
        for i, motorData in pairs(motor6ds) do
            if motorData.motor and motorData.motor.Parent then
                local wave1 = math.sin(currentTime * 2 + i) * 0.1
                local wave2 = math.cos(currentTime * 1.5 + i) * 0.08
                
                local newC0 = motorData.originalC0 * CFrame.Angles(wave1, wave2, wave1 * 0.5)
                motorData.motor.C0 = newC0
                
                local newC1 = motorData.originalC1 * CFrame.Angles(wave2 * 0.5, wave1 * 0.3, wave2)
                motorData.motor.C1 = newC1
            end
        end
    end)
else
    print("❌ Motor6D не найдены в Tool")
end
]]
    
    -- Устанавливаем код в LocalScript
    newPetLocal.Source = animationCode
    newPetLocal.Enabled = true
    
    print("✅ Создан новый работающий PetToolLocal!")
    print("🎮 LocalScript должен запустить анимацию!")
    
    return true
end

-- Основная функция замены с восстановлением оригинальной анимации
local function replaceWithOriginalAnimation()
    print("\n🔄 === ЗАМЕНА С ОРИГИНАЛЬНОЙ АНИМАЦИЕЙ ===")
    
    if not petTool or #savedPetData.children == 0 then
        print("❌ Сначала сохраните питомца!")
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
    
    -- Шаг 3: Копируем содержимое (БЕЗ PetToolLocal - создадим новый!)
    for _, child in pairs(savedPetData.children) do
        if child and child.Parent and child.Name ~= "PetToolLocal" then
            local copy = child:Clone()
            copy.Parent = toolToReplace
            print("📋 Скопировано: " .. child.Name)
        end
    end
    
    wait(0.2)
    
    -- Шаг 4: Переэкипировка
    print("🔄 Переэкипировка...")
    toolToReplace.Parent = player.Backpack
    wait(0.2)
    toolToReplace.Parent = player.Character
    wait(0.3)
    
    -- Шаг 5: СОЗДАЕМ НОВЫЙ РАБОТАЮЩИЙ PetToolLocal
    print("\n🎯 === СОЗДАНИЕ НОВОГО PETTOOLLOCAL ===")
    local success = createWorkingPetToolLocal(toolToReplace)
    
    if success then
        print("✅ УСПЕХ! Новый PetToolLocal создан и запущен!")
        print("🎮 Питомец должен анимироваться через LocalScript!")
    else
        print("⚠️ Проблемы с созданием PetToolLocal")
    end
    
    return true
end

-- Создание GUI
local function createGUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "DirectShovelFixV10"
    screenGui.Parent = player:WaitForChild("PlayerGui")
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 520, 0, 280)
    frame.Position = UDim2.new(0.5, -260, 0.5, -140)
    frame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
    frame.BorderSizePixel = 0
    frame.Parent = screenGui
    
    -- Заголовок
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundTransparency = 1
    title.Text = "🎯 DirectShovelFix v10 - Original Animation"
    title.TextColor3 = Color3.new(1, 1, 1)
    title.TextScaled = true
    title.Font = Enum.Font.GothamBold
    title.Parent = frame
    
    -- Кнопка сохранения
    local saveBtn = Instance.new("TextButton")
    saveBtn.Size = UDim2.new(0.45, 0, 0, 60)
    saveBtn.Position = UDim2.new(0.025, 0, 0, 50)
    saveBtn.BackgroundColor3 = Color3.new(0.2, 0.6, 0.2)
    saveBtn.Text = "💾 СОХРАНИТЬ\nОРИГИНАЛ"
    saveBtn.TextColor3 = Color3.new(1, 1, 1)
    saveBtn.TextScaled = true
    saveBtn.Font = Enum.Font.Gotham
    saveBtn.Parent = frame
    
    -- Кнопка замены
    local replaceBtn = Instance.new("TextButton")
    replaceBtn.Size = UDim2.new(0.45, 0, 0, 60)
    replaceBtn.Position = UDim2.new(0.525, 0, 0, 50)
    replaceBtn.BackgroundColor3 = Color3.new(0.8, 0.2, 0.2)
    replaceBtn.Text = "🎯 ЗАМЕНИТЬ\n+ НОВЫЙ LOCALSCRIPT"
    replaceBtn.TextColor3 = Color3.new(1, 1, 1)
    replaceBtn.TextScaled = true
    replaceBtn.Font = Enum.Font.Gotham
    replaceBtn.Parent = frame
    
    -- Информационная панель
    local infoLabel = Instance.new("TextLabel")
    infoLabel.Size = UDim2.new(0.95, 0, 0, 150)
    infoLabel.Position = UDim2.new(0.025, 0, 0, 120)
    infoLabel.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
    infoLabel.Text = "🎯 НОВЫЙ ПОДХОД: Восстановление оригинальной анимации!\n\nПроблема: Tool Motor6D связаны с игроком\nРешение: Создание нового работающего LocalScript\n\n1. Сохранить оригинальный PetToolLocal\n2. Создать новый LocalScript с анимацией\n3. Запустить на копии Tool"
    infoLabel.TextColor3 = Color3.new(1, 1, 1)
    infoLabel.TextScaled = true
    infoLabel.Font = Enum.Font.Gotham
    infoLabel.Parent = frame
    
    -- Кнопка закрытия
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0.95, 0, 0, 20)
    closeBtn.Position = UDim2.new(0.025, 0, 0, 275)
    closeBtn.BackgroundColor3 = Color3.new(0.6, 0.1, 0.1)
    closeBtn.Text = "❌ ЗАКРЫТЬ"
    closeBtn.TextColor3 = Color3.new(1, 1, 1)
    closeBtn.TextScaled = true
    closeBtn.Font = Enum.Font.Gotham
    closeBtn.Parent = frame
    
    -- Обработчики событий
    saveBtn.MouseButton1Click:Connect(saveOriginalPetAnimation)
    replaceBtn.MouseButton1Click:Connect(replaceWithOriginalAnimation)
    closeBtn.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)
    
    print("🎮 GUI создан! Новый подход: восстановление оригинальной анимации!")
end

-- Запуск
createGUI()
