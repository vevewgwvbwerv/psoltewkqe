-- SmartPetReplacer.lua
-- Умная замена питомца с несколькими стратегиями

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer

-- GUI элементы
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SmartPetReplacer"
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Главное окно
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 400, 0, 300)
mainFrame.Position = UDim2.new(0.5, -200, 0.5, -150)
mainFrame.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

-- Заголовок
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0, 40)
titleLabel.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
titleLabel.BorderSizePixel = 0
titleLabel.Text = "🤖 Умная замена питомца"
titleLabel.TextColor3 = Color3.new(1, 1, 1)
titleLabel.TextScaled = true
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.Parent = mainFrame

-- Статус
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -20, 0, 60)
statusLabel.Position = UDim2.new(0, 10, 0, 50)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Анализирую доступных питомцев..."
statusLabel.TextColor3 = Color3.new(1, 1, 1)
statusLabel.TextScaled = true
statusLabel.Font = Enum.Font.SourceSans
statusLabel.TextWrapped = true
statusLabel.Parent = mainFrame

-- Кнопка действия
local actionButton = Instance.new("TextButton")
actionButton.Size = UDim2.new(0, 200, 0, 40)
actionButton.Position = UDim2.new(0.5, -100, 1, -60)
actionButton.BackgroundColor3 = Color3.new(0, 0.6, 0)
actionButton.BorderSizePixel = 0
actionButton.Text = "🔄 Начать замену"
actionButton.TextColor3 = Color3.new(1, 1, 1)
actionButton.TextScaled = true
actionButton.Font = Enum.Font.SourceSansBold
actionButton.Visible = false
actionButton.Parent = mainFrame

-- Кнопка закрытия
local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 30, 0, 30)
closeButton.Position = UDim2.new(1, -35, 0, 5)
closeButton.BackgroundColor3 = Color3.new(0.8, 0, 0)
closeButton.BorderSizePixel = 0
closeButton.Text = "✕"
closeButton.TextColor3 = Color3.new(1, 1, 1)
closeButton.TextScaled = true
closeButton.Font = Enum.Font.SourceSansBold
closeButton.Parent = mainFrame

-- Функция обновления статуса
local function updateStatus(text, color)
    statusLabel.Text = text
    statusLabel.TextColor3 = color or Color3.new(1, 1, 1)
    print("📱 " .. text)
end

-- Функция поиска питомцев в Hotbar
local function findPetsInHotbar()
    local playerGui = player:FindFirstChild("PlayerGui")
    if not playerGui then return {} end
    
    local backpackGui = playerGui:FindFirstChild("BackpackGui")
    if not backpackGui then return {} end
    
    local backpack = backpackGui:FindFirstChild("Backpack")
    if not backpack then return {} end
    
    local hotbar = backpack:FindFirstChild("Hotbar")
    if not hotbar then return {} end
    
    local pets = {}
    local items = {}
    
    for _, child in pairs(hotbar:GetChildren()) do
        if child:IsA("TextButton") then
            -- Ищем текст в кнопке
            for _, desc in pairs(child:GetDescendants()) do
                if desc:IsA("TextLabel") and desc.Text ~= "" then
                    local text = desc.Text
                    local isPet = text:lower():find("kg") and text:lower():find("age")
                    
                    if isPet then
                        table.insert(pets, {
                            slot = child.Name,
                            name = text,
                            button = child
                        })
                    else
                        table.insert(items, {
                            slot = child.Name,
                            name = text,
                            button = child
                        })
                    end
                    break
                end
            end
        end
    end
    
    return pets, items
end

-- Функция поиска Dragonfly в UIGridFrame
local function findDragonflyInExtended()
    local playerGui = player:FindFirstChild("PlayerGui")
    if not playerGui then return nil end
    
    local backpackGui = playerGui:FindFirstChild("BackpackGui")
    if not backpackGui then return nil end
    
    -- Ищем UIGridFrame
    for _, desc in pairs(backpackGui:GetDescendants()) do
        if desc.Name == "UIGridFrame" and desc:IsA("Frame") then
            -- Ищем Dragonfly в UIGridFrame
            for _, child in pairs(desc:GetChildren()) do
                if child:IsA("TextButton") then
                    for _, textDesc in pairs(child:GetDescendants()) do
                        if textDesc:IsA("TextLabel") and textDesc.Text:lower():find("dragonfly") then
                            return {
                                slot = child.Name,
                                name = textDesc.Text,
                                button = child,
                                container = desc
                            }
                        end
                    end
                end
            end
        end
    end
    
    return nil
