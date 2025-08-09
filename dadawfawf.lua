-- DirectShovelFix.lua
-- ПРЯМОЕ РЕШЕНИЕ: Меняем содержимое Shovel на содержимое питомца

local Players = game:GetService("Players")
local player = game.Players.LocalPlayer

print("=== DIRECT SHOVEL FIX ===")

-- Глобальные переменные
local player = game.Players.LocalPlayer
local petTool = nil
local savedPetGripC0 = nil
local savedPetGripC1 = nil
local weldProtectionActive = false

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

-- Поиск Shovel в руках
local function findShovelInHands()
    local character = player.Character
    if not character then return nil end
    
    for _, tool in pairs(character:GetChildren()) do
        if tool:IsA("Tool") and (string.find(tool.Name, "Shovel") or string.find(tool.Name, "Destroy")) then
            return tool
        end
    end
    return nil
end

-- Функция сохранения питомца
local function savePet()
    print("\n💾 === СОХРАНЕНИЕ ПИТОМЦА ===")
    
    local foundPet = findPetInHands()
    if foundPet then
        petTool = foundPet:Clone()
        print("✅ Питомец сохранен: " .. foundPet.Name)
        
        -- КРИТИЧЕСКИ ВАЖНО: Сохраняем ориентацию крепления питомца
        local character = player.Character
        if character then
            local rightHand = character:FindFirstChild("Right Arm") or character:FindFirstChild("RightHand")
            if rightHand then
                local rightGrip = rightHand:FindFirstChild("RightGrip")
                if rightGrip then
                    savedPetGripC0 = rightGrip.C0
                    savedPetGripC1 = rightGrip.C1
                    print("📍 СОХРАНЕНА ориентация крепления питомца!")
                    print("📍 C0:", savedPetGripC0)
                    print("📍 C1:", savedPetGripC1)
                else
                    print("⚠️ RightGrip не найден при сохранении")
                end
            end
        end
        
        return true
    else
        print("❌ Питомец в руках не найден!")
        return false
    end
end

-- ПРЯМАЯ ЗАМЕНА содержимого
local function directReplace()
    print("\n🔄 === ПРЯМАЯ ЗАМЕНА СОДЕРЖИМОГО ===")
    
    if not petTool then
        print("❌ Сначала сохраните питомца!")
        return false
    end
    
    local shovel = findShovelInHands()
    if not shovel then
        print("❌ Shovel в руках не найден!")
        return false
    end
    
    print("✅ Найден Shovel: " .. shovel.Name)
    print("🔧 Меняю содержимое Shovel на содержимое питомца...")
    
    -- Шаг 1: Меняем имя
    shovel.Name = "Dragonfly [6.36 KG] [Age 35]"
    print("📝 Имя изменено: " .. shovel.Name)
    
    -- Шаг 2: Копируем свойства Tool
    shovel.RequiresHandle = petTool.RequiresHandle
    shovel.CanBeDropped = petTool.CanBeDropped
    shovel.ManualActivationOnly = petTool.ManualActivationOnly
    print("🔧 Свойства Tool скопированы")
    
    -- Шаг 3: Удаляем все содержимое Shovel
    print("🗑️ Очищаю содержимое Shovel...")
    for _, child in pairs(shovel:GetChildren()) do
        child:Destroy()
    end
    
    wait(0.1)
    
    -- Шаг 4: Копируем все содержимое питомца
    print("📋 Копирую содержимое питомца...")
    for _, child in pairs(petTool:GetChildren()) do
        local copy = child:Clone()
        copy.Parent = shovel
        print("   ✅ Скопировано: " .. child.Name .. " (" .. child.ClassName .. ")")
    end
    
    print("🎯 === РЕЗУЛЬТАТ ===")
    print("✅ Shovel ПОЛНОСТЬЮ заменен содержимым питомца!")
    print("📝 Новое имя: " .. shovel.Name)
    print("🎮 В руках должен быть питомец с именем Dragonfly!")
    
    return true
end

