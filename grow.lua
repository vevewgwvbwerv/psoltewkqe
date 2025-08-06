-- 🔍 ПОЛНАЯ ДИАГНОСТИКА DRAGONFLY В РУКЕ
-- Анализирует ВСЕ возможные анимации, Motor6D, CFrame, скрипты, треки

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

print("🔍 === ПОЛНАЯ ДИАГНОСТИКА DRAGONFLY ===")
print("=" .. string.rep("=", 60))

-- Глобальные переменные для мониторинга
local monitoringConnection = nil
local previousStates = {}

-- Функция глубокого анализа модели
local function deepAnalyzeModel(model, indent, path)
    indent = indent or ""
    path = path or model.Name
    
    print(indent .. "📁 " .. model.Name .. " (" .. model.ClassName .. ") - Path: " .. path)
    
    -- Анализ PrimaryPart
    if model.PrimaryPart then
        print(indent .. "  ✅ PrimaryPart: " .. model.PrimaryPart.Name)
    else
        print(indent .. "  ❌ PrimaryPart НЕ УСТАНОВЛЕН!")
    end
    
    -- Анализ всех дочерних объектов
    for _, child in pairs(model:GetChildren()) do
        local childPath = path .. "." .. child.Name
        
        if child:IsA("Model") then
            print(indent .. "  📁 SUB-MODEL: " .. child.Name)
            deepAnalyzeModel(child, indent .. "    ", childPath)
            
        elseif child:IsA("BasePart") then
            -- Анализ части
            local meshInfo = ""
            local mesh = child:FindFirstChildOfClass("SpecialMesh") or child:FindFirstChildOfClass("MeshPart")
            if mesh then
                if mesh:IsA("SpecialMesh") then
                    meshInfo = " [Mesh: " .. mesh.MeshType.Name .. ", Scale: " .. tostring(mesh.Scale) .. "]"
                else
                    meshInfo = " [MeshPart: " .. tostring(mesh.MeshId) .. "]"
                end
            end
            
            print(indent .. "  🧱 PART: " .. child.Name .. " (" .. child.Material.Name .. ", " .. child.BrickColor.Name .. ")" .. meshInfo)
            print(indent .. "    📍 Position: " .. tostring(child.Position))
            print(indent .. "    🔄 CFrame: " .. tostring(child.CFrame))
            print(indent .. "    ⚖️ Size: " .. tostring(child.Size))
            print(indent .. "    🔒 Anchored: " .. tostring(child.Anchored))
            print(indent .. "    👁️ Transparency: " .. child.Transparency)
            
            -- Сохраняем начальное состояние для мониторинга
            previousStates[childPath] = {
                CFrame = child.CFrame,
                Position = child.Position,
                Rotation = child.Rotation
            }
            
        elseif child:IsA("Motor6D") then
            print(indent .. "  ⚙️ MOTOR6D: " .. child.Name)
            print(indent .. "    🔗 Part0: " .. (child.Part0 and child.Part0.Name or "NIL"))
            print(indent .. "    🔗 Part1: " .. (child.Part1 and child.Part1.Name or "NIL"))
            print(indent .. "    📍 C0: " .. tostring(child.C0))
            print(indent .. "    📍 C1: " .. tostring(child.C1))
            
            -- Сохраняем состояние Motor6D
            previousStates[childPath] = {
                C0 = child.C0,
                C1 = child.C1
            }
            
        elseif child:IsA("Attachment") then
            print(indent .. "  📎 ATTACHMENT: " .. child.Name)
            print(indent .. "    📍 Position: " .. tostring(child.Position))
            print(indent .. "    🔄 CFrame: " .. tostring(child.CFrame))
            
        elseif child:IsA("Humanoid") then
            print(indent .. "  👤 HUMANOID: " .. child.Name)
            print(indent .. "    ❤️ Health: " .. child.Health .. "/" .. child.MaxHealth)
            print(indent .. "    🚶 WalkSpeed: " .. child.WalkSpeed)
            print(indent .. "    🦘 JumpPower: " .. child.JumpPower)
            
            -- Анализ Animator
            local animator = child:FindFirstChild("Animator")
            if animator then
                print(indent .. "    🎭 ANIMATOR НАЙДЕН!")
                
                -- Получаем все активные треки анимации
                local tracks = animator:GetPlayingAnimationTracks()
                print(indent .. "    📊 Активных треков: " .. #tracks)
                
                for i, track in pairs(tracks) do
                    print(indent .. "      🎬 Трек " .. i .. ": " .. (track.Animation and track.Animation.AnimationId or "Неизвестно"))
                    print(indent .. "        ⏯️ Играет: " .. tostring(track.IsPlaying))
                    print(indent .. "        🔊 Громкость: " .. track.WeightCurrent)
                    print(indent .. "        ⏱️ Время: " .. track.TimePosition)
                    print(indent .. "        🔄 Зацикленность: " .. tostring(track.Looped))
                end
            else
                print(indent .. "    ❌ ANIMATOR НЕ НАЙДЕН!")
            end
            
        elseif child:IsA("LocalScript") or child:IsA("Script") then
            print(indent .. "  📜 SCRIPT: " .. child.Name .. " (" .. child.ClassName .. ")")
            print(indent .. "    🔧 Enabled: " .. tostring(child.Enabled))
            
        elseif child:IsA("RemoteEvent") or child:IsA("RemoteFunction") then
            print(indent .. "  📡 REMOTE: " .. child.Name .. " (" .. child.ClassName .. ")")
            
        else
            print(indent .. "  ❓ OTHER: " .. child.Name .. " (" .. child.ClassName .. ")")
        end
    end
end

-- Функция мониторинга изменений в реальном времени (ИСПРАВЛЕННАЯ)
local function startRealTimeMonitoring(tool)
    print("\n🔄 === ЗАПУСК МОНИТОРИНГА В РЕАЛЬНОМ ВРЕМЕНИ ===")
    
    -- Получаем ВСЕ анимируемые части из Tool (как в CFrameAnimationTester)
    local animatedParts = {}
    local previousCFrames = {}
    
    for _, obj in pairs(tool:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name ~= "Handle" then
            table.insert(animatedParts, obj)
            previousCFrames[obj] = obj.CFrame
            print("📦 Отслеживаю часть: " .. obj.Name .. " (родитель: " .. obj.Parent.Name .. ")")
        end
    end
    
    print("📊 Всего отслеживается частей: " .. #animatedParts)
    
    local frameCount = 0
    local changeCount = 0
    
    monitoringConnection = RunService.Heartbeat:Connect(function()
        frameCount = frameCount + 1
        
        -- Проверяем каждые 5 кадров (более частая проверка)
        if frameCount % 5 == 0 then
            local changesDetected = 0
            
            -- Проверяем каждую часть на изменения CFrame
            for _, part in pairs(animatedParts) do
                if part and part.Parent then
                    local currentCFrame = part.CFrame
                    local previousCFrame = previousCFrames[part]
                    
                    if previousCFrame then
                        -- Проверяем изменения позиции
                        local positionDiff = (currentCFrame.Position - previousCFrame.Position).Magnitude
                        if positionDiff > 0.001 then
                            print("🔄 [" .. frameCount .. "] ДВИЖЕНИЕ " .. part.Name .. ": " .. tostring(currentCFrame.Position))
                            changesDetected = changesDetected + 1
                        end
                        
                        -- Проверяем изменения поворота
                        local rotationDiff = math.abs((currentCFrame - currentCFrame.Position):ToEulerAnglesXYZ() - (previousCFrame - previousCFrame.Position):ToEulerAnglesXYZ())
                        if rotationDiff > 0.01 then
                            local angles = {currentCFrame:ToEulerAnglesXYZ()}
                            print("🔄 [" .. frameCount .. "] ПОВОРОТ " .. part.Name .. ": X=" .. math.deg(angles[1]) .. ", Y=" .. math.deg(angles[2]) .. ", Z=" .. math.deg(angles[3]))
                            changesDetected = changesDetected + 1
                        end
                        
                        -- Особая проверка для крыльев
                        if part.Name:find("Wing") or part.Name:find("wing") then
                            if rotationDiff > 0.001 then
                                print("🦅 [" .. frameCount .. "] КРЫЛО МАХАЕТ " .. part.Name .. ": " .. math.deg(rotationDiff) .. " градусов")
                            end
                        end
                        
                        previousCFrames[part] = currentCFrame
                    end
                end
            end
            
            changeCount = changeCount + changesDetected
            
            -- Показываем статистику каждые 300 кадров (5 секунд)
            if frameCount % 300 == 0 then
                print("📊 [СТАТИСТИКА " .. frameCount .. "] Изменений обнаружено: " .. changeCount)
            end
        end
    end)
    
    print("✅ Мониторинг запущен! Наблюдаю за изменениями...")
    print("⏹️ Для остановки мониторинга запустите скрипт еще раз")
end

-- Основная функция
local function main()
    local playerChar = player.Character
    if not playerChar then
        print("❌ Персонаж не найден!")
        return
    end
    
    print("🎒 Поиск Dragonfly в руках...")
    
    for _, tool in pairs(playerChar:GetChildren()) do
        if tool:IsA("Tool") and string.find(tool.Name, "%[") and string.find(tool.Name, "KG%]") then
            print("✅ Найден Tool:", tool.Name)
            
            print("\n📋 ПОЛНОЕ СОДЕРЖИМОЕ TOOL:")
            print("🔍 Прямые дети Tool:")
            
            -- Показываем прямых детей Tool
            for _, child in pairs(tool:GetChildren()) do
                print("📁 ОБЪЕКТ:", child.Name, "(", child.ClassName, ")")
                
                if child:IsA("Model") then
                    print("  🎯 НАЙДЕНА МОДЕЛЬ:", child.Name)
                    deepAnalyzeModel(child, "    ")
                elseif child:IsA("BasePart") then
                    print("  🧱 ЧАСТЬ:", child.Name, "- Материал:", child.Material.Name)
                    -- Проверяем есть ли меши
                    for _, mesh in pairs(child:GetChildren()) do
                        if mesh:IsA("SpecialMesh") or mesh:IsA("MeshPart") then
                            print("    🔳 МЕШ:", mesh.Name, "(", mesh.ClassName, ")")
                        end
                    end
                elseif child:IsA("LocalScript") or child:IsA("Script") then
                    print("  📜 СКРИПТ:", child.Name, "- Активен:", child.Enabled)
                else
                    print("  ❓ ДРУГОЕ:", child.Name, "(", child.ClassName, ")")
                end
            end
            
            print("\n🔍 ВСЕ ПОТОМКИ Tool (рекурсивно):")
            
            -- Показываем ВСЕХ потомков рекурсивно
            for _, descendant in pairs(tool:GetDescendants()) do
                local depth = 0
                local parent = descendant.Parent
                while parent and parent ~= tool do
                    depth = depth + 1
                    parent = parent.Parent
                end
                
                local indent = string.rep("  ", depth)
                print(indent .. "📄 " .. descendant.Name .. " (" .. descendant.ClassName .. ")")
                
                if descendant:IsA("Model") and not descendant.Name:find("Handle") then
                    print(indent .. "  🎯 МОДЕЛЬ ПИТОМЦА НАЙДЕНА!")
                end
            end
            
            -- Запускаем мониторинг для всего Tool
            print("\n🚀 ЗАПУСК МОНИТОРИНГА ДЛЯ ВСЕГО TOOL...")
            startRealTimeMonitoring(tool)
            
            return
        end
    end
    
    print("❌ Dragonfly в руках не найден!")
end

-- Остановка предыдущего мониторинга если есть
if monitoringConnection then
    monitoringConnection:Disconnect()
    print("⏹️ Предыдущий мониторинг остановлен")
end

main()
