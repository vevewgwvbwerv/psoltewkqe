-- 📊 ЗАПИСЫВАЮЩИЙ СКРИПТ MOTOR6D IDLE АНИМАЦИИ
-- Записывает идеальную idle анимацию питомца в руке для применения на копии

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer

-- 📊 КОНФИГУРАЦИЯ ЗАПИСИ
local CONFIG = {
    RECORD_DURATION = 8,      -- Записываем 8 секунд (полный цикл анимации)
    FRAME_RATE = 30,          -- 30 кадров в секунду
    EXPORT_FORMAT = "LUA"     -- Формат экспорта данных
}

-- 📊 ГЛОБАЛЬНЫЕ ПЕРЕМЕННЫЕ
local recordedFrames = {}
local motor6DList = {}
local isRecording = false

-- 🔍 ПОИСК И АНАЛИЗ ПИТОМЦА В РУКЕ
local function findHandPetMotor6Ds()
    local character = player.Character
    if not character then
        print("❌ Character не найден!")
        return nil
    end
    
    local handTool = character:FindFirstChildOfClass("Tool")
    if not handTool then
        print("❌ Tool в руке не найден!")
        print("💡 Возьмите питомца в руку и запустите снова")
        return nil
    end
    
    print("🎯 Найден Tool:", handTool.Name)
    
    -- Собираем все Motor6D из Tool
    local motor6ds = {}
    for _, obj in pairs(handTool:GetDescendants()) do
        if obj:IsA("Motor6D") then
            table.insert(motor6ds, obj)
        end
    end
    
    if #motor6ds == 0 then
        print("❌ Motor6D не найдены в Tool!")
        return nil
    end
    
    print(string.format("✅ Найдено Motor6D: %d", #motor6ds))
    
    -- Показываем структуру
    for i, motor in ipairs(motor6ds) do
        print(string.format("  %d. %s (%s → %s)", 
            i, motor.Name,
            motor.Part0 and motor.Part0.Name or "nil",
            motor.Part1 and motor.Part1.Name or "nil"))
    end
    
    return motor6ds
end

-- 📊 ЗАПИСЬ КАДРА АНИМАЦИИ
local function recordFrame(frameIndex, elapsedTime)
    local frame = {
        index = frameIndex,
        time = elapsedTime,
        motor6ds = {}
    }
    
    for _, motor in ipairs(motor6DList) do
        if motor.Parent then
            frame.motor6ds[motor.Name] = {
                c0 = motor.C0,
                c1 = motor.C1,
                -- Дополнительная информация для отладки
                part0 = motor.Part0 and motor.Part0.Name or "nil",
                part1 = motor.Part1 and motor.Part1.Name or "nil"
            }
        end
    end
    
    table.insert(recordedFrames, frame)
end

-- 🎬 ГЛАВНАЯ ФУНКЦИЯ ЗАПИСИ
local function startRecording()
    print("\n🎬 === ЗАПИСЬ MOTOR6D IDLE АНИМАЦИИ ===")
    
    -- Поиск Motor6D в питомце
    motor6DList = findHandPetMotor6Ds()
    if not motor6DList then
        return
    end
    
    -- Подготовка к записи
    recordedFrames = {}
    isRecording = true
    
    local startTime = tick()
    local frameInterval = 1 / CONFIG.FRAME_RATE
    local nextFrameTime = 0
    local frameIndex = 0
    
    print(string.format("🎯 Начинаем запись на %.1f секунд с частотой %d FPS", 
        CONFIG.RECORD_DURATION, CONFIG.FRAME_RATE))
    print("⏱️ Убедитесь что питомец играет idle анимацию...")
    
    -- Основной цикл записи
    local connection = RunService.Heartbeat:Connect(function()
        local elapsedTime = tick() - startTime
        
        -- Проверяем время окончания записи
        if elapsedTime >= CONFIG.RECORD_DURATION then
            connection:Disconnect()
            isRecording = false
            finishRecording()
            return
        end
        
        -- Записываем кадр с нужной частотой
        if elapsedTime >= nextFrameTime then
            frameIndex = frameIndex + 1
            recordFrame(frameIndex, elapsedTime)
            nextFrameTime = nextFrameTime + frameInterval
            
            -- Показываем прогресс каждые 2 секунды
            if frameIndex % (CONFIG.FRAME_RATE * 2) == 0 then
                print(string.format("📊 Записано кадров: %d (%.1f/%.1f сек)", 
                    frameIndex, elapsedTime, CONFIG.RECORD_DURATION))
            end
        end
    end)
end

-- 🎉 ЗАВЕРШЕНИЕ ЗАПИСИ И ЭКСПОРТ
local function finishRecording()
    print(string.format("\n🎉 === ЗАПИСЬ ЗАВЕРШЕНА ==="))
    print(string.format("📊 Записано кадров: %d", #recordedFrames))
    print(string.format("⏱️ Длительность: %.2f секунд", CONFIG.RECORD_DURATION))
    print(string.format("🎯 Частота: %d FPS", CONFIG.FRAME_RATE))
    
    if #recordedFrames == 0 then
        print("❌ Кадры не записаны!")
        return
    end
    
    -- Анализ записанных данных
    analyzeRecordedData()
    
    -- Экспорт данных
    exportAnimationData()
end

-- 📈 АНАЛИЗ ЗАПИСАННЫХ ДАННЫХ
local function analyzeRecordedData()
    print("\n📈 === АНАЛИЗ ЗАПИСАННЫХ ДАННЫХ ===")
    
    if #recordedFrames < 2 then
        print("❌ Недостаточно кадров для анализа")
        return
    end
    
    local firstFrame = recordedFrames[1]
    local lastFrame = recordedFrames[#recordedFrames]
    
    -- Анализируем каждый Motor6D
    for motorName, _ in pairs(firstFrame.motor6ds) do
        local firstC0 = firstFrame.motor6ds[motorName].c0
        local lastC0 = lastFrame.motor6ds[motorName].c0
        
        -- Вычисляем изменение углов
        local firstX, firstY, firstZ = firstC0:ToEulerAnglesXYZ()
        local lastX, lastY, lastZ = lastC0:ToEulerAnglesXYZ()
        
        local deltaX = math.abs(math.deg(lastX - firstX))
        local deltaY = math.abs(math.deg(lastY - firstY))
        local deltaZ = math.abs(math.deg(lastZ - firstZ))
        local totalDelta = deltaX + deltaY + deltaZ
        
        print(string.format("🔧 %s:", motorName))
        print(string.format("  Изменение углов: X=%.1f°, Y=%.1f°, Z=%.1f°", deltaX, deltaY, deltaZ))
        
        if totalDelta > 5 then
            print("  ✅ АКТИВНЫЙ - участвует в анимации")
        else
            print("  ⚪ СТАТИЧНЫЙ - не анимируется")
        end
    end
end

-- 💾 ЭКСПОРТ ДАННЫХ АНИМАЦИИ
local function exportAnimationData()
    print("\n💾 === ЭКСПОРТ ДАННЫХ АНИМАЦИИ ===")
    
    -- Создаем Lua код для интеграции в PetScaler
    local luaCode = "-- 🎬 ЗАПИСАННАЯ IDLE АНИМАЦИЯ ПИТОМЦА В РУКЕ\n"
    luaCode = luaCode .. "-- Автоматически сгенерировано Motor6DIdleRecorder.lua\n\n"
    
    luaCode = luaCode .. "local RECORDED_IDLE_ANIMATION = {\n"
    luaCode = luaCode .. string.format("    duration = %.2f,\n", CONFIG.RECORD_DURATION)
    luaCode = luaCode .. string.format("    frameRate = %d,\n", CONFIG.FRAME_RATE)
    luaCode = luaCode .. string.format("    totalFrames = %d,\n", #recordedFrames)
    luaCode = luaCode .. "    frames = {\n"
    
    -- Экспортируем каждый кадр (каждый 5-й для оптимизации)
    local exportStep = math.max(1, math.floor(#recordedFrames / 60)) -- Максимум 60 кадров
    
    for i = 1, #recordedFrames, exportStep do
        local frame = recordedFrames[i]
        luaCode = luaCode .. string.format("        [%d] = {\n", i)
        luaCode = luaCode .. string.format("            time = %.3f,\n", frame.time)
        luaCode = luaCode .. "            motor6ds = {\n"
        
        for motorName, data in pairs(frame.motor6ds) do
            local c0 = data.c0
            luaCode = luaCode .. string.format("                [\"%s\"] = CFrame.new(%.3f, %.3f, %.3f, %.3f, %.3f, %.3f, %.3f, %.3f, %.3f, %.3f, %.3f, %.3f),\n",
                motorName, c0.X, c0.Y, c0.Z, c0.RightVector.X, c0.UpVector.X, -c0.LookVector.X,
                c0.RightVector.Y, c0.UpVector.Y, -c0.LookVector.Y, c0.RightVector.Z, c0.UpVector.Z, -c0.LookVector.Z)
        end
        
        luaCode = luaCode .. "            },\n"
        luaCode = luaCode .. "        },\n"
    end
    
    luaCode = luaCode .. "    }\n"
    luaCode = luaCode .. "}\n\n"
    
    -- Добавляем функцию воспроизведения
    luaCode = luaCode .. "-- 🎯 ФУНКЦИЯ ВОСПРОИЗВЕДЕНИЯ ЗАПИСАННОЙ АНИМАЦИИ\n"
    luaCode = luaCode .. "local function playRecordedIdleAnimation(petModel)\n"
    luaCode = luaCode .. "    -- Ваш код воспроизведения здесь\n"
    luaCode = luaCode .. "    print('🎬 Воспроизводим записанную idle анимацию!')\n"
    luaCode = luaCode .. "end\n\n"
    
    luaCode = luaCode .. "return RECORDED_IDLE_ANIMATION\n"
    
    -- Выводим код в консоль
    print("📋 === ЭКСПОРТИРОВАННЫЙ КОД ===")
    print("💾 Скопируйте этот код для интеграции в PetScaler:")
    print("\n" .. string.rep("=", 50))
    print(luaCode)
    print(string.rep("=", 50))
    
    print(string.format("\n✅ Экспорт завершен! Записано %d ключевых кадров", 
        math.ceil(#recordedFrames / exportStep)))
    print("🎯 Теперь можно интегрировать эти данные в PetScaler!")
end

-- 🚀 ГЛАВНАЯ ФУНКЦИЯ ЗАПУСКА
local function main()
    print("📊 === MOTOR6D IDLE RECORDER ===")
    print("🎯 Цель: записать идеальную idle анимацию питомца в руке")
    print("💡 Убедитесь что питомец в руке играет idle анимацию")
    print("\n⏱️ Запуск записи через 3 секунды...")
    
    wait(3)
    startRecording()
end

-- 🚀 ЗАПУСК
main()
