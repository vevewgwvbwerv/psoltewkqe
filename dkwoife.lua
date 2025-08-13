-- 🔍 PET CREATION ANALYZER v1.0
-- Анализирует процесс создания визуального питомца
-- Отслеживает: Backpack → Handle → Позиционирование

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local backpack = player.Backpack
local playerGui = player:WaitForChild("PlayerGui")

print("🔍 === PET CREATION ANALYZER v1.0 ===")
print("🎯 Отслеживаем: Backpack → Handle → Позиционирование")

-- === СИСТЕМЫ ЛОГИРОВАНИЯ ===
local analysisLog = {}
local petCreationEvents = {}
local currentHandleTool = nil

-- Функция логирования
local function log(category, message, data)
    local entry = {
        time = tick(),
        category = category,
        message = message,
        data = data or {}
    }
    table.insert(analysisLog, entry)
    print(string.format("[%.3f] [%s] %s", entry.time, category, message))
    if data and next(data) then
        for key, value in pairs(data) do
            print(string.format("  └─ %s: %s", key, tostring(value)))
        end
    end
end

-- Функция анализа Tool
local function analyzeTool(tool)
    if not tool or not tool:IsA("Tool") then return nil end
    
    local info = {
        name = tool.Name,
        parent = tool.Parent and tool.Parent.Name or "nil",
        handle = nil
    }
    
    local handle = tool:FindFirstChild("Handle")
    if handle and handle:IsA("BasePart") then
        info.handle = {
            size = tostring(handle.Size),
            position = tostring(handle.Position),
            cframe = tostring(handle.CFrame),
            anchored = handle.Anchored,
            transparency = handle.Transparency
        }
        
        -- Анализируем Mesh
        for _, child in pairs(handle:GetChildren()) do
            if child:IsA("SpecialMesh") then
                info.handle.mesh = {
                    meshId = child.MeshId,
                    textureId = child.TextureId,
                    scale = tostring(child.Scale)
                }
            end
        end
    end
    
    return info
end

-- === МОНИТОРИНГ BACKPACK ===
log("SYSTEM", "🎒 Запуск мониторинга Backpack")

backpack.ChildAdded:Connect(function(child)
    if child:IsA("Tool") then
        wait(0.1)
        local toolInfo = analyzeTool(child)
        log("BACKPACK", "✅ НОВЫЙ TOOL: " .. child.Name, toolInfo)
        
        -- Проверяем питомца
        if child.Name:find("KG") or child.Name:find("Dragonfly") or 
           child.Name:find("%{") or child.Name:find("Pet") then
            log("PET_DETECTION", "🐾 ПИТОМЕЦ В BACKPACK: " .. child.Name, toolInfo)
            table.insert(petCreationEvents, {
                timestamp = tick(),
                phase = "BACKPACK_ADDED",
                petName = child.Name,
                toolInfo = toolInfo
            })
        end
        
        -- Отслеживаем когда покидает Backpack
        child.AncestryChanged:Connect(function()
            if child.Parent ~= backpack then
                log("BACKPACK", "📤 Tool покинул Backpack: " .. child.Name, {
                    newParent = child.Parent and child.Parent.Name or "nil"
                })
            end
        end)
    end
end)

-- === МОНИТОРИНГ HANDLE ===
log("SYSTEM", "🤲 Запуск мониторинга Handle")

