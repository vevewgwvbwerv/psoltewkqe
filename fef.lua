-- 🔬 ГЛУБОКАЯ ДИАГНОСТИКА ПИТОМЦА - ПОНИМАЕМ КАК ОН РАБОТАЕТ
-- Анализируем ВСЕ: Motor6D, Animator, Humanoid, анимации, состояния

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

print("🔬 === ГЛУБОКАЯ ДИАГНОСТИКА ПИТОМЦА ===")
print("🎯 Цель: ПОНЯТЬ как работает idle анимация")

-- Получаем позицию игрока
local playerChar = player.Character
if not playerChar then
    print("❌ Персонаж игрока не найден!")
    return
end

local hrp = playerChar:FindFirstChild("HumanoidRootPart")
if not hrp then
    print("❌ HumanoidRootPart не найден!")
    return
end

local playerPos = hrp.Position

-- Функция поиска питомца
local function findPet()
    print("🔍 Ищу питомца рядом с игроком...")
    
    for _, obj in pairs(Workspace:GetChildren()) do
        if obj:IsA("Model") and obj ~= playerChar then
            local success, modelCFrame = pcall(function() return obj:GetModelCFrame() end)
            if success then
                local distance = (modelCFrame.Position - playerPos).Magnitude
                if distance <= 50 then
                    -- Проверяем есть ли у модели части тела питомца
                    local hasBodyParts = false
                    for _, child in pairs(obj:GetChildren()) do
                        if child:IsA("BasePart") and (child.Name:lower():find("body") or 
                           child.Name:lower():find("torso") or child.Name:lower():find("head") or
                           child.Name:lower():find("root")) then
                            hasBodyParts = true
                            break
                        end
                    end
                    
                    if hasBodyParts then
                        print("🐾 Найден питомец:", obj.Name, "на расстоянии:", math.floor(distance))
                        return obj
                    end
                end
            end
        end
    end
    
    print("❌ Питомец не найден!")
    return nil
end

