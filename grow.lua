-- 🎯 PET SCALER - UNIFIED VERSION
-- Основан на диагностике оригинальной игры: равномерное масштабирование 1.184x

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

print("🎯 === PET SCALER - UNIFIED VERSION ===")
print("📊 Основан на анализе оригинальной игры")

-- Конфигурация (основана на диагностике)
local CONFIG = {
    SEARCH_RADIUS = 100,
    SCALE_FACTOR = 1.184, -- Точно как в оригинальной игре!
    TWEEN_TIME = 3.2,     -- Близко к времени жизни питомца (3.22 сек)
    EASING_STYLE = Enum.EasingStyle.Quad,
    EASING_DIRECTION = Enum.EasingDirection.Out
}

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
print("📍 Позиция игрока:", playerPos)

-- Функция копирования модели
local function deepCopyModel(originalModel)
    print("📋 Создаю копию модели:", originalModel.Name)
    
    local copy = originalModel:Clone()
    copy.Name = originalModel.Name .. "_UNIFIED_COPY"
    copy.Parent = Workspace
    
    -- Позиционирование копии
    if copy.PrimaryPart and originalModel.PrimaryPart then
        local originalCFrame = originalModel.PrimaryPart.CFrame
        local offset = Vector3.new(15, 0, 0)
        local newPosition = originalCFrame.Position + offset
        local newCFrame = CFrame.lookAt(newPosition, newPosition + originalCFrame.LookVector, Vector3.new(0, 1, 0))
        copy:SetPrimaryPartCFrame(newCFrame)
    end
    
    print("✅ Копия создана:", copy.Name)
    return copy
end

