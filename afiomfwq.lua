--[[
    VISIBLE SIZE TEST
    Тест с принудительно увеличенным размером для видимости
]]

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer

print("👁️ Visible Size Test загружен!")

-- Простой GUI с кнопкой
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "VisibleSizeTest"
screenGui.Parent = CoreGui

local button = Instance.new("TextButton")
button.Size = UDim2.new(0, 200, 0, 50)
button.Position = UDim2.new(0, 10, 0, 310)
button.BackgroundColor3 = Color3.new(0, 1, 1)
button.Text = "👁️ VISIBLE SIZE TEST"
button.TextColor3 = Color3.new(0, 0, 0)
button.TextScaled = true
button.Font = Enum.Font.GothamBold
button.Parent = screenGui

-- Функция теста с видимым размером
local function visibleSizeTest()
    print("\n👁️ === ТЕСТ С ВИДИМЫМ РАЗМЕРОМ ===")
    
    -- Получаем Tool
    local tool = nil
    for _, child in pairs(player.Character:GetChildren()) do
        if child:IsA("Tool") then
            tool = child
            break
        end
    end
    
    if not tool then
        print("❌ Tool не найден!")
        return
    end
    
    print("✅ Tool найден: " .. tool.Name)
    
    -- Находим Handle
    local handle = tool:FindFirstChild("Handle")
    if not handle then
        print("❌ Handle не найден!")
        return
    end
    
    print("✅ Handle найден с размером: " .. tostring(handle.Size))
    
    -- Клонируем Handle
    local clone = handle:Clone()
    clone.Name = "VisibleTestClone"
    
    -- Позиционируем клон
    local playerPos = player.Character.HumanoidRootPart.Position
    clone.Position = playerPos + Vector3.new(3, 5, 0)  -- Высоко в воздухе
    clone.Anchored = true
    clone.CanCollide = false
    clone.Parent = Workspace
    
    print("🌍 Клон добавлен в Workspace")
    
    -- ПРИНУДИТЕЛЬНО устанавливаем ВИДИМЫЙ размер
    local targetSize = Vector3.new(4, 4, 4)  -- Большой видимый размер 4x4x4
    local startSize = Vector3.new(1, 1, 1)   -- Начинаем с размера 1x1x1
    
    clone.Size = startSize
    clone.Transparency = 0.8
    clone.BrickColor = BrickColor.new("Bright red")  -- Красный цвет для видимости
    
    print("📏 Установлен начальный размер: " .. tostring(startSize))
    print("🎯 Целевой размер: " .. tostring(targetSize))
    print("🔴 Цвет изменен на красный для видимости")
    
    -- Ждем 1 секунду
    wait(1)
    print("⏰ Начинаю анимацию увеличения...")
    
    -- Анимация увеличения с большими шагами
    local steps = 20
    local sizeStep = (targetSize - startSize) / steps
    local transparencyStep = 0.8 / steps
    
    for i = 1, steps do
        local currentSize = startSize + (sizeStep * i)
        local currentTransparency = 0.8 - (transparencyStep * i)
        
        clone.Size = currentSize
        clone.Transparency = currentTransparency
        
        if i % 5 == 0 then  -- Каждый 5-й шаг
            print("🔄 Шаг " .. i .. "/" .. steps .. ": Size=" .. tostring(currentSize) .. ", Trans=" .. string.format("%.2f", currentTransparency))
        end
        
        wait(0.1)
    end
    
    print("✅ Анимация завершена!")
    print("📏 Финальный размер: " .. tostring(clone.Size))
    print("💫 Финальная прозрачность: " .. clone.Transparency)
    print("👁️ Теперь клон должен быть ХОРОШО ВИДИМЫМ!")
    
    -- Ждем 5 секунд чтобы посмотреть
    wait(5)
    
    -- Анимация исчезновения
    print("💥 Начинаю исчезновение...")
    for i = 1, 10 do
        clone.Transparency = i / 10
        wait(0.1)
    end
    
    clone:Destroy()
    print("🗑️ Клон удален")
end

-- Обработчик кнопки
button.MouseButton1Click:Connect(function()
    button.Text = "⏳ TESTING..."
    button.BackgroundColor3 = Color3.new(1, 1, 0)
    
    spawn(function()
        visibleSizeTest()
        
        wait(1)
        button.Text = "👁️ VISIBLE SIZE TEST"
        button.BackgroundColor3 = Color3.new(0, 1, 1)
    end)
end)

print("🎯 Visible Size Test готов!")
print("📋 Этот тест использует БОЛЬШИЕ размеры (1x1x1 → 4x4x4)")
print("📋 И красный цвет для максимальной видимости!")
print("📋 Нажми кнопку и смотри на красный куб в воздухе!")
