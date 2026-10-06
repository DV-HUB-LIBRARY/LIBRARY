local DurationPicker = {}

function DurationPicker.new(parent, options, Config, Utils, onConfirm)
    options = options or {}
    
    local defaultValue = options.Default or { amount = 30, unit = "hari" }
    
    local frame = Instance.new("Frame", parent)
    frame.Name = "DurationPicker"
    frame.Size = UDim2.new(1, 0, 0, 0)
    frame.AutomaticSize = Enum.AutomaticSize.Y
    frame.BackgroundTransparency = 1
    frame.ZIndex = 220
    
    local layout = Instance.new("UIListLayout", frame)
    layout.Padding = UDim.new(0, 6)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    
    local inputRow = Instance.new("Frame", frame)
    inputRow.Size = UDim2.new(1, 0, 0, 32)
    inputRow.BackgroundColor3 = Config.Colors.Base
    inputRow.BorderSizePixel = 0
    inputRow.ZIndex = 221
    inputRow.LayoutOrder = 1
    Utils.corner(inputRow, Config.Sizes.RadiusSmall)
    Utils.stroke(inputRow, Config.Colors.Border, 1)
    
    local amountInput = Instance.new("TextBox", inputRow)
    amountInput.Size = UDim2.new(0.4, -4, 1, 0)
    amountInput.Position = UDim2.new(0, 4, 0, 0)
    amountInput.BackgroundTransparency = 1
    amountInput.Font = Config.Fonts.Mono
    amountInput.Text = tostring(defaultValue.amount or 30)
    amountInput.PlaceholderText = "30"
    amountInput.PlaceholderColor3 = Config.Colors.Muted
    amountInput.TextColor3 = Config.Colors.Text
    amountInput.TextSize = Config.Sizes.BodySize
    amountInput.TextXAlignment = Enum.TextXAlignment.Left
    amountInput.ClearTextOnFocus = false
    amountInput.ZIndex = 222
    
    local unitBtn = Instance.new("TextButton", inputRow)
    unitBtn.Size = UDim2.new(0.6, -4, 1, 0)
    unitBtn.Position = UDim2.new(0.4, 0, 0, 0)
    unitBtn.BackgroundColor3 = Config.Colors.Card
    unitBtn.Text = "📅 " .. (defaultValue.unit or "hari") .. " ▾"
    unitBtn.TextColor3 = Config.Colors.Text
    unitBtn.Font = Config.Fonts.Body
    unitBtn.TextSize = Config.Sizes.BodySize
    unitBtn.BorderSizePixel = 0
    unitBtn.AutoButtonColor = false
    unitBtn.ZIndex = 222
    Utils.corner(unitBtn, Config.Sizes.RadiusSmall)
    
    local units = {
        { label = "⏱️ Menit", value = "menit" },
        { label = "⏱️ Jam", value = "jam" },
        { label = "📅 Hari", value = "hari" },
        { label = "📅 Bulan", value = "bulan" },
        { label = "📅 Tahun", value = "tahun" },
        { label = "♾️ Lifetime", value = "lifetime" },
    }
    
    local currentUnit = defaultValue.unit or "hari"
    local unitDropdown = nil
    
    local unitDropdownGui = Instance.new("ScreenGui")
    unitDropdownGui.Name = "DVLlib_UnitDropdown"
    unitDropdownGui.ResetOnSpawn = false
    unitDropdownGui.DisplayOrder = 10000
    unitDropdownGui.IgnoreGuiInset = true
    unitDropdownGui.Enabled = false
    unitDropdownGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    
    local dropdownFrame = Instance.new("Frame", unitDropdownGui)
    dropdownFrame.Size = UDim2.new(0, 200, 0, 0)
    dropdownFrame.AutomaticSize = Enum.AutomaticSize.Y
    dropdownFrame.BackgroundColor3 = Config.Colors.Base
    dropdownFrame.BorderSizePixel = 0
    dropdownFrame.ZIndex = 10001
    Utils.corner(dropdownFrame, Config.Sizes.RadiusSmall)
    Utils.stroke(dropdownFrame, Config.Colors.Accent, 1)
    
    local dropdownList = Instance.new("Frame", dropdownFrame)
    dropdownList.Size = UDim2.new(1, 0, 0, 0)
    dropdownList.AutomaticSize = Enum.AutomaticSize.Y
    dropdownList.BackgroundTransparency = 1
    dropdownList.ZIndex = 10002
    
    local dropdownLayout = Instance.new("UIListLayout", dropdownList)
    dropdownLayout.Padding = UDim.new(0, 2)
    dropdownLayout.SortOrder = Enum.SortOrder.LayoutOrder
    
    local dropdownPadding = Instance.new("UIPadding", dropdownList)
    dropdownPadding.PaddingTop = UDim.new(0, 4)
    dropdownPadding.PaddingBottom = UDim.new(0, 4)
    dropdownPadding.PaddingLeft = UDim.new(0, 4)
    dropdownPadding.PaddingRight = UDim.new(0, 4)
    
    for _, unit in ipairs(units) do
        local optBtn = Instance.new("TextButton", dropdownList)
        optBtn.Size = UDim2.new(1, 0, 0, 28)
        optBtn.BackgroundColor3 = (unit.value == currentUnit) and Config.Colors.Accent or Config.Colors.Card
        optBtn.Text = unit.label
        optBtn.TextColor3 = Config.Colors.Text
        optBtn.Font = Config.Fonts.Body
        optBtn.TextSize = Config.Sizes.BodySize
        optBtn.BorderSizePixel = 0
        optBtn.AutoButtonColor = false
        optBtn.ZIndex = 10003
        Utils.corner(optBtn, Config.Sizes.RadiusSmall)
        
        optBtn.MouseEnter:Connect(function()
            if unit.value ~= currentUnit then
                optBtn.BackgroundColor3 = Config.Colors.CardHover
            end
        end)
        optBtn.MouseLeave:Connect(function()
            if unit.value ~= currentUnit then
                optBtn.BackgroundColor3 = Config.Colors.Card
            end
        end)
        
        optBtn.MouseButton1Click:Connect(function()
            currentUnit = unit.value
            unitBtn.Text = unit.label .. " ▾"
            unitDropdownGui.Enabled = false
            if unit.value == "lifetime" then
                amountInput.Text = "∞"
                amountInput.TextEditable = false
            else
                if amountInput.Text == "∞" then
                    amountInput.Text = "30"
                end
                amountInput.TextEditable = true
            end
        end)
    end
    
    unitBtn.MouseButton1Click:Connect(function()
        if unitDropdownGui.Enabled then
            unitDropdownGui.Enabled = false
        else
            unitDropdownGui.Enabled = true
            local pos = unitBtn.AbsolutePosition
            local size = unitBtn.AbsoluteSize
            dropdownFrame.Position = UDim2.new(0, pos.X, 0, pos.Y + size.Y + 4)
        end
    end)
    
    local preview = Instance.new("TextLabel", frame)
    preview.Size = UDim2.new(1, 0, 0, 32)
    preview.BackgroundColor3 = Config.Colors.Card
    preview.BorderSizePixel = 0
    preview.Font = Config.Fonts.Mono
    preview.Text = ""
    preview.TextColor3 = Config.Colors.Accent
    preview.TextSize = Config.Sizes.SmallSize
    preview.TextXAlignment = Enum.TextXAlignment.Left
    preview.ZIndex = 221
    preview.LayoutOrder = 2
    Utils.corner(preview, Config.Sizes.RadiusSmall)
    Utils.padding(preview, 8)
    
    local presets = {
        { label = "1m", amount = 1, unit = "menit" },
        { label = "5m", amount = 5, unit = "menit" },
        { label = "1j", amount = 1, unit = "jam" },
        { label = "1h", amount = 1, unit = "hari" },
        { label = "7h", amount = 7, unit = "hari" },
        { label = "30h", amount = 30, unit = "hari" },
        { label = "1b", amount = 1, unit = "bulan" },
        { label = "1t", amount = 1, unit = "tahun" },
        { label = "∞", amount = 0, unit = "lifetime" },
    }
    
    local presetRow = Instance.new("Frame", frame)
    presetRow.Size = UDim2.new(1, 0, 0, 28)
    presetRow.BackgroundTransparency = 1
    presetRow.ZIndex = 221
    presetRow.LayoutOrder = 3
    
    local presetLayout = Instance.new("UIListLayout", presetRow)
    presetLayout.FillDirection = Enum.FillDirection.Horizontal
    presetLayout.Padding = UDim.new(0, 4)
    presetLayout.SortOrder = Enum.SortOrder.LayoutOrder
    
    for _, preset in ipairs(presets) do
        local pbtn = Instance.new("TextButton", presetRow)
        pbtn.Size = UDim2.new(0, 40, 1, 0)
        pbtn.BackgroundColor3 = Config.Colors.Card
        pbtn.Text = preset.label
        pbtn.TextColor3 = Config.Colors.Text
        pbtn.Font = Config.Fonts.Mono
        pbtn.TextSize = 10
        pbtn.BorderSizePixel = 0
        pbtn.AutoButtonColor = false
        pbtn.ZIndex = 222
        Utils.corner(pbtn, Config.Sizes.RadiusSmall)
        Utils.stroke(pbtn, Config.Colors.Border, 1)
        
        pbtn.MouseEnter:Connect(function()
            pbtn.BackgroundColor3 = Config.Colors.CardHover
        end)
        pbtn.MouseLeave:Connect(function()
            pbtn.BackgroundColor3 = Config.Colors.Card
        end)
        
        pbtn.MouseButton1Click:Connect(function()
            currentUnit = preset.unit
            if preset.unit == "lifetime" then
                amountInput.Text = "∞"
                amountInput.TextEditable = false
                unitBtn.Text = "♾️ Lifetime ▾"
            else
                amountInput.Text = tostring(preset.amount)
                amountInput.TextEditable = true
                local label = "📅"
                if preset.unit == "menit" or preset.unit == "jam" then label = "⏱️" end
                unitBtn.Text = label .. " " .. preset.unit .. " ▾"
            end
            unitDropdownGui.Enabled = false
        end)
    end
    
    local function formatExpiry()
        local amount = tonumber(amountInput.Text)
        local unit = currentUnit
        
        if unit == "lifetime" then
            preview.Text = "♾️ Lifetime (permanent)"
            return nil, "Lifetime"
        end
        
        if not amount or amount <= 0 then
            preview.Text = "⚠️ Isi jumlah dulu"
            return nil, "Invalid"
        end
        
        amount = math.floor(amount)
        
        local units = {
            menit = { seconds = 60, label = "menit" },
            jam = { seconds = 3600, label = "jam" },
            hari = { seconds = 86400, label = "hari" },
            bulan = { seconds = 2592000, label = "bulan" },
            tahun = { seconds = 31536000, label = "tahun" },
        }
        
        local u = units[unit]
        if not u then return nil, "Invalid" end
        
        local expiry = os.time() + (amount * u.seconds)
        local expiryStr = os.date("%d/%m/%y %H:%M", expiry)
        local display = amount .. " " .. u.label
        
        preview.Text = "⏱️ " .. display .. " • Expired: " .. expiryStr
        return expiry, display
    end
    
    amountInput:GetPropertyChangedSignal("Text"):Connect(formatExpiry)
    
    task.spawn(function()
        while frame.Parent do
            if unitDropdownGui.Enabled then
                if not unitBtn:IsDescendantOf(unitBtn.Parent.Parent.Parent) then
                    unitDropdownGui.Enabled = false
                end
            end
            task.wait(0.2)
        end
        if unitDropdownGui then unitDropdownGui:Destroy() end
    end)
    
    formatExpiry()
    
    frame.GetValue = function()
        local amount = tonumber(amountInput.Text) or 0
        return {
            amount = amount,
            unit = currentUnit,
            display = preview.Text,
        }
    end
    
    return frame
end

return DurationPicker
