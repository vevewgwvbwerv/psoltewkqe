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

-- Функция мониторинга изменений в реальном времени
local function startRealTimeMonitoring(model)
    print("\n🔄 === ЗАПУСК МОНИТОРИНГА В РЕАЛЬНОМ ВРЕМЕНИ ===")
    
    local frameCount = 0
    local changeCount = 0
    
    monitoringConnection = RunService.Heartbeat:Connect(function()
        frameCount = frameCount + 1
        
        -- Проверяем каждые 10 кадров (примерно 6 раз в секунду)
        if frameCount % 10 == 0 then
            local hasChanges = false
            
            for path, previousState in pairs(previousStates) do
                local parts = string.split(path, ".")
                local currentObj = model
                
                -- Находим объект по пути
                for i = 2, #parts do
                    currentObj = currentObj:FindFirstChild(parts[i])
                    if not currentObj then break end
                end
                
                if currentObj then
                    if currentObj:IsA("BasePart") then
                        -- Проверяем изменения CFrame
                        if (currentObj.CFrame.Position - previousState.CFrame.Position).Magnitude > 0.001 then
                            print("🔄 [" .. frameCount .. "] ДВИЖЕНИЕ " .. path .. ": " .. tostring(currentObj.CFrame.Position))
                            previousStates[path].CFrame = currentObj.CFrame
                            hasChanges = true
                            changeCount = changeCount + 1
                        end
                        
                        -- Проверяем изменения поворота
                        local currentRotation = currentObj.CFrame - currentObj.CFrame.Position
                        local previousRotation = previousState.CFrame - previousState.CFrame.Position
                        if (currentRotation:VectorToWorldSpace(Vector3.new(1,0,0)) - previousRotation:VectorToWorldSpace(Vector3.new(1,0,0))).Magnitude > 0.001 then
                            print("🔄 [" .. frameCount .. "] ПОВОРОТ " .. path .. ": " .. tostring(currentObj.CFrame))
                            hasChanges = true
                            changeCount = changeCount + 1
                        end
                        
                    elseif currentObj:IsA("Motor6D") then
                        -- Проверяем изменения Motor6D
                        if (currentObj.C0.Position - previousState.C0.Position).Magnitude > 0.001 then
                            print("⚙️ [" .. frameCount .. "] MOTOR6D C0 " .. path .. ": " .. tostring(currentObj.C0))
                            previousStates[path].C0 = currentObj.C0
                            hasChanges = true
                            changeCount = changeCount + 1
                        end
                        
                        if (currentObj.C1.Position - previousState.C1.Position).Magnitude > 0.001 then
                            print("⚙️ [" .. frameCount .. "] MOTOR6D C1 " .. path .. ": " .. tostring(currentObj.C1))
                            previousStates[path].C1 = currentObj.C1
                            hasChanges = true
                            changeCount = changeCount + 1
                        end
                    end
                end
            end
            
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
            
            -- Ищем модель питомца внутри Tool
            for _, child in pairs(tool:GetChildren()) do
                if child:IsA("Model") and child.Name ~= "Handle" then
                    print("\n🎯 НАЙДЕНА МОДЕЛЬ ПИТОМЦА:", child.Name)
                    print("📋 ПОЛНЫЙ АНАЛИЗ СТРУКТУРЫ:")
                    
                    -- Глубокий анализ
                    deepAnalyzeModel(child, "  ")
                    
                    -- Запуск мониторинга
                    startRealTimeMonitoring(child)
                    
                    return
                end
            end
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
