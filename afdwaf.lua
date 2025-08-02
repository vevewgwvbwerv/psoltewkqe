--[[
    IMPROVED ANIMATION TEST
    Улучшенная версия с лучшей диагностикой и принудительной анимацией
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer

print("🧪 Improved Animation Test загружен!")

-- Простой GUI с кнопкой
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ImprovedAnimationTest"
screenGui.Parent = CoreGui

local button = Instance.new("TextButton")
button.Size = UDim2.new(0, 200, 0, 50)
button.Position = UDim2.new(0, 10, 0, 190)
button.BackgroundColor3 = Color3.new(1, 0, 1)
button.Text = "🧪 IMPROVED TEST"
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
            print("✅ Найден Tool: " .. tool.Name)
            return tool
        end
    end
    
    print("❌ Tool не найден в руке!")
    return nil
end

-- Функция создания модели из Tool с подробной диагностикой
local function createModelFromTool(tool)
    print("📦 Создаю модель из Tool: " .. tool.Name)
    
    local model = Instance.new("Model")
    model.Name = tool.Name
    
    local partCount = 0
    
    -- Копируем ВСЕ BasePart из Tool
    for _, child in pairs(tool:GetChildren()) do
        if child:IsA("BasePart") then
            local partClone = child:Clone()
            partClone.Parent = model
            partCount = partCount + 1
            
            print("  📦 Скопировал: " .. child.Name .. " (Size: " .. tostring(child.Size) .. ")")
            
            -- Убираем все скрипты из клона
            for _, script in pairs(partClone:GetDescendants()) do
                if script:IsA("BaseScript") or script:IsA("LocalScript") then
                    script:Destroy()
                end
            end
        end
    end
    
    print("📊 Создана модель с " .. partCount .. " частями")
    return model, partCount
end

-- Функция ручной анимации через RunService
local function manualGrowthAnimation(model)
    print("🎬 Запускаю РУЧНУЮ анимацию роста...")
    
    local parts = {}
    local originalSizes = {}
    
    -- Собираем все части и их размеры
    for _, part in pairs(model:GetChildren()) do
        if part:IsA("BasePart") then
            table.insert(parts, part)
            originalSizes[part] = part.Size
            
            -- Устанавливаем начальные параметры
            part.Size = part.Size / 1.88  -- Маленький размер
            part.Transparency = 0.8       -- Полупрозрачный
            part.Anchored = true          -- Фиксируем
            part.CanCollide = false       -- Убираем коллизию
            
            print("  📦 Подготовил: " .. part.Name .. " к анимации")
        end
    end
    
    print("📊 Подготовлено " .. #parts .. " частей к анимации")
    
    -- Ручная анимация через RunService
    local startTime = tick()
    local animationDuration = 1.5
    
    local connection
    connection = RunService.Heartbeat:Connect(function()
        local elapsed = tick() - startTime
        local progress = math.min(elapsed / animationDuration, 1)
        
        -- Плавное увеличение размера и уменьшение прозрачности
        local sizeMultiplier = (1/1.88) + ((1 - 1/1.88) * progress)  -- От 1/1.88 до 1
        local transparency = 0.8 - (0.8 * progress)  -- От 0.8 до 0
        
        for _, part in pairs(parts) do
            if part and part.Parent then
                part.Size = originalSizes[part] * sizeMultiplier
                part.Transparency = transparency
            end
        end
        
        -- Показываем прогресс каждые 10 кадров
        if math.floor(elapsed * 60) % 10 == 0 then
            print("🔄 Анимация: " .. string.format("%.1f", progress * 100) .. "% (размер: " .. string.format("%.2f", sizeMultiplier) .. "x)")
        end
        
        if progress >= 1 then
            connection:Disconnect()
            print("✅ Анимация роста завершена!")
            
            -- Через 3 секунды удаляем модель
            wait(3)
            print("💥 Удаляю модель...")
            model:Destroy()
        end
    end)
end

-- Главная функция теста
local function improvedTest()
    print("\n🧪 === УЛУЧШЕННЫЙ ТЕСТ АНИМАЦИИ ===")
    
    -- Получаем Tool из руки
    local handTool = getHandPet()
    if not handTool then return end
    
    -- Создаем модель из Tool
    local model, partCount = createModelFromTool(handTool)
    
    if partCount == 0 then
        print("❌ Нет частей для анимации!")
        return
    end
    
    -- Позиционируем модель рядом с игроком
    local playerPosition = player.Character.HumanoidRootPart.Position
    local testPosition = playerPosition + Vector3.new(5, 2, 0) -- 5 вправо, 2 вверх
    
    model:MoveTo(testPosition)
    model.Parent = Workspace
    print("🌍 Добавил модель в Workspace на позиции: " .. tostring(testPosition))
    
    -- Запускаем ручную анимацию
    spawn(function()
        manualGrowthAnimation(model)
    end)
end

-- Обработчик кнопки
button.MouseButton1Click:Connect(function()
    button.Text = "⏳ TESTING..."
    button.BackgroundColor3 = Color3.new(1, 1, 0)
    
    spawn(function()
        improvedTest()
        
        wait(1)
        button.Text = "🧪 IMPROVED TEST"
        button.BackgroundColor3 = Color3.new(1, 0, 1)
    end)
end)

print("🎯 Улучшенный тест готов!")
print("📋 1. Держи питомца в руке")
print("📋 2. Нажми кнопку IMPROVED TEST")
print("📋 3. Смотри на анимацию - теперь с ручным управлением!")
