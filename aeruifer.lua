--[[
    TEST GROWTH ANIMATION
    Тестируем анимацию роста на клоне питомца из руки
    Просто берем питомца из руки и показываем анимацию рядом
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer

print("🧪 Test Growth Animation загружен!")

-- Простой GUI с кнопкой
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TestGrowthAnimation"
screenGui.Parent = CoreGui

local button = Instance.new("TextButton")
button.Size = UDim2.new(0, 200, 0, 50)
button.Position = UDim2.new(0, 10, 0, 10)
button.BackgroundColor3 = Color3.new(0, 1, 0)
button.Text = "🧪 TEST GROWTH ANIMATION"
button.TextColor3 = Color3.new(1, 1, 1)
button.TextScaled = true
button.Font = Enum.Font.GothamBold
button.Parent = screenGui

-- Функция получения питомца из руки
local function getHandPet()
    if not player.Character then 
        print("❌ Character не найден!")
        return nil 
    end
    
    for _, tool in pairs(player.Character:GetChildren()) do
        if tool:IsA("Tool") then
            local model = tool:FindFirstChildWhichIsA("Model")
            if model then
                print("✅ Найден питомец в руке: " .. model.Name)
                return model
            end
        end
    end
    
    print("❌ Питомец в руке не найден!")
    return nil
end

-- Функция клонирования питомца
local function clonePet(originalModel)
    local clone = originalModel:Clone()
    
    -- Убираем скрипты из клона
    for _, script in pairs(clone:GetDescendants()) do
        if script:IsA("BaseScript") or script:IsA("LocalScript") then
            script:Destroy()
        end
    end
    
    print("📋 Клон создан: " .. clone.Name)
    return clone
end

-- Функция тестовой анимации роста
local function testGrowthAnimation()
    print("\n🧪 === ТЕСТ АНИМАЦИИ РОСТА ===")
    
    -- Получаем питомца из руки
    local handPet = getHandPet()
    if not handPet then return end
    
    -- Клонируем питомца
    local clone = clonePet(handPet)
    
    -- Позиционируем клон рядом с игроком
    local playerPosition = player.Character.HumanoidRootPart.Position
    local testPosition = playerPosition + Vector3.new(5, 0, 0) -- 5 единиц вправо
    
    if clone.PrimaryPart then
        clone:SetPrimaryPartCFrame(CFrame.new(testPosition))
        print("📍 Позиционировал клон через PrimaryPart")
    else
        clone:MoveTo(testPosition)
        print("📍 Позиционировал клон через MoveTo")
    end
    
    clone.Parent = Workspace
    print("🌍 Добавил клон в Workspace")
    
    -- Подготавливаем анимацию
    local originalSizes = {}
    local tweens = {}
    local partCount = 0
    
    print("📊 Подготавливаю анимацию...")
    
    for _, part in pairs(clone:GetDescendants()) do
        if part:IsA("BasePart") then
            partCount = partCount + 1
            originalSizes[part] = part.Size
            
            -- Начинаем с размера 1/1.88 от оригинала
            local startSize = part.Size / 1.88
            part.Size = startSize
            part.Transparency = 0.8  -- Полупрозрачный
            part.Anchored = true     -- Фиксируем
            
            print("  📦 " .. part.Name .. ": " .. tostring(startSize) .. " → " .. tostring(originalSizes[part]))
            
            -- Создаем анимацию роста (точно как в записи)
            local growTween = TweenService:Create(part, 
                TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), 
                {
                    Size = originalSizes[part],
                    Transparency = 0
                }
            )
            
            table.insert(tweens, growTween)
        end
    end
    
    print("🎬 Найдено " .. partCount .. " частей для анимации")
    print("📈 Запускаю рост в 1.88 раз...")
    
    -- Запускаем все анимации одновременно
    for _, tween in pairs(tweens) do
        tween:Play()
    end
    
    print("⏰ Анимация запущена! Длительность: 1.5 секунд")
    print("🔍 Смотри на клон рядом с собой!")
    
    -- Через 4 секунды удаляем клон
    wait(4)
    
    print("💥 Удаляю тестовый клон...")
    
    -- Анимация исчезновения
    local fadeTweens = {}
    for _, part in pairs(clone:GetDescendants()) do
        if part:IsA("BasePart") then
            local fadeTween = TweenService:Create(part,
                TweenInfo.new(0.5, Enum.EasingStyle.Quad),
                { Transparency = 1 }
            )
            table.insert(fadeTweens, fadeTween)
        end
    end
    
    for _, tween in pairs(fadeTweens) do
        tween:Play()
    end
    
    wait(0.5)
    clone:Destroy()
    
    print("✅ Тест завершен!")
    print("🎯 Если анимация выглядела правильно, можно использовать для замены питомца из яйца!")
end

-- Обработчик кнопки
button.MouseButton1Click:Connect(function()
    button.Text = "⏳ TESTING..."
    button.BackgroundColor3 = Color3.new(1, 1, 0)
    
    spawn(function()
        testGrowthAnimation()
        
        wait(1)
        button.Text = "🧪 TEST GROWTH ANIMATION"
        button.BackgroundColor3 = Color3.new(0, 1, 0)
    end)
end)

print("🎯 Готов к тестированию!")
print("📋 1. Возьми питомца в руку")
print("📋 2. Нажми кнопку TEST GROWTH ANIMATION")
print("📋 3. Смотри на анимацию рядом с собой")
