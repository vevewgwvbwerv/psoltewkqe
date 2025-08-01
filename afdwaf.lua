--[[
    EXPLOIT DIAGNOSTIC
    Проверяем что происходит при открытии яйца
]]

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer

-- GUI для диагностики
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ExploitDiagnostic"
screenGui.Parent = CoreGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 400, 0, 300)
frame.Position = UDim2.new(0, 10, 0, 10)
frame.BackgroundColor3 = Color3.new(0, 0, 0)
frame.BackgroundTransparency = 0.2
frame.BorderSizePixel = 0
frame.Parent = screenGui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundTransparency = 1
title.Text = "🔍 EXPLOIT DIAGNOSTIC"
title.TextColor3 = Color3.new(1, 1, 1)
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.Parent = frame

local logFrame = Instance.new("ScrollingFrame")
logFrame.Size = UDim2.new(1, -10, 1, -40)
logFrame.Position = UDim2.new(0, 5, 0, 35)
logFrame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
logFrame.BorderSizePixel = 0
logFrame.ScrollBarThickness = 8
logFrame.Parent = frame

local logText = Instance.new("TextLabel")
logText.Size = UDim2.new(1, -10, 1, 0)
logText.Position = UDim2.new(0, 5, 0, 0)
logText.BackgroundTransparency = 1
logText.Text = "Starting diagnostic...\n"
logText.TextColor3 = Color3.new(1, 1, 1)
logText.TextSize = 12
logText.Font = Enum.Font.Code
logText.TextXAlignment = Enum.TextXAlignment.Left
logText.TextYAlignment = Enum.TextYAlignment.Top
logText.TextWrapped = true
logText.Parent = logFrame

local function log(message)
    local timestamp = os.date("%H:%M:%S")
    logText.Text = logText.Text .. "[" .. timestamp .. "] " .. message .. "\n"
    logFrame.CanvasSize = UDim2.new(0, 0, 0, logText.TextBounds.Y)
    logFrame.CanvasPosition = Vector2.new(0, logFrame.CanvasSize.Y.Offset)
end

-- Проверяем структуру Workspace
log("=== WORKSPACE STRUCTURE ===")
for _, child in ipairs(Workspace:GetChildren()) do
    log("Workspace." .. child.Name .. " (" .. child.ClassName .. ")")
end

-- Проверяем есть ли Visuals
if Workspace:FindFirstChild("Visuals") then
    log("✅ Workspace.Visuals найден!")
    log("Visuals содержит " .. #Workspace.Visuals:GetChildren() .. " объектов")
    for _, child in ipairs(Workspace.Visuals:GetChildren()) do
        log("  - " .. child.Name .. " (" .. child.ClassName .. ")")
    end
else
    log("❌ Workspace.Visuals НЕ найден!")
    log("Ищем альтернативные папки...")
    for _, child in ipairs(Workspace:GetChildren()) do
        if child:IsA("Folder") or child:IsA("Model") then
            log("  Возможная папка: " .. child.Name)
        end
    end
end

-- Проверяем питомца в руке
log("\n=== PET IN HAND ===")
if player.Character then
    log("✅ Character найден: " .. player.Character.Name)
    local foundTool = false
    for _, tool in ipairs(player.Character:GetChildren()) do
        if tool:IsA("Tool") then
            foundTool = true
            log("✅ Tool найден: " .. tool.Name)
            local model = tool:FindFirstChildWhichIsA("Model")
            if model then
                log("✅ Model в Tool: " .. model.Name)
                log("  Parts в модели: " .. #model:GetChildren())
                for _, part in ipairs(model:GetChildren()) do
                    if part:IsA("BasePart") then
                        log("    - " .. part.Name .. " (Size: " .. tostring(part.Size) .. ")")
                    end
                end
            else
                log("❌ Model в Tool НЕ найден!")
                log("  Содержимое Tool:")
                for _, child in ipairs(tool:GetChildren()) do
                    log("    - " .. child.Name .. " (" .. child.ClassName .. ")")
                end
            end
        end
    end
    if not foundTool then
        log("❌ Tool НЕ найден в руке!")
        log("Содержимое Character:")
        for _, child in ipairs(player.Character:GetChildren()) do
            log("  - " .. child.Name .. " (" .. child.ClassName .. ")")
        end
    end
else
    log("❌ Character НЕ найден!")
end

-- Мониторим изменения в Workspace
log("\n=== MONITORING CHANGES ===")
log("Слушаем изменения в Workspace...")

Workspace.ChildAdded:Connect(function(child)
    log("🔥 WORKSPACE ADD: " .. child.Name .. " (" .. child.ClassName .. ")")
end)

Workspace.ChildRemoved:Connect(function(child)
    log("🗑️ WORKSPACE REMOVE: " .. child.Name .. " (" .. child.ClassName .. ")")
end)

-- Мониторим Visuals если есть
if Workspace:FindFirstChild("Visuals") then
    Workspace.Visuals.ChildAdded:Connect(function(child)
        log("🎯 VISUALS ADD: " .. child.Name .. " (" .. child.ClassName .. ")")
        if child:IsA("Model") then
            log("  📦 Model details:")
            log("    PrimaryPart: " .. (child.PrimaryPart and child.PrimaryPart.Name or "nil"))
            log("    Parts count: " .. #child:GetChildren())
            log("    Position: " .. tostring(child:GetModelCFrame().Position))
        end
    end)
    
    Workspace.Visuals.ChildRemoved:Connect(function(child)
        log("🗑️ VISUALS REMOVE: " .. child.Name .. " (" .. child.ClassName .. ")")
    end)
end

-- Мониторим все папки в Workspace
for _, folder in ipairs(Workspace:GetChildren()) do
    if folder:IsA("Folder") or folder:IsA("Model") then
        folder.ChildAdded:Connect(function(child)
            log("📁 " .. folder.Name .. " ADD: " .. child.Name .. " (" .. child.ClassName .. ")")
        end)
    end
end

log("✅ Diagnostic готов! Открой яйцо и смотри логи.")

print("🔍 Exploit Diagnostic loaded! Check GUI for logs.")
