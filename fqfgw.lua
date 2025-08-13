-- Advanced LuaArmor Interceptor
-- Self-contained script that uses advanced hooking techniques to intercept LuaArmor code

-- Check if we're in a Roblox environment
if not game then
    print("[ERROR] This script must be run in a Roblox environment")
    return
end

-- Store original functions
local original_loadstring = loadstring
local original_pcall = pcall
local original_xpcall = xpcall
local original_HttpGet = game.HttpGet

-- Table to store intercepted code
local interceptedCode = {}
local interceptedFunctions = {}

-- Function to safely add intercepted code
local function addInterceptedCode(source, chunkname, method)
    table.insert(interceptedCode, {
        source = source,
        chunkname = chunkname,
        method = method or "unknown",
        timestamp = tick()
    })
    
    -- Print to console for immediate viewing
    print("[INTERCEPTED] Code intercepted via " .. method .. ":")
    print(source)
    print("----------------------------------------")
end

-- Advanced loadstring hook using hookfunction if available
local function hookLoadstring()
    -- Try to hook loadstring directly
    loadstring = function(source, chunkname)
        addInterceptedCode(source, chunkname, "loadstring")
        -- Return a dummy function instead of the actual loaded function
        return function() end
    end
    
    -- Try to hook with hookfunction if available (in some exploits)
    if hookfunction then
        local success, err = pcall(function()
            hookfunction(original_loadstring, function(source, chunkname)
                addInterceptedCode(source, chunkname, "hookfunction(loadstring)")
                return function() end
            end)
        end)
        
        if success then
            print("[HOOK] Successfully hooked loadstring with hookfunction")
        else
            print("[HOOK] Failed to hook loadstring with hookfunction: " .. tostring(err))
        end
    end
end

-- Hook HttpGet to intercept network requests
local function hookHttpGet()
    if game.HttpGet then
        local success, err = pcall(function()
            game.HttpGet = function(self, url, nocache)
                local result = original_HttpGet(self, url, nocache)
                print("[INTERCEPTED] HttpGet request to: " .. tostring(url))
                addInterceptedCode(result, url, "HttpGet")
                return result
            end
        end)
        
        if success then
            print("[HOOK] Successfully hooked HttpGet")
        else
            print("[HOOK] Failed to hook HttpGet: " .. tostring(err))
        end
    end
end

-- Hook pcall and xpcall to catch executed functions
local function hookCallFunctions()
    pcall = function(func, ...)
        if type(func) == "function" then
            table.insert(interceptedFunctions, {
                func = func,
                args = {...},
                timestamp = tick(),
                method = "pcall"
            })
        end
        return original_pcall(func, ...)
    end
    
    xpcall = function(func, errHandler, ...)
        if type(func) == "function" then
            table.insert(interceptedFunctions, {
                func = func,
                args = {...},
                timestamp = tick(),
                method = "xpcall"
            })
        end
        return original_xpcall(func, errHandler, ...)
    end
end

-- Try to hook metamethods if possible
local function hookMetamethods()
    if hookmetamethod then
        local success, err = pcall(function()
            -- Hook __call metamethod
            local original_call = hookmetamethod(game, "__call", function(func, ...)
                if type(func) == "function" then
                    table.insert(interceptedFunctions, {
                        func = func,
                        args = {...},
                        timestamp = tick(),
                        method = "__call"
                    })
                end
                return original_call(func, ...)
            end)
            
            if success then
                print("[HOOK] Successfully hooked __call metamethod")
            else
                print("[HOOK] Failed to hook __call metamethod: " .. tostring(err))
            end
        end)
    end
end

-- Try to get function source if possible
local function tryGetFunctionSource(func)
    -- Some exploits have getinfo or similar functions
    if getinfo then
        local info = getinfo(func)
        if info and info.source then
            return info.source
        end
    end
    
    -- Try other methods if available
    if typeof and typeof(func) == "function" then
        -- In some environments, we can get function details
        return "function source not available"
    end
    
    return "function source not available"
end

