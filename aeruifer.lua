--[[
    HAND PET DIAGNOSTIC
    Диагностика - что находится в руке игрока
]]

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer

print("🔍 Hand Pet Diagnostic загружен!")

-- Простой GUI с кнопкой
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "HandPetDiagnostic"
screenGui.Parent = CoreGui

local button = Instance.new("TextButton")
button.Size = UDim2.new(0, 200, 0, 50)
button.Position = UDim2.new(0, 10, 0, 70)
button.BackgroundColor3 = Color3.new(0, 0, 1)
button.Text = "🔍 SCAN HAND"
button.TextColor3 = Color3.new(1, 1, 1)
button.TextScaled = true
button.Font = Enum.Font.GothamBold
button.Parent = screenGui

-- Функция диагностики
local function scanHand()
    print("\n🔍 === ДИАГНОСТИКА РУКИ ===")
    
    if not player then
        print("❌ Player не найден!")
        return
    end
    
    if not player.Character then
        print("❌ Character не найден!")
        return
    end
    
    print("✅ Character найден: " .. player.Character.Name)
    print("📋 Содержимое Character:")
    
    local toolCount = 0
    local modelCount = 0
    
    -- Сканируем все в Character
    for i, child in pairs(player.Character:GetChildren()) do
        print("  " .. i .. ". " .. child.Name .. " (" .. child.ClassName .. ")")
        
        if child:IsA("Tool") then
            toolCount = toolCount + 1
            print("    🔧 TOOL найден: " .. child.Name)
            
            -- Сканируем содержимое Tool
            for j, toolChild in pairs(child:GetChildren()) do
                print("      " .. j .. ". " .. toolChild.Name .. " (" .. toolChild.ClassName .. ")")
                
                if toolChild:IsA("Model") then
                    modelCount = modelCount + 1
                    print("        📦 MODEL найден: " .. toolChild.Name)
                    
                    -- Сканируем части модели
                    for k, part in pairs(toolChild:GetChildren()) do
                        print("          " .. k .. ". " .. part.Name .. " (" .. part.ClassName .. ")")
                    end
                    
                    print("        📊 Всего частей в модели: " .. #toolChild:GetChildren())
                    
                elseif toolChild:IsA("BasePart") then
                    print("        🧱 BasePart: " .. toolChild.Name .. " (Size: " .. tostring(toolChild.Size) .. ")")
                end
            end
            
            print("    📊 Всего объектов в Tool: " .. #child:GetChildren())
        end
    end
    
    print("\n📊 === ИТОГИ ===")
    print("🔧 Tools найдено: " .. toolCount)
    print("📦 Models найдено: " .. modelCount)
    
    if toolCount == 0 then
        print("❌ ПРОБЛЕМА: Tool не найден в Character!")
        print("💡 Убедись что питомец действительно в руке (экипирован)")
    elseif modelCount == 0 then
        print("❌ ПРОБЛЕМА: Model не найден в Tool!")
        print("💡 Возможно питомец имеет другую структуру")
    else
        print("✅ Все найдено! Tool и Model присутствуют")
    end
    
    print("\n🎯 Диагностика завершена!")
end

-- Обработчик кнопки
button.MouseButton1Click:Connect(function()
    button.Text = "⏳ SCANNING..."
    button.BackgroundColor3 = Color3.new(1, 1, 0)
    
    scanHand()
    
    wait(1)
    button.Text = "🔍 SCAN HAND"
    button.BackgroundColor3 = Color3.new(0, 0, 1)
end)

print("🎯 Готов к диагностике!")
print("📋 1. Убедись что питомец в руке (экипирован)")
print("📋 2. Нажми кнопку SCAN HAND")
print("📋 3. Смотри результаты в консоли")
