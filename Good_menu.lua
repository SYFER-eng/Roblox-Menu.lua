-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

-- Create Main GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "PhantomMenu"
ScreenGui.DisplayOrder = 999999
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global

-- Try to parent to CoreGui
local success, result = pcall(function()
    ScreenGui.Parent = CoreGui
end)

if not success then
    ScreenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
end

-- Main Frame Setup
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 669, 0, 400)
MainFrame.Position = UDim2.new(0.5, -334, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.ZIndex = 999999
MainFrame.Parent = ScreenGui

-- UI Elements
local UICorner_Main = Instance.new("UICorner")
UICorner_Main.CornerRadius = UDim.new(0, 10)
UICorner_Main.Parent = MainFrame

-- Shadow Effect
local Shadow = Instance.new("ImageLabel")
Shadow.Name = "Shadow"
Shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Shadow.BackgroundTransparency = 1
Shadow.Position = UDim2.new(-0.0293, 0, -0.0244, 0)
Shadow.Size = UDim2.new(1.06, 0, 1.06, 0)
Shadow.ZIndex = 999998
Shadow.Image = "rbxassetid://5554236805"
Shadow.ImageColor3 = Color3.fromRGB(147, 112, 219)
Shadow.ImageTransparency = 0.4
Shadow.Parent = MainFrame

-- Title Setup
local Title = Instance.new("TextLabel")
Title.Name = "MenuTitle"
Title.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Font = Enum.Font.GothamBold
Title.Text = "✦ PHANTOM MENU ✦"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 22
Title.ZIndex = 999999
Title.Parent = MainFrame

local UIGradient_Title = Instance.new("UIGradient")
UIGradient_Title.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(147, 112, 219)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(138, 43, 226))
}
UIGradient_Title.Parent = Title

-- Enhanced Settings
Settings = {
    ESP = {
        Enabled = false,
        Boxes = false,
        Names = false,
        Distance = false,
        Health = false,
        Snaplines = false,
        TeamCheck = false,
        Rainbow = false,
        BoxColor = Color3.fromRGB(147, 112, 219),
        Players = {},
        Tracers = {}
    },
    Aimbot = {
        Enabled = false,
        FOV = 100,
        ShowFOV = false,
        Smoothness = 0.5,
        TeamCheck = false,
        TargetPart = "Head",
        SmoothingEnabled = false
    },
    Misc = {
        NoRecoil = false,
        BunnyHop = false
    }
}

-- Drawing Objects
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 2
FOVCircle.NumSides = 100
FOVCircle.Radius = 100
FOVCircle.Filled = false
FOVCircle.Visible = false
FOVCircle.ZIndex = 999
FOVCircle.Transparency = 1
FOVCircle.Color = Color3.fromRGB(147, 112, 219)

-- Navigation Setup
local Navigation = Instance.new("Frame")
Navigation.Size = UDim2.new(1, 0, 0, 50)
Navigation.Position = UDim2.new(0, 0, 0, 40)
Navigation.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
Navigation.ZIndex = 999999
Navigation.Parent = MainFrame

local UICorner_Nav = Instance.new("UICorner")
UICorner_Nav.CornerRadius = UDim.new(0, 6)
UICorner_Nav.Parent = Navigation

-- Create Page Function
local function CreatePage(name)
    local Page = Instance.new("ScrollingFrame")
    Page.Name = name
    Page.Size = UDim2.new(1, 0, 1, -90)
    Page.Position = UDim2.new(0, 0, 0, 90)
    Page.BackgroundTransparency = 1
    Page.ScrollBarThickness = 2
    Page.ScrollBarImageColor3 = Color3.fromRGB(147, 112, 219)
    Page.ZIndex = 999999
    Page.Parent = MainFrame
    
    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.Parent = Page
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout.Padding = UDim.new(0, 5)
    
    return Page
end
-- Create Navigation Buttons
local function CreateNavButton(text, position)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(0.25, -4, 1, -4)
    Button.Position = position
    Button.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    Button.Text = text
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.Font = Enum.Font.GothamBold
    Button.TextSize = 14
    Button.Parent = Navigation
    Button.ZIndex = 999999
    
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 6)
    UICorner.Parent = Button
    
    return Button
end

