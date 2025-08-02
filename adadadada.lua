-- ⚙️ MOTOR6D COPIER - Копирование состояний Motor6D вместо анимаций
-- Анимации rbxasset защищены, но состояния Motor6D можно копировать!

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

print("⚙️ === MOTOR6D COPIER ===")
print("=" .. string.rep("=", 40))

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

-- Функция создания карты Motor6D по именам
local function createMotorMap(motors)
    local map = {}
    
    for _, motor in ipairs(motors) do
        -- Используем имя Motor6D + имена Part0 и Part1 как ключ
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

-- Функция копирования состояния одного Motor6D
local function copyMotorState(originalMotor, copyMotor)
    if not originalMotor or not copyMotor then
        return false
    end
    
    -- Копируем Transform (основное состояние)
    copyMotor.Transform = originalMotor.Transform
    
    -- Копируем C0 и C1 (позиции соединения)
    copyMotor.C0 = originalMotor.C0
    copyMotor.C1 = originalMotor.C1
    
    -- Копируем CurrentAngle и DesiredAngle если есть
    if originalMotor:FindFirstChild("CurrentAngle") then
        copyMotor.CurrentAngle = originalMotor.CurrentAngle
    end
    if originalMotor:FindFirstChild("DesiredAngle") then
        copyMotor.DesiredAngle = originalMotor.DesiredAngle
    end
    
    return true
end

-- Функция анализа Motor6D состояний
local function analyzeMotorStates(model, modelName)
    print("🔍 Анализ Motor6D в " .. modelName .. ":")
    
    local motors = getMotor6Ds(model)
    print("  Найдено Motor6D: " .. #motors)
    
    for i, motor in ipairs(motors) do
        print("  [" .. i .. "] " .. motor.Name)
        if motor.Part0 then
            print("    Part0: " .. motor.Part0.Name)
        end
        if motor.Part1 then
            print("    Part1: " .. motor.Part1.Name)
        end
        print("    Transform: " .. tostring(motor.Transform))
        print("    C0: " .. tostring(motor.C0))
        print("    C1: " .. tostring(motor.C1))
        print()
    end
    
    return motors
end

-- Функция однократного копирования состояний
local function copyMotorStatesOnce(original, copy)
    print("📋 Копирование состояний Motor6D (однократно)...")
    
    local originalMotors = getMotor6Ds(original)
    local copyMotors = getMotor6Ds(copy)
    
    print("  Оригинал: " .. #originalMotors .. " Motor6D")
    print("  Копия: " .. #copyMotors .. " Motor6D")
    
    if #originalMotors == 0 or #copyMotors == 0 then
        print("❌ Недостаточно Motor6D для копирования!")
        return false
    end
    
    -- Создаем карты для сопоставления
    local originalMap = createMotorMap(originalMotors)
    local copyMap = createMotorMap(copyMotors)
    
    local successCount = 0
    
    -- Копируем состояния
    for key, originalMotor in pairs(originalMap) do
        local copyMotor = copyMap[key]
        if copyMotor then
            local success = copyMotorState(originalMotor, copyMotor)
            if success then
                successCount = successCount + 1
                print("  ✅ " .. key)
            else
                print("  ❌ " .. key)
            end
        else
            print("  ⚠️ Не найден в копии: " .. key)
        end
    end
    
    print("✅ Скопировано состояний: " .. successCount .. "/" .. #originalMotors)
    return successCount > 0
end

-- Функция непрерывного копирования состояний (живая анимация)
local function startLiveMotorCopying(original, copy)
    print("🔄 Запуск живого копирования Motor6D состояний...")
    
    local originalMotors = getMotor6Ds(original)
    local copyMotors = getMotor6Ds(copy)
    
    local originalMap = createMotorMap(originalMotors)
    local copyMap = createMotorMap(copyMotors)
    
    local connection = nil
    local isRunning = true
    
    connection = RunService.Heartbeat:Connect(function()
        if not isRunning then
            connection:Disconnect()
            return
        end
        
        -- Проверяем что модели еще существуют
        if not original.Parent or not copy.Parent then
            print("⚠️ Одна из моделей удалена, останавливаю копирование")
            isRunning = false
            return
        end
        
        -- Копируем состояния всех Motor6D
        for key, originalMotor in pairs(originalMap) do
            local copyMotor = copyMap[key]
            if copyMotor and originalMotor.Parent then
                copyMotorState(originalMotor, copyMotor)
            end
        end
    end)
    
    print("✅ Живое копирование запущено!")
    print("💡 Копия должна повторять движения оригинала в реальном времени")
    
    -- Останавливаем через 30 секунд для теста
    spawn(function()
        wait(30)
        isRunning = false
        print("⏰ Живое копирование остановлено через 30 секунд")
    end)
    
    return connection
end

-- Основная функция
local function main()
    local original, copy = findModels()
    
    if not original or not copy then
        print("❌ Модели не найдены!")
        return
    end
    
    print("🎯 Найдены модели:")
    print("  Оригинал:", original.Name)
    print("  Копия:", copy.Name)
    print()
    
    -- Анализируем Motor6D в обеих моделях
    print("📊 АНАЛИЗ MOTOR6D:")
    analyzeMotorStates(original, "ОРИГИНАЛ")
    analyzeMotorStates(copy, "КОПИЯ")
    
    -- Тест 1: Однократное копирование
    print("🧪 ТЕСТ 1: Однократное копирование состояний")
    local success = copyMotorStatesOnce(original, copy)
    
    if success then
        print("✅ Однократное копирование успешно!")
        
        wait(2)
        
        -- Тест 2: Живое копирование
        print()
        print("🧪 ТЕСТ 2: Живое копирование (30 секунд)")
        print("💡 Теперь подвигай оригинального питомца - копия должна повторять!")
        
        local connection = startLiveMotorCopying(original, copy)
        
    else
        print("❌ Однократное копирование не удалось")
        print("💡 Возможно проблема в структуре Motor6D")
    end
    
    print("=" .. string.rep("=", 40))
end

-- Запуск
main()