-- Функция глубокого анализа питомца
local function deepAnalyzePet(petModel)
    print("\n🔬 === ГЛУБОКИЙ АНАЛИЗ ПИТОМЦА ===")
    print("📋 Модель:", petModel.Name)
    
    -- 1. АНАЛИЗ СТРУКТУРЫ МОДЕЛИ
    print("\n📁 === СТРУКТУРА МОДЕЛИ ===")
    local allChildren = petModel:GetChildren()
    print("👥 Всего детей:", #allChildren)
    
    for i, child in pairs(allChildren) do
        print(string.format("  %d. %s (%s)", i, child.Name, child.ClassName))
        
        -- Если это BasePart, показываем дополнительную информацию
        if child:IsA("BasePart") then
            print(string.format("     📐 Size: %s", tostring(child.Size)))
            print(string.format("     📍 Position: %s", tostring(child.Position)))
            print(string.format("     ⚓ Anchored: %s", tostring(child.Anchored)))
            print(string.format("     ⚡ Velocity: %s", tostring(child.Velocity)))
        end
    end
    
    -- 2. ПОИСК ВСЕХ КОМПОНЕНТОВ
    print("\n🧩 === ПОИСК КОМПОНЕНТОВ ===")
    
    local humanoid = petModel:FindFirstChildOfClass("Humanoid")
    local animator = petModel:FindFirstChildOfClass("Animator")
    local rootPart = petModel:FindFirstChild("RootPart") or petModel:FindFirstChild("Torso") or petModel:FindFirstChild("HumanoidRootPart")
    
    print("🤖 Humanoid:", humanoid and "✅ НАЙДЕН" or "❌ НЕ НАЙДЕН")
    print("🎭 Animator:", animator and "✅ НАЙДЕН" or "❌ НЕ НАЙДЕН")
    print("🎯 RootPart:", rootPart and "✅ НАЙДЕН (" .. rootPart.Name .. ")" or "❌ НЕ НАЙДЕН")
    
    -- 3. АНАЛИЗ MOTOR6D
    print("\n⚙️ === АНАЛИЗ MOTOR6D ===")
    local motors = {}
    for _, obj in pairs(petModel:GetDescendants()) do
        if obj:IsA("Motor6D") then
            table.insert(motors, obj)
        end
    end
    
    print("⚙️ Найдено Motor6D:", #motors)
    for i, motor in pairs(motors) do
        print(string.format("  %d. %s", i, motor.Name))
        print(string.format("     🔗 Part0: %s", motor.Part0 and motor.Part0.Name or "nil"))
        print(string.format("     🔗 Part1: %s", motor.Part1 and motor.Part1.Name or "nil"))
        print(string.format("     📐 C0: %s", tostring(motor.C0)))
        print(string.format("     📐 C1: %s", tostring(motor.C1)))
        print(string.format("     🔄 Transform: %s", tostring(motor.Transform)))
    end
    
    return {
        humanoid = humanoid,
        animator = animator,
        rootPart = rootPart,
        motors = motors
    }
end

-- Функция мониторинга в реальном времени
local function startRealTimeMonitoring(petData)
    print("\n📊 === ЗАПУСК МОНИТОРИНГА В РЕАЛЬНОМ ВРЕМЕНИ ===")
    print("⏱️ Обновление каждые 0.5 секунды")
    print("🎯 Следим за состоянием питомца...")
    
    local lastPosition = petData.rootPart and petData.rootPart.Position or Vector3.new(0, 0, 0)
    local isMoving = false
    local standingTime = 0
    
    local connection
    connection = RunService.Heartbeat:Connect(function()
        
        -- Проверяем движение
        if petData.rootPart and petData.rootPart.Parent then
            local currentPos = petData.rootPart.Position
            local distance = (currentPos - lastPosition).Magnitude
            
            if distance > 0.1 then
                if not isMoving then
                    print("\n🏃 === ПИТОМЕЦ НАЧАЛ ДВИГАТЬСЯ ===")
                    isMoving = true
                    standingTime = 0
                end
            else
                if isMoving then
                    print("\n🛑 === ПИТОМЕЦ ОСТАНОВИЛСЯ ===")
                    isMoving = false
                    standingTime = 0
                else
                    standingTime = standingTime + 1
                end
            end
            
            lastPosition = currentPos
        end
        
        -- ДИАГНОСТИКА КАЖДЫЕ 30 КАДРОВ (примерно 0.5 сек)
        if tick() % 0.5 < 0.02 then
            
            print(string.format("\n📊 === СОСТОЯНИЕ (%.1f сек) ===", tick()))
            print("🏃 Движется:", isMoving and "ДА" or "НЕТ")
            print("⏰ Стоит уже:", standingTime, "кадров")
            
            -- Анализ Humanoid
            if petData.humanoid and petData.humanoid.Parent then
                print("🤖 === HUMANOID ===")
                print("  🏃 WalkSpeed:", petData.humanoid.WalkSpeed)
                print("  🦘 JumpPower:", petData.humanoid.JumpPower or "nil")
                print("  🦘 JumpHeight:", petData.humanoid.JumpHeight or "nil")
                print("  🛑 PlatformStand:", petData.humanoid.PlatformStand or "nil")
                print("  💺 Sit:", petData.humanoid.Sit or "nil")
                print("  🎯 State:", petData.humanoid:GetState().Name)
                print("  ❤️ Health:", petData.humanoid.Health)
            else
                print("❌ HUMANOID ПРОПАЛ!")
            end
            
            -- Анализ Animator
            if petData.animator and petData.animator.Parent then
                print("🎭 === ANIMATOR ===")
                local tracks = petData.animator:GetPlayingAnimationTracks()
                print("  📽️ Играющих анимаций:", #tracks)
                
                for i, track in pairs(tracks) do
                    print(string.format("    %d. %s", i, track.Animation.Name))
                    print(string.format("       🆔 ID: %s", track.Animation.AnimationId))
                    print(string.format("       ▶️ Playing: %s", track.IsPlaying))
                    print(string.format("       🔄 Looped: %s", track.Looped))
                    print(string.format("       ⚡ Priority: %s", track.Priority.Name))
                    print(string.format("       ⏱️ Time: %.2f", track.TimePosition))
                    print(string.format("       📏 Length: %.2f", track.Length or 0))
                    print(string.format("       🔊 Weight: %.2f", track.WeightCurrent))
                end
            else
                print("❌ ANIMATOR ПРОПАЛ!")
            end
            
            -- Анализ позиции и скорости
            if petData.rootPart and petData.rootPart.Parent then
                print("📍 === ПОЗИЦИЯ И ДВИЖЕНИЕ ===")
                print("  📍 Position:", petData.rootPart.Position)
                print("  ⚡ Velocity:", petData.rootPart.Velocity)
                print("  🌀 AngularVelocity:", petData.rootPart.AngularVelocity)
            end
            
            -- ОСОБОЕ ВНИМАНИЕ КОГДА ПИТОМЕЦ СТОИТ ДОЛГО
            if not isMoving and standingTime > 60 then -- Стоит больше 1 секунды
                print("\n🎯 === ПИТОМЕЦ ДОЛГО СТОИТ - ДЕТАЛЬНЫЙ АНАЛИЗ ===")
                
                -- Анализ Motor6D в момент стояния
                print("⚙️ === MOTOR6D В МОМЕНТ СТОЯНИЯ ===")
                for i, motor in pairs(petData.motors) do
                    if motor.Parent then
                        print(string.format("  %s:", motor.Name))
                        print(string.format("    🔄 Transform: %s", tostring(motor.Transform)))
                        print(string.format("    📐 C0: %s", tostring(motor.C0)))
                        print(string.format("    📐 C1: %s", tostring(motor.C1)))
                    end
                end
            end
        end
    end)
    
    print("✅ Мониторинг запущен! Наблюдайте за выводом...")
    return connection
end

-- Главная функция
local function main()
    local petModel = findPet()
    if not petModel then
        return
    end
    
    local petData = deepAnalyzePet(petModel)
    
    print("\n🎮 === НАЧИНАЕМ МОНИТОРИНГ ===")
    print("💡 Подойдите к питомцу и наблюдайте за выводом")
    print("🎯 Особое внимание на моменты когда питомец СТОИТ")
    
    local connection = startRealTimeMonitoring(petData)
    
    -- Останавливаем через 60 секунд
    spawn(function()
        wait(60)
        connection:Disconnect()
        print("\n⏹️ Мониторинг остановлен через 60 секунд")
    end)
end

-- 🚀 ПРЯМОЙ ЗАПУСК ДИАГНОСТИКИ
print("\n🚀 === ЗАПУСКАЮ ДИАГНОСТИКУ СРАЗУ ===")
print("💡 Подойдите к питомцу и смотрите консоль!")
print("🔬 Анализ будет идти 60 секунд...")

-- Запускаем диагностику сразу
spawn(function()
    wait(2) -- Небольшая задержка для загрузки
    main()
end)

-- Создание GUI (исправленная версия)
local function createGUI()
    print("🖥️ Создаю диагностический GUI...")
    
    local playerGui = player.PlayerGui
    if not playerGui then
        print("❌ PlayerGui не найден!")
        return
    end
    
    -- Удаляем старый GUI
    local oldGui = playerGui:FindFirstChild("PetDiagnosticGUI")
    if oldGui then
        oldGui:Destroy()
        print("🗑️ Удалил старый GUI")
    end
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "PetDiagnosticGUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = playerGui
    
    local frame = Instance.new("Frame")
    frame.Name = "MainFrame"
    frame.Size = UDim2.new(0, 300, 0, 100)
    frame.Position = UDim2.new(0, 50, 0, 200)
    frame.BackgroundColor3 = Color3.fromRGB(50, 0, 50)
    frame.BorderSizePixel = 3
    frame.BorderColor3 = Color3.fromRGB(255, 0, 255)
    frame.Parent = screenGui
    
    -- Заголовок
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 0, 30)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "🔬 ДИАГНОСТИКА ПИТОМЦА"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 16
    title.Font = Enum.Font.SourceSansBold
    title.Parent = frame
    
    local button = Instance.new("TextButton")
    button.Name = "DiagnosticButton"
    button.Size = UDim2.new(0, 280, 0, 50)
    button.Position = UDim2.new(0, 10, 0, 40)
    button.BackgroundColor3 = Color3.fromRGB(255, 0, 255)
    button.BorderSizePixel = 0
    button.Text = "🔬 ЗАПУСТИТЬ ДИАГНОСТИКУ"
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextSize = 18
    button.Font = Enum.Font.SourceSansBold
    button.Parent = frame
    
    button.MouseButton1Click:Connect(function()
        print("\n🔬 === КНОПКА НАЖАТА! ЗАПУСКАЮ ДИАГНОСТИКУ ===\n")
        button.Text = "🔬 АНАЛИЗИРУЮ..."
        button.BackgroundColor3 = Color3.fromRGB(255, 165, 0)
        
        spawn(function()
            main()
            
            wait(5)
            button.Text = "🔬 ЗАПУСТИТЬ ДИАГНОСТИКУ"
            button.BackgroundColor3 = Color3.fromRGB(255, 0, 255)
        end)
    end)
    
    print("✅ Диагностический GUI создан успешно!")
    print("📍 Позиция GUI: левый верх экрана")
    print("🎯 Ищите ФИОЛЕТОВУЮ кнопку!")
end

-- Создаем GUI
createGUI()

print("\n💡 === ИНСТРУКЦИИ ===\n")
print("🎯 1. Ищите ФИОЛЕТОВУЮ кнопку в левом верхнем углу")
print("🔬 2. Нажмите кнопку для запуска диагностики")
print("📊 3. Смотрите консоль для анализа")
print("🐾 4. Подойдите к питомцу во время анализа")
print("⏰ 5. Диагностика длится 60 секунд")
print("\n🚀 ДИАГНОСТИКА УЖЕ ЗАПУЩЕНА АВТОМАТИЧЕСКИ!")
