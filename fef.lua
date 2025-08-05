-- 🎯 АНАЛИЗАТОР ПИТОМЦА В РУКЕ
-- Изучает идеальную бесконечную idle анимацию питомца в руке

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

-- 📊 КОНФИГУРАЦИЯ
local CONFIG = {
    ANALYSIS_DURATION = 30,  -- Анализируем 30 секунд
    LOG_INTERVAL = 0.5,      -- Логируем каждые 0.5 секунды
    MOTOR6D_PRECISION = 3    -- Точность записи углов
}

-- 🔍 ПОИСК ПИТОМЦА В РУКЕ
local function findHandPet()
    local character = player.Character
    if not character then
        return nil
    end
    
    -- Ищем питомца в руке (обычно в Backpack или как Tool)
    local backpack = player.Backpack
    local handTool = character:FindFirstChildOfClass("Tool")
    
    print("🔍 === ПОИСК ПИТОМЦА В РУКЕ ===")
    
    -- Проверяем активный инструмент в руке
    if handTool then
        print("🎯 Найден активный инструмент:", handTool.Name)
        
        -- Ищем модель питомца внутри инструмента
        for _, child in pairs(handTool:GetChildren()) do
            if child:IsA("Model") and child.Name:find("{") and child.Name:find("}") then
                print("🐕 Найден питомец в руке:", child.Name)
                return child
            end
        end
    end
    
    -- Проверяем рюкзак
    if backpack then
        for _, tool in pairs(backpack:GetChildren()) do
            if tool:IsA("Tool") then
                for _, child in pairs(tool:GetChildren()) do
                    if child:IsA("Model") and child.Name:find("{") and child.Name:find("}") then
                        print("🎒 Найден питомец в рюкзаке:", child.Name)
                        print("💡 Возьмите питомца в руку для анализа!")
                        return child
                    end
                end
            end
        end
    end
    
    print("❌ Питомец в руке не найден!")
    print("💡 Убедитесь что питомец экипирован как инструмент")
    return nil
end

