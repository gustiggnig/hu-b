local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
 
local player = Players.LocalPlayer
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FPSControlGUI"
screenGui.Parent = player:WaitForChild("PlayerGui")
 
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 300, 0, 250)
frame.Position = UDim2.new(0, 10, 0, 10)
frame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
frame.Parent = screenGui
 
local function makeDraggable(frame)
    local dragToggle = nil
    local dragInput = nil
    local dragStart = nil
    local startPos = nil
 
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragToggle = true
            dragStart = input.Position
            startPos = frame.Position
 
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragToggle = false
                end
            end)
        end
    end)
 
    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
 
    game:GetService("RunService").RenderStepped:Connect(function()
        if dragToggle and dragInput then
            local delta = dragInput.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end
 
makeDraggable(frame)
 
local fpsLabel = Instance.new("TextLabel")
fpsLabel.Size = UDim2.new(1, 0, 0, 30)
fpsLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
fpsLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
fpsLabel.Text = "FPS Control"
fpsLabel.Parent = frame
 
local fpsInput = Instance.new("TextBox")
fpsInput.Size = UDim2.new(1, -20, 0, 30)
fpsInput.Position = UDim2.new(0, 10, 0, 40)
fpsInput.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
fpsInput.TextColor3 = Color3.fromRGB(0, 0, 0)
fpsInput.PlaceholderText = "Enter FPS Value"
fpsInput.Parent = frame
 
local fluctuationInput = Instance.new("TextBox")
fluctuationInput.Size = UDim2.new(1, -20, 0, 30)
fluctuationInput.Position = UDim2.new(0, 10, 0, 80)
fluctuationInput.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
fluctuationInput.TextColor3 = Color3.fromRGB(0, 0, 0)
fluctuationInput.PlaceholderText = "Enter Fluctuation Range"
fluctuationInput.Parent = frame
 
local waitTimeInput = Instance.new("TextBox")
waitTimeInput.Size = UDim2.new(1, -20, 0, 30)
waitTimeInput.Position = UDim2.new(0, 10, 0, 120)
waitTimeInput.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
waitTimeInput.TextColor3 = Color3.fromRGB(0, 0, 0)
waitTimeInput.PlaceholderText = "Enter Wait Time (s)"
waitTimeInput.Parent = frame
 
local enterButton = Instance.new("TextButton")
enterButton.Size = UDim2.new(1, -20, 0, 30)
enterButton.Position = UDim2.new(0, 10, 0, 160)
enterButton.BackgroundColor3 = Color3.fromRGB(0, 128, 0)
enterButton.TextColor3 = Color3.fromRGB(255, 255, 255)
enterButton.Text = "Apply"
enterButton.Parent = frame
 
local clearButton = Instance.new("TextButton")
clearButton.Size = UDim2.new(1, -20, 0, 30)
clearButton.Position = UDim2.new(0, 10, 0, 200)
clearButton.BackgroundColor3 = Color3.fromRGB(128, 0, 0)
clearButton.TextColor3 = Color3.fromRGB(255, 255, 255)
clearButton.Text = "Clear FPS"
clearButton.Parent = frame
 
local notification = Instance.new("TextLabel")
notification.Size = UDim2.new(1, 0, 0, 50)
notification.Position = UDim2.new(0, 0, 1, -50)
notification.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
notification.TextColor3 = Color3.fromRGB(255, 255, 255)
notification.Text = "GUI Hidden"
notification.Visible = false
notification.Parent = screenGui
 
local UserInputService = game:GetService("UserInputService")
local isVisible = true
 
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.RightShift then
        isVisible = not isVisible
        frame.Visible = isVisible
        notification.Visible = not isVisible
        notification.Text = isVisible and "GUI Visible" or "GUI Hidden"
    end
end)
 
local fluctuationCoroutine = nil
local storedFPS = 1000
 
local function stopFluctuation()
    if fluctuationCoroutine then
        coroutine.close(fluctuationCoroutine)
        fluctuationCoroutine = nil
    end
end
 
clearButton.MouseButton1Click:Connect(function()
    stopFluctuation()
    local args = { [1] = storedFPS }
    ReplicatedStorage.UpdateFPS:FireServer(unpack(args))
    fpsInput.Text = tostring(storedFPS)
    fluctuationInput.Text = "0"
    waitTimeInput.Text = "0.01"
end)
 
local function applyFPSSettings(fpsValue, fluctuationRange, waitTime)
    if waitTime <= 0 then
        waitTime = 0.01
    end
 
    while true do
        local fluctuation = math.random(-fluctuationRange, fluctuationRange)
        local fluctuatedValue = fpsValue + fluctuation
 
        local args = { fluctuatedValue }
        ReplicatedStorage.UpdateFPS:FireServer(unpack(args))
        wait(waitTime)
    end
end
 
enterButton.MouseButton1Click:Connect(function()
    storedFPS = tonumber(fpsInput.Text) or 1000
    local fluctuationRange = tonumber(fluctuationInput.Text) or 10
    local waitTime = tonumber(waitTimeInput.Text) or 0.01
 
    stopFluctuation()
    fluctuationCoroutine = coroutine.create(function()
        applyFPSSettings(storedFPS, fluctuationRange, waitTime)
    end)
    coroutine.resume(fluctuationCoroutine)
end)
