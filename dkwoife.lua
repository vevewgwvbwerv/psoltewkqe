-- 🤖 PET SCALER INDEPENDENT - Создание независимого питомца
-- Клонирует AnimationController и все анимации для создания самостоятельного питомца

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

print("🤖 === PET SCALER INDEPENDENT ===")
print("Создаем независимого питомца с собственной анимацией!")

-- Конфигурация
local CONFIG = {
    SEARCH_RADIUS = 100,
    SCALE_FACTOR = 3.0,
    TWEEN_TIME = 3.0,
    EASING_STYLE = Enum.EasingStyle.Quad,
    EASING_DIRECTION = Enum.EasingDirection.Out
}

-- Функция поиска питомца
local function findPet()
    local playerChar = player.Character
    if not playerChar then return nil end
    
    local hrp = playerChar:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    
    local playerPos = hrp.Position
    
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and obj.Name:match("%x%x%x%x%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%x%x%x%x%x%x%x%x") then
            if obj.PrimaryPart then
                local distance = (obj.PrimaryPart.Position - playerPos).Magnitude
                if distance <= CONFIG.SEARCH_RADIUS then
                    return obj
                end
            end
        end
    end
    
    return nil
end

-- Функция глубокого копирования модели
local function deepCopyModel(originalModel)
    print("📋 Создаю глубокую копию модели:", originalModel.Name)
    
    local copy = originalModel:Clone()
    copy.Name = originalModel.Name .. "_INDEPENDENT_COPY"
    copy.Parent = Workspace
    
    -- Позиционирование копии
    if copy.PrimaryPart and originalModel.PrimaryPart then
        local originalCFrame = originalModel.PrimaryPart.CFrame
        local offset = Vector3.new(15, 0, 0)
        
        local targetPosition = originalCFrame.Position + offset
        
        local raycastParams = RaycastParams.new()
        raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
        raycastParams.FilterDescendantsInstances = {copy, originalModel}
        
        local rayOrigin = Vector3.new(targetPosition.X, targetPosition.Y + 100, targetPosition.Z)
        local rayDirection = Vector3.new(0, -200, 0)
        
        local raycastResult = Workspace:Raycast(rayOrigin, rayDirection, raycastParams)
        
        if raycastResult then
            local groundY = raycastResult.Position.Y
            local finalPosition = Vector3.new(targetPosition.X, groundY, targetPosition.Z)
            
            local newCFrame = CFrame.new(finalPosition, finalPosition + originalCFrame.LookVector)
            copy:SetPrimaryPartCFrame(newCFrame)
            print("📍 Копия размещена на земле")
        else
            local newCFrame = CFrame.new(targetPosition, targetPosition + originalCFrame.LookVector)
            copy:SetPrimaryPartCFrame(newCFrame)
            print("📍 Копия размещена на уровне оригинала")
        end
    end
    
    print("✅ Копия создана:", copy.Name)
    return copy
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