-- Create Toggle Function
local function CreateToggle(parent, name, callback)
    local Toggle = Instance.new("Frame")
    local Button = Instance.new("TextButton")
    local UICorner = Instance.new("UICorner")
    local Status = Instance.new("Frame")
    local UICorner_Status = Instance.new("UICorner")
    
    Toggle.Size = UDim2.new(0.9, 0, 0, 40)
    Toggle.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    Toggle.Position = UDim2.new(0.05, 0, 0, 0)
    Toggle.ZIndex = 999999
    Toggle.Parent = parent
    
    UICorner.CornerRadius = UDim.new(0, 6)
    UICorner.Parent = Toggle
    
    Button.Size = UDim2.new(1, 0, 1, 0)
    Button.BackgroundTransparency = 1
    Button.Text = name
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.Font = Enum.Font.GothamSemibold
    Button.TextSize = 14
    Button.ZIndex = 999999
    Button.Parent = Toggle
    
    Status.Size = UDim2.new(0, 10, 0, 10)
    Status.Position = UDim2.new(0.95, -5, 0.5, -5)
    Status.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    Status.ZIndex = 999999
    Status.Parent = Toggle
    
    UICorner_Status.CornerRadius = UDim.new(1, 0)
    UICorner_Status.Parent = Status
    
    local enabled = false
    Button.MouseButton1Click:Connect(function()
        enabled = not enabled
        Status.BackgroundColor3 = enabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
        callback(enabled)
    end)
end

-- Enhanced ESP Implementation
local function CreateSnapline(player)
    local Line = Drawing.new("Line")
    Line.Thickness = 1
    Line.Color = Color3.fromRGB(147, 112, 219)
    Line.Transparency = 1
    Line.Visible = false
    Line.ZIndex = 999998
    
    Settings.ESP.Tracers[player] = Line
end
local function CreateESP(player)
    CreateSnapline(player)
    local Box = Drawing.new("Square")
    Box.Thickness = 1
    Box.Filled = false
    Box.Color = Settings.ESP.BoxColor
    Box.Visible = false
    Box.ZIndex = 999999
    
    Settings.ESP.Players[player] = Box
end

local function UpdateESP()
    local camera = workspace.CurrentCamera
    local cameraPosition = camera.CFrame.Position
    local screenCenter = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
    
    for player, box in pairs(Settings.ESP.Players) do
        if player.Character and player ~= Players.LocalPlayer then
            if Settings.ESP.TeamCheck and player.Team == Players.LocalPlayer.Team then
                box.Visible = false
                Settings.ESP.Tracers[player].Visible = false
                continue
            end
            
            local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
            local humanoid = player.Character:FindFirstChild("Humanoid")
            local head = player.Character:FindFirstChild("Head")
            
            if humanoidRootPart and humanoid and head and Settings.ESP.Enabled then
                local vector, onScreen = camera:WorldToViewportPoint(humanoidRootPart.Position)
                local headPos = camera:WorldToViewportPoint(head.Position)
                
                if onScreen then
                    -- Box ESP
                    local rootPos = humanoidRootPart.Position
                    local screenPos = camera:WorldToViewportPoint(rootPos)
                    
                    box.Size = Vector2.new(1000 / screenPos.Z, headPos.Y - screenPos.Y)
                    box.Position = Vector2.new(screenPos.X - box.Size.X / 2, screenPos.Y - box.Size.Y / 2)
                    box.Color = Settings.ESP.Rainbow and Color3.fromHSV(tick() % 5 / 5, 1, 1) or Settings.ESP.BoxColor
                    box.Visible = Settings.ESP.Boxes
                    
                    -- Snaplines
                    if Settings.ESP.Snaplines then
                        local tracer = Settings.ESP.Tracers[player]
                        tracer.From = screenCenter
                        tracer.To = Vector2.new(headPos.X, headPos.Y)
                        tracer.Visible = true
                    else
                        Settings.ESP.Tracers[player].Visible = false
                    end
                else
                    box.Visible = false
                    Settings.ESP.Tracers[player].Visible = false
                end
            end
        end
    end
end
-- Aimbot Implementation
local function GetTarget()
    local closestPlayer = nil
    local shortestDistance = Settings.Aimbot.FOV
    local mousePos = Vector2.new(workspace.CurrentCamera.ViewportSize.X/2, workspace.CurrentCamera.ViewportSize.Y/2)
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= Players.LocalPlayer and player.Character then
            if Settings.Aimbot.TeamCheck and player.Team == Players.LocalPlayer.Team then
                continue
            end
            
            local targetPart = player.Character:FindFirstChild(Settings.Aimbot.TargetPart)
            if targetPart then
                local screenPos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(targetPart.Position)
                if onScreen then
                    local distance = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                    if distance < shortestDistance then
                        closestPlayer = player
                        shortestDistance = distance
                    end
                end
            end
        end
    end
    return closestPlayer
end

-- Create Pages
local Pages = {
    Aimbot = CreatePage("Aimbot"),
    ESP = CreatePage("ESP"),
    Misc = CreatePage("Misc")
}

-- Setup Navigation
local NavButtons = {}
local PageOrder = {"Aimbot", "ESP", "Misc"}

for i, pageName in ipairs(PageOrder) do
    local btn = CreateNavButton(pageName, UDim2.new((i-1) * 0.33, 2, 0, 2))
    NavButtons[pageName] = btn
    
    btn.MouseButton1Click:Connect(function()
        for _, page in pairs(Pages) do
            page.Visible = false
        end
        Pages[pageName].Visible = true
        
        for _, button in pairs(NavButtons) do
            button.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
        end
        btn.BackgroundColor3 = Color3.fromRGB(147, 112, 219)
    end)
