local Tab = {}

function Tab.new(window, options, Config, Utils)
    options = options or {}
    
    local tabId = options.Id or ("tab_" .. tostring(math.random(1000, 9999)))
    local tabIcon = options.Icon or "•"
    local tabLabel = options.Label or "Tab"
    
    local tabBtn = Instance.new("TextButton")
    tabBtn.Name = "Tab_" .. tabId
    tabBtn.Size = UDim2.new(0, 100, 1, -8)
    tabBtn.Position = UDim2.new(0, 0, 0, 4)
    tabBtn.BackgroundColor3 = Config.Colors.Base
    tabBtn.Text = ""
    tabBtn.BorderSizePixel = 0
    tabBtn.AutoButtonColor = false
    tabBtn.ZIndex = 13
    tabBtn.Parent = window.TabScroll
    
    Utils.corner(tabBtn, Config.Sizes.RadiusSmall)
    
    local iconLabel = Instance.new("TextLabel")
    iconLabel.Name = "Icon"
    iconLabel.Size = UDim2.new(0, 24, 1, 0)
    iconLabel.Position = UDim2.new(0, 6, 0, 0)
    iconLabel.BackgroundTransparency = 1
    iconLabel.Font = Config.Fonts.Title
    iconLabel.Text = tabIcon
    iconLabel.TextColor3 = Config.Colors.Muted
    iconLabel.TextSize = 14
    iconLabel.ZIndex = 14
    iconLabel.Parent = tabBtn
    
    local labelText = Instance.new("TextLabel")
    labelText.Name = "Label"
    labelText.Size = UDim2.new(1, -34, 1, 0)
    labelText.Position = UDim2.new(0, 30, 0, 0)
    labelText.BackgroundTransparency = 1
    labelText.Font = Config.Fonts.Body
    labelText.Text = tabLabel
    labelText.TextColor3 = Config.Colors.Muted
    labelText.TextSize = 11
    labelText.TextXAlignment = Enum.TextXAlignment.Left
    labelText.ZIndex = 14
    labelText.Parent = tabBtn
    
    local content = Instance.new("ScrollingFrame")
    content.Name = "Content_" .. tabId
    content.Size = UDim2.new(1, 0, 1, 0)
    content.Position = UDim2.new(0, 0, 0, 0)
    content.BackgroundTransparency = 1
    content.BorderSizePixel = 0
    content.ScrollBarThickness = 3
    content.ScrollBarImageColor3 = Config.Colors.Accent
    content.CanvasSize = UDim2.new(0, 0, 0, 0)
    content.Visible = false
    content.ZIndex = 12
    content.Parent = window.Content
    
    local contentLayout = Instance.new("UIListLayout")
    contentLayout.Padding = UDim.new(0, 8)
    contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    contentLayout.Parent = content
    
    local contentPadding = Instance.new("UIPadding")
    contentPadding.PaddingTop = UDim.new(0, 10)
    contentPadding.PaddingBottom = UDim.new(0, 10)
    contentPadding.PaddingLeft = UDim.new(0, 10)
    contentPadding.PaddingRight = UDim.new(0, 10)
    contentPadding.Parent = content
    
    content.AutomaticCanvasSize = Enum.AutomaticSize.Y
    
    if not window.Tabs then window.Tabs = {} end
    window.Tabs[tabId] = {
        Id = tabId,
        Btn = tabBtn,
        Icon = iconLabel,
        Label = labelText,
        Content = content,
    }
    
    local function activateTab()
        for _, tabData in pairs(window.Tabs) do
            tabData.Btn.BackgroundColor3 = Config.Colors.Base
            tabData.Icon.TextColor3 = Config.Colors.Muted
            tabData.Label.TextColor3 = Config.Colors.Muted
            tabData.Content.Visible = false
        end
        
        tabBtn.BackgroundColor3 = Config.Colors.Card
        iconLabel.TextColor3 = Config.Colors.Accent
        labelText.TextColor3 = Config.Colors.Text
        content.Visible = true
        
        window.ActiveTab = tabId
    end
    
    tabBtn.MouseButton1Click:Connect(activateTab)
    
    tabBtn.MouseEnter:Connect(function()
        if window.ActiveTab ~= tabId then
            Utils.tween(tabBtn, { BackgroundColor3 = Config.Colors.CardHover }, 0.1)
        end
    end)
    
    tabBtn.MouseLeave:Connect(function()
        if window.ActiveTab ~= tabId then
            Utils.tween(tabBtn, { BackgroundColor3 = Config.Colors.Base }, 0.1)
        end
    end)
    
    if not window.ActiveTab then
        activateTab()
    end
    
    local tabObj = {}
    tabObj.Id = tabId
    tabObj.Btn = tabBtn
    tabObj.Content = content
    tabObj.Activate = activateTab
    
    return tabObj
end

return Tab
