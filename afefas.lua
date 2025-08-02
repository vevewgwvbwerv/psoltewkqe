--[[
    SIMPLE DEBUG TEST
    Максимально простая версия для отладки анимации
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer

print("🔍 Simple Debug Test загружен!")

-- Простой GUI с кнопкой
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SimpleDebugTest"
screenGui.Parent = CoreGui

local button = Instance.new("TextButton")
button.Size = UDim2.new(0, 200, 0, 50)
button.Position = UDim2.new(0, 10, 0, 250)
button.BackgroundColor3 = Color3.new(1, 0.5, 0)
button.Text = "🔍 SIMPLE DEBUG"
button.TextColor3 = Color3.new(1, 1, 1)
button.TextScaled = true
button.Font = Enum.Font.GothamBold
button.Parent = screenGui

-- Функция простого теста
local function simpleDebugTest()
    print("\n🔍 === ПРОСТОЙ ТЕСТ ОТЛАДКИ ===")
    
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
        print("❌ Handle не найден в Tool!")
        return
    end
    
    print("✅ Handle найден: " .. handle.Name .. " (Size: " .. tostring(handle.Size) .. ")")
    
    -- Клонируем только Handle
    local clone = handle:Clone()
    clone.Name = "TestClone"
    
    -- Позиционируем клон
    local playerPos = player.Character.HumanoidRootPart.Position
    clone.Position = playerPos + Vector3.new(3, 3, 0)  -- 3 вправо, 3 вверх
    clone.Anchored = true
    clone.CanCollide = false
    clone.Parent = Workspace
    
    print("🌍 Клон добавлен в Workspace на позиции: " .. tostring(clone.Position))
    
    -- Сохраняем оригинальный размер
    local originalSize = clone.Size
    print("📏 Оригинальный размер: " .. tostring(originalSize))
    
    -- Устанавливаем маленький размер
    local smallSize = originalSize / 1.88
    clone.Size = smallSize
    clone.Transparency = 0.8
    
    print("📏 Установлен маленький размер: " .. tostring(smallSize))
    print("💫 Установлена прозрачность: 0.8")
    
    -- Ждем 1 секунду чтобы увидеть маленький размер
    wait(1)
    print("⏰ Прошла 1 секунда, начинаю анимацию...")
    
    -- Простая анимация - меняем размер каждые 0.1 секунды
    local steps = 15  -- 15 шагов по 0.1 секунды = 1.5 секунды
    local sizeStep = (originalSize - smallSize) / steps
    local transparencyStep = 0.8 / steps
    
    for i = 1, steps do
        local currentSize = smallSize + (sizeStep * i)
        local currentTransparency = 0.8 - (transparencyStep * i)
        
        clone.Size = currentSize
        clone.Transparency = currentTransparency
        
        print("🔄 Шаг " .. i .. "/" .. steps .. ": Size=" .. tostring(currentSize) .. ", Trans=" .. string.format("%.2f", currentTransparency))
        
        wait(0.1)
    end
    
    print("✅ Анимация завершена!")
    print("📏 Финальный размер: " .. tostring(clone.Size))
    print("💫 Финальная прозрачность: " .. clone.Transparency)
    
    -- Ждем 3 секунды и удаляем
    wait(3)
    clone:Destroy()
    print("💥 Клон удален")
end

-- Обработчик кнопки
button.MouseButton1Click:Connect(function()
    button.Text = "⏳ TESTING..."
    button.BackgroundColor3 = Color3.new(1, 1, 0)
    
    spawn(function()
        simpleDebugTest()
        
        wait(1)
        button.Text = "🔍 SIMPLE DEBUG"
        button.BackgroundColor3 = Color3.new(1, 0.5, 0)
    end)
end)

print("🎯 Simple Debug Test готов!")
print("📋 Этот тест покажет каждый шаг анимации в консоли")
print("📋 Нажми кнопку и смотри подробные логи!")
