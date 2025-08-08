-- DragonflyFinder.lua
-- Специальный поиск Dragonfly в расширенном инвентаре

local Players = game:GetService("Players")
local player = Players.LocalPlayer

print("=== ПОИСК DRAGONFLY ===")

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

-- Функция поиска всех элементов с текстом "dragonfly"
local function findAllDragonfly()
    print("🔍 Ищу все элементы с текстом 'dragonfly'...")
    
    local found = {}
    
    for _, desc in pairs(backpackGui:GetDescendants()) do
        if desc:IsA("TextLabel") and desc.Text:lower():find("dragonfly") then
            -- Найдем путь к элементу
            local path = desc.Name
            local parent = desc.Parent
            local fullPath = {}
            
            while parent and parent ~= backpackGui do
                table.insert(fullPath, 1, parent.Name .. "(" .. parent.ClassName .. ")")
                parent = parent.Parent
            end
            
            local pathString = "BackpackGui/" .. table.concat(fullPath, "/") .. "/" .. desc.Name
            
            print("✅ НАЙДЕН: " .. desc.Text)
            print("   📍 Путь: " .. pathString)
            print("   🔧 Родитель: " .. desc.Parent.Name .. " (" .. desc.Parent.ClassName .. ")")
            
            table.insert(found, {
                element = desc,
                text = desc.Text,
                parent = desc.Parent,
                path = pathString
            })
        end
    end
    
    return found
end

-- Функция поиска всех CategoryFrame
local function findAllCategoryFrames()
    print("🔍 Ищу все CategoryFrame...")
    
    local frames = {}
    
    for _, desc in pairs(backpackGui:GetDescendants()) do
        if desc.Name == "CategoryFrame" and desc:IsA("Frame") then
            -- Найдем путь к элементу
            local path = desc.Name
            local parent = desc.Parent
            local fullPath = {}
            
            while parent and parent ~= backpackGui do
                table.insert(fullPath, 1, parent.Name .. "(" .. parent.ClassName .. ")")
                parent = parent.Parent
            end
            
            local pathString = "BackpackGui/" .. table.concat(fullPath, "/") .. "/" .. desc.Name
            
            -- Считаем кнопки в CategoryFrame
            local buttonCount = 0
            for _, child in pairs(desc:GetChildren()) do
                if child:IsA("TextButton") then
                    buttonCount = buttonCount + 1
                end
            end
            
            print("✅ НАЙДЕН CategoryFrame: " .. pathString)
            print("   📊 Кнопок в CategoryFrame: " .. buttonCount)
            
            table.insert(frames, {
                element = desc,
                path = pathString,
                buttonCount = buttonCount
            })
        end
    end
    
    return frames
end

-- Функция поиска всех TextButton с номерами
local function findNumberedButtons()
    print("🔍 Ищу все TextButton с номерами...")
    
    local buttons = {}
    
    for _, desc in pairs(backpackGui:GetDescendants()) do
        if desc:IsA("TextButton") and tonumber(desc.Name) then
            -- Ищем текст в кнопке
            local buttonText = "пусто"
            for _, child in pairs(desc:GetDescendants()) do
                if child:IsA("TextLabel") and child.Text ~= "" then
                    buttonText = child.Text
                    break
                end
            end
            
            -- Найдем путь к элементу
            local parent = desc.Parent
            local parentPath = "неизвестно"
            if parent then
                parentPath = parent.Name .. "(" .. parent.ClassName .. ")"
            end
            
            print("🔢 Кнопка " .. desc.Name .. ": " .. buttonText)
            print("   📍 Родитель: " .. parentPath)
            
            if buttonText:lower():find("dragonfly") then
                print("   🐉 ЭТО DRAGONFLY!")
                table.insert(buttons, {
                    element = desc,
                    name = desc.Name,
                    text = buttonText,
                    parent = parent
                })
            end
        end
    end
    
    return buttons
end

-- Выполняем поиск
print("")
local dragonflyLabels = findAllDragonfly()

print("")
local categoryFrames = findAllCategoryFrames()

print("")
local dragonflyButtons = findNumberedButtons()

print("")
print("🎯 РЕЗУЛЬТАТЫ:")
print("Найдено Dragonfly текстов: " .. #dragonflyLabels)
print("Найдено CategoryFrame: " .. #categoryFrames)
print("Найдено Dragonfly кнопок: " .. #dragonflyButtons)

if #dragonflyButtons > 0 then
    local button = dragonflyButtons[1]
    print("")
    print("✅ ЛУЧШИЙ КАНДИДАТ:")
    print("Кнопка: " .. button.name)
    print("Текст: " .. button.text)
    print("Родитель: " .. button.parent.Name .. " (" .. button.parent.ClassName .. ")")
    print("")
    print("🔧 Используйте эту информацию для исправления DragonflyTransfer!")
end

print("=== ПОИСК ЗАВЕРШЕН ===")
