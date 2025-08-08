-- HotbarFinder.lua
-- Специальный поиск Hotbar для DragonflyTransfer

local Players = game:GetService("Players")
local player = Players.LocalPlayer

print("=== ПОИСК HOTBAR ===")

local playerGui = player:FindFirstChild("PlayerGui")
if not playerGui then
    print("ERROR: PlayerGui не найден!")
    return
end

local backpackGui = playerGui:FindFirstChild("BackpackGui")
if not backpackGui then
    print("ERROR: BackpackGui не найден!")
    return
end

print("SUCCESS: BackpackGui найден!")

-- Функция поиска Hotbar
local function findHotbar()
    print("🔍 Ищу Hotbar...")
    
    -- Метод 1: Прямой поиск в BackpackGui
    local hotbar = backpackGui:FindFirstChild("Hotbar")
    if hotbar then
        print("✅ НАЙДЕН: BackpackGui/Hotbar")
        return hotbar, "BackpackGui/Hotbar"
    end
    
    -- Метод 2: Поиск через Backpack
    local backpack = backpackGui:FindFirstChild("Backpack")
    if backpack then
        print("🔍 Найден Backpack, ищу Hotbar внутри...")
        hotbar = backpack:FindFirstChild("Hotbar")
        if hotbar then
            print("✅ НАЙДЕН: BackpackGui/Backpack/Hotbar")
            return hotbar, "BackpackGui/Backpack/Hotbar"
        end
    end
    
    -- Метод 3: Поиск по всем потомкам
    print("🔍 Ищу Hotbar среди всех потомков...")
    for _, desc in pairs(backpackGui:GetDescendants()) do
        if desc.Name == "Hotbar" and desc:IsA("Frame") then
            -- Найдем путь к элементу
            local path = desc.Name
            local parent = desc.Parent
            while parent and parent ~= backpackGui do
                path = parent.Name .. "/" .. path
                parent = parent.Parent
            end
            path = "BackpackGui/" .. path
            
            print("✅ НАЙДЕН: " .. path)
            return desc, path
        end
    end
    
    -- Метод 4: Поиск фрейма с 10 кнопками
    print("🔍 Ищу фрейм с 10 кнопками...")
    for _, desc in pairs(backpackGui:GetDescendants()) do
        if desc:IsA("Frame") then
            local buttonCount = 0
            for _, child in pairs(desc:GetChildren()) do
                if child:IsA("TextButton") then
                    buttonCount = buttonCount + 1
                end
            end
            
            if buttonCount == 10 then
                -- Найдем путь к элементу
                local path = desc.Name
                local parent = desc.Parent
                while parent and parent ~= backpackGui do
                    path = parent.Name .. "/" .. path
                    parent = parent.Parent
                end
                path = "BackpackGui/" .. path
                
                print("✅ НАЙДЕН фрейм с 10 кнопками: " .. path)
                return desc, path
            end
        end
    end
    
    print("❌ Hotbar не найден!")
    return nil, nil
end

-- Ищем Hotbar
local hotbar, path = findHotbar()

if hotbar then
    print("")
    print("🎯 РЕЗУЛЬТАТ:")
    print("Hotbar найден по пути: " .. path)
    print("Класс: " .. hotbar.ClassName)
    
    -- Показываем содержимое
    local children = hotbar:GetChildren()
    local buttonCount = 0
    for _, child in pairs(children) do
        if child:IsA("TextButton") then
            buttonCount = buttonCount + 1
        end
    end
    
    print("Кнопок в Hotbar: " .. buttonCount)
    
    -- Показываем первые несколько кнопок
    print("Первые кнопки:")
    local count = 0
    for _, child in pairs(children) do
        if child:IsA("TextButton") and count < 3 then
            count = count + 1
            
            -- Ищем текст в кнопке
            local buttonText = "пусто"
            for _, desc in pairs(child:GetDescendants()) do
                if desc:IsA("TextLabel") and desc.Text ~= "" then
                    buttonText = desc.Text
                    break
                end
            end
            
            print("  " .. child.Name .. ": " .. buttonText)
        end
    end
    
    print("")
    print("✅ Используйте этот путь в DragonflyTransfer: " .. path)
else
    print("")
    print("❌ Hotbar не найден! Проверьте структуру GUI.")
end

print("=== ПОИСК ЗАВЕРШЕН ===")