-- АЛЬТЕРНАТИВА: Замена содержимого существующего Tool БЕЗ создания нового
local function alternativeReplace()
    print("\n🔄 === АЛЬТЕРНАТИВНАЯ ЗАМЕНА ===")
    
    if not petTool then
        print("❌ Сначала сохраните питомца!")
        return false
    end
    
    local shovel = findShovelInHands()
    if not shovel then
        print("❌ Shovel в руках не найден!")
        return false
    end
    
    local character = player.Character
    if not character then
        print("❌ Character не найден!")
        return false
    end
    
    print("✅ Найден Shovel: " .. shovel.Name)
    print("🔧 Замена содержимого существующего Tool...")
    
    -- КАРДИНАЛЬНО НОВЫЙ ПОДХОД: НЕ создаем новый Tool, а меняем содержимое существующего!
    
    -- Шаг 1: Меняем имя Tool (остается в том же слоте)
    shovel.Name = "Dragonfly [6.36 KG] [Age 35]"
    print("📝 Имя Tool изменено: " .. shovel.Name)
    
    -- Шаг 2: Копируем свойства Tool от питомца
    shovel.RequiresHandle = petTool.RequiresHandle
    shovel.CanBeDropped = petTool.CanBeDropped  
    shovel.ManualActivationOnly = petTool.ManualActivationOnly
    shovel.Enabled = petTool.Enabled
    print("🔧 Свойства Tool обновлены от питомца")
    
    -- Шаг 3: Сохраняем позицию Handle ПЕРЕД очисткой
    local shovelHandle = shovel:FindFirstChild("Handle")
    local savedPosition = nil
    local savedOrientation = nil
    
    if shovelHandle then
        savedPosition = shovelHandle.Position
        savedOrientation = shovelHandle.Orientation
        print("📍 Сохранена позиция Handle: " .. tostring(savedPosition))
    end
    
    -- Шаг 4: ПОЛНАЯ очистка содержимого Shovel
    print("🗑️ Очищаю содержимое Shovel...")
    for _, child in pairs(shovel:GetChildren()) do
        child:Destroy()
        print("   🗑️ Удалено: " .. child.Name)
    end
    
    wait(0.05) -- Минимальная пауза для очистки
    
    -- Шаг 5: Копируем ВСЕ содержимое питомца в существующий Tool
    print("📋 Копирую содержимое питомца в существующий Tool...")
    for _, child in pairs(petTool:GetChildren()) do
        local copy = child:Clone()
        copy.Parent = shovel  -- В существующий Tool!
        
        -- КРИТИЧЕСКИ ВАЖНО: Правильная настройка физики
        if copy:IsA("BasePart") then
            copy.Anchored = false
            copy.CanCollide = false
            
            -- Если это Handle - восстанавливаем позицию
            if copy.Name == "Handle" and savedPosition then
                copy.Position = savedPosition
                copy.Orientation = savedOrientation
                print("   📍 Восстановлена позиция Handle")
            end
            
            print("   ✅ Скопировано: " .. child.Name .. " (BasePart)")
        else
            print("   ✅ Скопировано: " .. child.Name .. " (" .. child.ClassName .. ")")
        end
    end
    
    -- Шаг 6: КРИТИЧЕСКОЕ КРЕПЛЕНИЕ Tool к руке как настоящий питомец
    spawn(function()
        wait(0.1)
        
        -- Проверяем что Tool все еще в руках
        if shovel.Parent == character then
            local handle = shovel:FindFirstChild("Handle")
            local rightHand = character:FindFirstChild("Right Arm") or character:FindFirstChild("RightHand")
            
            if handle and rightHand then
                print(" Критическое крепление Handle к руке...")
                
                -- КРИТИЧЕСКИ ВАЖНО: Удаляем старое крепление перед созданием нового
                local oldGrip = rightHand:FindFirstChild("RightGrip")
                if oldGrip then
                    oldGrip:Destroy()
                    print(" Удалено старое крепление")
                end
                
                -- МГНОВЕННО создаем новое крепление Handle к руке
                local newGrip = Instance.new("Weld")
                newGrip.Name = "RightGrip"
                newGrip.Part0 = rightHand
                newGrip.Part1 = handle
                newGrip.Parent = rightHand
                
                -- ВРЕМЕННО ИСПОЛЬЗУЕМ ТОЛЬКО СТАНДАРТНОЕ КРЕПЛЕНИЕ
                -- Сбрасываем неправильную изученную ориентацию
                savedPetGripC0 = nil
                savedPetGripC1 = nil
                
                -- Применяем стандартное крепление
                newGrip.C0 = CFrame.new(0, -1, -0.5) * CFrame.Angles(0, 0, 0)
                newGrip.C1 = CFrame.new(0, 0, 0)
                print("📍 ПРИМЕНЕНО СТАНДАРТНОЕ крепление (изученная ориентация СБРОШЕНА)")
                print("📍 C0: CFrame.new(0, -1, -0.5)")
                print("📍 C1: CFrame.new(0, 0, 0)")
                print("⚠️ Изученная ориентация была неправильной - используем стандартную!")
                print("🔍 После коррекции игрой изучите правильную ориентацию ВРУЧНУЮ!")
                
                -- Настраиваем Handle как у настоящего питомца (ПОСЛЕ крепления)
                handle.Anchored = false
                handle.CanCollide = false
                handle.CanTouch = false
                handle.TopSurface = Enum.SurfaceType.Smooth
                handle.BottomSurface = Enum.SurfaceType.Smooth
                
                -- Запускаем фоновую защиту Weld от игры (ОЧЕНЬ КОРОТКОЕ время)
                weldProtectionActive = true
                spawn(function()
                    local protectionTime = 0
                    local maxProtectionCycles = 10 -- Максимум 0.1 секунды защиты (СОКРАЩЕНО!)
                    
                    while newGrip and newGrip.Parent and weldProtectionActive and protectionTime < maxProtectionCycles do
                        wait(0.01)
                        protectionTime = protectionTime + 1
                        
                        -- Проверяем, не создала ли игра свой RightGrip
                        local gameGrip = rightHand:FindFirstChild("RightGrip")
                        if gameGrip and gameGrip ~= newGrip then
                            print("🛡️ Обнаружен автоматический RightGrip от игры! Удаляем...")
                            gameGrip:Destroy()
                            
                            -- Восстанавливаем наш Weld с правильными параметрами
                            if not newGrip or not newGrip.Parent then
                                local restoredGrip = Instance.new("Weld")
                                restoredGrip.Name = "RightGrip"
                                restoredGrip.Part0 = rightHand
                                restoredGrip.Part1 = handle
                                restoredGrip.Parent = rightHand
                                
                                -- Используем изученную ориентацию при восстановлении
                                if savedPetGripC0 and savedPetGripC1 then
                                    restoredGrip.C0 = savedPetGripC0
                                    restoredGrip.C1 = savedPetGripC1
                                    print("🔧 Восстановлен Weld с изученной ориентацией!")
                                else
                                    restoredGrip.C0 = CFrame.new(0, -1, -0.5) * CFrame.Angles(0, 0, 0)
                                    restoredGrip.C1 = CFrame.new(0, 0, 0)
                                    print("🔧 Восстановлен Weld со стандартной ориентацией!")
                                end
                                
                                print("🔧 Weld восстановлен с правильной ориентацией!")
                            end
                        end
                    end
                    
                    -- Автоматически отключаем защиту через КОРОТКОЕ время
                    weldProtectionActive = false
                    print("🛡️ Защита Weld автоматически отключена через", protectionTime * 0.01, "секунд")
                    print("🎮 ИГРА ТЕПЕРЬ МОЖЕТ ИСПРАВИТЬ ОРИЕНТАЦИЮ! Попробуйте убрать и взять питомца обратно.")
                    
                    -- Дополнительная задержка для стабилизации
                    wait(0.1)
                    print("✅ Система готова к естественной коррекции ориентации игрой")
                    
                    -- АВТОМАТИЧЕСКОЕ ИЗУЧЕНИЕ ОТКЛЮЧЕНО - ТОЛЬКО РУЧНОЕ!
                    print("⚠️ Автоматическое изучение ориентации ОТКЛЮЧЕНО")
                    print("🔍 Используйте кнопку 'ИЗУЧИТЬ ТЕКУЩУЮ ОРИЕНТАЦИЮ' вручную!")
                    print("📋 ИНСТРУКЦИЯ:")
                    print("   1. Уберите питомца в инвентарь")
                    print("   2. Возьмите питомца обратно в руки")
                    print("   3. Убедитесь, что питомец в ПРАВИЛЬНОЙ позе")
                    print("   4. Нажмите 'ИЗУЧИТЬ ТЕКУЩУЮ ОРИЕНТАЦИЮ'")
                    print("   5. Теперь можно делать новые замены")
                end)
                
                print("✅ Handle ЖЕСТКО закреплен к руке через Weld!")
                print("🎯 Падение исключено!")
                
                -- Дополнительная стабилизация - принудительная активация Tool
                local humanoid = character:FindFirstChild("Humanoid")
                if humanoid then
                    -- Имитируем "взятие" Tool для активации системы
                    shovel.Parent = character.Backpack
                    wait(0.02)
                    shovel.Parent = character
                    print("⚡ Tool принудительно активирован с новым креплением")
                end
            else
                print("❌ Handle или Right Arm не найдены!")
            end
        end
    end)
    
    print("✅ Замена содержимого завершена!")
    print("🎯 Tool остается в том же слоте с новым содержимым!")
    print("📍 Позиция сохранена, падения быть не должно!")
    return true
