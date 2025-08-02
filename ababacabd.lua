-- 🧠 SMART MOTOR COPIER - Умное копирование с управлением Anchored
-- Временно снимает Anchored для анимации, но не дает копии упасть

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

print("🧠 === SMART MOTOR COPIER ===")
print("=" .. string.rep("=", 50))

-- Функция поиска моделей
local function findModels()
    local original = nil
    local copy = nil
    local copyUUID = nil
    
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and obj.Name:find("%{") and obj.Name:find("%}") and obj.Name:find("_SCALED_COPY") then
            copy = obj
            copyUUID = obj.Name:gsub("_SCALED_COPY", "")
            break
        end
    end
    
    if copy then
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("Model") and obj.Name == copyUUID then
                original = obj
                break
            end
        end
    end
    
    return original, copy
end

-- Функция получения всех BasePart из модели
local function getAllParts(model)
    local parts = {}
    
    for _, obj in pairs(model:GetDescendants()) do
        if obj:IsA("BasePart") then
            table.insert(parts, obj)
        end
    end
    
    return parts
end

-- Функция получения всех Motor6D из модели
local function getMotor6Ds(model)
    local motors = {}
    
    for _, obj in pairs(model:GetDescendants()) do
        if obj:IsA("Motor6D") then
            table.insert(motors, obj)
        end
    end
    
    return motors
end

-- Функция создания карты Motor6D
local function createMotorMap(motors)
    local map = {}
    
    for _, motor in ipairs(motors) do
        local key = motor.Name
        if motor.Part0 then
            key = key .. "_" .. motor.Part0.Name
        end
        if motor.Part1 then
            key = key .. "_" .. motor.Part1.Name
        end
        
        map[key] = motor
    end
    
    return map
end

