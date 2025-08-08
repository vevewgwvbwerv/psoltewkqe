-- SimpleInventoryAnalyzer.lua
-- Простой анализ структуры инвентаря без GUI

local Players = game:GetService("Players")
local player = Players.LocalPlayer

print("🔍 === АНАЛИЗ СТРУКТУРЫ ИНВЕНТАРЯ ===")

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

print("✅ BackpackGui найден, анализирую структуру...")
print("")

-- Функция анализа элемента
local function analyzeElement(element, depth, path)
    depth = depth or 0
    path = path or ""
    
    if depth > 3 then return end -- Ограничиваем глубину
    
    local indent = string.rep("  ", depth)
    local fullPath = path .. "/" .. element.Name
    
    print(indent .. "📁 " .. element.Name .. " (" .. element.ClassName .. ")")
    
    if element:IsA("Frame") or element:IsA("ScrollingFrame") then
        local childCount = 0
        local buttonCount = 0
        local petCount = 0
        local itemCount = 0
        
        for _, child in pairs(element:GetChildren()) do
            if child:IsA("GuiObject") and child.Visible then
                childCount = childCount + 1
                
                if child:IsA("TextButton") then
                    buttonCount = buttonCount + 1
                    
                    -- Проверяем содержимое кнопки
                    for _, desc in pairs(child:GetDescendants()) do
                        if desc:IsA("TextLabel") and desc.Text ~= "" then
                            if desc.Text:lower():find("kg") and desc.Text:lower():find("age") then
                                petCount = petCount + 1
                            else
                                itemCount = itemCount + 1
                            end
                            break
                        end
                    end
                end
            end
        end
        
        if childCount > 0 then
            print(indent .. "   📊 Элементов: " .. childCount .. " | Кнопок: " .. buttonCount .. " | Питомцев: " .. petCount .. " | Предметов: " .. itemCount)
            
            -- Проверяем, может ли это быть основным инвентарем
            if childCount >= 8 and childCount <= 15 and buttonCount >= 5 then
                print(indent .. "   ⭐ ВОЗМОЖНЫЙ ОСНОВНОЙ ИНВЕНТАРЬ!")
                print(indent .. "   🎯 Путь: " .. fullPath)
            end
        end
        
        -- Рекурсивно анализируем дочерние элементы
        for _, child in pairs(element:GetChildren()) do
            if child:IsA("GuiObject") then
                analyzeElement(child, depth + 1, fullPath)
            end
        end
        
    elseif element:IsA("TextButton") then
        -- Анализируем содержимое кнопки
        for _, desc in pairs(element:GetDescendants()) do
            if desc:IsA("TextLabel") and desc.Text ~= "" then
                if desc.Text:lower():find("kg") and desc.Text:lower():find("age") then
                    print(indent .. "   🐾 ПИТОМЕЦ: " .. desc.Text)
                else
                    print(indent .. "   📦 ПРЕДМЕТ: " .. desc.Text)
                end
                break
            end
        end
    end
end

-- Анализируем BackpackGui
analyzeElement(backpackGui, 0, "PlayerGui")

print("")
print("🎯 === АНАЛИЗ ЗАВЕРШЕН ===")
print("💡 Ищите элементы с пометкой ⭐ ВОЗМОЖНЫЙ ОСНОВНОЙ ИНВЕНТАРЬ!")
print("📝 Основной инвентарь должен содержать 8-15 элементов и несколько кнопок")
