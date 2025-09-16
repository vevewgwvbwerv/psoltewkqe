-- ⚡ МГНОВЕННАЯ ВИЗУАЛЬНАЯ ЗАМЕНА - Быстрая подмена модели питомца
print("⚡ Запуск системы мгновенной визуальной замены...")

-- Загрузка WindUI
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local players = game:GetService("Players")
local workspace = game:GetService("Workspace")
local replicatedStorage = game:GetService("ReplicatedStorage")
local runService = game:GetService("RunService")
local localPlayer = players.LocalPlayer

-- Настройки
local espEnabled = false
local replacementActive = false

-- База данных питомцев по яйцам
local eggChances = {
    ["Common Egg"] = {"Dog", "Bunny", "Golden Lab"},
    ["Uncommon Egg"] = {"Black Bunny", "Chicken", "Cat", "Deer"},
    ["Rare Egg"] = {"Orange Tabby", "Spotted Deer", "Pig", "Rooster", "Monkey"},
    ["Legendary Egg"] = {"Cow", "Silver Monkey", "Sea Otter", "Turtle", "Polar Bear"},
    ["Mythic Egg"] = {"Grey Mouse", "Brown Mouse", "Squirrel", "Red Giant Ant", "Red Fox"},
    ["Bug Egg"] = {"Snail", "Giant Ant", "Caterpillar", "Praying Mantis", "Dragon Fly"},
    ["Night Egg"] = {"Hedgehog", "Mole", "Frog", "Echo Frog", "Night Owl", "Raccoon"},
    ["Bee Egg"] = {"Bee", "Honey Bee", "Bear Bee", "Petal Bee", "Queen Bee"},
    ["Anti Bee Egg"] = {"Wasp", "Tarantula Hawk", "Moth", "Butterfly", "Disco Bee"},
    ["Common Summer Egg"] = {"Starfish", "Seafull", "Crab"},
    ["Rare Summer Egg"] = {"Flamingo", "Toucan", "Sea Turtle", "Orangutan", "Seal"},
    ["Paradise Egg"] = {"Ostrich", "Peacock", "Capybara", "Scarlet Macaw", "Mimic Octopus"},
    ["Premium Night Egg"] = {"Hedgehog", "Mole", "Frog", "Echo Frog"},
    ["Dinosaur Egg"] = {"Raptor", "Triceratops", "T-Rex", "Stegosaurus", "Pterodactyl", "Brontosaurus"}
}

-- Хранилище данных
local displayedEggs = {}
local replacementLog = {}
local petModels = {}