end

-- ИСПРАВЛЕНИЕ ОРИЕНТАЦИИ питомца в руках
local function fixPetOrientation()
    print("\n🔧 === ИСПРАВЛЕНИЕ ОРИЕНТАЦИИ ===")
    
    if not petTool then
        print("❌ Сначала сохраните питомца!")
        return false
    end
    
    local character = player.Character
    if not character then
        print("❌ Character не найден!")
        return false
    end
    
    -- Ищем Tool питомца в руках (замененный Shovel)
    local petToolInHands = nil
    for _, tool in pairs(character:GetChildren()) do
        if tool:IsA("Tool") and (string.find(tool.Name, "Dragonfly") or string.find(tool.Name, "KG%]")) then
            petToolInHands = tool
            break
        end
    end
    
    if not petToolInHands then
        print("❌ Питомец в руках не найден!")
        return false
    end
    
    print("✅ Найден питомец в руках: " .. petToolInHands.Name)
    
    local rightHand = character:FindFirstChild("Right Arm") or character:FindFirstChild("RightHand")
    local handle = petToolInHands:FindFirstChild("Handle")
    
    if not rightHand or not handle then
        print("❌ Right Arm или Handle не найдены!")
        return false
    end
    
    local rightGrip = rightHand:FindFirstChild("RightGrip")
    if not rightGrip then
        print("❌ RightGrip не найден!")
        return false
    end
    
    print("🔧 Применяю СОХРАНЕННУЮ ориентацию питомца...")
    
    -- ЦИКЛИЧЕСКОЕ ПЕРЕКЛЮЧЕНИЕ разных ориентаций для питомцев
    local orientations = {
        {name = "Стандартная", c0 = CFrame.new(0, -1, -0.5) * CFrame.Angles(0, 0, 0), c1 = CFrame.new(0, 0, 0)},
        {name = "Повернутая вправо", c0 = CFrame.new(0, -1, -0.5) * CFrame.Angles(0, math.rad(90), 0), c1 = CFrame.new(0, 0, 0)},
        {name = "Повернутая влево", c0 = CFrame.new(0, -1, -0.5) * CFrame.Angles(0, math.rad(-90), 0), c1 = CFrame.new(0, 0, 0)},
        {name = "Перевернутая", c0 = CFrame.new(0, -1, -0.5) * CFrame.Angles(math.rad(180), 0, 0), c1 = CFrame.new(0, 0, 0)},
        {name = "Наклоненная вперед", c0 = CFrame.new(0, -1, -0.5) * CFrame.Angles(math.rad(45), 0, 0), c1 = CFrame.new(0, 0, 0)},
        {name = "Наклоненная назад", c0 = CFrame.new(0, -1, -0.5) * CFrame.Angles(math.rad(-45), 0, 0), c1 = CFrame.new(0, 0, 0)},
        {name = "Сохраненная (если есть)", c0 = savedPetGripC0 or CFrame.new(0, -1, -0.5), c1 = savedPetGripC1 or CFrame.new(0, 0, 0)},
        {name = "Сохраненная + Переворот головой вниз", c0 = (savedPetGripC0 or CFrame.new(0, -1, -0.5)) * CFrame.Angles(math.rad(180), 0, 0), c1 = savedPetGripC1 or CFrame.new(0, 0, 0)},
        {name = "Сохраненная + Поворот вправо", c0 = (savedPetGripC0 or CFrame.new(0, -1, -0.5)) * CFrame.Angles(0, math.rad(90), 0), c1 = savedPetGripC1 or CFrame.new(0, 0, 0)},
        {name = "Сохраненная + Поворот влево", c0 = (savedPetGripC0 or CFrame.new(0, -1, -0.5)) * CFrame.Angles(0, math.rad(-90), 0), c1 = savedPetGripC1 or CFrame.new(0, 0, 0)},
    }
    
    -- Инициализируем индекс ориентации
    if not _G.currentOrientationIndex then
        _G.currentOrientationIndex = 1
    else
        _G.currentOrientationIndex = _G.currentOrientationIndex + 1
        if _G.currentOrientationIndex > #orientations then
            _G.currentOrientationIndex = 1
        end
    end
    
    local currentOrientation = orientations[_G.currentOrientationIndex]
    
    rightGrip.C0 = currentOrientation.c0
    rightGrip.C1 = currentOrientation.c1
    
    print("📍 Применена ориентация: " .. currentOrientation.name)
    print("📍 C0:", currentOrientation.c0)
    print("📍 C1:", currentOrientation.c1)
    print("🔄 Нажмите еще раз для следующей ориентации (" .. _G.currentOrientationIndex .. "/" .. #orientations .. ")")
    
    return true
end

-- ИЗУЧЕНИЕ ТЕКУЩЕЙ ОРИЕНТАЦИИ питомца в руках
local function learnCurrentOrientation()
    print("\n🔍 === ИЗУЧЕНИЕ ТЕКУЩЕЙ ОРИЕНТАЦИИ ===")
    
    local character = player.Character
    if not character then
        print("❌ Character не найден!")
        return false
    end
    
    -- Ищем Tool питомца в руках (замененный Dragonfly)
    local petToolInHands = nil
    for _, tool in pairs(character:GetChildren()) do
        if tool:IsA("Tool") and (string.find(tool.Name, "Dragonfly") or string.find(tool.Name, "KG%]")) then
            petToolInHands = tool
            break
        end
    end
    
    if not petToolInHands then
        print("❌ Питомец в руках не найден!")
        print("💡 Сначала возьмите замененного питомца в руки")
        return false
    end
    
    print("✅ Найден питомец в руках: " .. petToolInHands.Name)
    
    local rightHand = character:FindFirstChild("Right Arm") or character:FindFirstChild("RightHand")
    if not rightHand then
        print("❌ Right Arm не найдена!")
        return false
    end
    
    local rightGrip = rightHand:FindFirstChild("RightGrip")
    if not rightGrip then
        print("❌ RightGrip не найден!")
        return false
    end
    
    -- СОХРАНЯЕМ ТЕКУЩУЮ ОРИЕНТАЦИЮ как "правильную"
    savedPetGripC0 = rightGrip.C0
    savedPetGripC1 = rightGrip.C1
    
    print("🔍 ИЗУЧЕНА и СОХРАНЕНА текущая ориентация!")
    print("📍 Новая сохраненная C0:", savedPetGripC0)
    print("📍 Новая сохраненная C1:", savedPetGripC1)
    print("✅ Теперь эта ориентация будет использоваться при следующих заменах!")
    
    return true
end

-- Создаем GUI
local function createDirectFixGUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "DirectShovelFixGUI"
    screenGui.Parent = player:WaitForChild("PlayerGui")
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 400, 0, 500)
    frame.Position = UDim2.new(0.5, -200, 0.5, -250)
    frame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.3)
    frame.BorderSizePixel = 0
    frame.Parent = screenGui
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundColor3 = Color3.new(0.2, 0.2, 0.6)
    title.BorderSizePixel = 0
    title.Text = "🎯 DIRECT SHOVEL FIX"
    title.TextColor3 = Color3.new(1, 1, 1)
    title.TextScaled = true
    title.Font = Enum.Font.SourceSansBold
    title.Parent = frame
    
    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(1, -20, 0, 80)
    status.Position = UDim2.new(0, 10, 0, 50)
    status.BackgroundTransparency = 1
    status.Text = "ПРОСТОЕ РЕШЕНИЕ:\n1. Возьмите питомца → Сохранить\n2. Возьмите Shovel → Заменить\nБЕЗ СЛОЖНОСТЕЙ!"
    status.TextColor3 = Color3.new(1, 1, 1)
    status.TextScaled = true
    status.Font = Enum.Font.SourceSans
    status.TextWrapped = true
    status.Parent = frame
    
    -- Кнопка сохранения
    local saveBtn = Instance.new("TextButton")
    saveBtn.Size = UDim2.new(1, -20, 0, 50)
    saveBtn.Position = UDim2.new(0, 10, 0, 140)
    saveBtn.BackgroundColor3 = Color3.new(0, 0.8, 0)
    saveBtn.BorderSizePixel = 0
    saveBtn.Text = "💾 Сохранить питомца"
    saveBtn.TextColor3 = Color3.new(1, 1, 1)
    saveBtn.TextScaled = true
    saveBtn.Font = Enum.Font.SourceSansBold
    saveBtn.Parent = frame
    
    -- Кнопка прямой замены
    local directBtn = Instance.new("TextButton")
    directBtn.Size = UDim2.new(1, -20, 0, 50)
    directBtn.Position = UDim2.new(0, 10, 0, 200)
    directBtn.BackgroundColor3 = Color3.new(0.8, 0.4, 0)
    directBtn.BorderSizePixel = 0
    directBtn.Text = "🔄 ПРЯМАЯ ЗАМЕНА"
    directBtn.TextColor3 = Color3.new(1, 1, 1)
    directBtn.TextScaled = true
    directBtn.Font = Enum.Font.SourceSansBold
    directBtn.Visible = false
    directBtn.Parent = frame
    
    -- Кнопка альтернативы
    local altBtn = Instance.new("TextButton")
    altBtn.Size = UDim2.new(1, -20, 0, 50)
    altBtn.Position = UDim2.new(0, 10, 0, 260)
    altBtn.BackgroundColor3 = Color3.new(0.6, 0, 0.8)
    altBtn.BorderSizePixel = 0
    altBtn.Text = "🔄 АЛЬТЕРНАТИВА"
    altBtn.TextColor3 = Color3.new(1, 1, 1)
    altBtn.TextScaled = true
    altBtn.Font = Enum.Font.SourceSansBold
    altBtn.Visible = false
    altBtn.Parent = frame
    
    -- Кнопка исправления ориентации
    local fixOrientBtn = Instance.new("TextButton")
    fixOrientBtn.Size = UDim2.new(1, -20, 0, 40)
    fixOrientBtn.Position = UDim2.new(0, 10, 0, 320)
    fixOrientBtn.BackgroundColor3 = Color3.new(0, 0.6, 0.8)
    fixOrientBtn.BorderSizePixel = 0
    fixOrientBtn.Text = "🔧 ИСПРАВИТЬ ОРИЕНТАЦИЮ"
    fixOrientBtn.TextColor3 = Color3.new(1, 1, 1)
    fixOrientBtn.TextScaled = true
    fixOrientBtn.Font = Enum.Font.SourceSansBold
    fixOrientBtn.Visible = false
    fixOrientBtn.Parent = frame
    
    -- Кнопка изучения текущей ориентации
    local learnOrientBtn = Instance.new("TextButton")
    learnOrientBtn.Size = UDim2.new(1, -20, 0, 40)
    learnOrientBtn.Position = UDim2.new(0, 10, 0, 370)
    learnOrientBtn.BackgroundColor3 = Color3.new(0.8, 0.6, 0)
    learnOrientBtn.BorderSizePixel = 0
    learnOrientBtn.Text = "🔍 ИЗУЧИТЬ ТЕКУЩУЮ ОРИЕНТАЦИЮ"
    learnOrientBtn.TextColor3 = Color3.new(1, 1, 1)
    learnOrientBtn.TextScaled = true
    learnOrientBtn.Font = Enum.Font.SourceSansBold
    learnOrientBtn.Visible = false
    learnOrientBtn.Parent = frame
    
    -- Кнопка отключения защиты Weld
    local disableProtectionBtn = Instance.new("TextButton")
    disableProtectionBtn.Size = UDim2.new(1, -20, 0, 30)
    disableProtectionBtn.Position = UDim2.new(0, 10, 0, 420)
    disableProtectionBtn.BackgroundColor3 = Color3.new(0.8, 0.2, 0.2)
    disableProtectionBtn.BorderSizePixel = 0
    disableProtectionBtn.Text = "🛡️ ОТКЛЮЧИТЬ ЗАЩИТУ WELD"
    disableProtectionBtn.TextColor3 = Color3.new(1, 1, 1)
    disableProtectionBtn.TextScaled = true
    disableProtectionBtn.Font = Enum.Font.SourceSansBold
    disableProtectionBtn.Visible = false
    disableProtectionBtn.Parent = frame
    
    -- Кнопка закрытия
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(1, -20, 0, 30)
    closeBtn.Position = UDim2.new(0, 10, 0, 460)
    closeBtn.BackgroundColor3 = Color3.new(0.6, 0.2, 0.2)
    closeBtn.BorderSizePixel = 0
    closeBtn.Text = "❌ Закрыть"
    closeBtn.TextColor3 = Color3.new(1, 1, 1)
    closeBtn.TextScaled = true
    closeBtn.Font = Enum.Font.SourceSansBold
    closeBtn.Parent = frame
    
    -- События
    saveBtn.MouseButton1Click:Connect(function()
        status.Text = "💾 Сохраняю питомца..."
        status.TextColor3 = Color3.new(1, 1, 0)
        
        local success = savePet()
        
        if success then
            status.Text = "✅ ПИТОМЕЦ СОХРАНЕН!\nТеперь возьмите Shovel"
            status.TextColor3 = Color3.new(0, 1, 0)
            altBtn.Visible = true
            fixOrientBtn.Visible = true -- Показываем кнопку исправления ориентации
        else
            status.Text = "❌ Ошибка сохранения!"
            status.TextColor3 = Color3.new(1, 0, 0)
        end
    end)
    
    directBtn.MouseButton1Click:Connect(function()
        status.Text = "🔄 Прямая замена содержимого..."
        status.TextColor3 = Color3.new(1, 1, 0)
        
        local success = directReplace()
        
        if success then
            status.Text = "✅ ЗАМЕНА ЗАВЕРШЕНА!\nShovel = Питомец!"
            status.TextColor3 = Color3.new(0, 1, 0)
        else
            status.Text = "❌ Ошибка замены!\nВозьмите Shovel в руки!"
            status.TextColor3 = Color3.new(1, 0, 0)
        end
    end)
    
    altBtn.MouseButton1Click:Connect(function()
        status.Text = "🔄 Альтернативная замена..."
        status.TextColor3 = Color3.new(1, 1, 0)
        
        local success = alternativeReplace()
        
        if success then
            status.Text = "✅ АЛЬТЕРНАТИВА ЗАВЕРШЕНА!\nНовый Tool создан!"
            status.TextColor3 = Color3.new(0, 1, 0)
            fixOrientBtn.Visible = true -- Показываем кнопку исправления ориентации
            learnOrientBtn.Visible = true -- Показываем кнопку изучения ориентации
            disableProtectionBtn.Visible = true -- Показываем кнопку отключения защиты
        else
            status.Text = "❌ Ошибка альтернативы!"
            status.TextColor3 = Color3.new(1, 0, 0)
        end
    end)
    
    fixOrientBtn.MouseButton1Click:Connect(function()
        status.Text = "🔧 Исправляю ориентацию..."
        status.TextColor3 = Color3.new(0, 1, 1)
        
        local success = fixPetOrientation()
        
        if success then
            status.Text = "✅ ОРИЕНТАЦИЯ ИСПРАВЛЕНА!\nНажмите еще раз для другой позиции"
            status.TextColor3 = Color3.new(0, 1, 0)
        else
            status.Text = "❌ Ошибка исправления ориентации!"
            status.TextColor3 = Color3.new(1, 0, 0)
        end
    end)
    
    learnOrientBtn.MouseButton1Click:Connect(function()
        status.Text = "🔍 Изучаю текущую ориентацию..."
        status.TextColor3 = Color3.new(1, 1, 0)
        
        local success = learnCurrentOrientation()
        
        if success then
            status.Text = "✅ ОРИЕНТАЦИЯ ИЗУЧЕНА!\nТеперь она будет использоваться"
            status.TextColor3 = Color3.new(0, 1, 0)
        else
            status.Text = "❌ Ошибка изучения ориентации!"
            status.TextColor3 = Color3.new(1, 0, 0)
        end
    end)
    
    disableProtectionBtn.MouseButton1Click:Connect(function()
        weldProtectionActive = false
        status.Text = "🛡️ ЗАЩИТА WELD ОТКЛЮЧЕНА!\nИгра может корректировать ориентацию"
        status.TextColor3 = Color3.new(1, 0.5, 0)
        disableProtectionBtn.Text = "✅ ЗАЩИТА ОТКЛЮЧЕНА"
        disableProtectionBtn.BackgroundColor3 = Color3.new(0.2, 0.8, 0.2)
        print("🛡️ Защита Weld принудительно отключена пользователем")
    end)
    
    closeBtn.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)
end

-- Запускаем
createDirectFixGUI()
print("✅ DirectShovelFix готов!")
print("🎯 ПРОСТОЕ РЕШЕНИЕ БЕЗ СЛОЖНОСТЕЙ!")
print("💾 1. Сохранить питомца")
print("🔄 2. Заменить Shovel")
