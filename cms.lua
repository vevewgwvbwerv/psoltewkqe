-- Universal LuaArmor Interceptor
-- Self-contained script that can be loaded directly into an exploit
-- Intercepts loadstring calls and displays code in GUI instead of executing

-- Check if we're in a Roblox environment
if not game thenn
    print("[ERROR] This script must be run in a Roblox environment")
    return
end

-- Store original functions
local original_loadstring = loadstring
local original_HttpGet = game.HttpGet

-- Table to store intercepted code
local interceptedCode = {}

-- Override loadstring to intercept code
loadstring = function(source, chunkname)
    -- Store the code instead of executing it
    table.insert(interceptedCode, {
        source = source,
        chunkname = chunkname,
        timestamp = tick()
    })
    
    -- Print to console for immediate viewing
    print("[INTERCEPTED] Code loaded via loadstring:")
    print(source)
    print("----------------------------------------")
    
    -- Return a dummy function instead of the actual loaded function
    return function() end
end

-- Override HttpGet to intercept network requests (if possible)
do
    local function override_HttpGet()
        -- Try to override HttpGet directly
        if game.HttpGet then
            game.HttpGet = function(self, url, nocache)
                local result = original_HttpGet(self, url, nocache)
                print("[INTERCEPTED] HttpGet request to: " .. tostring(url))
                print("Response:")
                print(result)
                print("----------------------------------------")
                return result
            end
        end
    end
    
    -- Try to override HttpGet
    pcall(override_HttpGet)
end

-- Create GUI Console for displaying intercepted code
local function createGUI()
    -- Prevent multiple GUI instances
    if game.Players.LocalPlayer:FindFirstChild("PlayerGui"):FindFirstChild("LuaArmorInterceptor") then
        return
    end
    
    -- Create ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "LuaArmorInterceptor"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    
    -- Create Frame
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0.8, 0, 0.8, 0)
    frame.Position = UDim2.new(0.1, 0, 0.1, 0)
    frame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
    frame.BorderSizePixel = 2
    frame.BorderColor3 = Color3.new(0, 0.5, 1)
    frame.Parent = screenGui
    
    -- Create Title
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0.05, 0)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "LuaArmor Interceptor Console"
    title.TextColor3 = Color3.new(1, 1, 1)
    title.TextScaled = true
    title.Font = Enum.Font.SourceSansBold
    title.Parent = frame
    
    -- Create ScrollingFrame for code display
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Size = UDim2.new(1, -20, 0.9, -40)
    scrollFrame.Position = UDim2.new(0, 10, 0.05, 10)
    scrollFrame.BackgroundTransparency = 0.5
    scrollFrame.BackgroundColor3 = Color3.new(0, 0, 0)
    scrollFrame.BorderSizePixel = 0
    scrollFrame.ScrollBarThickness = 10
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    scrollFrame.Parent = frame
    
    -- Create TextLabel for code display
    local codeDisplay = Instance.new("TextLabel")
    codeDisplay.Name = "CodeDisplay"
    codeDisplay.Size = UDim2.new(1, -20, 0, 0)
    codeDisplay.Position = UDim2.new(0, 10, 0, 0)
    codeDisplay.BackgroundTransparency = 1
    codeDisplay.Text = "Intercepted code will appear here...\n\nLoad a LuaArmor script to begin interception.\nExample: loadstring(game:HttpGet(\"https://api.luarmor.net/files/v4/loaders/0e08efc5390446f12bb3f48e59cc6766.lua\"))()"
    codeDisplay.TextColor3 = Color3.new(1, 1, 1)
    codeDisplay.TextXAlignment = Enum.TextXAlignment.Left
    codeDisplay.TextYAlignment = Enum.TextYAlignment.Top
    codeDisplay.TextWrapped = true
    codeDisplay.RichText = true
    codeDisplay.Font = Enum.Font.Monospace
    codeDisplay.TextSize = 14
    codeDisplay.Parent = scrollFrame
    
    -- Update function for displaying code
    local function updateDisplay()
        local text = ""
        for i, code in ipairs(interceptedCode) do
            text = text .. "[[ CODE BLOCK " .. i .. " - " .. os.date("%H:%M:%S", math.floor(code.timestamp)) .. " ]]\n" .. code.source .. "\n\n"
        end
        
        if text == "" then
            codeDisplay.Text = "Intercepted code will appear here...\n\nLoad a LuaArmor script to begin interception.\nExample: loadstring(game:HttpGet(\"https://api.luarmor.net/files/v4/loaders/0e08efc5390446f12bb3f48e59cc6766.lua\"))()"
        else
            codeDisplay.Text = text
        end
        
        -- Update canvas size
        codeDisplay.Size = UDim2.new(1, -20, 0, codeDisplay.TextBounds.Y)
        scrollFrame.CanvasSize = UDim2.new(0, 0, 0, codeDisplay.TextBounds.Y + 20)
    end
    
    -- Update display when new code is intercepted
    local updateConnection
    updateConnection = game:GetService("RunService").Heartbeat:Connect(function()
        updateDisplay()
    end)
    
    -- Create Close Button
    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.new(0.2, 0, 0.05, 0)
    closeButton.Position = UDim2.new(0.8, -10, 0.95, -10)
    closeButton.AnchorPoint = Vector2.new(1, 1)
    closeButton.Text = "Close"
    closeButton.TextColor3 = Color3.new(1, 1, 1)
    closeButton.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
    closeButton.Parent = frame
    
    closeButton.MouseButton1Click:Connect(function()
        screenGui:Destroy()
        if updateConnection then
            updateConnection:Disconnect()
        end
    end)
    
    return screenGui
end

-- Initialize the interceptor
print("[LuaArmor Interceptor] Initializing...")

-- Create GUI
local success, gui = pcall(createGUI)
if not success then
    warn("[LuaArmor Interceptor] Failed to create GUI: " .. tostring(gui))
else
    print("[LuaArmor Interceptor] GUI created successfully!")
end

print("[LuaArmor Interceptor] Ready! Intercepting loadstring calls...")
print("[LuaArmor Interceptor] Load LuaArmor scripts normally, code will be displayed in GUI instead of executing.")

-- Example usage (commented out):
-- loadstring(game:HttpGet("https://api.luarmor.net/files/v4/loaders/0e08efc5390446f12bb3f48e59cc6766.lua"))()

return true