-- Кэш моделей питомцев для быстрого доступа
local function cachePetModels()
    print("🔍 Кэширование моделей питомцев...")
    
    -- Поиск в ReplicatedStorage
    for _, obj in pairs(replicatedStorage:GetDescendants()) do
        if obj:IsA("Model") and obj:FindFirstChildOfClass("Humanoid") then
            local modelName = obj.Name
            petModels[modelName] = obj
            
            -- Также добавляем варианты названий
            petModels[modelName:lower()] = obj
            petModels[modelName:gsub(" ", "")] = obj
            petModels[modelName:gsub(" ", "_")] = obj
        end
    end
    
    print("✅ Закэшировано моделей: " .. #petModels)
end

-- Функция получения модели питомца
local function getPetModel(petName)
    -- Сначала проверяем кэш
    if petModels[petName] then
        return petModels[petName]
    end
    
    -- Проверяем варианты названий
    local variants = {
        petName,
        petName:lower(),
        petName:upper(),
        petName:gsub(" ", ""),
        petName:gsub(" ", "_"),
        petName:gsub(" ", "-")
    }
    
    for _, variant in pairs(variants) do
        if petModels[variant] then
            return petModels[variant]
        end
    end
    
    -- Если не найдено в кэше, ищем в реальном времени
    for _, obj in pairs(replicatedStorage:GetDescendants()) do
        if obj:IsA("Model") and obj:FindFirstChildOfClass("Humanoid") then
            for _, variant in pairs(variants) do
                if obj.Name == variant then
                    petModels[petName] = obj -- Добавляем в кэш
                    return obj
                end
            end
        end
    end
    
    return nil
end

-- Функция создания ESP
local function createEspGui(egg, eggName, petName)
    if egg:FindFirstChild("EggESP") then
        egg:FindFirstChild("EggESP"):Destroy()
    end
    
    local adornee = egg:FindFirstChildWhichIsA("BasePart") or egg.PrimaryPart
    if not adornee then return nil end

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "EggESP"
    billboard.Adornee = adornee
    billboard.Size = UDim2.new(0, 200, 0, 60)
    billboard.StudsOffset = Vector3.new(0, 2.5, 0)
    billboard.AlwaysOnTop = true

    local eggLabel = Instance.new("TextLabel")
    eggLabel.Size = UDim2.new(1, 0, 0.5, 0)
    eggLabel.BackgroundTransparency = 1
    eggLabel.Text = eggName
    eggLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    eggLabel.TextStrokeTransparency = 0
    eggLabel.TextScaled = true
    eggLabel.Font = Enum.Font.SourceSansBold
    eggLabel.Parent = billboard

    local petLabel = Instance.new("TextLabel")
    petLabel.Name = "PetLabel"
    petLabel.Size = UDim2.new(1, 0, 0.5, 0)
    petLabel.Position = UDim2.new(0, 0, 0.5, 0)
    petLabel.BackgroundTransparency = 1
    petLabel.Text = petName
    petLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
    petLabel.TextStrokeTransparency = 0
    petLabel.TextScaled = true
    petLabel.Font = Enum.Font.SourceSansBold
    petLabel.Parent = billboard

    billboard.Parent = egg
    return billboard
end

-- Функция поиска яиц
local function findEggs()
    local eggs = {}
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and string.find(obj.Name, "Egg") then
            local eggName = obj.Name
            if eggChances[eggName] then
                table.insert(eggs, obj)
            end
        end
    end
    return eggs
end

-- Функция добавления ESP к яйцу
local function addESP(egg)
    if displayedEggs[egg] then return end
    
    local eggName = egg.Name
    if not eggChances[eggName] then return end

    local availablePets = eggChances[eggName]
    local randomPet = availablePets[math.random(1, #availablePets)]
    
    local espGui = nil
    if espEnabled then
        espGui = createEspGui(egg, eggName, randomPet)
    end
    
    displayedEggs[egg] = {
        egg = egg,
        gui = espGui,
        eggName = eggName,
        currentPet = randomPet,
        availablePets = availablePets
    }
    
    print("🥚 ESP добавлен: " .. eggName .. " → " .. randomPet)
end

-- Функция переключения ESP
local function toggleESP()
    espEnabled = not espEnabled
    
    for egg, data in pairs(displayedEggs) do
        if espEnabled then
            if not data.gui then
                data.gui = createEspGui(egg, data.eggName, data.currentPet)
            end
        else
            if data.gui then
                data.gui:Destroy()
                data.gui = nil
            end
        end
    end
    
    print(espEnabled and "🟢 ESP включен" or "🔴 ESP выключен")
end

-- Функция рандомизации питомцев
local function randomizePets()
    local randomizedCount = 0
    
    for egg, data in pairs(displayedEggs) do
        local newPet = data.availablePets[math.random(1, #data.availablePets)]
        data.currentPet = newPet
        
        if espEnabled and data.gui then
            local petLabel = data.gui:FindFirstChild("PetLabel")
            if petLabel then
                petLabel.Text = newPet
            end
        end
        
        randomizedCount = randomizedCount + 1
        print("🎲 " .. data.eggName .. " → " .. newPet)
    end
    
    print("🎲 Рандомизировано питомцев: " .. randomizedCount)
end

-- ⚡ МГНОВЕННАЯ ЗАМЕНА ПИТОМЦА
local function instantReplacePet(originalPet, targetPetName, eggPosition)
    print("⚡ МГНОВЕННАЯ ЗАМЕНА: " .. originalPet.Name .. " → " .. targetPetName)
    
    -- Получаем модель целевого питомца
    local targetModel = getPetModel(targetPetName)
    if not targetModel then
        print("❌ Модель не найдена: " .. targetPetName)
        return false
    end
    
    -- Сохраняем важные данные оригинального питомца
    local originalData = {
        parent = originalPet.Parent,
        cframe = originalPet.PrimaryPart and originalPet.PrimaryPart.CFrame or 
                originalPet:FindFirstChildWhichIsA("BasePart") and originalPet:FindFirstChildWhichIsA("BasePart").CFrame,
        name = originalPet.Name,
        attributes = {}
    }
    
    -- Сохраняем все атрибуты
    for attr, value in pairs(originalPet:GetAttributes()) do
        originalData.attributes[attr] = value
    end
    
    -- Создаем новую модель
    local newPet = targetModel:Clone()
    newPet.Name = originalData.name -- Сохраняем оригинальное имя для совместимости
    
    -- Устанавливаем позицию
    if originalData.cframe then
        if newPet.PrimaryPart then
            newPet.PrimaryPart.CFrame = originalData.cframe
        elseif newPet:FindFirstChildWhichIsA("BasePart") then
            newPet:FindFirstChildWhichIsA("BasePart").CFrame = originalData.cframe
        end
    end
    
    -- Восстанавливаем атрибуты
    for attr, value in pairs(originalData.attributes) do
        newPet:SetAttribute(attr, value)
    end
    
    -- МГНОВЕННАЯ замена
    originalPet:Destroy()
    newPet.Parent = originalData.parent
    
    -- Логируем замену
    table.insert(replacementLog, {
        time = tick(),
        original = originalPet.Name,
        target = targetPetName,
        success = true,
        method = "instant_visual"
    })
    
    print("✅ МГНОВЕННАЯ ЗАМЕНА ЗАВЕРШЕНА: " .. targetPetName)
    return true
end

-- Функция проверки на питомца
local function isPetModel(obj)
    if not obj:IsA("Model") then return false end
    
    local humanoid = obj:FindFirstChildOfClass("Humanoid")
    if not humanoid then return false end
    
    local hasHead = obj:FindFirstChild("Head")
    local hasTorso = obj:FindFirstChild("Torso") or obj:FindFirstChild("UpperTorso")
    
    return hasHead and hasTorso
end

-- ⚡ СИСТЕМА МГНОВЕННОГО МОНИТОРИНГА
local function setupInstantMonitoring()
    -- 1. Мониторинг workspace с мгновенной реакцией
    workspace.ChildAdded:Connect(function(child)
        if not replacementActive then return end
        
        if isPetModel(child) then
            -- МГНОВЕННАЯ обработка без задержек
            spawn(function()
                print("🐾 ОБНАРУЖЕН ПИТОМЕЦ: " .. child.Name)
                
                -- Ищем ближайший ESP для замены
                local targetPet = nil
                local minDistance = math.huge
                local childPos = child.PrimaryPart and child.PrimaryPart.Position or 
                                child:FindFirstChildWhichIsA("BasePart") and child:FindFirstChildWhichIsA("BasePart").Position
                
                if childPos then
                    for egg, data in pairs(displayedEggs) do
                        if data.currentPet then
                            local eggPos = egg.PrimaryPart and egg.PrimaryPart.Position or 
                                          egg:FindFirstChildWhichIsA("BasePart") and egg:FindFirstChildWhichIsA("BasePart").Position
                            
                            if eggPos then
                                local distance = (childPos - eggPos).Magnitude
                                if distance < minDistance and distance < 100 then
                                    minDistance = distance
                                    targetPet = data.currentPet
                                end
                            end
                        end
                    end
                    
                    -- Если найден ESP и питомец не соответствует - МГНОВЕННАЯ ЗАМЕНА
                    if targetPet and targetPet ~= child.Name then
                        print("🎯 НЕСООТВЕТСТВИЕ! ESP: " .. targetPet .. ", Выпал: " .. child.Name)
                        instantReplacePet(child, targetPet, childPos)
                    else
                        print("✅ Питомец соответствует ESP: " .. (targetPet or "нет ESP"))
                    end
                end
            end)
        end
    end)
    
    -- 2. Мониторинг NPCS папки
    local npcsFolder = workspace:FindFirstChild("NPCS")
    if npcsFolder then
        npcsFolder.ChildAdded:Connect(function(child)
            if not replacementActive then return end
            
            if isPetModel(child) then
                spawn(function()
                    print("👥 ПИТОМЕЦ В NPCS: " .. child.Name)
                    
                    -- Ищем любой ESP для замены
                    for egg, data in pairs(displayedEggs) do
                        if data.currentPet and data.currentPet ~= child.Name then
                            print("🔄 ЗАМЕНА В NPCS: " .. data.currentPet)
                            instantReplacePet(child, data.currentPet, nil)
                            break
                        end
                    end
                end)
            end
        end)
    end
    
    -- 3. Мониторинг каждый кадр для максимальной скорости
    runService.Heartbeat:Connect(function()
        if not replacementActive then return end
        
        -- Проверяем все новые питомцы в workspace
        for _, obj in pairs(workspace:GetChildren()) do
            if isPetModel(obj) and not obj:GetAttribute("ProcessedByReplacer") then
                obj:SetAttribute("ProcessedByReplacer", true)
                
                spawn(function()
                    -- Ищем соответствующий ESP
                    local objPos = obj.PrimaryPart and obj.PrimaryPart.Position or 
                                  obj:FindFirstChildWhichIsA("BasePart") and obj:FindFirstChildWhichIsA("BasePart").Position
                    
                    if objPos then
                        for egg, data in pairs(displayedEggs) do
                            if data.currentPet then
                                local eggPos = egg.PrimaryPart and egg.PrimaryPart.Position or 
                                              egg:FindFirstChildWhichIsA("BasePart") and egg:FindFirstChildWhichIsA("BasePart").Position
                                
                                if eggPos and (objPos - eggPos).Magnitude < 50 then
                                    if data.currentPet ~= obj.Name then
                                        print("⚡ HEARTBEAT ЗАМЕНА: " .. obj.Name .. " → " .. data.currentPet)
                                        instantReplacePet(obj, data.currentPet, objPos)
                                        break
                                    end
                                end
                            end
                        end
                    end
                end)
            end
        end
    end)
end

-- Сканирование яиц
local function scanForEggs()
    local eggs = findEggs()
    for _, egg in pairs(eggs) do
        addESP(egg)
    end
    print("🔍 Найдено яиц: " .. #eggs)
end

-- Мониторинг новых яиц
workspace.ChildAdded:Connect(function(child)
    wait(0.1)
    if child:IsA("Model") and string.find(child.Name, "Egg") and eggChances[child.Name] then
        addESP(child)
    end
end)

-- 🎨 СОВРЕМЕННЫЙ WINDUI ИНТЕРФЕЙС
function gradient(text, startColor, endColor)
    local result = ""
    local length = #text

    for i = 1, length do
        local t = (i - 1) / math.max(length - 1, 1)
        local r = math.floor((startColor.R + (endColor.R - startColor.R) * t) * 255)
        local g = math.floor((startColor.G + (endColor.G - startColor.G) * t) * 255)
        local b = math.floor((startColor.B + (endColor.B - startColor.B) * t) * 255)

        local char = text:sub(i, i)
        result = result .. '<font color="rgb(' .. r .. ", " .. g .. ", " .. b .. ')">' .. char .. "</font>"
    end

    return result
end

local Confirmed = false

WindUI:Popup(
    {
        Title = "Loaded!!! Instant Pet Replacer",
        Icon = "sparkles",
        IconThemed = true,
        Content = "This is a " ..
            gradient("Visual Pet Replacer", Color3.fromHex("#00FF87"), Color3.fromHex("#60EFFF")) ..
                " with " .. gradient("Instant Replacement", Color3.fromHex("#FF6B6B"), Color3.fromHex("#4ECDC4")) .. " for Pet Simulator",
        Buttons = {
            {
                Title = "Cancel",
                Callback = function()
                end,
                Variant = "Secondary"
            },
            {
                Title = "Continue",
                Icon = "arrow-right",
                Callback = function()
                    Confirmed = true
                end,
                Variant = "Primary"
            }
        }
    }
)

repeat
    wait()
until Confirmed

local Window =
    WindUI:CreateWindow(
    {
        Title = "Instant Pet Replacer | Made by TW2LOCK",
        Icon = "sparkles",
        IconThemed = true,
        Author = "Pet Simulator ESP",
        Folder = "InstantReplacer",
        Size = UDim2.fromOffset(420, 350),
        Transparent = false,
        Theme = "Dark",
        User = {
            Enabled = true,
            Callback = function()
            end,
            Anonymous = false
        },
        SideBarWidth = 150,
        ScrollBarEnabled = true
    }
)

Window:EditOpenButton(
    {
        Title = "Open Replacer",
        Icon = "sparkles",
        CornerRadius = UDim.new(0, 12),
        StrokeThickness = 2,
        Color = ColorSequence.new(Color3.fromHex("FF6B6B"), Color3.fromHex("4ECDC4")),
        Draggable = true
    }
)

local Tabs = {}

-- Create main sections
do
    Tabs.ESPSection =
        Window:Section(
        {
            Title = "ESP Tools",
            Icon = "eye",
            Opened = true
        }
    )

    Tabs.ReplacerSection =
        Window:Section(
        {
            Title = "Instant Replacer",
            Icon = "zap",
            Opened = false
        }
    )

    -- ESP tabs
    Tabs.EggESPTab =
        Tabs.ESPSection:Tab(
        {
            Title = "Egg ESP",
            Icon = "eye",
            Desc = "Visual egg predictions and ESP"
        }
    )

    -- Replacer Tab
    Tabs.ReplacerTab =
        Tabs.ReplacerSection:Tab(
        {
            Title = "Pet Replacer",
            Icon = "zap",
            Desc = "Instant pet replacement system"
        }
    )

    Tabs.LogTab =
        Tabs.ReplacerSection:Tab(
        {
            Title = "Logs",
            Icon = "file-text",
            Desc = "View replacement logs and stats"
        }
    )
end

Window:SelectTab(1)

-- ESP Tab Implementation
Tabs.EggESPTab:Paragraph(
    {
        Title = "Egg ESP System",
        Desc = "Visual egg predictions with instant replacement | Made by TW2LOCK",
        Image = "eye",
        Color = "Red"
    }
)

Tabs.EggESPTab:Toggle(
    {
        Title = "Enable Egg ESP",
        Value = false,
        Callback = function(enabled)
            toggleESP()
            if enabled then
                WindUI:Notify({
                    Title = "Egg ESP Enabled",
                    Content = "Visual predictions and ESP active",
                    Icon = "eye",
                    Duration = 3
                })
            else
                WindUI:Notify({
                    Title = "Egg ESP Disabled",
                    Content = "All visuals have been removed",
                    Icon = "eye-off",
                    Duration = 3
                })
            end
        end
    }
)

Tabs.EggESPTab:Button(
    {
        Title = "Randomize Predictions",
        Icon = "refresh-cw",
        Callback = function()
            if espEnabled then
                randomizePets()
                WindUI:Notify({
                    Title = "Predictions Randomized",
                    Content = "All egg predictions have been updated",
                    Icon = "refresh-cw",
                    Duration = 3
                })
            else
                WindUI:Notify({
                    Title = "ESP Not Active",
                    Content = "Please enable Egg ESP first!",
                    Icon = "alert-triangle",
                    Duration = 3
                })
            end
        end
    }
)

-- Replacer Tab Implementation
Tabs.ReplacerTab:Paragraph(
    {
        Title = "Instant Pet Replacer",
        Desc = "Instantly replace pets with ESP predictions - VISUAL ONLY",
        Image = "zap",
        Color = "Purple"
    }
)

Tabs.ReplacerTab:Toggle(
    {
        Title = "Enable Instant Replace",
        Value = false,
        Callback = function(enabled)
            replacementActive = enabled
            if enabled then
                WindUI:Notify({
                    Title = "Instant Replace Enabled",
                    Content = "Pet replacement system is now active",
                    Icon = "zap",
                    Duration = 3
                })
            else
                WindUI:Notify({
                    Title = "Instant Replace Disabled",
                    Content = "Pet replacement system is now paused",
                    Icon = "pause",
                    Duration = 3
                })
            end
        end
    }
)

Tabs.ReplacerTab:Divider()

Tabs.ReplacerTab:Paragraph(
    {
        Title = "How to Use",
        Desc = "1. Enable Egg ESP to see predictions\n2. Randomize predictions to get desired pets\n3. Enable Instant Replace for automatic replacement\n4. Check logs for replacement history",
        Image = "info",
        Color = "Blue"
    }
)

-- Log Tab Implementation
local logText = ""

local function updateLogDisplay()
    logText = "📊 REPLACEMENT LOG:\n\n"
    for i, entry in ipairs(replacementLog) do
        logText = logText .. "✅ " .. entry.original .. " → " .. entry.target .. " (" .. entry.method .. ")\n"
    end
    logText = logText .. "\n📈 Total Replacements: " .. #replacementLog
    logText = logText .. "\n🥚 Active Eggs: " .. (function()
        local count = 0
        for _ in pairs(displayedEggs) do count = count + 1 end
        return count
    end)()
    logText = logText .. "\n⚡ Status: " .. (replacementActive and "Active" or "Paused")
end

Tabs.LogTab:Paragraph(
    {
        Title = "Replacement Statistics",
        Desc = "View detailed logs and statistics",
        Image = "file-text",
        Color = "Green"
    }
)

local logDisplay = Tabs.LogTab:Paragraph(
    {
        Title = "Live Log",
        Desc = logText,
        Image = "activity",
        Color = "Blue"
    }
)

Tabs.LogTab:Button(
    {
        Title = "Refresh Logs",
        Icon = "refresh-cw",
        Callback = function()
            updateLogDisplay()
            -- Update the log display
            WindUI:Notify({
                Title = "Logs Refreshed",
                Content = "Log display has been updated",
                Icon = "refresh-cw",
                Duration = 2
            })
        end
    }
)

Tabs.LogTab:Button(
    {
        Title = "Clear Logs",
        Icon = "trash-2",
        Callback = function()
            replacementLog = {}
            updateLogDisplay()
            WindUI:Notify({
                Title = "Logs Cleared",
                Content = "All replacement logs have been cleared",
                Icon = "trash-2",
                Duration = 3
            })
        end
    }
)

-- Функция обновления статистики
local function updateStats()
    updateLogDisplay()
end

-- Периодическое обновление статистики
spawn(function()
    while wait(2) do
        updateStats()
    end
end)

-- Запуск системы
cachePetModels()
scanForEggs()
setupInstantMonitoring()

-- Глобальные переменные
_G.InstantReplacer = {
    espEnabled = espEnabled,
    replacementActive = replacementActive,
    displayedEggs = displayedEggs,
    replacementLog = replacementLog,
    petModels = petModels,
    instantReplacePet = instantReplacePet
}

print("⚡ МГНОВЕННЫЙ ЗАМЕНИТЕЛЬ ЗАГРУЖЕН!")
print("🔥 Особенности:")
print("   - Кэширование моделей для скорости")
print("   - Мгновенная замена без задержек")
print("   - Тройной мониторинг (workspace, NPCS, heartbeat)")
print("   - Полное сохранение атрибутов")
print("⚡ Теперь замена должна быть МГНОВЕННОЙ!")
