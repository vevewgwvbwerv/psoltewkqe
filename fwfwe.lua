-- DetailedInventoryAnalyzer.lua
-- Детальный анализ ВСЕХ элементов в BackpackGui

local Players = game:GetService("Players")
local player = Players.LocalPlayer

print("🔍 === ДЕТАЛЬНЫЙ АНАЛИЗ ИНВЕНТАРЯ ===")

local playerGui = player:FindFirstChild("PlayerGui")
if not playerGui then
    print("❌ PlayerGui не найден!")
    return
end

local backpackGui = playerGui:FindFirstChild("BackpackGui")
if not backpackGui then
    print("❌ BackpackGui не найден!")
    return
end

print("✅ BackpackGui найден!")
print("📊 Класс: " .. backpackGui.ClassName)
print("👁️ Видимый: " .. tostring(backpackGui.Visible))
print("")

-- Функция детального анализа
local function analyzeDetailed(element, depth, path)
    depth = depth or 0
    path = path or ""
    
    if depth > 5 then return end -- Увеличиваем глубину
    
    local indent = string.rep("  ", depth)
    local fullPath = path .. "/" .. element.Name
    
    -- Базовая информация об элементе
    local info = indent .. "📁 " .. element.Name .. " (" .. element.ClassName .. ")"
    
    -- Дополнительная информация
    if element:IsA("GuiObject") then
        info = info .. " [Видимый: " .. tostring(element.Visible) .. "]"
        
        if element:IsA("Frame") or element:IsA("ScrollingFrame") then
            local children = element:GetChildren()
            local visibleChildren = 0
            
            for _, child in pairs(children) do
                if child:IsA("GuiObject") and child.Visible then
                    visibleChildren = visibleChildren + 1
                end
            end
            
            info = info .. " [Детей: " .. #children .. ", Видимых: " .. visibleChildren .. "]"
        end
    end
    
    print(info)
    
    -- Если это TextButton, показываем его содержимое
    if element:IsA("TextButton") then
        for _, desc in pairs(element:GetDescendants()) do
            if desc:IsA("TextLabel") and desc.Text ~= "" then
                print(indent .. "   📝 Текст: \"" .. desc.Text .. "\"")
                break
            end
        end
    end
    
    -- Анализируем дочерние элементы
    local children = element:GetChildren()
    if #children > 0 then
        -- Сначала показываем статистику
        local frameCount = 0
        local buttonCount = 0
        local labelCount = 0
        local otherCount = 0
        
        for _, child in pairs(children) do
            if child:IsA("Frame") or child:IsA("ScrollingFrame") then
                frameCount = frameCount + 1
            elseif child:IsA("TextButton") or child:IsA("ImageButton") then
                buttonCount = buttonCount + 1
            elseif child:IsA("TextLabel") or child:IsA("ImageLabel") then
                labelCount = labelCount + 1
            else
                otherCount = otherCount + 1
            end
        end
        
        if frameCount > 0 or buttonCount > 0 or labelCount > 0 or otherCount > 0 then
            print(indent .. "   📊 Содержит: Фреймов=" .. frameCount .. ", Кнопок=" .. buttonCount .. ", Лейблов=" .. labelCount .. ", Других=" .. otherCount)
        end
        
        -- Рекурсивно анализируем каждого ребенка
        for _, child in pairs(children) do
            analyzeDetailed(child, depth + 1, fullPath)
        end
    end
    
    -- Проверяем, может ли это быть основным инвентарем
    if element:IsA("Frame") or element:IsA("ScrollingFrame") then
        local childButtons = 0
        local childPets = 0
        local childItems = 0
        
        for _, child in pairs(element:GetChildren()) do
            if child:IsA("TextButton") and child.Visible then
                childButtons = childButtons + 1
                
                -- Проверяем содержимое
                for _, desc in pairs(child:GetDescendants()) do
                    if desc:IsA("TextLabel") and desc.Text ~= "" then
                        if desc.Text:lower():find("kg") and desc.Text:lower():find("age") then
                            childPets = childPets + 1
                        else
                            childItems = childItems + 1
                        end
                        break
                    end
                end
            end
        end
        
        if childButtons >= 5 and childButtons <= 15 and (childPets > 0 or childItems > 0) then
            print(indent .. "   ⭐ ВОЗМОЖНЫЙ ОСНОВНОЙ ИНВЕНТАРЬ!")
            print(indent .. "   🎯 Путь: " .. fullPath)
            print(indent .. "   📈 Кнопок: " .. childButtons .. ", Питомцев: " .. childPets .. ", Предметов: " .. childItems)
        end
    end
end

-- Анализируем BackpackGui
print("🔍 Анализирую BackpackGui:")
analyzeDetailed(backpackGui, 0, "PlayerGui")

print("")
print("🎯 === АНАЛИЗ ЗАВЕРШЕН ===")
print("💡 Ищите элементы с пометкой ⭐ ВОЗМОЖНЫЙ ОСНОВНОЙ ИНВЕНТАРЬ!")
print("📋 Если основной инвентарь не найден, возможно он скрыт или имеет другую структуру")
