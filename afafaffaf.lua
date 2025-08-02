--[[
    SIMPLE MODEL LISTER
    Показывает ВСЕ модели рядом с игроком - без всякой фильтрации
]]

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer
local foundModels = {}

print("📋 Simple Model Lister загружен!")

-- GUI с фиксированной позицией
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SimpleModelLister"
screenGui.Parent = CoreGui

local listButton = Instance.new("TextButton")
listButton.Size = UDim2.new(0, 180, 0, 40)
listButton.Position = UDim2.new(0, 10, 0, 100)  -- ФИКСИРОВАННАЯ позиция
listButton.BackgroundColor3 = Color3.new(1, 0.5, 0)
listButton.Text = "📋 LIST ALL MODELS"
listButton.TextColor3 = Color3.new(1, 1, 1)
listButton.TextScaled = true
listButton.Font = Enum.Font.GothamBold
listButton.Parent = screenGui

local copyButton = Instance.new("TextButton")
copyButton.Size = UDim2.new(0, 180, 0, 40)
copyButton.Position = UDim2.new(0, 200, 0, 100)  -- ФИКСИРОВАННАЯ позиция
copyButton.BackgroundColor3 = Color3.new(0, 1, 0)
copyButton.Text = "🎯 COPY MODEL #1"
copyButton.TextColor3 = Color3.new(1, 1, 1)
copyButton.TextScaled = true
copyButton.Font = Enum.Font.GothamBold
copyButton.Parent = screenGui

-- Функция показа ВСЕХ моделей рядом
local function listAllModels()
    print("\n📋 === ВСЕ МОДЕЛИ РЯДОМ С ИГРОКОМ ===")
    
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
        print("❌ Character не найден!")
        return
    end
    
    local playerPos = player.Character.HumanoidRootPart.Position
    foundModels = {}
    
    -- Показываем ВСЕ модели в радиусе 30 единиц
    for i, child in pairs(Workspace:GetChildren()) do
        if child:IsA("Model") and child ~= player.Character then
            
            local modelPos = nil
            local partCount = 0
            
            -- Находим любую BasePart для определения позиции
            for _, part in pairs(child:GetChildren()) do
                if part:IsA("BasePart") then
                    if not modelPos then
                        modelPos = part.Position
                    end
                    partCount = partCount + 1
                end
            end
            
            if modelPos then
                local distance = (modelPos - playerPos).Magnitude
                
                if distance < 30 then  -- В радиусе 30 единиц
                    table.insert(foundModels, child)
                    
                    print("📦 #" .. #foundModels .. ": " .. child.Name)
                    print("   📏 Расстояние: " .. string.format("%.1f", distance))
                    print("   🧱 Частей: " .. partCount)
                    
                    -- Показываем первые 3 части
                    local showCount = 0
                    for _, part in pairs(child:GetChildren()) do
                        if part:IsA("BasePart") and showCount < 3 then
                            showCount = showCount + 1
                            print("     - " .. part.Name .. " (" .. tostring(part.Size) .. ")")
                        end
                    end
                    print("")
                end
            end
        end
    end
    
    print("📊 Найдено моделей: " .. #foundModels)
    
    if #foundModels > 0 then
        print("✅ Теперь можешь скопировать любую модель!")
        print("🎯 Нажми COPY MODEL #1 чтобы скопировать первую модель")
    else
        print("❌ Модели рядом не найдены!")
    end
end

-- Функция копирования первой найденной модели
local function copyFirstModel()
    print("\n🎯 === КОПИРОВАНИЕ ПЕРВОЙ МОДЕЛИ ===")
    
    if #foundModels == 0 then
        print("❌ Сначала найди модели!")
        return
    end
    
    local model = foundModels[1]
    print("📦 Копирую модель: " .. model.Name)
    
    -- Клонируем модель
    local clone = model:Clone()
    clone.Name = "TestClone"
    
    -- Ставим рядом с игроком
    local playerPos = player.Character.HumanoidRootPart.Position
    local targetPos = playerPos + Vector3.new(3, 3, 0)
    
    if clone.PrimaryPart then
        clone:SetPrimaryPartCFrame(CFrame.new(targetPos))
    else
        clone:MoveTo(targetPos)
    end
    
    clone.Parent = Workspace
    print("🌍 Клон добавлен в Workspace")
    
    -- Простая анимация роста
    local parts = {}
    local originalSizes = {}
    
    for _, part in pairs(clone:GetDescendants()) do
        if part:IsA("BasePart") then
            table.insert(parts, part)
            originalSizes[part] = part.Size
            part.Size = part.Size / 1.88
            part.Transparency = 0.8
            part.Anchored = true
            part.CanCollide = false
        end
    end
    
    print("📊 Анимирую " .. #parts .. " частей...")
    
    -- Анимация
    for i = 1, 15 do
        local progress = i / 15
        local sizeMultiplier = (1/1.88) + ((1 - 1/1.88) * progress)
        local transparency = 0.8 - (0.8 * progress)
        
        for _, part in pairs(parts) do
            if part and part.Parent then
                part.Size = originalSizes[part] * sizeMultiplier
                part.Transparency = transparency
            end
        end
        
        wait(0.1)
    end
    
    print("✅ Анимация завершена!")
    
    -- Удаляем через 3 секунды
    wait(3)
    clone:Destroy()
    print("🗑️ Клон удален")
end

-- Обработчики кнопок
listButton.MouseButton1Click:Connect(function()
    listButton.Text = "⏳ LISTING..."
    spawn(function()
        listAllModels()
        wait(1)
        listButton.Text = "📋 LIST ALL MODELS"
    end)
end)

copyButton.MouseButton1Click:Connect(function()
    copyButton.Text = "⏳ COPYING..."
    spawn(function()
        copyFirstModel()
        wait(1)
        copyButton.Text = "🎯 COPY MODEL #1"
    end)
end)

print("🎯 Simple Model Lister готов!")
print("📋 1. Нажми LIST ALL MODELS")
print("📋 2. Посмотри в консоль - там будут ВСЕ модели рядом")
print("📋 3. Нажми COPY MODEL #1 для анимации")
