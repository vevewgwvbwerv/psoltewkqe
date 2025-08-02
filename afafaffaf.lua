--[[
    FIXED TEST GROWTH ANIMATION
    Исправленная версия под реальную структуру питомца
    Питомец = Tool с BasePart объектами (не Model)
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer

print("🧪 Fixed Test Growth Animation загружен!")

-- Простой GUI с кнопкой
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FixedTestGrowthAnimation"
screenGui.Parent = CoreGui

local button = Instance.new("TextButton")
button.Size = UDim2.new(0, 200, 0, 50)
button.Position = UDim2.new(0, 10, 0, 130)
button.BackgroundColor3 = Color3.new(0, 1, 0)
button.Text = "🧪 FIXED TEST ANIMATION"
button.TextColor3 = Color3.new(1, 1, 1)
button.TextScaled = true
button.Font = Enum.Font.GothamBold
button.Parent = screenGui

-- Функция получения питомца из руки (исправленная)
local function getHandPet()
    if not player.Character then 
        print("❌ Character не найден!")
        return nil 
    end
    
    for _, tool in pairs(player.Character:GetChildren()) do
        if tool:IsA("Tool") then
            print("✅ Найден Tool: " .. tool.Name)
            return tool  -- Возвращаем сам Tool, не Model внутри
        end
    end
    
    print("❌ Tool не найден в руке!")
    return nil
end

-- Функция создания модели из Tool
local function createModelFromTool(tool)
    print("📦 Создаю модель из Tool: " .. tool.Name)
    
    -- Создаем новую модель
    local model = Instance.new("Model")
    model.Name = tool.Name
    
    -- Копируем все BasePart из Tool в модель
    local partCount = 0
    for _, child in pairs(tool:GetChildren()) do
        if child:IsA("BasePart") and child.Name ~= "Handle" then
            local partClone = child:Clone()
            partClone.Parent = model
            partCount = partCount + 1
            print("  📦 Скопировал часть: " .. child.Name)
        end
    end
    
    -- Если есть Handle, тоже копируем
    local handle = tool:FindFirstChild("Handle")
    if handle then
        local handleClone = handle:Clone()
        handleClone.Name = "Body"  -- Переименовываем Handle в Body
        handleClone.Parent = model
        partCount = partCount + 1
        print("  📦 Скопировал Handle как Body")
    end
    
    print("📊 Создана модель с " .. partCount .. " частями")
    return model
end

-- Функция тестовой анимации роста
local function testGrowthAnimation()
    print("\n🧪 === ТЕСТ АНИМАЦИИ РОСТА (ИСПРАВЛЕННЫЙ) ===")
    
    -- Получаем Tool из руки
    local handTool = getHandPet()
    if not handTool then return end
    
    -- Создаем модель из Tool
    local model = createModelFromTool(handTool)
    
    -- Позиционируем модель рядом с игроком
    local playerPosition = player.Character.HumanoidRootPart.Position
    local testPosition = playerPosition + Vector3.new(5, 0, 0) -- 5 единиц вправо
    
    model:MoveTo(testPosition)
    model.Parent = Workspace
    print("🌍 Добавил модель в Workspace")
    
    -- Подготавливаем анимацию
    local originalSizes = {}
    local tweens = {}
    local partCount = 0
    
    print("📊 Подготавливаю анимацию...")
    
    for _, part in pairs(model:GetChildren()) do
        if part:IsA("BasePart") then
            partCount = partCount + 1
            originalSizes[part] = part.Size
            
            -- Начинаем с размера 1/1.88 от оригинала (как в записи)
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
    print("🔍 Смотри на модель рядом с собой!")
    
    -- Через 4 секунды удаляем модель
    wait(4)
    
    print("💥 Удаляю тестовую модель...")
    
    -- Анимация исчезновения
    local fadeTweens = {}
    for _, part in pairs(model:GetChildren()) do
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
    model:Destroy()
    
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
        button.Text = "🧪 FIXED TEST ANIMATION"
        button.BackgroundColor3 = Color3.new(0, 1, 0)
    end)
end)

print("🎯 Готов к тестированию!")
print("📋 1. Убедись что питомец в руке")
print("📋 2. Нажми кнопку FIXED TEST ANIMATION")
print("📋 3. Смотри на анимацию рядом с собой")
