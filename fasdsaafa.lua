-- DirectSlotReplacer.lua
-- Прямая замена Tool в слоте 1 Hotbar

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

print("=== DIRECT SLOT REPLACER ===")

-- Функция поиска питомца в руке
local function findHandPetTool()
    local character = player.Character
    if not character then return nil end
    
    for _, tool in pairs(character:GetChildren()) do
        if tool:IsA("Tool") and string.find(tool.Name, "%[") and string.find(tool.Name, "KG%]") then
            return tool
        end
    end
    return nil
end

-- НОВЫЙ ПОДХОД: Прямое управление слотом через StarterPlayer
local function replaceSlot1Direct()
    print("\n🔄 === ПРЯМАЯ ЗАМЕНА СЛОТА 1 ===")
    
    -- Находим питомца для копирования
    local sourceTool = findHandPetTool()
    if not sourceTool then
        print("❌ Питомец в руке не найден!")
        return false
    end
    
    print("✅ Найден питомец: " .. sourceTool.Name)
    
    local character = player.Character
    if not character then
        print("❌ Персонаж не найден!")
        return false
    end
    
    -- Шаг 1: Создаем копию питомца
    print("🔧 Создаю копию питомца...")
    local newTool = sourceTool:Clone()
    newTool.Name = "Dragonfly [6.36 KG] [Age 35]"
    
    -- Шаг 2: Находим StarterPlayer для управления слотами
    local starterPlayer = game:GetService("StarterPlayer")
    local starterPlayerScripts = starterPlayer:FindFirstChild("StarterPlayerScripts")
    
    -- Шаг 3: Принудительно заменяем Tool в слоте 1
    print("🎯 Принудительно заменяю Tool в слоте 1...")
    
    -- Метод 1: Через прямое управление Backpack
    local backpack = character:FindFirstChild("Backpack")
    if not backpack then
        backpack = Instance.new("Backpack")
        backpack.Parent = character
        print("✅ Создан Backpack")
    end
    
    -- Удаляем все Tool из Backpack
    for _, tool in pairs(backpack:GetChildren()) do
        if tool:IsA("Tool") then
            print("🗑️ Удаляю: " .. tool.Name)
            tool:Destroy()
        end
    end
    
    -- Удаляем Tool из рук (кроме питомца)
    for _, tool in pairs(character:GetChildren()) do
        if tool:IsA("Tool") and tool ~= sourceTool then
            print("🗑️ Удаляю из рук: " .. tool.Name)
            tool:Destroy()
        end
    end
    
    wait(0.2)
    
    -- Добавляем новый Tool как ПЕРВЫЙ в Backpack
    newTool.Parent = backpack
    print("✅ Dragonfly добавлен в Backpack как первый Tool")
    
    -- Шаг 4: Принудительно активируем слот 1 через UserInputService
    print("⌨️ Активирую слот 1 через клавишу...")
    
    -- Симулируем нажатие клавиши "1"
    wait(0.1)
    pcall(function()
        -- Создаем InputObject для клавиши "1"
        local inputObj = {
            KeyCode = Enum.KeyCode.One,
            UserInputType = Enum.UserInputType.Keyboard
        }
        
        -- Пытаемся симулировать нажатие
        game:GetService("UserInputService").InputBegan:Fire(inputObj, false)
        print("✅ Клавиша '1' нажата!")
    end)
    
    -- Шаг 5: Дополнительно - прямое перемещение в руки
    wait(0.3)
    if newTool.Parent == backpack then
        print("🔄 Принудительно перемещаю Tool в руки...")
        newTool.Parent = character
        print("✅ Tool перемещен в руки!")
    end
    
    print("🎯 === РЕЗУЛЬТАТ ===")
    print("📝 Tool создан: " .. newTool.Name)
    print("📍 Местоположение: " .. (newTool.Parent and newTool.Parent.Name or "NIL"))
    print("🎮 Слот 1 должен быть активирован")
    
    return true
end

