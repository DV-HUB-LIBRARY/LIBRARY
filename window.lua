local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local Window = {}

function Window.new(options)
    options = options or {}
    
    local BASE = "https://raw.githubusercontent.com/DV-HUB-LIBRARY/LIBRARY/main"
    
    local Config = options.Config or loadstring(game:HttpGet(BASE .. "/config.lua"))()
    local Utils = options.Utils or loadstring(game:HttpGet(BASE .. "/utils.lua"))()
    
    if not Config or not Utils then
        warn("[DVLlib] Config atau Utils gagal di-load!")
        return nil
    end
    
    local self = {}
    
    self.Config = Config
    self.Utils = Utils
    self.Options = options
    self.Tabs = {}
    self.ActiveTab = nil
    self.IsMinimized = false
    self.IsHidden = false
    
    self.Size = options.Size or UDim2.new(0, 400, 0, 340)
    self.Position = options.Position or UDim2.new(0.5, -200, 0.5, -170)
    
    local parent = options.Parent or Players.LocalPlayer:WaitForChild("PlayerGui")
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "DVLlib_" .. (options.Name or "Window")
    screenGui.ResetOnSpawn = false
    screenGui.DisplayOrder = 999
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = parent
    self.ScreenGui = screenGui
    
    local win = Instance.new("Frame")
    win.Name = "MainWindow"
    win.Size = self.Size
    win.Position = self.Position
    win.BackgroundColor3 = Config.Colors.Base
    win.BorderSizePixel = 0
    win.Active = true
    win.Draggable = true
    win.ZIndex = 10
    win.Parent = screenGui
    self.Frame = win
    
    Utils.corner(win, Config.Sizes.Radius)
    Utils.stroke(win, Config.Colors.Border, 1)
    
    local accentBar = Instance.new("Frame")
    accentBar.Name = "AccentBar"
    accentBar.Size = UDim2.new(0, 3, 0, Config.Sizes.TopbarH)
    accentBar.Position = UDim2.new(0, 0, 0, 0)
    accentBar.BackgroundColor3 = Config.Colors.Accent
    accentBar.BorderSizePixel = 0
    accentBar.ZIndex = 11
    accentBar.Parent = win
    Utils.corner(accentBar, Config.Sizes.Radius)
    
    local topbar = Instance.new("Frame")
    topbar.Name = "Topbar"
    topbar.Size = UDim2.new(1, 0, 0, Config.Sizes.TopbarH)
    topbar.Position = UDim2.new(0, 0, 0, 0)
    topbar.BackgroundColor3 = Config.Colors.Topbar
    topbar.BorderSizePixel = 0
    topbar.ZIndex = 12
    topbar.Parent = win
    Utils.corner(topbar, Config.Sizes.Radius)
    self.Topbar = topbar
    
    local topbarPatch = Instance.new("Frame")
    topbarPatch.Size = UDim2.new(0, 12, 0, 12)
    topbarPatch.Position = UDim2.new(0, 0, 1, -12)
    topbarPatch.BackgroundColor3 = Config.Colors.Topbar
    topbarPatch.BorderSizePixel = 0
    topbarPatch.ZIndex = 13
    topbarPatch.Parent = topbar
    
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, -120, 1, 0)
    title.Position = UDim2.new(0, 14, 0, 0)
    title.BackgroundTransparency = 1
    title.Font = Config.Fonts.Title
    title.Text = options.Title or "DVLlib Window"
    title.TextColor3 = Config.Colors.Text
    title.TextSize = Config.Sizes.TitleSize
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.ZIndex = 14
    title.Parent = topbar
    self.Title = title
    
    local subtitle = Instance.new("TextLabel")
    subtitle.Name = "Subtitle"
    subtitle.Size = UDim2.new(1, -120, 0, 12)
    subtitle.Position = UDim2.new(0, 14, 1, -14)
    subtitle.BackgroundTransparency = 1
    subtitle.Font = Config.Fonts.Mono
    subtitle.Text = options.Subtitle or ""
    subtitle.TextColor3 = Config.Colors.Muted
    subtitle.TextSize = 9
    subtitle.TextXAlignment = Enum.TextXAlignment.Left
    subtitle.ZIndex = 14
    subtitle.Parent = topbar
    self.Subtitle = subtitle
    
    local function makeCtrlBtn(icon, xOffset, color, hoverColor)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 22, 0, 22)
        btn.Position = UDim2.new(1, xOffset, 0.5, -11)
        btn.BackgroundColor3 = color
        btn.Text = icon
        btn.TextColor3 = Config.Colors.Text
        btn.Font = Config.Fonts.Title
        btn.TextSize = 12
        btn.BorderSizePixel = 0
        btn.AutoButtonColor = false
        btn.ZIndex = 14
        btn.Parent = topbar
        Utils.corner(btn, 5)
        Utils.hover(btn, color, hoverColor)
        return btn
    end
    
    self.BtnMin = makeCtrlBtn("−", -76, Config.Colors.Card, Config.Colors.CardHover)
    self.BtnHide = makeCtrlBtn("◉", -52, Config.Colors.Card, Config.Colors.CardHover)
    self.BtnClose = makeCtrlBtn("✕", -28, Config.Colors.Danger, Color3.fromRGB(220, 40, 40))
    
    local tabbar = Instance.new("Frame")
    tabbar.Name = "Tabbar"
    tabbar.Size = UDim2.new(1, 0, 0, Config.Sizes.TabbarH)
    tabbar.Position = UDim2.new(0, 0, 0, Config.Sizes.TopbarH)
    tabbar.BackgroundColor3 = Config.Colors.Tabbar
    tabbar.BorderSizePixel = 0
    tabbar.ZIndex = 11
    tabbar.Parent = win
    self.Tabbar = tabbar
    
    local tabScroll = Instance.new("ScrollingFrame")
    tabScroll.Name = "TabScroll"
    tabScroll.Size = UDim2.new(1, -12, 1, 0)
    tabScroll.Position = UDim2.new(0, 6, 0, 0)
    tabScroll.BackgroundTransparency = 1
    tabScroll.BorderSizePixel = 0
    tabScroll.ScrollBarThickness = 0
    tabScroll.ScrollingDirection = Enum.ScrollingDirection.X
    tabScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    tabScroll.ZIndex = 12
    tabScroll.Parent = tabbar
    self.TabScroll = tabScroll
    
    local tabLayout = Instance.new("UIListLayout")
    tabLayout.FillDirection = Enum.FillDirection.Horizontal
    tabLayout.Padding = UDim.new(0, 4)
    tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    tabLayout.Parent = tabScroll
    
    local content = Instance.new("Frame")
    content.Name = "Content"
    content.Size = UDim2.new(1, 0, 1, -(Config.Sizes.TopbarH + Config.Sizes.TabbarH))
    content.Position = UDim2.new(0, 0, 0, Config.Sizes.TopbarH + Config.Sizes.TabbarH)
    content.BackgroundTransparency = 1
    content.ClipsDescendants = true
    content.ZIndex = 11
    content.Parent = win
    self.Content = content
    
    self.BtnClose.MouseButton1Click:Connect(function()
        if self.ScreenGui then
            self.ScreenGui:Destroy()
        end
    end)
    
    self.BtnMin.MouseButton1Click:Connect(function()
        self.IsMinimized = not self.IsMinimized
        if self.IsMinimized then
            self.Content.Visible = false
            self.Tabbar.Visible = false
            TweenService:Create(self.Frame, TweenInfo.new(0.2), {
                Size = UDim2.new(0, self.Size.X.Offset, 0, Config.Sizes.TopbarH)
            }):Play()
            self.BtnMin.Text = "⊕"
        else
            self.Content.Visible = true
            self.Tabbar.Visible = true
            TweenService:Create(self.Frame, TweenInfo.new(0.2), {
                Size = self.Size
            }):Play()
            self.BtnMin.Text = "−"
        end
    end)
    
    self.BtnHide.MouseButton1Click:Connect(function()
        self.IsHidden = true
        self.Frame.Visible = false
    end)
    
    return self
end

return Window