-- 🔥 НОВАЯ ФУНКЦИЯ: Унифицированное масштабирование как в оригинале
local function scaleModelUnified(model, scaleFactor, tweenTime)
    print("🔥 Начинаю УНИФИЦИРОВАННОЕ масштабирование:", model.Name)
    print("📐 Коэффициент масштабирования:", scaleFactor)
    
    -- Получаем все BasePart
    local parts = {}
    for _, obj in pairs(model:GetDescendants()) do
        if obj:IsA("BasePart") then
            table.insert(parts, obj)
        end
    end
    
    print("🧩 Найдено частей:", #parts)
    
    if #parts == 0 then
        print("❌ Нет частей для масштабирования!")
        return false
    end
    
    -- 🎯 КЛЮЧЕВОЕ ОТЛИЧИЕ: Сохраняем исходные размеры и применяем ОДИНАКОВЫЙ коэффициент
    local originalSizes = {}
    for _, part in ipairs(parts) do
        originalSizes[part] = part.Size
        -- Закрепляем части для стабильности
        part.Anchored = true
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
    
    -- 🔥 УНИФИЦИРОВАННОЕ масштабирование: ВСЕ части получают ОДИНАКОВЫЙ коэффициент
    local tweens = {}
    local completedTweens = 0
    
    for _, part in ipairs(parts) do
        local originalSize = originalSizes[part]
        local newSize = originalSize * scaleFactor -- Простое умножение на коэффициент!
        
        print("📏 Масштабирую", part.Name, ":", originalSize, "->", newSize)
        
        -- Создаем tween только для размера (БЕЗ сложных CFrame вычислений!)
        local tween = TweenService:Create(part, tweenInfo, {
            Size = newSize
        })
        
        tween.Completed:Connect(function()
            completedTweens = completedTweens + 1
            if completedTweens == #parts then
                print("✅ УНИФИЦИРОВАННОЕ масштабирование завершено!")
                print("🎉 Все", #parts, "частей масштабированы на", scaleFactor .. "x")
            end
        end)
        
        table.insert(tweens, tween)
        tween:Play()
    end
    
    return true
end

-- Главная функция
local function main()
    print("\n🔍 === ПОИСК ПИТОМЦА ===")
    
    local petModel = nil
    for _, obj in pairs(Workspace:GetChildren()) do
        if obj:IsA("Model") and obj ~= playerChar then
            -- Ищем модели с Humanoid (питомцы)
            local humanoid = obj:FindFirstChildOfClass("Humanoid")
            if humanoid then
                local rootPart = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Torso") or obj:FindFirstChild("UpperTorso")
                if rootPart then
                    local distance = (rootPart.Position - playerPos).Magnitude
                    if distance <= CONFIG.SEARCH_RADIUS then
                        petModel = obj
                        print("🐾 Найден питомец:", obj.Name, "на расстоянии:", math.floor(distance))
                        break
                    end
                end
            end
        end
    end
    
    if not petModel then
        print("❌ Питомец не найден в радиусе", CONFIG.SEARCH_RADIUS)
        return
    end
    
    -- Создаем копию
    print("\n📋 === СОЗДАНИЕ КОПИИ ===")
    local petCopy = deepCopyModel(petModel)
    
    -- 🔥 УНИФИЦИРОВАННОЕ масштабирование
    print("\n📏 === УНИФИЦИРОВАННОЕ МАСШТАБИРОВАНИЕ ===")
    print("🎯 Применяю коэффициент", CONFIG.SCALE_FACTOR, "ко ВСЕМ частям одинаково")
    
    wait(0.5)
    local scaleSuccess = scaleModelUnified(petCopy, CONFIG.SCALE_FACTOR, CONFIG.TWEEN_TIME)
    
    if not scaleSuccess then
        print("❌ Масштабирование не удалось!")
        return
    end
    
    -- Ждем завершения масштабирования
    wait(CONFIG.TWEEN_TIME + 1)
    
    print("\n🎉 === УСПЕХ! ===")
    print("✅ Унифицированная копия создана успешно!")
    print("📐 Масштаб:", CONFIG.SCALE_FACTOR .. "x (как в оригинале)")
    print("📍 Копия размещена рядом с оригиналом")
    print("🎯 Использован подход оригинальной игры: равномерное масштабирование")
    print("💡 БЕЗ разрозненности частей!")
end

-- Создание GUI
local function createGUI()
    local playerGui = player:WaitForChild("PlayerGui")
    
    local oldGui = playerGui:FindFirstChild("PetScalerUnifiedGUI")
    if oldGui then
        oldGui:Destroy()
    end
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "PetScalerUnifiedGUI"
    screenGui.Parent = playerGui
    
    local frame = Instance.new("Frame")
    frame.Name = "MainFrame"
    frame.Size = UDim2.new(0, 280, 0, 80)
    frame.Position = UDim2.new(0, 50, 0, 650)
    frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    frame.BorderSizePixel = 2
    frame.BorderColor3 = Color3.fromRGB(0, 150, 255) -- Синяя рамка
    frame.Parent = screenGui
    
    local button = Instance.new("TextButton")
    button.Name = "ScaleButton"
    button.Size = UDim2.new(0, 260, 0, 40)
    button.Position = UDim2.new(0, 10, 0, 20)
    button.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    button.BorderSizePixel = 0
    button.Text = "🎯 PetScaler UNIFIED"
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextSize = 14
    button.Font = Enum.Font.SourceSansBold
    button.Parent = frame
    
    button.MouseButton1Click:Connect(function()
        button.Text = "📏 Унифицированное масштабирование..."
        button.BackgroundColor3 = Color3.fromRGB(255, 165, 0)
        
        spawn(function()
            main()
            
            wait(3)
            button.Text = "🎯 PetScaler UNIFIED"
            button.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
        end)
    end)
    
    print("🖥️ PetScaler UNIFIED GUI создан!")
end

-- Запуск
createGUI()
print("💡 Нажмите СИНЮЮ кнопку для унифицированного масштабирования!")
print("🎯 UNIFIED версия - основана на анализе оригинальной игры")
print("✅ Коэффициент 1.184x применяется ко ВСЕМ частям одинаково")
print("🐾 БЕЗ разрозненности частей, как в оригинале!")
print("📊 Диагностика показала: равномерное масштабирование = успех!")
