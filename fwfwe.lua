-- 📊 БЫСТРЫЙ ЭКСПОРТЕР ЗАПИСАННЫХ ДАННЫХ
-- Создает готовый код для интеграции в PetScaler

local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- 🎯 СОЗДАНИЕ УПРОЩЕННОЙ АНИМАЦИИ ДЛЯ PETSCALER
local function createPetScalerAnimation()
    print("🎬 === СОЗДАНИЕ АНИМАЦИИ ДЛЯ PETSCALER ===")
    
    -- Находим питомца в руке для получения текущих Motor6D
    local character = player.Character
    if not character then
        print("❌ Character не найден!")
        return
    end
    
    local handTool = character:FindFirstChildOfClass("Tool")
    if not handTool then
        print("❌ Tool в руке не найден!")
        return
    end
    
    print("🎯 Найден Tool:", handTool.Name)
    
    -- Собираем все Motor6D
    local motor6ds = {}
    for _, obj in pairs(handTool:GetDescendants()) do
        if obj:IsA("Motor6D") then
            table.insert(motor6ds, obj)
        end
    end
    
    print(string.format("✅ Найдено Motor6D: %d", #motor6ds))
    
    -- Записываем несколько ключевых кадров idle анимации
    print("📊 Записываем ключевые кадры...")
    
    local keyFrames = {}
    local frameCount = 8  -- 8 ключевых кадров
    
    for frame = 1, frameCount do
        print(string.format("📸 Кадр %d/%d", frame, frameCount))
        
        local frameData = {}
        for _, motor in ipairs(motor6ds) do
            if motor.Parent then
                frameData[motor.Name] = {
                    c0 = motor.C0,
                    c1 = motor.C1
                }
            end
        end
        
        table.insert(keyFrames, frameData)
        wait(1) -- Ждем 1 секунду между кадрами
    end
    
    -- Создаем код для PetScaler
    print("\n💾 === СОЗДАНИЕ КОДА ДЛЯ PETSCALER ===")
    
    local code = [[
-- 🎬 IDLE АНИМАЦИЯ ДЛЯ PETSCALER (автоматически сгенерировано)
local IDLE_ANIMATION_FRAMES = {
]]
    
    for i, frameData in ipairs(keyFrames) do
        code = code .. string.format("    -- Кадр %d\n", i)
        code = code .. "    {\n"
        
        for motorName, data in pairs(frameData) do
            local c0 = data.c0
            code = code .. string.format('        ["%s"] = CFrame.new(%.3f, %.3f, %.3f) * CFrame.Angles(%.3f, %.3f, %.3f),\n',
                motorName, c0.Position.X, c0.Position.Y, c0.Position.Z,
                select(1, c0:ToEulerAnglesXYZ()), select(2, c0:ToEulerAnglesXYZ()), select(3, c0:ToEulerAnglesXYZ()))
        end
        
        code = code .. "    },\n"
    end
    
    code = code .. [[
}

-- 🎯 ФУНКЦИЯ ВОСПРОИЗВЕДЕНИЯ IDLE АНИМАЦИИ
local function playIdleAnimation(petCopy)
    if not petCopy then return end
    
    local motor6ds = {}
    for _, obj in pairs(petCopy:GetDescendants()) do
        if obj:IsA("Motor6D") then
            motor6ds[obj.Name] = obj
        end
    end
    
    local frameIndex = 1
    local connection = game:GetService("RunService").Heartbeat:Connect(function()
        if not petCopy.Parent then
            connection:Disconnect()
            return
        end
        
        local currentFrame = IDLE_ANIMATION_FRAMES[frameIndex]
        if currentFrame then
            -- Применяем кадр анимации
            for motorName, targetCFrame in pairs(currentFrame) do
                local motor = motor6ds[motorName]
                if motor and motor.Parent then
                    -- Плавная интерполяция к целевому CFrame
                    local currentC0 = motor.C0
                    motor.C0 = currentC0:Lerp(targetCFrame, 0.1)
                end
            end
        end
        
        -- Переходим к следующему кадру каждые 0.5 секунды
        if tick() % 0.5 < 0.016 then  -- ~60 FPS проверка
            frameIndex = frameIndex + 1
            if frameIndex > #IDLE_ANIMATION_FRAMES then
                frameIndex = 1  -- Зацикливаем
            end
        end
    end)
    
    print("🎬 Idle анимация запущена для копии!")
    return connection
end

-- Экспортируем функцию
return playIdleAnimation
]]
    
    -- Выводим готовый код
    print("\n📋 === ГОТОВЫЙ КОД ДЛЯ PETSCALER ===")
    print("💾 Скопируйте этот код:")
    print("\n" .. string.rep("=", 60))
    print(code)
    print(string.rep("=", 60))
    
    print(string.format("\n🎉 ГОТОВО! Создано %d ключевых кадров idle анимации", frameCount))
    print("🔧 Теперь интегрируйте этот код в PetScaler_v3.221.lua")
end

-- 🚀 ЗАПУСК
print("📊 === БЫСТРЫЙ ЭКСПОРТЕР ДАННЫХ ===")
print("🎯 Создаем упрощенную idle анимацию для PetScaler")
print("⏱️ Запуск через 2 секунды...")

wait(2)
createPetScalerAnimation()
