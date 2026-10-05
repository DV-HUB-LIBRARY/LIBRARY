local Dialog = {}

function Dialog.new(window, options, Config, Utils)
    options = options or {}
    
    local title = options.Title or "Confirm"
    local content = options.Content or "Yakin?"
    local buttons = options.Buttons or {
        { Title = "OK", Callback = function() end },
        { Title = "Cancel", Callback = function() end },
    }
    
    local screenGui = window.ScreenGui
    
    local overlay = Instance.new("Frame")
    overlay.Name = "DialogOverlay"
    overlay.Size = UDim2.new(1, 0, 1, 0)
    overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    overlay.BackgroundTransparency = 0.5
    overlay.BorderSizePixel = 0
    overlay.ZIndex = 500
    overlay.Parent = screenGui
    
    local modal = Instance.new("Frame")
    modal.Name = "DialogModal"
    modal.Size = UDim2.new(0, 280, 0, 160)
    modal.Position = UDim2.new(0.5, -140, 0.5, -80)
    modal.BackgroundColor3 = Config.Colors.Card
    modal.BorderSizePixel = 0
    modal.ZIndex = 501
    modal.Parent = overlay
    
    Utils.corner(modal, Config.Sizes.Radius)
    Utils.stroke(modal, Config.Colors.Border, 1)
    
    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size = UDim2.new(1, -20, 0, 26)
    titleLbl.Position = UDim2.new(0, 10, 0, 12)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Font = Config.Fonts.Title
    titleLbl.Text = title
    titleLbl.TextColor3 = Config.Colors.Text
    titleLbl.TextSize = 13
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.ZIndex = 502
    titleLbl.Parent = modal
    
    local contentLbl = Instance.new("TextLabel")
    contentLbl.Size = UDim2.new(1, -20, 0, 50)
    contentLbl.Position = UDim2.new(0, 10, 0, 42)
    contentLbl.BackgroundTransparency = 1
    contentLbl.Font = Config.Fonts.Body
    contentLbl.Text = content
    contentLbl.TextColor3 = Config.Colors.Muted
    contentLbl.TextSize = 11
    contentLbl.TextXAlignment = Enum.TextXAlignment.Left
    contentLbl.TextYAlignment = Enum.TextYAlignment.Top
    contentLbl.TextWrapped = true
    contentLbl.ZIndex = 502
    contentLbl.Parent = modal
    
    local btnContainer = Instance.new("Frame")
    btnContainer.Size = UDim2.new(1, -20, 0, 34)
    btnContainer.Position = UDim2.new(0, 10, 1, -44)
    btnContainer.BackgroundTransparency = 1
    btnContainer.ZIndex = 502
    btnContainer.Parent = modal
    
    local btnLayout = Instance.new("UIListLayout")
    btnLayout.FillDirection = Enum.FillDirection.Horizontal
    btnLayout.Padding = UDim.new(0, 8)
    btnLayout.SortOrder = Enum.SortOrder.LayoutOrder
    btnLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    btnLayout.Parent = btnContainer
    
    local function closeDialog()
        overlay:Destroy()
    end
    
    for i, btnData in ipairs(buttons) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 100, 1, 0)
        btn.BackgroundColor3 = (i == 1) and Config.Colors.Accent or Config.Colors.Base
        btn.Text = btnData.Title or "OK"
        btn.TextColor3 = Config.Colors.Text
        btn.Font = Config.Fonts.Title
        btn.TextSize = 11
        btn.BorderSizePixel = 0
        btn.AutoButtonColor = false
        btn.LayoutOrder = i
        btn.ZIndex = 503
        btn.Parent = btnContainer
        
        Utils.corner(btn, Config.Sizes.RadiusSmall)
        Utils.stroke(btn, Config.Colors.Border, 1)
        
        local normalColor = (i == 1) and Config.Colors.Accent or Config.Colors.Base
        local hoverColor = (i == 1) and Config.Colors.AccentDim or Config.Colors.CardHover
        
        Utils.hover(btn, normalColor, hoverColor)
        
        btn.MouseButton1Click:Connect(function()
            closeDialog()
            if btnData.Callback then
                btnData.Callback()
            end
        end)
    end
    
    return overlay
end

return Dialog
