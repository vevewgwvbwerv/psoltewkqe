-- TextReplacer.lua
-- Замена текста в GUI элементах инвентаря

local Players = game:GetService("Players")
local player = Players.LocalPlayer

print("=== TEXT REPLACER ===")

-- Функция поиска и замены текста в Hotbar
local function replaceTextInHotbar(slotNumber, newText)
    local playerGui = player:FindFirstChild("PlayerGui")
    if not playerGui then
        print("❌ PlayerGui не найден!")
        return false
    end
    
    local backpackGui = playerGui:FindFirstChild("BackpackGui")
    if not backpackGui then
        print("❌ BackpackGui не найден!")
        return false
    end
    
    local backpack = backpackGui:FindFirstChild("Backpack")
    if not backpack then
        print("❌ Backpack не найден!")
        return false
    end
    
    local hotbar = backpack:FindFirstChild("Hotbar")
    if not hotbar then
        print("❌ Hotbar не найден!")
        return false
    end
    
    print("✅ Hotbar найден, ищу слот " .. slotNumber)
    
    -- Ищем слот с указанным номером
    local targetSlot = hotbar:FindFirstChild(tostring(slotNumber))
    if not targetSlot then
        print("❌ Слот " .. slotNumber .. " не найден в Hotbar")
        return false
    end
    
    print("✅ Слот " .. slotNumber .. " найден")
    
    -- Ищем TextLabel в слоте
    local textLabel = nil
    for _, desc in pairs(targetSlot:GetDescendants()) do
        if desc:IsA("TextLabel") and desc.Text ~= "" then
            textLabel = desc
            break
        end
    end
    
    if not textLabel then
        print("❌ TextLabel не найден в слоте " .. slotNumber)
        return false
    end
    
    local oldText = textLabel.Text
    print("📝 Старый текст: " .. oldText)
    print("🔄 Меняю на: " .. newText)
    
    -- Заменяем текст
    textLabel.Text = newText
    
    print("✅ Текст успешно заменен!")
    print("   Слот: " .. slotNumber)
    print("   Было: " .. oldText)
    print("   Стало: " .. newText)
    
    return true
end

-- Функция показа всех текстов в Hotbar
local function showAllHotbarTexts()
    local playerGui = player:FindFirstChild("PlayerGui")
    if not playerGui then return end
    
    local backpackGui = playerGui:FindFirstChild("BackpackGui")
    if not backpackGui then return end
    
    local backpack = backpackGui:FindFirstChild("Backpack")
    if not backpack then return end
    
    local hotbar = backpack:FindFirstChild("Hotbar")
    if not hotbar then return end
    
    print("📋 Все тексты в Hotbar:")
    
    for i = 1, 10 do
        local slot = hotbar:FindFirstChild(tostring(i))
        if slot then
            for _, desc in pairs(slot:GetDescendants()) do
                if desc:IsA("TextLabel") and desc.Text ~= "" then
                    print("   Слот " .. i .. ": " .. desc.Text)
                    break
                end
            end
        end
    end
end

-- Функция создания GUI для управления
local function createControlGUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "TextReplacerGUI"
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
    titleLabel.Text = "📝 Замена текста в инвентаре"
    titleLabel.TextColor3 = Color3.new(1, 1, 1)
    titleLabel.TextScaled = true
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.Parent = mainFrame
    
    -- Кнопка замены слота 1
    local replaceSlot1Button = Instance.new("TextButton")
    replaceSlot1Button.Size = UDim2.new(1, -20, 0, 40)
    replaceSlot1Button.Position = UDim2.new(0, 10, 0, 60)
    replaceSlot1Button.BackgroundColor3 = Color3.new(0, 0.6, 0)
    replaceSlot1Button.BorderSizePixel = 0
    replaceSlot1Button.Text = "🔄 Заменить слот 1 на Dragonfly"
    replaceSlot1Button.TextColor3 = Color3.new(1, 1, 1)
    replaceSlot1Button.TextScaled = true
    replaceSlot1Button.Font = Enum.Font.SourceSansBold
    replaceSlot1Button.Parent = mainFrame
    
    -- Кнопка замены слота 2
    local replaceSlot2Button = Instance.new("TextButton")
    replaceSlot2Button.Size = UDim2.new(1, -20, 0, 40)
    replaceSlot2Button.Position = UDim2.new(0, 10, 0, 110)
    replaceSlot2Button.BackgroundColor3 = Color3.new(0, 0.6, 0)
    replaceSlot2Button.BorderSizePixel = 0
    replaceSlot2Button.Text = "🔄 Заменить слот 2 на Dragonfly"
    replaceSlot2Button.TextColor3 = Color3.new(1, 1, 1)
    replaceSlot2Button.TextScaled = true
    replaceSlot2Button.Font = Enum.Font.SourceSansBold
    replaceSlot2Button.Parent = mainFrame
    
    -- Кнопка показа всех текстов
    local showAllButton = Instance.new("TextButton")
    showAllButton.Size = UDim2.new(1, -20, 0, 40)
    showAllButton.Position = UDim2.new(0, 10, 0, 160)
    showAllButton.BackgroundColor3 = Color3.new(0, 0.4, 0.8)
    showAllButton.BorderSizePixel = 0
    showAllButton.Text = "📋 Показать все тексты"
    showAllButton.TextColor3 = Color3.new(1, 1, 1)
    showAllButton.TextScaled = true
    showAllButton.Font = Enum.Font.SourceSansBold
    showAllButton.Parent = mainFrame
    
    -- Кнопка закрытия
    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.new(1, -20, 0, 40)
    closeButton.Position = UDim2.new(0, 10, 0, 210)
    closeButton.BackgroundColor3 = Color3.new(0.8, 0, 0)
    closeButton.BorderSizePixel = 0
    closeButton.Text = "❌ Закрыть"
    closeButton.TextColor3 = Color3.new(1, 1, 1)
    closeButton.TextScaled = true
    closeButton.Font = Enum.Font.SourceSansBold
    closeButton.Parent = mainFrame
    
    -- Подключаем события
    replaceSlot1Button.MouseButton1Click:Connect(function()
        replaceTextInHotbar(1, "Dragonfly [6.36 KG] [Age 35]")
    end)
    
    replaceSlot2Button.MouseButton1Click:Connect(function()
        replaceTextInHotbar(2, "Dragonfly [6.36 KG] [Age 35]")
    end)
    
    showAllButton.MouseButton1Click:Connect(function()
        showAllHotbarTexts()
    end)
    
    closeButton.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)
end

-- Тестирование
print("🧪 Тестирую замену текста...")

-- Показываем текущие тексты
showAllHotbarTexts()

print("")
print("🎯 Попытка замены слота 1...")
local success = replaceTextInHotbar(1, "Dragonfly [6.36 KG] [Age 35]")

if success then
    print("✅ Замена успешна! Проверяем результат...")
    wait(1)
    showAllHotbarTexts()
else
    print("❌ Замена не удалась")
end

-- Создаем GUI для управления
print("")
print("🎮 Создаю GUI для управления...")
createControlGUI()

print("=== TEXT REPLACER ГОТОВ ===")
