--// SOZA HUB - Fish It (REMOTE WORK)
--// UI Simple | Anti AFK | Auto Fish | Blatant Ready

--================ SAFE LOAD =================--
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

if LocalPlayer.PlayerGui:FindFirstChild("SOZA_HUB") then
    LocalPlayer.PlayerGui.SOZA_HUB:Destroy()
end

warn("SOZA HUB LOADED")

--================ ANTI AFK =================--
pcall(function()
    local VirtualUser = game:GetService("VirtualUser")
    LocalPlayer.Idled:Connect(function()
        VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        task.wait(1)
        VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    end)
end)

--================ CONFIG =================--
local Config = {
    AutoFish = false,
    Blatant = false,
    CompleteDelay = 1,
    ReelDelay = 1,
}

--================ REMOTE FINDER =================--
local function findRemote(keyword)
    for _,v in pairs(ReplicatedStorage:GetDescendants()) do
        if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
            if string.find(string.lower(v.Name), keyword) then
                return v
            end
        end
    end
end

-- Auto detect (AMAN)
local RemoteCast     = findRemote("cast") or findRemote("charge")
local RemoteComplete = findRemote("complete") or findRemote("finish")
local RemoteReel     = findRemote("reel")
local RemoteSell     = findRemote("sell")

--================ UI =================--
local gui = Instance.new("ScreenGui", LocalPlayer.PlayerGui)
gui.Name = "SOZA_HUB"
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.fromScale(0.25,0.35)
frame.Position = UDim2.fromScale(0.375,0.3)
frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
Instance.new("UICorner", frame).CornerRadius = UDim.new(0,12)

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,40)
title.BackgroundTransparency = 1
title.Text = "SOZA HUB | Fish It"
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.GothamBold
title.TextSize = 16

local function button(text, y)
    local b = Instance.new("TextButton", frame)
    b.Size = UDim2.new(0.9,0,0,35)
    b.Position = UDim2.new(0.05,0,0,y)
    b.Text = text
    b.Font = Enum.Font.Gotham
    b.TextSize = 14
    b.TextColor3 = Color3.new(1,1,1)
    b.BackgroundColor3 = Color3.fromRGB(40,40,40)
    b.BorderSizePixel = 0
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,8)
    return b
end

local autoBtn = button("Auto Fish : OFF", 50)
local blatantBtn = button("Blatant Mode : OFF", 95)

--================ UI LOGIC =================--
autoBtn.MouseButton1Click:Connect(function()
    Config.AutoFish = not Config.AutoFish
    autoBtn.Text = "Auto Fish : " .. (Config.AutoFish and "ON" or "OFF")
end)

blatantBtn.MouseButton1Click:Connect(function()
    Config.Blatant = not Config.Blatant
    blatantBtn.Text = "Blatant Mode : " .. (Config.Blatant and "ON" or "OFF")
end)

--================ CORE LOOP =================--
task.spawn(function()
    while task.wait(0.4) do
        if Config.AutoFish then
            -- CAST / CHARGE
            pcall(function()
                if RemoteCast then
                    RemoteCast:FireServer()
                end
            end)

            -- COMPLETE / MINIGAME SKIP
            if Config.Blatant then
                task.wait(Config.CompleteDelay)
                pcall(function()
                    if RemoteComplete then
                        RemoteComplete:FireServer()
                    end
                end)
            end

            -- REEL
            task.wait(Config.ReelDelay)
            pcall(function()
                if RemoteReel then
                    RemoteReel:FireServer()
                end
            end)

            -- AUTO SELL (NO TP)
            pcall(function()
                if RemoteSell then
                    RemoteSell:FireServer()
                end
            end)
        end
    end
end)
