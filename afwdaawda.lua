-- 🎭 PET ANIMATION RESTORER - Восстановление анимации на копии питомца
-- Анализирует оригинал и восстанавливает анимацию на увеличенной копии

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

print("🎭 === PET ANIMATION RESTORER ===")
print("=" .. string.rep("=", 50))

-- Функция восстановления анимации на копии
local function restoreAnimationOnCopy(originalModel, copyModel)
    print("🔄 Восстанавливаю анимацию на копии...")
    print("  Оригинал:", originalModel.Name)
    print("  Копия:", copyModel.Name)
    
    -- 1. Находим анимационные компоненты в оригинале
    local originalAnimator = nil
    local originalAnimController = nil
    local activeAnimations = {}
    
    for _, obj in pairs(originalModel:GetDescendants()) do
        if obj:IsA("Animator") then
            originalAnimator = obj
            -- Получаем активные анимации
            local tracks = obj:GetPlayingAnimationTracks()
            for _, track in ipairs(tracks) do
                if track.IsPlaying then
                    table.insert(activeAnimations, {
                        animationId = track.Animation.AnimationId,
                        speed = track.Speed,
                        weight = track.WeightCurrent,
                        looped = track.Looped,
                        priority = track.Priority
                    })
                    print("  📹 Найдена активная анимация:", track.Animation.AnimationId)
                end
            end
        elseif obj:IsA("AnimationController") then
            originalAnimController = obj
        end
    end
    
    -- 2. Находим анимационные компоненты в копии
    local copyAnimator = nil
    local copyAnimController = nil
    
    for _, obj in pairs(copyModel:GetDescendants()) do
        if obj:IsA("Animator") then
            copyAnimator = obj
        elseif obj:IsA("AnimationController") then
            copyAnimController = obj
        end
    end
    
    if not copyAnimator or not copyAnimController then
        print("❌ Анимационные компоненты не найдены в копии!")
        return false
    end
    
    -- 3. ИСПРАВЛЕНО: Умное управление Anchored - основа закреплена, остальные свободны
    print("🔓 Настраиваю Anchored для анимации...")
    local unanchoredCount = 0
    local anchoredCount = 0
    
    -- Находим основную часть (PrimaryPart, RootPart или Torso)
    local mainPart = copyModel.PrimaryPart or copyModel:FindFirstChild("RootPart") or copyModel:FindFirstChild("Torso")
    
    for _, obj in pairs(copyModel:GetDescendants()) do
        if obj:IsA("BasePart") then
            if obj == mainPart then
                -- Основная часть остается закрепленной чтобы не падать
                obj.Anchored = true
                anchoredCount = anchoredCount + 1
                print("  ⚓ Основная часть закреплена:", obj.Name)
            else
                -- Остальные части освобождаем для анимации
                obj.Anchored = false
                unanchoredCount = unanchoredCount + 1
            end
        end
    end
    print("  ✅ Освобождено частей:", unanchoredCount)
    print("  ⚓ Закреплено частей:", anchoredCount)
    
    -- 4. Запускаем анимации на копии
    print("🎬 Запускаю анимации на копии...")
    for i, animData in ipairs(activeAnimations) do
        -- Создаем Animation объект
        local animation = Instance.new("Animation")
        animation.AnimationId = animData.animationId
        
        -- Загружаем анимацию через Animator копии
        local animTrack = copyAnimator:LoadAnimation(animation)
        
        -- Настраиваем параметры как у оригинала
        animTrack.Looped = animData.looped
        animTrack.Priority = animData.priority
        
        -- Запускаем анимацию
        animTrack:Play()
        animTrack:AdjustSpeed(animData.speed)
        animTrack:AdjustWeight(animData.weight)
        
        print("  ✅ [" .. i .. "] Запущена анимация:", animData.animationId)
        print("    Speed:", animData.speed)
        print("    Weight:", animData.weight)
        print("    Looped:", animData.looped)
    end
    
    -- 5. Проверяем что Motor6D работают
    print("🔧 Проверяю Motor6D в копии...")
    local motor6DCount = 0
    for _, obj in pairs(copyModel:GetDescendants()) do
        if obj:IsA("Motor6D") then
            motor6DCount = motor6DCount + 1
            if obj.Part0 and obj.Part1 then
                print("  ✅ Motor6D:", obj.Name, "(" .. obj.Part0.Name .. " -> " .. obj.Part1.Name .. ")")
            end
        end
    end
    print("  📊 Всего Motor6D:", motor6DCount)
    
    print("🎉 Анимация восстановлена на копии!")
    return true