-- Enhanced GUI Console for displaying intercepted code
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
    frame.Size = UDim2.new(0.9, 0, 0.9, 0)
    frame.Position = UDim2.new(0.05, 0, 0.05, 0)
    frame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
    frame.BorderSizePixel = 2
    frame.BorderColor3 = Color3.new(0, 0.5, 1)
    frame.Parent = screenGui
    
    -- Create Title
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0.05, 0)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "Advanced LuaArmor Interceptor Console"
    title.TextColor3 = Color3.new(1, 1, 1)
    title.TextScaled = true
    title.Font = Enum.Font.SourceSansBold
    title.Parent = frame
    
    -- Create Tabs
    local tabFrame = Instance.new("Frame")
    tabFrame.Size = UDim2.new(1, 0, 0.05, 0)
    tabFrame.Position = UDim2.new(0, 0, 0.05, 0)
    tabFrame.BackgroundTransparency = 0.8
    tabFrame.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
    tabFrame.Parent = frame
    
    local tabLoadstring = Instance.new("TextButton")
    tabLoadstring.Size = UDim2.new(0.5, 0, 1, 0)
    tabLoadstring.Position = UDim2.new(0, 0, 0, 0)
    tabLoadstring.Text = "Loadstring Code"
    tabLoadstring.TextColor3 = Color3.new(1, 1, 1)
    tabLoadstring.BackgroundTransparency = 0.5
    tabLoadstring.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
    tabLoadstring.Parent = tabFrame
    
    local tabFunctions = Instance.new("TextButton")
    tabFunctions.Size = UDim2.new(0.5, 0, 1, 0)
    tabFunctions.Position = UDim2.new(0.5, 0, 0, 0)
    tabFunctions.Text = "Intercepted Functions"
    tabFunctions.TextColor3 = Color3.new(1, 1, 1)
    tabFunctions.BackgroundTransparency = 0.5
    tabFunctions.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
    tabFunctions.Parent = tabFrame
    
    -- Create ScrollingFrame for code display
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Size = UDim2.new(1, -20, 0.85, -40)
    scrollFrame.Position = UDim2.new(0, 10, 0.1, 10)
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
    codeDisplay.Text = "Intercepted code will appear here...\n\nLoad a LuaArmor script to begin interception.\nExample: loadstring(game:HttpGet(\"https://api.luarmor.net/files/v4/loaders/0e08efc5390446f12bb3f48e59cc6766.lua\"))()\n\nAdvanced hooks status:\n- loadstring: " .. (hookfunction and "Available" or "Not available") .. "\n- hookmetamethod: " .. (hookmetamethod and "Available" or "Not available")
    codeDisplay.TextColor3 = Color3.new(1, 1, 1)
    codeDisplay.TextXAlignment = Enum.TextXAlignment.Left
    codeDisplay.TextYAlignment = Enum.TextYAlignment.Top
    codeDisplay.TextWrapped = true
    codeDisplay.RichText = true
    codeDisplay.Font = Enum.Font.Monospace
    codeDisplay.TextSize = 14
    codeDisplay.Parent = scrollFrame
    
    -- Update function for displaying code
    local currentTab = "loadstring"
    
    local function updateDisplay()
        local text = ""
        
        if currentTab == "loadstring" then
            for i, code in ipairs(interceptedCode) do
                text = text .. "[[ " .. code.method .. " - " .. os.date("%H:%M:%S", math.floor(code.timestamp)) .. " ]]\n" .. code.source .. "\n\n"
            end
            
            if text == "" then
                text = "Intercepted code will appear here...\n\nLoad a LuaArmor script to begin interception.\nExample: loadstring(game:HttpGet(\"https://api.luarmor.net/files/v4/loaders/0e08efc5390446f12bb3f48e59cc6766.lua\"))()\n\nAdvanced hooks status:\n- loadstring: " .. (hookfunction and "Available" or "Not available") .. "\n- hookmetamethod: " .. (hookmetamethod and "Available" or "Not available")
            end
        else
            for i, funcData in ipairs(interceptedFunctions) do
                local source = tryGetFunctionSource(funcData.func)
                text = text .. "[[ " .. funcData.method .. " - " .. os.date("%H:%M:%S", math.floor(funcData.timestamp)) .. " ]]\nFunction source: " .. source .. "\nArgs: " .. tostring(funcData.args) .. "\n\n"
            end
            
            if text == "" then
                text = "Intercepted functions will appear here...\n\nThis tab shows functions that were intercepted via pcall/xpcall/__call hooks."
            end
        end
        
        codeDisplay.Text = text
        
        -- Update canvas size
        codeDisplay.Size = UDim2.new(1, -20, 0, codeDisplay.TextBounds.Y)
        scrollFrame.CanvasSize = UDim2.new(0, 0, 0, codeDisplay.TextBounds.Y + 20)
    end
    
    -- Tab switching
    tabLoadstring.MouseButton1Click:Connect(function()
        currentTab = "loadstring"
        tabLoadstring.BackgroundTransparency = 0.2
        tabLoadstring.BackgroundColor3 = Color3.new(0.4, 0.4, 0.4)
        tabFunctions.BackgroundTransparency = 0.5
        tabFunctions.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
        updateDisplay()
    end)
    
    tabFunctions.MouseButton1Click:Connect(function()
        currentTab = "functions"
        tabFunctions.BackgroundTransparency = 0.2
        tabFunctions.BackgroundColor3 = Color3.new(0.4, 0.4, 0.4)
        tabLoadstring.BackgroundTransparency = 0.5
        tabLoadstring.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
        updateDisplay()
    end)
    
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
print("[LuaArmor Interceptor] Initializing advanced hooks...")

-- Apply hooks
hookLoadstring()
hookHttpGet()
hookCallFunctions()
hookMetamethods()

-- Create GUI
local success, gui = pcall(createGUI)
if not success then
    warn("[LuaArmor Interceptor] Failed to create GUI: " .. tostring(gui))
else
    print("[LuaArmor Interceptor] Advanced GUI created successfully!")
end

print("[LuaArmor Interceptor] Advanced hooks ready! Intercepting loadstring calls and functions...")
print("[LuaArmor Interceptor] Load LuaArmor scripts normally, code will be displayed in GUI instead of executing.")

-- Example usage (commented out):
-- loadstring(game:HttpGet("https://api.luarmor.net/files/v4/loaders/0e08efc5390446f12bb3f48e59cc6766.lua"))()

return true
