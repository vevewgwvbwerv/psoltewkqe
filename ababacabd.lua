-- 🎭 ANIMATION FIXER - Исправляет анимацию в масштабированных копиях питомцев
-- Работает ПОСЛЕ PetScaler - находит копии и исправляет только Anchored состояния
-- НЕ ТРОГАЕТ оригинальный PetScaler!

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer

print("🎭 === ANIMATION FIXER - ИСПРАВЛЕНИЕ АНИМАЦИИ ===")
print("=" .. string.rep("=", 60))

-- Функция поиска масштабированных копий
local function findScaledCopies()
    local copies = {}
    
    for _, obj in pairs(Workspace:GetChildren()) do
        if obj:IsA("Model") and string.find(obj.Name, "_SCALED_COPY") then
            table.insert(copies, obj)
            print("📋 Найдена копия:", obj.Name)
        end
    end
    
    return copies
end

-- Функция анализа текущих Anchored состояний
local function analyzeAnchoredStates(model)
    local anchoredParts = {}
    local freeParts = {}
    local totalParts = 0
    
    for _, obj in pairs(model:GetDescendants()) do
        if obj:IsA("BasePart") then
            totalParts = totalParts + 1
            if obj.Anchored then
                table.insert(anchoredParts, obj.Name)
            else
                table.insert(freeParts, obj.Name)
            end
        end
    end
    
    print("📊 Анализ Anchored состояний для:", model.Name)
    print("   🧩 Всего частей:", totalParts)
    print("   ⚓ Заякоренных:", #anchoredParts)
    print("   🎭 Свободных:", #freeParts)
    
    if #anchoredParts > 0 then
        print("   ⚓ Заякоренные части:", table.concat(anchoredParts, ", "))
    end
    
    return totalParts, #anchoredParts, #freeParts
end

-- Функция проверки наличия компонентов анимации
local function checkAnimationComponents(model)
    local hasAnimator = false
    local hasMotor6D = false
    local animatorLocation = "не найден"
    local motor6dCount = 0
    
    -- Проверяем Animator
    local animator = model:FindFirstChildOfClass("Animator", true)
    if animator then
        hasAnimator = true
        animatorLocation = animator.Parent.Name
    end
    
    -- Проверяем Motor6D
    for _, obj in pairs(model:GetDescendants()) do
        if obj:IsA("Motor6D") then
            motor6dCount = motor6dCount + 1
            hasMotor6D = true
        end
    end
    
    print("🔍 Компоненты анимации:")
    print("   🎬 Animator:", hasAnimator and ("✅ найден в " .. animatorLocation) or "❌ отсутствует")
    print("   🔧 Motor6D:", hasMotor6D and ("✅ найдено " .. motor6dCount .. " соединений") or "❌ отсутствуют")
    
    return hasAnimator, hasMotor6D, motor6dCount
end

-- Основная функция исправления Anchored состояний
local function fixAnchoredStates(model)
    print("\n🔧 Исправляю Anchored состояния для анимации...")
    print("   Модель:", model.Name)
    
    -- Находим основную часть для якорения
    local anchorPart = nil
    local anchorPartName = "не найдена"
    
    -- Приоритет поиска основной части
    if model:FindFirstChild("RootPart") then
        anchorPart = model.RootPart
        anchorPartName = "RootPart"
    elseif model.PrimaryPart then
        anchorPart = model.PrimaryPart
        anchorPartName = "PrimaryPart (" .. model.PrimaryPart.Name .. ")"
    elseif model:FindFirstChild("Torso") then
        anchorPart = model.Torso
        anchorPartName = "Torso"
    elseif model:FindFirstChild("HumanoidRootPart") then
        anchorPart = model.HumanoidRootPart
        anchorPartName = "HumanoidRootPart"
    else
        -- Если ничего не найдено, берем первую найденную часть
        for _, obj in pairs(model:GetDescendants()) do
            if obj:IsA("BasePart") then
                anchorPart = obj
                anchorPartName = obj.Name .. " (первая найденная)"
                break
            end
        end
    end
    
    if not anchorPart then
        print("❌ Не найдена подходящая часть для якорения!")
        return false
    end
    
    print("⚓ Выбрана основная часть для якорения:", anchorPartName)
    
    -- Применяем правильные Anchored состояния
    local fixedParts = 0
    local anchoredCount = 0
    local freeCount = 0
    
    for _, obj in pairs(model:GetDescendants()) do
        if obj:IsA("BasePart") then
            if obj == anchorPart then
                obj.Anchored = true
                anchoredCount = anchoredCount + 1
                print("   ⚓ Заякорена:", obj.Name)
            else
                obj.Anchored = false
                freeCount = freeCount + 1
            end
            fixedParts = fixedParts + 1
        end
    end
    
    print("✅ Исправлено частей:", fixedParts)
    print("   ⚓ Заякоренных:", anchoredCount)
    print("   🎭 Свободных для анимации:", freeCount)
    
    return true
end

-- Функция попытки запуска анимации
local function tryStartAnimation(model)
    print("\n🎬 Попытка запуска анимации...")
    
    local animator = model:FindFirstChildOfClass("Animator", true)
    if not animator then
        print("❌ Animator не найден - анимация невозможна")
        return false
    end
    
    print("✅ Animator найден в:", animator.Parent.Name)
    
    -- Проверяем активные анимации
    local activeAnimations = animator:GetPlayingAnimationTracks()
    print("🎭 Активных анимаций:", #activeAnimations)
    
    if #activeAnimations > 0 then
        print("✅ Анимации уже запущены!")
        for i, track in ipairs(activeAnimations) do
            print(string.format("   🎵 %s (Playing: %s, Looped: %s)", 
                track.Name or "Unnamed",
                tostring(track.IsPlaying),
                tostring(track.Looped)
            ))
        end
        return true
    else
        print("⚠️ Нет активных анимаций")
        print("💡 Анимации должны запускаться автоматически, если все настроено правильно")
        return false
    end
end

-- Основная функция
local function main()
    print("🔍 Поиск масштабированных копий...")
    
    local copies = findScaledCopies()
    
    if #copies == 0 then
        print("❌ Масштабированные копии не найдены!")
        print("💡 Сначала создайте копию с помощью PetScaler")
        return
    end
    
    print("📊 Найдено копий:", #copies)
    print()
    
    -- Обрабатываем каждую копию
    for i, copy in ipairs(copies) do
        print("🎯 === ОБРАБОТКА КОПИИ " .. i .. " ===")
        print("📋 Модель:", copy.Name)
        
        -- Анализируем текущее состояние
        local totalParts, anchoredParts, freeParts = analyzeAnchoredStates(copy)
        local hasAnimator, hasMotor6D, motor6dCount = checkAnimationComponents(copy)
        
        -- Проверяем, нужно ли исправление
        if anchoredParts == totalParts then
            print("⚠️ ВСЕ части заякорены - анимация заблокирована!")
            print("🔧 Требуется исправление Anchored состояний")
            
            -- Исправляем Anchored состояния
            if fixAnchoredStates(copy) then
                print("✅ Anchored состояния исправлены!")
                
                -- Пробуем запустить анимацию
                wait(1) -- Небольшая задержка
                tryStartAnimation(copy)
            else
                print("❌ Не удалось исправить Anchored состояния")
            end
        elseif anchoredParts == 1 then
            print("✅ Anchored состояния уже правильные (1 заякоренная часть)")
            tryStartAnimation(copy)
        else
            print("⚠️ Необычное состояние Anchored - проверяю...")
            fixAnchoredStates(copy)
            wait(1)
            tryStartAnimation(copy)
        end
        
        print("-" .. string.rep("-", 50))
    end
    
    print("\n🎉 === ОБРАБОТКА ЗАВЕРШЕНА ===")
    print("💡 Если анимация все еще не работает, проблема может быть в:")
    print("   • Отсутствии или повреждении Motor6D соединений")
    print("   • Проблемах с Animator или анимационными треками")
    print("   • Неправильном копировании анимационных данных")
end

-- Создание GUI с кнопкой
local function createGUI()
    local playerGui = player:WaitForChild("PlayerGui")
    
    -- Удаляем старый GUI если есть
    local oldGui = playerGui:FindFirstChild("AnimationFixerGUI")
    if oldGui then
        oldGui:Destroy()
    end
    
    -- Создаем ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "AnimationFixerGUI"
    screenGui.Parent = playerGui
    
    -- Создаем Frame для кнопки
    local frame = Instance.new("Frame")
    frame.Name = "MainFrame"
    frame.Size = UDim2.new(0, 220, 0, 80)
    frame.Position = UDim2.new(0, 270, 0, 50) -- Рядом с PetScaler
    frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    frame.BorderSizePixel = 2
    frame.BorderColor3 = Color3.fromRGB(255, 100, 100) -- Красная рамка
    frame.Parent = screenGui
    
    -- Создаем кнопку
    local button = Instance.new("TextButton")
    button.Name = "FixButton"
    button.Size = UDim2.new(0, 200, 0, 40)
    button.Position = UDim2.new(0, 10, 0, 20)
    button.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
    button.BorderSizePixel = 0
    button.Text = "🎭 Исправить Анимацию"
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextSize = 14
    button.Font = Enum.Font.SourceSansBold
    button.Parent = frame
    
    -- Обработчик нажатия кнопки
    button.MouseButton1Click:Connect(function()
        button.Text = "⏳ Исправляю..."
        button.BackgroundColor3 = Color3.fromRGB(255, 165, 0)
        
        -- Запускаем основную функцию
        spawn(function()
            main()
            
            -- Возвращаем кнопку в исходное состояние
            wait(2)
            button.Text = "🎭 Исправить Анимацию"
            button.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
        end)
    end)
    
    -- Эффект наведения
    button.MouseEnter:Connect(function()
        if button.BackgroundColor3 == Color3.fromRGB(255, 100, 100) then
            button.BackgroundColor3 = Color3.fromRGB(220, 80, 80)
        end
    end)
    
    button.MouseLeave:Connect(function()
        if button.BackgroundColor3 == Color3.fromRGB(220, 80, 80) then
            button.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
        end
    end)
    
    print("🖥️ AnimationFixer GUI создан! Кнопка появится рядом с PetScaler")
end

-- Запуск GUI
createGUI()
print("=" .. string.rep("=", 60))
print("💡 ИНСТРУКЦИЯ:")
print("1. Сначала используйте PetScaler для создания увеличенной копии")
print("2. Затем нажмите 'Исправить Анимацию' для включения анимации в копии")
print("=" .. string.rep("=", 60))
