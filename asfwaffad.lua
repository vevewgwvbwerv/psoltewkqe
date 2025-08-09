-- 🏆 DirectShovelFix FINAL - ТОЛЬКО ПЕРЕИМЕНОВАНИЕ (БЕЗ КОПИРОВАНИЯ!)
-- ФИНАЛЬНОЕ РЕШЕНИЕ: Просто переименовываем оригинальный питомец
-- Это сохраняет ВСЮ оригинальную анимацию без проблем с копированием!

local Players = game:GetService("Players")
local player = Players.LocalPlayer

print("🏆 === DirectShovelFix FINAL - RENAME ONLY ===")

-- Поиск питомца в руках
local function findPetInHands()
    local character = player.Character
    if not character then return nil end
    
    for _, tool in pairs(character:GetChildren()) do
        if tool:IsA("Tool") and string.find(tool.Name, "%[") and string.find(tool.Name, "KG%]") then
            return tool
        end
    end
    return nil
end

-- Поиск Shovel в backpack
local function findShovelInBackpack()
    local backpack = player.Backpack
    if not backpack then return nil end
    
    for _, tool in pairs(backpack:GetChildren()) do
        if tool:IsA("Tool") then
            print("   Найден инструмент в backpack: " .. tool.Name)
            if string.find(tool.Name:lower(), "shovel") or 
               (not string.find(tool.Name, "%[") and not string.find(tool.Name, "KG%]")) then
                return tool
            end
        end
    end
    return nil
end

-- ПРОСТОЕ И ЭФФЕКТИВНОЕ РЕШЕНИЕ: Переименование + перестановка
local function simpleRenameSwap()
    print("\n🔄 === ПРОСТОЕ ПЕРЕИМЕНОВАНИЕ + SWAP ===")
    
    local pet = findPetInHands()
    if not pet then
        print("❌ Питомец в руках не найден!")
        return false
    end
    
    local shovel = findShovelInBackpack()
    if not shovel then
        print("❌ Shovel в backpack не найден!")
        print("💡 Положите Shovel в backpack перед заменой!")
        return false
    end
    
    print("✅ Найден питомец в руках: " .. pet.Name)
    print("✅ Найден Shovel в backpack: " .. shovel.Name)
    
    -- Сохраняем имена
    local petName = pet.Name
    local shovelName = shovel.Name
    
    -- ПРОСТОЕ РЕШЕНИЕ: Меняем имена местами!
    print("🔄 Меняем имена местами...")
    pet.Name = shovelName  -- Питомец становится "Shovel"
    shovel.Name = petName  -- Shovel становится питомцем
    
    print("✅ ГОТОВО!")
    print("📝 Питомец в руках теперь называется: " .. pet.Name)
    print("📝 Shovel в backpack теперь называется: " .. shovel.Name)
    print("🎮 Анимация питомца сохранена полностью!")
    print("🎯 Проблема решена БЕЗ копирования!")
    
    return true
end

-- Альтернативное решение: Переименование питомца в "Shovel"
local function renamePetToShovel()
    print("\n🎯 === ПЕРЕИМЕНОВАНИЕ ПИТОМЦА В SHOVEL ===")
    
    local pet = findPetInHands()
    if not pet then
        print("❌ Питомец в руках не найден!")
        return false
    end
    
    print("✅ Найден питомец: " .. pet.Name)
    
    -- Сохраняем оригинальное имя
    local originalName = pet.Name
    
    -- Переименовываем в Shovel
    pet.Name = "Shovel"
    
    print("✅ ГОТОВО!")
    print("📝 Питомец переименован: " .. originalName .. " → " .. pet.Name)
    print("🎮 ВСЯ анимация сохранена!")
    print("🎯 Теперь у вас 'Shovel' с анимацией питомца!")
    
    return true
end

-- Создание GUI
local function createGUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "DirectShovelFixFinal"
    screenGui.Parent = player:WaitForChild("PlayerGui")
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 500, 0, 300)
    frame.Position = UDim2.new(0.5, -250, 0.5, -150)
    frame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
    frame.BorderSizePixel = 0
    frame.Parent = screenGui
    
    -- Заголовок
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundTransparency = 1
    title.Text = "🏆 DirectShovelFix FINAL - Rename Only"
    title.TextColor3 = Color3.new(1, 1, 1)
    title.TextScaled = true
    title.Font = Enum.Font.GothamBold
    title.Parent = frame
    
    -- Кнопка простого переименования
    local renameBtn = Instance.new("TextButton")
    renameBtn.Size = UDim2.new(0.9, 0, 0, 60)
    renameBtn.Position = UDim2.new(0.05, 0, 0, 50)
    renameBtn.BackgroundColor3 = Color3.new(0.2, 0.8, 0.2)
    renameBtn.Text = "🎯 ПЕРЕИМЕНОВАТЬ ПИТОМЦА В 'SHOVEL'\n(Сохраняет ВСЮ анимацию!)"
    renameBtn.TextColor3 = Color3.new(1, 1, 1)
    renameBtn.TextScaled = true
    renameBtn.Font = Enum.Font.Gotham
    renameBtn.Parent = frame
    
    -- Кнопка обмена именами
    local swapBtn = Instance.new("TextButton")
    swapBtn.Size = UDim2.new(0.9, 0, 0, 60)
    swapBtn.Position = UDim2.new(0.05, 0, 0, 120)
    swapBtn.BackgroundColor3 = Color3.new(0.8, 0.4, 0.2)
    swapBtn.Text = "🔄 ОБМЕНЯТЬ ИМЕНА С SHOVEL\n(Питомец в руках, Shovel в backpack)"
    swapBtn.TextColor3 = Color3.new(1, 1, 1)
    swapBtn.TextScaled = true
    swapBtn.Font = Enum.Font.Gotham
    swapBtn.Parent = frame
    
    -- Информационная панель
    local infoLabel = Instance.new("TextLabel")
    infoLabel.Size = UDim2.new(0.95, 0, 0, 80)
    infoLabel.Position = UDim2.new(0.025, 0, 0, 190)
    infoLabel.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
    infoLabel.Text = "🏆 ФИНАЛЬНОЕ РЕШЕНИЕ!\n\nПроблема: копирование ломает анимацию\nРешение: НЕ копируем, а просто переименовываем!\n\nРезультат: питомец с полной анимацией + имя 'Shovel'"
    infoLabel.TextColor3 = Color3.new(1, 1, 1)
    infoLabel.TextScaled = true
    infoLabel.Font = Enum.Font.Gotham
    infoLabel.Parent = frame
    
    -- Кнопка закрытия
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0.9, 0, 0, 20)
    closeBtn.Position = UDim2.new(0.05, 0, 0, 275)
    closeBtn.BackgroundColor3 = Color3.new(0.6, 0.1, 0.1)
    closeBtn.Text = "❌ ЗАКРЫТЬ"
    closeBtn.TextColor3 = Color3.new(1, 1, 1)
    closeBtn.TextScaled = true
    closeBtn.Font = Enum.Font.Gotham
    closeBtn.Parent = frame
    
    -- Обработчики событий
    renameBtn.MouseButton1Click:Connect(renamePetToShovel)
    swapBtn.MouseButton1Click:Connect(simpleRenameSwap)
    closeBtn.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)
    
    print("🎮 GUI создан! ФИНАЛЬНОЕ решение: простое переименование!")
end

-- Запуск
createGUI()
