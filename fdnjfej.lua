-- 🔍 ДИАГНОСТИКА СКАНИРОВАНИЯ ПИТОМЦЕВ
-- Детальный анализ того, что происходит при поиске моделей в Workspace

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer

print("🔍 === ДИАГНОСТИКА СКАНИРОВАНИЯ ПИТОМЦЕВ ===")
print("=" .. string.rep("=", 60))

-- Получаем позицию игрока
local playerChar = player.Character
if not playerChar then
    print("❌ Персонаж игрока не найден!")
    return
end

local hrp = playerChar:FindFirstChild("HumanoidRootPart")
if not hrp then
    print("❌ HumanoidRootPart не найден!")
    return
end

local playerPos = hrp.Position
print("📍 Позиция игрока:", playerPos)

-- Настройки поиска
local SEARCH_RADIUS = 50
local petPartNames = {"Tail", "Mouth", "Jaw", "LeftEye", "RightEye", "LeftEar", "RightEar", "ColourSpot", "PetMover", "Head", "Body", "Ear", "Eye"}

print("🎯 Радиус поиска:", SEARCH_RADIUS)
print("🔍 Ищем части:", table.concat(petPartNames, ", "))
print()

-- Этап 1: Анализ всех объектов в Workspace
print("📊 ЭТАП 1: АНАЛИЗ ВСЕХ ОБЪЕКТОВ В WORKSPACE")
print("-" .. string.rep("-", 50))

local totalObjects = 0
local modelsFound = 0
local partsFound = 0
local nearbyObjects = 0

for _, obj in ipairs(Workspace:GetDescendants()) do
    totalObjects = totalObjects + 1
    
    if obj:IsA("Model") then
        modelsFound = modelsFound + 1
        
        -- Проверяем расстояние для моделей
        local success, modelCFrame = pcall(function() return obj:GetModelCFrame() end)
        if success then
            local distance = (modelCFrame.Position - playerPos).Magnitude
            if distance <= SEARCH_RADIUS then
                nearbyObjects = nearbyObjects + 1
                print("  📦 Модель рядом:", obj.Name, "| Расстояние:", math.floor(distance))
                
                -- Анализируем части модели
                local modelParts = {}
                for _, child in ipairs(obj:GetChildren()) do
                    if child:IsA("BasePart") then
                        table.insert(modelParts, child.Name .. " (T:" .. math.floor(child.Transparency * 100) .. "%)")
                    end
                end
                
                if #modelParts > 0 then
                    print("    🧩 Части:", table.concat(modelParts, ", "))
                end
            end
        end
    elseif obj:IsA("BasePart") then
        partsFound = partsFound + 1
        
        local distance = (obj.Position - playerPos).Magnitude
        if distance <= SEARCH_RADIUS then
            -- Проверяем, является ли это частью питомца
            for _, petPartName in ipairs(petPartNames) do
                if obj.Name == petPartName or obj.Name:find(petPartName) then
                    print("  🎯 НАЙДЕНА ЧАСТЬ ПИТОМЦА:", obj.Name, "| Родитель:", obj.Parent and obj.Parent.Name or "НЕТ", "| Расстояние:", math.floor(distance))
                    break
                end
            end
        end
    end
end

print()
print("📈 СТАТИСТИКА WORKSPACE:")
print("  📊 Всего объектов:", totalObjects)
print("  📦 Моделей:", modelsFound)
print("  🧩 Частей:", partsFound)
print("  📍 Объектов рядом:", nearbyObjects)
print()

-- Этап 2: Поиск моделей с UUID именами
print("📊 ЭТАП 2: ПОИСК МОДЕЛЕЙ С UUID ИМЕНАМИ")
print("-" .. string.rep("-", 50))

local uuidModels = {}