end

-- Функция поиска оригинала и копии
local function findOriginalAndCopy()
    local original = nil
    local copy = nil
    
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and obj.Name:find("%{") and obj.Name:find("%}") then
            if obj.Name:find("_SCALED_COPY") then
                copy = obj
                print("🎯 Найдена копия:", obj.Name)
            else
                original = obj
                print("🎯 Найден оригинал:", obj.Name)
            end
        end
    end
    
    return original, copy
end

-- Основная функция
local function main()
    local original, copy = findOriginalAndCopy()
    
    if not original then
        print("❌ Оригинальный питомец не найден!")
        return false
    end
    
    if not copy then
        print("❌ Копия питомца не найдена!")
        print("💡 Сначала создайте копию через PetScaler")
        return false
    end
    
    -- Восстанавливаем анимацию
    local success = restoreAnimationOnCopy(original, copy)
    
    if success then
        print("✅ АНИМАЦИЯ УСПЕШНО ВОССТАНОВЛЕНА!")
        print("🎭 Копия питомца теперь должна анимироваться!")
    else
        print("❌ Не удалось восстановить анимацию")
    end
    
    print("=" .. string.rep("=", 50))
    return success
end

-- Создание GUI с кнопкой для восстановления анимации
local function createAnimationGUI()
    local Players = game:GetService("Players")
    local player = Players.LocalPlayer
    local playerGui = player:WaitForChild("PlayerGui")
    
    -- Создаем ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "PetAnimationRestorerGUI"
    screenGui.Parent = playerGui
    
    -- Создаем Frame для кнопки
    local frame = Instance.new("Frame")
    frame.Name = "AnimationFrame"
    frame.Size = UDim2.new(0, 220, 0, 80)
    frame.Position = UDim2.new(0, 270, 0, 50) -- Рядом с первой кнопкой
    frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    frame.BorderSizePixel = 2
    frame.BorderColor3 = Color3.fromRGB(255, 140, 0) -- Оранжевая рамка
    frame.Parent = screenGui
    
    -- Создаем кнопку
    local button = Instance.new("TextButton")
    button.Name = "AnimationButton"
    button.Size = UDim2.new(0, 200, 0, 40)
    button.Position = UDim2.new(0, 10, 0, 20)
    button.BackgroundColor3 = Color3.fromRGB(255, 140, 0) -- Оранжевый цвет
    button.BorderSizePixel = 0
    button.Text = "🎭 Оживить Копию"
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextSize = 14
    button.Font = Enum.Font.SourceSansBold
    button.Parent = frame
    
    -- Обработчик нажатия кнопки
    button.MouseButton1Click:Connect(function()
        button.Text = "⏳ Восстановление..."
        button.BackgroundColor3 = Color3.fromRGB(255, 165, 0)
        
        -- Запускаем восстановление анимации
        spawn(function()
            local success = main()
            
            -- Обновляем кнопку в зависимости от результата
            wait(1)
            if success then
                button.Text = "✅ Анимация Восстановлена!"
                button.BackgroundColor3 = Color3.fromRGB(0, 200, 0) -- Зеленый
                wait(3)
                button.Text = "🎭 Оживить Копию"
                button.BackgroundColor3 = Color3.fromRGB(255, 140, 0)
            else
                button.Text = "❌ Ошибка!"
                button.BackgroundColor3 = Color3.fromRGB(200, 0, 0) -- Красный
                wait(3)
                button.Text = "🎭 Оживить Копию"
                button.BackgroundColor3 = Color3.fromRGB(255, 140, 0)
            end
        end)
    end)
    
    -- Эффект наведения
    button.MouseEnter:Connect(function()
        if button.BackgroundColor3 == Color3.fromRGB(255, 140, 0) then
            button.BackgroundColor3 = Color3.fromRGB(255, 120, 0)
        end
    end)
    
    button.MouseLeave:Connect(function()
        if button.BackgroundColor3 == Color3.fromRGB(255, 120, 0) then
            button.BackgroundColor3 = Color3.fromRGB(255, 140, 0)
        end
    end)
    
    print("🎭 GUI для восстановления анимации создан!")
    print("🖱️ Нажмите кнопку '🎭 Оживить Копию' для восстановления анимации")
end

-- Запуск GUI
createAnimationGUI()