-- 🦴 АНАЛИЗ СТРУКТУРЫ МОДЕЛИ
local function analyzeModelStructure(petModel)
    print("\n🦴 === АНАЛИЗ СТРУКТУРЫ МОДЕЛИ ===")
    
    local motor6Ds = {}
    local animators = {}
    local humanoids = {}
    
    -- Собираем все важные компоненты
    for _, obj in pairs(petModel:GetDescendants()) do
        if obj:IsA("Motor6D") then
            table.insert(motor6Ds, obj)
        elseif obj:IsA("Animator") then
            table.insert(animators, obj)
        elseif obj:IsA("Humanoid") then
            table.insert(humanoids, obj)
        end
    end
    
    print("📊 Найдено Motor6D:", #motor6Ds)
    print("📊 Найдено Animator:", #animators)
    print("📊 Найдено Humanoid:", #humanoids)
    
    -- Детальная информация о Motor6D
    if #motor6Ds > 0 then
        print("\n🔧 MOTOR6D ДЕТАЛИ:")
        for i, motor in ipairs(motor6Ds) do
            print(string.format("  %d. %s (%s → %s)", 
                i, motor.Name, 
                motor.Part0 and motor.Part0.Name or "nil",
                motor.Part1 and motor.Part1.Name or "nil"))
        end
    end
    
    -- Информация об аниматорах
    if #animators > 0 then
        print("\n🎭 ANIMATOR ДЕТАЛИ:")
        for i, animator in ipairs(animators) do
            print(string.format("  %d. %s (Parent: %s)", 
                i, animator.Name, animator.Parent.Name))
        end
    end
    
    return motor6Ds, animators, humanoids
end

-- 🎬 АНАЛИЗ АКТИВНЫХ АНИМАЦИЙ
local function analyzeActiveAnimations(animators)
    print("\n🎬 === АНАЛИЗ АКТИВНЫХ АНИМАЦИЙ ===")
    
    for i, animator in ipairs(animators) do
        print(string.format("\n🎭 Аниматор %d: %s", i, animator.Name))
        
        -- Получаем активные треки
        local tracks = animator:GetPlayingAnimationTracks()
        print("📊 Активных треков:", #tracks)
        
        for j, track in ipairs(tracks) do
            print(string.format("  🎵 Трек %d:", j))
            print(string.format("    ID: %s", track.Animation.AnimationId))
            print(string.format("    Время: %.2f / %.2f", track.TimePosition, track.Length))
            print(string.format("    Скорость: %.2f", track.Speed))
            print(string.format("    Зацикливание: %s", tostring(track.Looped)))
            print(string.format("    Приоритет: %s", tostring(track.Priority)))
            print(string.format("    Вес: %.2f", track.WeightCurrent))
        end
    end
end

-- 📊 ЗАПИСЬ MOTOR6D СОСТОЯНИЙ
local function recordMotor6DStates(motor6Ds, duration)
    print("\n📊 === ЗАПИСЬ MOTOR6D СОСТОЯНИЙ ===")
    print(string.format("⏱️ Записываем %d секунд...", duration))
    
    local recordings = {}
    local startTime = tick()
    
    -- Инициализируем записи для каждого Motor6D
    for _, motor in ipairs(motor6Ds) do
        recordings[motor.Name] = {
            motor = motor,
            states = {}
        }
    end
    
    local connection = RunService.Heartbeat:Connect(function()
        local elapsed = tick() - startTime
        
        if elapsed >= duration then
            connection:Disconnect()
            return
        end
        
        -- Записываем состояние каждого Motor6D
        for _, motor in ipairs(motor6Ds) do
            if motor.Parent then
                local c0 = motor.C0
                local c1 = motor.C1
                
                -- Конвертируем в углы Эйлера для удобства
                local x, y, z = c0:ToEulerAnglesXYZ()
                
                table.insert(recordings[motor.Name].states, {
                    time = elapsed,
                    c0 = c0,
                    c1 = c1,
                    angles = {
                        x = math.deg(x),
                        y = math.deg(y),
                        z = math.deg(z)
                    }
                })
            end
        end
        
        -- Прогресс
        if math.floor(elapsed) % 5 == 0 and math.floor(elapsed * 10) % 10 == 0 then
            print(string.format("⏱️ Прогресс: %.1f/%.1f секунд", elapsed, duration))
        end
    end)
    
    -- Ждем завершения записи
    wait(duration + 1)
    
    return recordings
end

-- 📈 АНАЛИЗ ЗАПИСАННЫХ ДАННЫХ
local function analyzeRecordings(recordings)
    print("\n📈 === АНАЛИЗ ЗАПИСАННЫХ ДАННЫХ ===")
    
    for motorName, data in pairs(recordings) do
        local states = data.states
        if #states > 0 then
            print(string.format("\n🔧 Motor6D: %s", motorName))
            print(string.format("📊 Записано состояний: %d", #states))
            
            -- Анализируем изменения углов
            local firstState = states[1]
            local lastState = states[#states]
            
            local deltaX = math.abs(lastState.angles.x - firstState.angles.x)
            local deltaY = math.abs(lastState.angles.y - firstState.angles.y)
            local deltaZ = math.abs(lastState.angles.z - firstState.angles.z)
            
            print(string.format("📊 Изменение углов:"))
            print(string.format("    X: %.2f° (%.2f° → %.2f°)", deltaX, firstState.angles.x, lastState.angles.x))
            print(string.format("    Y: %.2f° (%.2f° → %.2f°)", deltaY, firstState.angles.y, lastState.angles.y))
            print(string.format("    Z: %.2f° (%.2f° → %.2f°)", deltaZ, firstState.angles.z, lastState.angles.z))
            
            -- Определяем активность
            local totalDelta = deltaX + deltaY + deltaZ
            if totalDelta > 5 then
                print("✅ АКТИВНЫЙ - участвует в анимации")
            else
                print("⚪ СТАТИЧНЫЙ - не анимируется")
            end
        end
    end
end

-- 🚀 ГЛАВНАЯ ФУНКЦИЯ
local function startHandPetAnalysis()
    print("🎯 === АНАЛИЗАТОР ПИТОМЦА В РУКЕ ===")
    print("🎯 Цель: изучить идеальную бесконечную idle анимацию")
    
    -- Шаг 1: Найти питомца в руке
    local handPet = findHandPet()
    if not handPet then
        return
    end
    
    -- Шаг 2: Анализ структуры
    local motor6Ds, animators, humanoids = analyzeModelStructure(handPet)
    
    -- Шаг 3: Анализ активных анимаций
    if #animators > 0 then
        analyzeActiveAnimations(animators)
    end
    
    -- Шаг 4: Запись Motor6D состояний
    if #motor6Ds > 0 then
        print(string.format("\n🎬 Начинаем запись анимации на %d секунд...", CONFIG.ANALYSIS_DURATION))
        local recordings = recordMotor6DStates(motor6Ds, CONFIG.ANALYSIS_DURATION)
        
        -- Шаг 5: Анализ записанных данных
        analyzeRecordings(recordings)
    end
    
    print("\n🎉 === АНАЛИЗ ЗАВЕРШЕН ===")
    print("💡 Теперь мы знаем как работает идеальная idle анимация!")
end

-- 🚀 ЗАПУСК
startHandPetAnalysis()