-- Функция плавного масштабирования модели
local function scaleModelSmoothly(model, scaleFactor, tweenTime)
    print("🔥 Начинаю плавное масштабирование модели:", model.Name)
    
    local parts = getAllParts(model)
    
    if #parts == 0 then
        print("❌ Не найдено частей для масштабирования")
        return false
    end
    
    print("📊 Найдено частей для масштабирования:", #parts)
    
    -- Сохраняем оригинальные данные
    local originalData = {}
    for _, part in ipairs(parts) do
        originalData[part] = {
            size = part.Size,
            cframe = part.CFrame
        }
    end
    
    -- Создаем TweenInfo
    local tweenInfo = TweenInfo.new(
        tweenTime,
        CONFIG.EASING_STYLE,
        CONFIG.EASING_DIRECTION,
        0,
        false,
        0
    )
    
    -- Масштабирование через CFrame
    local tweens = {}
    local completedTweens = 0
    
    for _, part in ipairs(parts) do
        local originalSize = originalData[part].size
        local originalCFrame = originalData[part].cframe
        
        local newSize = originalSize * scaleFactor
        
        local tween = TweenService:Create(part, tweenInfo, {
            Size = newSize,
            CFrame = originalCFrame
        })
        
        tween.Completed:Connect(function()
            completedTweens = completedTweens + 1
            if completedTweens == #parts then
                print("🎉 Все " .. #parts .. " частей успешно увеличены в " .. scaleFactor .. "x")
            end
        end)
        
        table.insert(tweens, tween)
        tween:Play()
    end
    
    print("🚀 Запущено " .. #tweens .. " твинов для плавного масштабирования")
    return true
end

-- Функция умного управления Anchored
local function smartAnchoredManagement(copyParts)
    print("🧠 Умное управление Anchored...")
    
    local rootPart = nil
    
    for _, part in ipairs(copyParts) do
        if part.Name == "HumanoidRootPart" or part.Name == "RootPart" or part.Name == "Torso" then
            rootPart = part
            part.Anchored = true
            print("  ⚓ Заякорен корень:", part.Name)
        else
            part.Anchored = false
            print("  🆓 Освобожден:", part.Name)
        end
    end
    
    print("  ✅ Anchored настроен: корень заякорен, остальные свободны")
    return rootPart
end

-- ГЛАВНАЯ ФУНКЦИЯ - КЛОНИРОВАНИЕ АНИМАЦИОННЫХ КОМПОНЕНТОВ
local function cloneAnimationComponents(original, copy)
    print("\n🤖 === КЛОНИРОВАНИЕ АНИМАЦИОННЫХ КОМПОНЕНТОВ ===")
    
    -- 1. ПОИСК ANIMATION CONTROLLER В ОРИГИНАЛЕ
    local originalAnimController = original:FindFirstChildOfClass("AnimationController")
    if not originalAnimController then
        print("❌ AnimationController не найден в оригинале")
        return false
    end
    
    print("✅ Найден AnimationController в оригинале")
    
    -- 2. КЛОНИРОВАНИЕ ANIMATION CONTROLLER
    local clonedAnimController = originalAnimController:Clone()
    clonedAnimController.Parent = copy
    
    print("✅ AnimationController склонирован в копию")
    
    -- 3. ПОИСК ANIMATOR В КЛОНИРОВАННОМ КОНТРОЛЛЕРЕ
    local clonedAnimator = clonedAnimController:FindFirstChildOfClass("Animator")
    if not clonedAnimator then
        print("❌ Animator не найден в склонированном контроллере")
        return false
    end
    
    print("✅ Animator найден в склонированном контроллере")
    
    -- 4. СОЗДАНИЕ IDLE АНИМАЦИИ
    print("\n🎭 === СОЗДАНИЕ IDLE АНИМАЦИИ ===")
    
    -- Создаем Animation объект с найденным rbxassetid
    local idleAnimation = Instance.new("Animation")
    idleAnimation.Name = "IdleAnimation"
    idleAnimation.AnimationId = "rbxassetid://107329390413456"  -- Найденный ID
    idleAnimation.Parent = clonedAnimController
    
    print("✅ Создан Animation объект с ID: rbxassetid://107329390413456")
    
    -- 5. ЗАГРУЗКА И ЗАПУСК АНИМАЦИИ
    wait(1) -- Даем время на инициализацию
    
    print("\n🚀 === ЗАПУСК НЕЗАВИСИМОЙ АНИМАЦИИ ===")
    
    local success, idleTrack = pcall(function()
        return clonedAnimator:LoadAnimation(idleAnimation)
    end)
    
    if success and idleTrack then
        print("✅ Анимация загружена успешно")
        
        -- Настраиваем анимацию
        idleTrack.Looped = true
        idleTrack.Priority = Enum.AnimationPriority.Action
        
        -- Запускаем анимацию
        idleTrack:Play()
        
        print("🎉 IDLE анимация запущена и зациклена!")
        print("💡 Копия теперь независимый питомец с собственной анимацией!")
        
        return true
    else
        print("❌ Ошибка загрузки анимации:", idleTrack)
        return false
    end
end

-- Основная функция
local function main()
    print("\n🔍 === ПОИСК ПИТОМЦА ===")
    
    local petModel = findPet()
    if not petModel then
        print("❌ Питомец не найден в радиусе", CONFIG.SEARCH_RADIUS, "блоков")
        return
    end
    
    print("✅ Питомец найден:", petModel.Name)
    
    -- Шаг 1: Создание копии
    print("\n📋 === СОЗДАНИЕ КОПИИ ===")
    local petCopy = deepCopyModel(petModel)
    
    -- Шаг 2: Масштабирование
    print("\n🔥 === МАСШТАБИРОВАНИЕ ===")
    
    -- Временно закрепляем все части
    local copyParts = getAllParts(petCopy)
    for _, part in ipairs(copyParts) do
        if part:IsA("BasePart") then
            part.Anchored = true
        end
    end
    
    wait(0.5)
    local scaleSuccess = scaleModelSmoothly(petCopy, CONFIG.SCALE_FACTOR, CONFIG.TWEEN_TIME)
    
    if not scaleSuccess then
        print("❌ Масштабирование не удалось!")
        return
    end
    
    -- Шаг 3: Настройка Anchored
    print("\n🧠 === НАСТРОЙКА ANCHORED ===")
    wait(CONFIG.TWEEN_TIME + 1)
    
    local rootPart = smartAnchoredManagement(copyParts)
    
    -- Шаг 4: Клонирование анимационных компонентов
    print("\n🤖 === КЛОНИРОВАНИЕ АНИМАЦИИ ===")
    
    local animationSuccess = cloneAnimationComponents(petModel, petCopy)
    
    if animationSuccess then
        print("\n🎉 === УСПЕХ! ===")
        print("✅ Масштабированная копия создана")
        print("✅ Независимая анимация запущена")
        print("🤖 Копия теперь самостоятельный питомец!")
        print("💡 Она будет анимироваться независимо от оригинала!")
    else
        print("\n⚠️ === ЧАСТИЧНЫЙ УСПЕХ ===")
        print("✅ Масштабированная копия создана")
        print("❌ Независимая анимация не запустилась")
        print("💡 Возможно нужны дополнительные настройки")
    end
end

-- Создание GUI
local function createGUI()
    local playerGui = player:WaitForChild("PlayerGui")
    
    local oldGui = playerGui:FindFirstChild("PetScalerIndependentGUI")
    if oldGui then
        oldGui:Destroy()
    end
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "PetScalerIndependentGUI"
    screenGui.Parent = playerGui
    
    local frame = Instance.new("Frame")
    frame.Name = "MainFrame"
    frame.Size = UDim2.new(0, 280, 0, 80)
    frame.Position = UDim2.new(0, 50, 0, 250) -- Под другими GUI
    frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    frame.BorderSizePixel = 2
    frame.BorderColor3 = Color3.fromRGB(0, 150, 255) -- Синяя рамка
    frame.Parent = screenGui
    
    local button = Instance.new("TextButton")
    button.Name = "IndependentButton"
    button.Size = UDim2.new(0, 260, 0, 40)
    button.Position = UDim2.new(0, 10, 0, 20)
    button.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    button.BorderSizePixel = 0
    button.Text = "🤖 Независимый Питомец"
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextSize = 14
    button.Font = Enum.Font.SourceSansBold
    button.Parent = frame
    
    button.MouseButton1Click:Connect(function()
        button.Text = "⏳ Создаю независимого питомца..."
        button.BackgroundColor3 = Color3.fromRGB(255, 165, 0)
        
        spawn(function()
            main()
            
            wait(3)
            button.Text = "🤖 Независимый Питомец"
            button.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
        end)
    end)
    
    button.MouseEnter:Connect(function()
        if button.BackgroundColor3 == Color3.fromRGB(0, 150, 255) then
            button.BackgroundColor3 = Color3.fromRGB(0, 130, 220)
        end
    end)
    
    button.MouseLeave:Connect(function()
        if button.BackgroundColor3 == Color3.fromRGB(0, 130, 220) then
            button.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
        end
    end)
    
    print("🖥️ PetScaler Independent GUI создан!")
end

-- Запуск
createGUI()
print("=" .. string.rep("=", 70))
print("💡 PETSCALER INDEPENDENT:")
print("   🤖 Создает полностью независимого питомца")
print("   🎭 Клонирует все анимационные компоненты")
print("   🔄 Запускает собственную idle анимацию")
print("   ✨ Копия анимируется независимо от оригинала!")
print("🎯 Нажмите синюю кнопку для создания независимого питомца!")
print("=" .. string.rep("=", 70))