for _, obj in ipairs(Workspace:GetChildren()) do
    if obj:IsA("Model") and obj.Name:find("%{") and obj.Name:find("%}") then
        local success, modelCFrame = pcall(function() return obj:GetModelCFrame() end)
        if success then
            local distance = (modelCFrame.Position - playerPos).Magnitude
            if distance <= SEARCH_RADIUS then
                table.insert(uuidModels, {
                    model = obj,
                    name = obj.Name,
                    distance = distance
                })
                
                print("  🆔 UUID Модель:", obj.Name, "| Расстояние:", math.floor(distance))
                
                -- Детальный анализ частей
                local petParts = {}
                local visibleParts = 0
                local totalParts = 0
                
                for _, child in ipairs(obj:GetChildren()) do
                    if child:IsA("BasePart") then
                        totalParts = totalParts + 1
                        if child.Transparency < 1 then
                            visibleParts = visibleParts + 1
                        end
                        
                        for _, petPartName in ipairs(petPartNames) do
                            if child.Name == petPartName or child.Name:find(petPartName) then
                                table.insert(petParts, child.Name)
                                break
                            end
                        end
                    end
                end
                
                print("    📊 Частей всего:", totalParts, "| Видимых:", visibleParts, "| Частей питомца:", #petParts)
                if #petParts > 0 then
                    print("    🐾 Части питомца:", table.concat(petParts, ", "))
                end
                
                -- Проверяем PrimaryPart
                if obj.PrimaryPart then
                    print("    ✅ PrimaryPart:", obj.PrimaryPart.Name)
                else
                    print("    ❌ PrimaryPart отсутствует")
                end
            end
        end
    end
end

print()
print("📈 НАЙДЕНО UUID МОДЕЛЕЙ:", #uuidModels)
print()

-- Этап 3: Тестирование логики определения питомцев
print("📊 ЭТАП 3: ТЕСТИРОВАНИЕ ЛОГИКИ ОПРЕДЕЛЕНИЯ ПИТОМЦЕВ")
print("-" .. string.rep("-", 50))

for i, modelInfo in ipairs(uuidModels) do
    local obj = modelInfo.model
    print("🧪 Тестируем модель #" .. i .. ":", obj.Name)
    
    -- Применяем ту же логику, что и в основном скрипте
    local hasPetParts = false
    local petPartNames_check = {"Tail", "Mouth", "Jaw", "Eye", "Ear", "Body", "Head", "PetMover"}
    local visibleParts = 0
    
    for _, child in ipairs(obj:GetChildren()) do
        if child:IsA("BasePart") then
            if child.Transparency < 1 then
                visibleParts = visibleParts + 1
            end
            
            for _, petPartName in ipairs(petPartNames_check) do
                if child.Name:find(petPartName) then
                    hasPetParts = true
                    print("    ✅ Найдена часть питомца:", child.Name, "| Прозрачность:", child.Transparency)
                    break
                end
            end
        end
    end
    
    print("    📊 Результат: hasPetParts =", hasPetParts, "| visibleParts =", visibleParts)
    
    if hasPetParts and visibleParts >= 5 then
        print("    ✅ МОДЕЛЬ ПРОШЛА ПРОВЕРКУ - это питомец!")
    else
        print("    ❌ Модель НЕ прошла проверку")
        if not hasPetParts then
            print("      - Не найдены части питомца")
        end
        if visibleParts < 5 then
            print("      - Недостаточно видимых частей (" .. visibleParts .. " < 5)")
        end
    end
    print()
end

-- Этап 4: Рекомендации
print("💡 РЕКОМЕНДАЦИИ:")
print("-" .. string.rep("-", 30))

if #uuidModels == 0 then
    print("❌ UUID модели не найдены - проверьте:")
    print("  1. Находитесь ли вы рядом с питомцами?")
    print("  2. Правильно ли определяется позиция игрока?")
    print("  3. Достаточен ли радиус поиска?")
elseif #uuidModels > 0 then
    print("✅ UUID модели найдены, но логика определения может быть неточной")
    print("  1. Проверьте названия частей питомцев")
    print("  2. Возможно, нужно изменить критерии определения")
    print("  3. Рассмотрите снижение порога visibleParts")
end

print()
print("🎯 ДИАГНОСТИКА ЗАВЕРШЕНА")
print("=" .. string.rep("=", 60))