end

-- Enhanced Main Update Loop
local lastUpdate = 0
RunService.RenderStepped:Connect(function()
    local currentTime = tick()
    if currentTime - lastUpdate >= 0.001 then  -- 1ms refresh rate
        UpdateESP()
        
        if Settings.Aimbot.ShowFOV then
            FOVCircle.Position = Vector2.new(workspace.CurrentCamera.ViewportSize.X/2, workspace.CurrentCamera.ViewportSize.Y/2)
            FOVCircle.Radius = Settings.Aimbot.FOV
            FOVCircle.Visible = true
        else
            FOVCircle.Visible = false
        end
        
        if Settings.Aimbot.Enabled and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
            local target = GetTarget()
            if target then
                local targetPart = target.Character:FindFirstChild(Settings.Aimbot.TargetPart)
                if targetPart then
                    local screenPos = workspace.CurrentCamera:WorldToViewportPoint(targetPart.Position)
                    local mousePos = Vector2.new(workspace.CurrentCamera.ViewportSize.X/2, workspace.CurrentCamera.ViewportSize.Y/2)
                    local movePos = Vector2.new(screenPos.X, screenPos.Y)
                    
                    if Settings.Aimbot.SmoothingEnabled then
                        mousemoverel(
                            (movePos.X - mousePos.X) * Settings.Aimbot.Smoothness,
                            (movePos.Y - mousePos.Y) * Settings.Aimbot.Smoothness
                        )
                    else
                        mousemoverel(
                            (movePos.X - mousePos.X),
                            (movePos.Y - mousePos.Y)
                        )
                    end
                end
            end
        end
        lastUpdate = currentTime
    end
end)
-- Initialize UI Elements
local function InitializeUI()
    -- Aimbot Page
    CreateToggle(Pages.Aimbot, "Enable Aimbot", function(enabled)
        Settings.Aimbot.Enabled = enabled
    end)
    
    CreateToggle(Pages.Aimbot, "Show FOV", function(enabled)
        Settings.Aimbot.ShowFOV = enabled
    end)
    
    CreateToggle(Pages.Aimbot, "Team Check", function(enabled)
        Settings.Aimbot.TeamCheck = enabled
    end)
    
    CreateToggle(Pages.Aimbot, "Enable Smoothing", function(enabled)
        Settings.Aimbot.SmoothingEnabled = enabled
    end)
    
    -- Enhanced ESP Page
    CreateToggle(Pages.ESP, "Enable ESP", function(enabled)
        Settings.ESP.Enabled = enabled
    end)
    
    CreateToggle(Pages.ESP, "Box ESP", function(enabled)
        Settings.ESP.Boxes = enabled
    end)
    
    CreateToggle(Pages.ESP, "Snaplines", function(enabled)
        Settings.ESP.Snaplines = enabled
    end)
    
    CreateToggle(Pages.ESP, "Names", function(enabled)
        Settings.ESP.Names = enabled
    end)
    
    CreateToggle(Pages.ESP, "Health", function(enabled)
        Settings.ESP.Health = enabled
    end)
    
    CreateToggle(Pages.ESP, "Distance", function(enabled)
        Settings.ESP.Distance = enabled
    end)
    
    CreateToggle(Pages.ESP, "Team Check", function(enabled)
        Settings.ESP.TeamCheck = enabled
    end)
    
    CreateToggle(Pages.ESP, "Rainbow Mode", function(enabled)
        Settings.ESP.Rainbow = enabled
    end)
    
    -- Misc Page
    CreateToggle(Pages.Misc, "No Recoil", function(enabled)
        Settings.Misc.NoRecoil = enabled
    end)
    
    CreateToggle(Pages.Misc, "Bunny Hop", function(enabled)
        Settings.Misc.BunnyHop = enabled
    end)
end

-- Initialize ESP for existing players
for _, player in pairs(Players:GetPlayers()) do
    if player ~= Players.LocalPlayer then
        CreateESP(player)
    end
end

-- Handle new players
Players.PlayerAdded:Connect(function(player)
    if player ~= Players.LocalPlayer then
        CreateESP(player)
    end
end)

-- Enhanced cleanup when players leave
Players.PlayerRemoving:Connect(function(player)
    if Settings.ESP.Players[player] then
        Settings.ESP.Players[player]:Remove()
        Settings.ESP.Players[player] = nil
    end
    if Settings.ESP.Tracers[player] then
        Settings.ESP.Tracers[player]:Remove()
        Settings.ESP.Tracers[player] = nil
    end
end)

-- Initialize the UI
InitializeUI()

-- Show first page by default
Pages.Aimbot.Visible = true
NavButtons.Aimbot.BackgroundColor3 = Color3.fromRGB(147, 112, 219)

-- Add keybind to toggle GUI visibility
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.RightShift then
        MainFrame.Visible = not MainFrame.Visible
    end
end)