-- Функция анализа Anchored состояний
local function analyzeAnchored(model, modelName)
    print("⚓ Анализ Anchored в " .. modelName .. ":")
    
    local parts = getAllParts(model)
    local anchoredCount = 0
    local unanchoredCount = 0
    
    for _, part in ipairs(parts) do
        if part.Anchored then
            anchoredCount = anchoredCount + 1
        else
            unanchoredCount = unanchoredCount + 1
        end
    end
    
    print("  Всего частей: " .. #parts)
    print("  Anchored: " .. anchoredCount)
    print("  Unanchored: " .. unanchoredCount)
    
    if anchoredCount > 0 then
        print("  ⚠️ Anchored части блокируют движение!")
    else
        print("  ✅ Все части могут двигаться")
    end
    
    return parts, anchoredCount, unanchoredCount
end

-- Функция умного управления Anchored
local function smartAnchoredManagement(copyParts)
    print("🧠 Умное управление Anchored...")
    
    -- Находим "корневую" часть (обычно Torso или HumanoidRootPart)
    local rootPart = nil
    local rootCandidates = {"Torso", "HumanoidRootPart", "UpperTorso", "LowerTorso"}
    
    for _, candidate in ipairs(rootCandidates) do
        for _, part in ipairs(copyParts) do
            if part.Name == candidate then
                rootPart = part
                break
            end
        end
        if rootPart then break end
    end
    
    if not rootPart then
        -- Берем первую часть как корневую
        rootPart = copyParts[1]
        print("  ⚠️ Корневая часть не найдена, использую: " .. rootPart.Name)
    else
        print("  ✅ Корневая часть: " .. rootPart.Name)
    end
    
    -- Стратегия: только корневая часть остается Anchored
    for _, part in ipairs(copyParts) do
        if part == rootPart then
            part.Anchored = true  -- Корневая остается заякоренной
        else
            part.Anchored = false -- Остальные могут двигаться
        end
    end
    
    print("  ✅ Anchored настроен: корень заякорен, остальные свободны")
    return rootPart
end

-- Функция копирования состояния Motor6D
local function copyMotorState(originalMotor, copyMotor)
    if not originalMotor or not copyMotor then
        return false
    end
    
    copyMotor.Transform = originalMotor.Transform
    copyMotor.C0 = originalMotor.C0
    copyMotor.C1 = originalMotor.C1
    
    return true
end

-- Функция живого копирования с умным Anchored
local function startSmartLiveCopying(original, copy)
    print("🔄 Запуск умного живого копирования...")
    
    -- Анализируем состояние частей
    local originalParts, origAnchored, origUnanchored = analyzeAnchored(original, "ОРИГИНАЛ")
    local copyParts, copyAnchored, copyUnanchored = analyzeAnchored(copy, "КОПИЯ")
    
    -- Настраиваем умный Anchored для копии
    local rootPart = smartAnchoredManagement(copyParts)
    
    -- Получаем Motor6D
    local originalMotors = getMotor6Ds(original)
    local copyMotors = getMotor6Ds(copy)
    
    print("  Motor6D - Оригинал: " .. #originalMotors .. ", Копия: " .. #copyMotors)
    
    local originalMap = createMotorMap(originalMotors)
    local copyMap = createMotorMap(copyMotors)
    
    -- Проверяем что части теперь могут двигаться
    wait(0.1)
    local _, newAnchored, newUnanchored = analyzeAnchored(copy, "КОПИЯ ПОСЛЕ НАСТРОЙКИ")
    
    if newUnanchored == 0 then
        print("❌ Все части все еще заякорены! Анимация не будет работать")
        return nil
    end
    
    print("✅ Настройка завершена, запускаю живое копирование...")
    
    local connection = nil
    local isRunning = true
    local frameCount = 0
    
    connection = RunService.Heartbeat:Connect(function()
        if not isRunning then
            connection:Disconnect()
            return
        end
        
        frameCount = frameCount + 1
        
        -- Проверяем существование моделей
        if not original.Parent or not copy.Parent then
            print("⚠️ Модель удалена, останавливаю")
            isRunning = false
            return
        end
        
        -- Копируем состояния Motor6D
        local copiedCount = 0
        for key, originalMotor in pairs(originalMap) do
            local copyMotor = copyMap[key]
            if copyMotor and originalMotor.Parent then
                if copyMotorState(originalMotor, copyMotor) then
                    copiedCount = copiedCount + 1
                end
            end
        end
        
        -- Каждые 60 кадров выводим статус
        if frameCount % 60 == 0 then
            print("📊 Кадр " .. frameCount .. ": скопировано " .. copiedCount .. " Motor6D")
        end
    end)
    
    print("✅ Умное живое копирование запущено!")
    print("💡 Копия должна двигаться, но не падать")
    print("⏰ Автостоп через 30 секунд")
    
    -- Автостоп
    spawn(function()
        wait(30)
        isRunning = false
        print("⏰ Умное копирование остановлено")
    end)
    
    return connection
end

-- Основная функция
local function main()
    local original, copy = findModels()
    
    if not original or not copy then
        print("❌ Модели не найдены!")
        print("💡 Убедись что есть копия с _SCALED_COPY")
        return
    end
    
    print("🎯 Найдены модели:")
    print("  Оригинал:", original.Name)
    print("  Копия:", copy.Name)
    print()
    
    print("📊 ДИАГНОСТИКА:")
    analyzeAnchored(original, "ОРИГИНАЛ")
    analyzeAnchored(copy, "КОПИЯ ДО НАСТРОЙКИ")
    print()
    
    print("🚀 ЗАПУСК УМНОГО КОПИРОВАНИЯ:")
    local connection = startSmartLiveCopying(original, copy)
    
    if connection then
        print("🎉 Умное копирование активно!")
        print("🎮 Теперь подвигай оригинального питомца")
        print("👀 Копия должна повторять движения, но не падать")
    else
        print("❌ Не удалось запустить умное копирование")
    end
    
    print("=" .. string.rep("=", 50))
end

-- Запуск
main()
