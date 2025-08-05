-- 🔧 ПРОСТОЙ АНАЛИЗАТОР TOOL В РУКЕ
-- Анализирует сам инструмент как источник анимации питомца

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

-- 🔍 АНАЛИЗ TOOL В РУКЕ
local function analyzeHandTool()
    print("🔧 === АНАЛИЗ TOOL В РУКЕ ===")
    
    local character = player.Character
    if not character then
        print("❌ Character не найден!")
        return
    end
    
    local handTool = character:FindFirstChildOfClass("Tool")
    if not handTool then
        print("❌ Tool в руке не найден!")
        print("💡 Возьмите питомца в руку и запустите снова")
        return
    end
    
    print("🎯 Найден Tool:", handTool.Name)
    
    -- 📊 ДЕТАЛЬНЫЙ АНАЛИЗ СТРУКТУРЫ TOOL
    print("\n📊 === СТРУКТУРА TOOL ===")
    for _, child in pairs(handTool:GetChildren()) do
        print(string.format("  - %s (%s)", child.Name, child.ClassName))
        
        -- Если это скрипт, показываем его содержимое (первые строки)
        if child:IsA("LocalScript") or child:IsA("Script") then
            print(string.format("    📜 Скрипт: %s", child.Name))
            -- Можем попробовать получить Source, но это может не работать
        end
    end
    
    -- 🎭 ПОИСК АНИМАЦИОННЫХ КОМПОНЕНТОВ В TOOL
    print("\n🎭 === ПОИСК АНИМАЦИОННЫХ КОМПОНЕНТОВ ===")
    
    local animators = {}
    local motor6ds = {}
    local humanoids = {}
    local remoteEvents = {}
    
    for _, obj in pairs(handTool:GetDescendants()) do
        if obj:IsA("Animator") then
            table.insert(animators, obj)
        elseif obj:IsA("Motor6D") then
            table.insert(motor6ds, obj)
        elseif obj:IsA("Humanoid") then
            table.insert(humanoids, obj)
        elseif obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            table.insert(remoteEvents, obj)
        end
    end
    
    print(string.format("📊 Найдено в Tool:"))
    print(string.format("  Animator: %d", #animators))
    print(string.format("  Motor6D: %d", #motor6ds))
    print(string.format("  Humanoid: %d", #humanoids))
    print(string.format("  RemoteEvent/Function: %d", #remoteEvents))
    
    -- 🎬 АНАЛИЗ АКТИВНЫХ АНИМАЦИЙ (если есть аниматоры)
    if #animators > 0 then
        print("\n🎬 === АНАЛИЗ АКТИВНЫХ АНИМАЦИЙ ===")
        for i, animator in ipairs(animators) do
            print(string.format("🎭 Аниматор %d: %s", i, animator:GetFullName()))
            
            local tracks = animator:GetPlayingAnimationTracks()
            print(string.format("  Активных треков: %d", #tracks))
            
            for j, track in ipairs(tracks) do
                print(string.format("    🎵 Трек %d:", j))
                print(string.format("      ID: %s", track.Animation.AnimationId))
                print(string.format("      Время: %.2f/%.2f", track.TimePosition, track.Length))
                print(string.format("      Зацикливание: %s", tostring(track.Looped)))
                print(string.format("      Скорость: %.2f", track.Speed))
            end
        end
    end
    
    -- 🦴 АНАЛИЗ MOTOR6D (если есть)
    if #motor6ds > 0 then
        print("\n🦴 === АНАЛИЗ MOTOR6D ===")
        for i, motor in ipairs(motor6ds) do
            print(string.format("🔧 Motor6D %d: %s", i, motor.Name))
            print(string.format("  Part0: %s", motor.Part0 and motor.Part0.Name or "nil"))
            print(string.format("  Part1: %s", motor.Part1 and motor.Part1.Name or "nil"))
            
            -- Записываем текущее состояние
            local c0 = motor.C0
            local x, y, z = c0:ToEulerAnglesXYZ()
            print(string.format("  Углы: X=%.1f°, Y=%.1f°, Z=%.1f°", 
                math.deg(x), math.deg(y), math.deg(z)))
        end
        
        -- 📊 ЗАПИСЬ ДВИЖЕНИЙ MOTOR6D
        print("\n📊 Записываем движения Motor6D на 10 секунд...")
        recordMotor6DMovements(motor6ds, 10)
    end
    
    -- 🌐 АНАЛИЗ REMOTE EVENTS
    if #remoteEvents > 0 then
        print("\n🌐 === АНАЛИЗ REMOTE EVENTS ===")
        for i, remote in ipairs(remoteEvents) do
            print(string.format("📡 Remote %d: %s (%s)", i, remote.Name, remote.ClassName))
        end
    end
    
    -- 💡 РЕКОМЕНДАЦИИ
    print("\n💡 === РЕКОМЕНДАЦИИ ===")
    if #animators == 0 and #motor6ds == 0 then
        print("🤔 Анимационные компоненты не найдены в Tool")
        print("💭 Возможно анимация обрабатывается:")
        print("   - На сервере через RemoteEvent")
        print("   - В Character игрока")
        print("   - Через GUI/ViewportFrame")
        print("   - В отдельной модели в Workspace")
    else
        print("✅ Найдены анимационные компоненты!")
        print("🎯 Можно анализировать их работу")
    end
end

-- 📊 ЗАПИСЬ ДВИЖЕНИЙ MOTOR6D
local function recordMotor6DMovements(motor6ds, duration)
    local startTime = tick()
    local recordings = {}
    
    -- Инициализация записей
    for _, motor in ipairs(motor6ds) do
        recordings[motor.Name] = {
            startAngles = {},
            endAngles = {},
            hasMovement = false
        }
        
        local c0 = motor.C0
        local x, y, z = c0:ToEulerAnglesXYZ()
        recordings[motor.Name].startAngles = {
            x = math.deg(x),
            y = math.deg(y), 
            z = math.deg(z)
        }
    end
    
    -- Ждем указанное время
    wait(duration)
    
    -- Записываем конечные состояния
    for _, motor in ipairs(motor6ds) do
        if motor.Parent then
            local c0 = motor.C0
            local x, y, z = c0:ToEulerAnglesXYZ()
            recordings[motor.Name].endAngles = {
                x = math.deg(x),
                y = math.deg(y),
                z = math.deg(z)
            }
            
            -- Проверяем было ли движение
            local deltaX = math.abs(recordings[motor.Name].endAngles.x - recordings[motor.Name].startAngles.x)
            local deltaY = math.abs(recordings[motor.Name].endAngles.y - recordings[motor.Name].startAngles.y)
            local deltaZ = math.abs(recordings[motor.Name].endAngles.z - recordings[motor.Name].startAngles.z)
            
            recordings[motor.Name].hasMovement = (deltaX + deltaY + deltaZ) > 1.0
        end
    end
    
    -- Выводим результаты
    print("\n📈 === РЕЗУЛЬТАТЫ ЗАПИСИ ===")
    for motorName, data in pairs(recordings) do
        print(string.format("🔧 %s:", motorName))
        if data.endAngles.x then
            print(string.format("  Начало: X=%.1f°, Y=%.1f°, Z=%.1f°", 
                data.startAngles.x, data.startAngles.y, data.startAngles.z))
            print(string.format("  Конец:  X=%.1f°, Y=%.1f°, Z=%.1f°", 
                data.endAngles.x, data.endAngles.y, data.endAngles.z))
            print(string.format("  Движение: %s", data.hasMovement and "ДА" or "НЕТ"))
        else
            print("  ❌ Motor6D исчез во время записи")
        end
    end
end

-- 🚀 ЗАПУСК АНАЛИЗА
analyzeHandTool()