end

-- Функция анализа ситуации
local function analyzeSituation()
    updateStatus("🔍 Анализирую инвентарь...", Color3.new(0, 1, 1))
    
    local pets, items = findPetsInHotbar()
    local dragonfly = findDragonflyInExtended()
    
    updateStatus("📊 Найдено в Hotbar: " .. #pets .. " питомцев, " .. #items .. " предметов", Color3.new(1, 1, 1))
    
    if dragonfly then
        updateStatus("✅ Dragonfly найден в расширенном инвентаре: " .. dragonfly.name, Color3.new(0, 1, 0))
        
        if #items > 0 then
            -- Есть предметы для замены
            updateStatus("🎯 Стратегия: Заменить предмет на Dragonfly", Color3.new(1, 1, 0))
            return "replace_item", {pets = pets, items = items, dragonfly = dragonfly}
        else
            -- Нет предметов, нужно заменить питомца
            updateStatus("🔄 Стратегия: Заменить слабого питомца на Dragonfly", Color3.new(1, 1, 0))
            return "replace_pet", {pets = pets, items = items, dragonfly = dragonfly}
        end
    else
        -- Dragonfly не найден
        if #pets > 0 then
            updateStatus("✅ Стратегия: Использовать лучшего питомца из Hotbar", Color3.new(0, 1, 0))
            return "use_existing", {pets = pets, items = items}
        else
            updateStatus("❌ Нет доступных питомцев!", Color3.new(1, 0, 0))
            return "no_pets", {}
        end
    end
end

-- Функция выполнения стратегии
local function executeStrategy(strategy, data)
    if strategy == "replace_item" then
        updateStatus("🔧 Попытка автоматической замены предмета...", Color3.new(1, 1, 0))
        
        -- Показываем инструкции пользователю
        wait(2)
        updateStatus("📋 Инструкция: Перетащите " .. data.dragonfly.name .. " на слот " .. data.items[1].slot .. " (" .. data.items[1].name .. ")", Color3.new(1, 0.5, 0))
        
        actionButton.Text = "✅ Готово!"
        actionButton.Visible = true
        
    elseif strategy == "use_existing" then
        updateStatus("✅ Используем лучшего питомца из Hotbar", Color3.new(0, 1, 0))
        
        -- Находим лучшего питомца (по весу)
        local bestPet = data.pets[1]
        for _, pet in pairs(data.pets) do
            local weight1 = tonumber(pet.name:match("(%d+%.?%d*) KG")) or 0
            local weight2 = tonumber(bestPet.name:match("(%d+%.?%d*) KG")) or 0
            if weight1 > weight2 then
                bestPet = pet
            end
        end
        
        updateStatus("🎯 Лучший питомец: " .. bestPet.name .. " в слоте " .. bestPet.slot, Color3.new(0, 1, 0))
        
        actionButton.Text = "🎮 Выбрать питомца"
        actionButton.Visible = true
        
        -- Автоматически кликаем на лучшего питомца
        actionButton.MouseButton1Click:Connect(function()
            bestPet.button:InvokeOnClick()
            updateStatus("✅ Питомец выбран!", Color3.new(0, 1, 0))
            wait(2)
            screenGui:Destroy()
        end)
        
    elseif strategy == "no_pets" then
        updateStatus("❌ Нет доступных питомцев для замены", Color3.new(1, 0, 0))
        actionButton.Text = "😞 Закрыть"
        actionButton.Visible = true
    end
end

-- Основная логика
local function main()
    wait(1)
    
    local strategy, data = analyzeSituation()
    
    wait(2)
    executeStrategy(strategy, data)
end

-- Подключаем кнопки
closeButton.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

actionButton.MouseButton1Click:Connect(function()
    if actionButton.Text == "✅ Готово!" or actionButton.Text == "😞 Закрыть" then
        screenGui:Destroy()
    end
end)

-- Запускаем
spawn(main)

updateStatus("🚀 SmartPetReplacer запущен!", Color3.new(0, 1, 0))