-- Альтернативный метод: Через прямое управление GUI
local function replaceSlot1GUI()
    print("\n🔄 === ЗАМЕНА ЧЕРЕЗ GUI ===")
    
    local sourceTool = findHandPetTool()
    if not sourceTool then
        print("❌ Питомец в руке не найден!")
        return false
    end
    
    -- Находим GUI элементы
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
    
    -- Создаем копию питомца
    local newTool = sourceTool:Clone()
    newTool.Name = "Dragonfly [6.36 KG] [Age 35]"
    
    -- Очищаем Backpack
    local character = player.Character
    local backpack = character and character:FindFirstChild("Backpack")
    if backpack then
        for _, tool in pairs(backpack:GetChildren()) do
            if tool:IsA("Tool") then
                tool:Destroy()
            end
        end
    end
    
    -- Добавляем новый Tool
    if not backpack then
        backpack = Instance.new("Backpack")
        backpack.Parent = character
    end
    
    newTool.Parent = backpack
    
    -- Принудительно обновляем GUI
    print("🔄 Обновляю BackpackGui...")
    pcall(function()
        backpackGui.Enabled = false
        wait(0.1)
        backpackGui.Enabled = true
        print("✅ BackpackGui обновлен!")
    end)
    
    return true
end

-- Создаем GUI для тестирования
local function createTestGUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "DirectSlotReplacerGUI"
    screenGui.Parent = player:WaitForChild("PlayerGui")
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 400, 0, 300)
    frame.Position = UDim2.new(0.5, -200, 0.5, -150)
    frame.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
    frame.BorderSizePixel = 0
    frame.Parent = screenGui
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
    title.BorderSizePixel = 0
    title.Text = "🎯 Прямая замена слота 1"
    title.TextColor3 = Color3.new(1, 1, 1)
    title.TextScaled = true
    title.Font = Enum.Font.SourceSansBold
    title.Parent = frame
    
    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(1, -20, 0, 60)
    status.Position = UDim2.new(0, 10, 0, 50)
    status.BackgroundTransparency = 1
    status.Text = "Возьмите питомца в руки и нажмите кнопку замены."
    status.TextColor3 = Color3.new(1, 1, 1)
    status.TextScaled = true
    status.Font = Enum.Font.SourceSans
    status.TextWrapped = true
    status.Parent = frame
    
    -- Кнопка прямой замены
    local directBtn = Instance.new("TextButton")
    directBtn.Size = UDim2.new(1, -20, 0, 50)
    directBtn.Position = UDim2.new(0, 10, 0, 120)
    directBtn.BackgroundColor3 = Color3.new(0, 0.6, 0)
    directBtn.BorderSizePixel = 0
    directBtn.Text = "🎯 Прямая замена слота 1"
    directBtn.TextColor3 = Color3.new(1, 1, 1)
    directBtn.TextScaled = true
    directBtn.Font = Enum.Font.SourceSansBold
    directBtn.Parent = frame
    
    -- Кнопка GUI замены
    local guiBtn = Instance.new("TextButton")
    guiBtn.Size = UDim2.new(1, -20, 0, 50)
    guiBtn.Position = UDim2.new(0, 10, 0, 180)
    guiBtn.BackgroundColor3 = Color3.new(0, 0.4, 0.8)
    guiBtn.BorderSizePixel = 0
    guiBtn.Text = "🔄 Замена через GUI"
    guiBtn.TextColor3 = Color3.new(1, 1, 1)
    guiBtn.TextScaled = true
    guiBtn.Font = Enum.Font.SourceSansBold
    guiBtn.Parent = frame
    
    -- События
    directBtn.MouseButton1Click:Connect(function()
        status.Text = "🔄 Выполняю прямую замену..."
        status.TextColor3 = Color3.new(1, 1, 0)
        
        local success = replaceSlot1Direct()
        
        if success then
            status.Text = "✅ Прямая замена выполнена!"
            status.TextColor3 = Color3.new(0, 1, 0)
        else
            status.Text = "❌ Ошибка прямой замены"
            status.TextColor3 = Color3.new(1, 0, 0)
        end
    end)
    
    guiBtn.MouseButton1Click:Connect(function()
        status.Text = "🔄 Выполняю замену через GUI..."
        status.TextColor3 = Color3.new(1, 1, 0)
        
        local success = replaceSlot1GUI()
        
        if success then
            status.Text = "✅ Замена через GUI выполнена!"
            status.TextColor3 = Color3.new(0, 1, 0)
        else
            status.Text = "❌ Ошибка замены через GUI"
            status.TextColor3 = Color3.new(1, 0, 0)
        end
    end)
end

-- Запускаем
createTestGUI()
print("✅ DirectSlotReplacer готов!")
print("🎮 Попробуйте оба метода замены слота 1")