local function monitorCharacter(char)
    if not char then return end
    
    char.ChildAdded:Connect(function(child)
        if child:IsA("Tool") then
            wait(0.1)
            currentHandleTool = child
            local analysis = analyzeTool(child)
            
            log("HANDLE", "⚡ TOOL ЭКИПИРОВАН: " .. child.Name, analysis)
            
            -- Проверяем питомца
            if child.Name:find("KG") or child.Name:find("Dragonfly") or 
               child.Name:find("%{") or child.Name:find("Pet") then
                
                log("PET_DETECTION", "🐾 ПИТОМЕЦ В РУКЕ: " .. child.Name, analysis)
                
                table.insert(petCreationEvents, {
                    timestamp = tick(),
                    phase = "HANDLE_EQUIPPED",
                    petName = child.Name,
                    analysis = analysis
                })
                
                -- Анализируем позиционирование
                local handle = child:FindFirstChild("Handle")
                if handle then
                    local torso = char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
                    if torso then
                        local relativePos = torso.CFrame:PointToObjectSpace(handle.Position)
                        log("POSITION", "📍 Относительная позиция Handle", {
                            relativePosition = tostring(relativePos),
                            handleCFrame = tostring(handle.CFrame)
                        })
                    end
                end
                
                -- Анализируем RightGrip
                local rightArm = char:FindFirstChild("Right Arm") or char:FindFirstChild("RightHand")
                if rightArm then
                    local rightGrip = rightArm:FindFirstChild("RightGrip")
                    if rightGrip then
                        log("GRIP", "🔗 RightGrip найден", {
                            c0 = tostring(rightGrip.C0),
                            c1 = tostring(rightGrip.C1),
                            part0 = rightGrip.Part0 and rightGrip.Part0.Name or "nil",
                            part1 = rightGrip.Part1 and rightGrip.Part1.Name or "nil"
                        })
                    end
                end
            end
        end
    end)
    
    char.ChildRemoved:Connect(function(child)
        if child:IsA("Tool") and child == currentHandleTool then
            log("HANDLE", "📤 TOOL СНЯТ: " .. child.Name)
            currentHandleTool = nil
        end
    end)
end

if character then
    monitorCharacter(character)
end

player.CharacterAdded:Connect(monitorCharacter)

-- === ФУНКЦИЯ ОТЧЕТА ===
local function generateReport()
    print("\n" .. "=" .. string.rep("=", 50))
    print("📊 === ОТЧЕТ О СОЗДАНИИ ПИТОМЦА ===")
    print("=" .. string.rep("=", 50))
    
    if #petCreationEvents == 0 then
        print("❌ Событий создания питомца не обнаружено")
        return
    end
    
    for i, event in ipairs(petCreationEvents) do
        print(string.format("\n🔸 Событие %d: %s", i, event.phase))
        print(string.format("   ⏰ Время: %.3f", event.timestamp))
        print(string.format("   🐾 Питомец: %s", event.petName))
        
        if event.toolInfo and event.toolInfo.handle then
            print("   📦 Handle Info:")
            print(string.format("      Size: %s", event.toolInfo.handle.size))
            print(string.format("      Position: %s", event.toolInfo.handle.position))
        end
    end
    
    print("\n" .. "=" .. string.rep("=", 50))
end

-- === GUI ===
local function createGUI()
    local oldGui = playerGui:FindFirstChild("PetAnalyzerGUI")
    if oldGui then oldGui:Destroy() end
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "PetAnalyzerGUI"
    screenGui.Parent = playerGui
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 300, 0, 200)
    frame.Position = UDim2.new(0, 10, 0, 10)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    frame.Parent = screenGui
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundColor3 = Color3.fromRGB(50, 150, 250)
    title.Text = "🔍 Pet Analyzer"
    title.TextColor3 = Color3.white
    title.TextScaled = true
    title.Font = Enum.Font.SourceSansBold
    title.Parent = frame
    
    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(1, -10, 0, 30)
    status.Position = UDim2.new(0, 5, 0, 45)
    status.BackgroundTransparency = 1
    status.Text = "✅ Анализатор активен"
    status.TextColor3 = Color3.fromRGB(0, 255, 0)
    status.TextScaled = true
    status.Parent = frame
    
    local reportBtn = Instance.new("TextButton")
    reportBtn.Size = UDim2.new(1, -10, 0, 35)
    reportBtn.Position = UDim2.new(0, 5, 0, 85)
    reportBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
    reportBtn.Text = "📊 Создать отчет"
    reportBtn.TextColor3 = Color3.white
    reportBtn.TextScaled = true
    reportBtn.Parent = frame
    
    local clearBtn = Instance.new("TextButton")
    clearBtn.Size = UDim2.new(1, -10, 0, 35)
    clearBtn.Position = UDim2.new(0, 5, 0, 130)
    clearBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
    clearBtn.Text = "🗑️ Очистить лог"
    clearBtn.TextColor3 = Color3.white
    clearBtn.TextScaled = true
    clearBtn.Parent = frame
    
    reportBtn.MouseButton1Click:Connect(generateReport)
    clearBtn.MouseButton1Click:Connect(function()
        analysisLog = {}
        petCreationEvents = {}
        log("SYSTEM", "🗑️ Лог очищен")
    end)
end

createGUI()

log("SYSTEM", "✅ Pet Creation Analyzer запущен!")
log("SYSTEM", "💡 Создайте питомца и возьмите его в руки для анализа")
