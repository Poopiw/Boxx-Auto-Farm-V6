-- === 1. ADONIS ANTI-CHEAT BYPASS ===
local getinfo = getinfo or debug.getinfo
setthreadidentity(2)
local Detected, Kill
for i, v in getgc(true) do
    if typeof(v) == "table" then
        local d, k = rawget(v, "Detected"), rawget(v, "Kill")
        if typeof(d) == "function" and not Detected then
            Detected = d
            hookfunction(Detected, function() return true end)
        end
        if rawget(v, "Variables") and typeof(k) == "function" and not Kill then
            Kill = k
            hookfunction(Kill, function() end)
        end
    end
end
setthreadidentity(7)
task.wait(1) 

-- === 2. MAIN SCRIPT & UI ===
local lp = game.Players.LocalPlayer
local pps = game:GetService("ProximityPromptService")
local VirtualUser = game:GetService("VirtualUser")
local boxPos, dropPos = nil, nil
_G.Running = false

-- Anti-AFK
lp.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

-- Instant Interaction
pps.PromptShown:Connect(function(p)
    p.HoldDuration = 0
    p.RequiresLineOfSight = false
end)

-- UI STYLING
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 260, 0, 320)
MainFrame.Position = UDim2.new(0.5, -130, 0.5, -160)
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 14)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true

-- RGB BORDER (Using 1-pixel frame overlay for sharp, non-blocky look)
local Border = Instance.new("Frame", MainFrame)
Border.Name = "RGB_Outline"
Border.Size = UDim2.new(1, 4, 1, 4)
Border.Position = UDim2.new(0, -2, 0, -2)
Border.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Border.BorderSizePixel = 0
Border.ZIndex = 0

local InnerFrame = Instance.new("Frame", MainFrame)
InnerFrame.Size = UDim2.new(1, 0, 1, 0)
InnerFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 14)
InnerFrame.BorderSizePixel = 0
InnerFrame.ZIndex = 1

-- RGB Loop
task.spawn(function()
    while task.wait() do
        local hue = tick() % 5 / 5
        Border.BackgroundColor3 = Color3.fromHSV(hue, 0.8, 1)
    end
end)

-- HEADER
local Header = Instance.new("Frame", InnerFrame)
Header.Size = UDim2.new(1, 0, 0, 45)
Header.BackgroundColor3 = Color3.fromRGB(20, 20, 23)
Header.BorderSizePixel = 0

local Title = Instance.new("TextLabel", Header)
Title.Size = UDim2.new(1, 0, 1, 0)
Title.BackgroundTransparency = 1
Title.Text = "FERDINAND Auto Farm v6"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 13

local Close = Instance.new("TextButton", Header)
Close.Size = UDim2.new(0, 30, 0, 30)
Close.Position = UDim2.new(1, -35, 0, 7)
Close.Text = "×"
Close.TextColor3 = Color3.fromRGB(255, 80, 80)
Close.BackgroundTransparency = 1
Close.TextSize = 22
Close.Font = Enum.Font.GothamBold

-- CONTAINER
local Container = Instance.new("Frame", InnerFrame)
Container.Size = UDim2.new(1, -30, 1, -60)
Container.Position = UDim2.new(0, 15, 0, 55)
Container.BackgroundTransparency = 1

local function CreateBtn(text, pos, color)
    local b = Instance.new("TextButton", Container)
    b.Size = UDim2.new(1, 0, 0, 48)
    b.Position = pos
    b.BackgroundColor3 = Color3.fromRGB(25, 25, 28)
    b.BorderSizePixel = 0
    b.Text = text
    b.TextColor3 = Color3.fromRGB(200, 200, 200)
    b.Font = Enum.Font.GothamSemibold
    b.TextSize = 11
    
    -- Accent bar at the bottom for "Premium" look
    local accent = Instance.new("Frame", b)
    accent.Size = UDim2.new(1, 0, 0, 2)
    accent.Position = UDim2.new(0, 0, 1, -2)
    accent.BackgroundColor3 = color
    accent.BorderSizePixel = 0
    
    return b
end

local B1 = CreateBtn("SET PICKUP LOCATION", UDim2.new(0, 0, 0, 10), Color3.fromRGB(0, 170, 255))
local B2 = CreateBtn("SET DELIVERY LOCATION", UDim2.new(0, 0, 0, 70), Color3.fromRGB(0, 170, 255))
local B3 = CreateBtn("INITIALIZE CORE ENGINE", UDim2.new(0, 0, 0, 150), Color3.fromRGB(0, 255, 150))

-- STATUS LOG
local Status = Instance.new("TextLabel", InnerFrame)
Status.Size = UDim2.new(1, 0, 0, 30)
Status.Position = UDim2.new(0, 0, 1, -30)
Status.BackgroundTransparency = 1
Status.Text = "SYSTEM: STANDBY"
Status.TextColor3 = Color3.fromRGB(100, 100, 100)
Status.Font = Enum.Font.Code
Status.TextSize = 10

-- GRIND LOGIC
local function forceFire()
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("ProximityPrompt") then
            local success, dist = pcall(function() 
                local pos = v.Parent:IsA("Attachment") and v.Parent.WorldPosition or v.Parent.Position
                return (lp.Character.PrimaryPart.Position - pos).Magnitude 
            end)
            if success and dist < 25 then fireproximityprompt(v) end
        end
    end
end

B1.MouseButton1Click:Connect(function() boxPos = lp.Character.PrimaryPart.CFrame Status.Text = "SYSTEM: POS_A_LATCHED" end)
B2.MouseButton1Click:Connect(function() dropPos = lp.Character.PrimaryPart.CFrame Status.Text = "SYSTEM: POS_B_LATCHED" end)

B3.MouseButton1Click:Connect(function()
    if not boxPos or not dropPos then Status.Text = "SYSTEM: ERR_POS_MISSING" return end
    _G.Running = not _G.Running
    B3.Text = _G.Running and "TERMINATE ENGINE" or "INITIALIZE CORE ENGINE"
    B3.BackgroundColor3 = _G.Running and Color3.fromRGB(35, 20, 20) or Color3.fromRGB(25, 25, 28)
    Status.Text = _G.Running and "SYSTEM: EXECUTING" or "SYSTEM: HALTED"
    
    if _G.Running then
        task.spawn(function()
            while _G.Running do
                local char = lp.Character
                if char and char.PrimaryPart then
                    char:SetPrimaryPartCFrame(boxPos)
                    task.wait(0.7)
                    forceFire()
                    task.wait(0.5)
                    local bp = lp:FindFirstChild("Backpack")
                    if bp then
                        for _, t in pairs(bp:GetChildren()) do
                            if t.Name:lower():find("box") or t.Name:lower():find("crate") then t.Parent = char end
                        end
                    end
                    task.wait(0.5)
                    char:SetPrimaryPartCFrame(dropPos)
                    task.wait(0.7)
                    forceFire()
                    task.wait(1.5)
                end
            end
        end)
    end
end)

Close.MouseButton1Click:Connect(function() _G.Running = false ScreenGui:Destroy() end)
