local Dropdown = {}

function Dropdown.new(parent, options, Config, Utils)
    options = options or {}
    
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    
    local container = Instance.new("Frame")
    container.Name = options.Name or "Dropdown"
    container.Size = options.Size or UDim2.new(1, 0, 0, Config.Sizes.RowH)
    container.Position = options.Position or UDim2.new(0, 0, 0, 0)
    container.BackgroundColor3 = Config.Colors.Card
    container.BorderSizePixel = 0
    container.ZIndex = options.ZIndex or 14
    container.Parent = parent
    
    Utils.corner(container, Config.Sizes.RadiusSmall)
    Utils.stroke(container, Config.Colors.Border, 1)
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -140, 1, 0)
    label.Position = UDim2.new(0, 12, 0, 0)
    label.BackgroundTransparency = 1
    label.Font = Config.Fonts.Body
    label.Text = options.Text or "Select"
    label.TextColor3 = Config.Colors.Text
    label.TextSize = Config.Sizes.BodySize
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 15
    label.Parent = container
    
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0, 100, 1, 0)
    valueLabel.Position = UDim2.new(1, -126, 0, 0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Font = Config.Fonts.Body
    valueLabel.Text = tostring(options.Default or "...")
    valueLabel.TextColor3 = Config.Colors.Muted
    valueLabel.TextSize = Config.Sizes.BodySize
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.ZIndex = 15
    valueLabel.Parent = container
    
    local arrow = Instance.new("TextLabel")
    arrow.Size = UDim2.new(0, 20, 1, 0)
    arrow.Position = UDim2.new(1, -26, 0, 0)
    arrow.BackgroundTransparency = 1
    arrow.Font = Config.Fonts.Title
    arrow.Text = "v"
    arrow.TextColor3 = Config.Colors.Muted
    arrow.TextSize = 12
    arrow.ZIndex = 15
    arrow.Parent = container
    
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 1, 0)
    button.BackgroundTransparency = 1
    button.Text = ""
    button.ZIndex = 16
    button.Parent = container
    
    local values = options.Values or {}
    local currentValue = options.Default or (values[1] or "")
    local isOpen = false
    local currentListGui = nil
    
    valueLabel.Text = tostring(currentValue)
    
    local function closeList()
        if currentListGui then
            currentListGui:Destroy()
            currentListGui = nil
        end
        isOpen = false
        arrow.Text = "v"
    end
    
    local function openList()
        closeList()
        
        local screenGui = Instance.new("ScreenGui")
        screenGui.Name = "DVLlib_DropdownList"
        screenGui.ResetOnSpawn = false
        screenGui.DisplayOrder = 9999
        screenGui.IgnoreGuiInset = true
        screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
        
        local listFrame = Instance.new("Frame")
        listFrame.Name = "ListFrame"
        listFrame.BackgroundColor3 = Config.Colors.Base
        listFrame.BorderSizePixel = 0
        listFrame.ZIndex = 10000
        listFrame.Parent = screenGui
        Utils.corner(listFrame, Config.Sizes.RadiusSmall)
        Utils.stroke(listFrame, Config.Colors.Accent, 1)
        
        local listLayout = Instance.new("UIListLayout")
        listLayout.Padding = UDim.new(0, 2)
        listLayout.SortOrder = Enum.SortOrder.LayoutOrder
        listLayout.Parent = listFrame
        
        local listPadding = Instance.new("UIPadding")
        listPadding.PaddingTop = UDim.new(0, 4)
        listPadding.PaddingBottom = UDim.new(0, 4)
        listPadding.PaddingLeft = UDim.new(0, 4)
        listPadding.PaddingRight = UDim.new(0, 4)
        listPadding.Parent = listFrame
        
        local totalHeight = 8
        for _, val in ipairs(values) do
            local optBtn = Instance.new("TextButton")
            optBtn.Size = UDim2.new(1, 0, 0, 28)
            optBtn.BackgroundColor3 = (val == currentValue) and Config.Colors.Accent or Config.Colors.Card
            optBtn.Text = tostring(val)
            optBtn.TextColor3 = Config.Colors.Text
            optBtn.Font = Config.Fonts.Body
            optBtn.TextSize = Config.Sizes.BodySize
            optBtn.BorderSizePixel = 0
            optBtn.AutoButtonColor = false
            optBtn.ZIndex = 10001
            optBtn.Parent = listFrame
            Utils.corner(optBtn, Config.Sizes.RadiusSmall)
            
            optBtn.MouseEnter:Connect(function()
                if val ~= currentValue then
                    optBtn.BackgroundColor3 = Config.Colors.CardHover
                end
            end)
            optBtn.MouseLeave:Connect(function()
                if val ~= currentValue then
                    optBtn.BackgroundColor3 = Config.Colors.Card
                end
            end)
            
            optBtn.MouseButton1Click:Connect(function()
                currentValue = val
                valueLabel.Text = tostring(val)
                closeList()
                if options.OnSelect then
                    options.OnSelect(val)
                end
            end)
            
            totalHeight = totalHeight + 28 + 2
        end
        
        local containerPos = container.AbsolutePosition
        local containerSize = container.AbsoluteSize
        
        listFrame.Size = UDim2.new(0, containerSize.X, 0, totalHeight)
        listFrame.Position = UDim2.new(0, containerPos.X, 0, containerPos.Y + containerSize.Y + 4)
        
        currentListGui = screenGui
        isOpen = true
        arrow.Text = "^"
    end
    
    button.MouseButton1Click:Connect(function()
        if isOpen then
            closeList()
        else
            openList()
        end
    end)
    
    local closeConn
    closeConn = button.MouseButton1Click:Connect(function() end)
    
    task.spawn(function()
        while container.Parent do
            if currentListGui and container.Parent then
                local containerPos = container.AbsolutePosition
                local containerSize = container.AbsoluteSize
                local listFrame = currentListGui:FindFirstChild("ListFrame")
                if listFrame then
                    listFrame.Position = UDim2.new(0, containerPos.X, 0, containerPos.Y + containerSize.Y + 4)
                end
            end
            task.wait(0.1)
        end
        closeList()
    end)
    
    return container
end

return Dropdown
