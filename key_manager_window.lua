local KeyManagerWindow = {}

local HttpService = game:GetService("HttpService")
local LocalPlayer = game.Players.LocalPlayer

function KeyManagerWindow.showGenerateModalInternal(parentGui, Config, Utils, modules, notify, refreshCallback)
    local gui = parentGui
    
    local overlay = Instance.new("Frame", gui)
    overlay.Size = UDim2.new(1, 0, 1, 0)
    overlay.BackgroundColor3 = Color3.new(0, 0, 0)
    overlay.BackgroundTransparency = 0.5
    overlay.BorderSizePixel = 0
    overlay.ZIndex = 900
    
    local modal = Instance.new("Frame", overlay)
    modal.Size = UDim2.new(0, 320, 0, 420)
    modal.Position = UDim2.new(0.5, -160, 0.5, -210)
    modal.BackgroundColor3 = Config.Colors.Card
    modal.BorderSizePixel = 0
    modal.ZIndex = 901
    Utils.corner(modal, Config.Sizes.Radius)
    Utils.stroke(modal, Config.Colors.Accent, 1)
    
    local mTitle = Instance.new("TextLabel", modal)
    mTitle.Size = UDim2.new(1, -60, 0, 26)
    mTitle.Position = UDim2.new(0, 14, 0, 10)
    mTitle.BackgroundTransparency = 1
    mTitle.Font = Config.Fonts.Title
    mTitle.Text = "➕ GENERATE KEY"
    mTitle.TextColor3 = Config.Colors.Accent
    mTitle.TextSize = 13
    mTitle.TextXAlignment = Enum.TextXAlignment.Left
    mTitle.ZIndex = 902
    
    local closeBtn = Instance.new("TextButton", modal)
    closeBtn.Size = UDim2.new(0, 24, 0, 24)
    closeBtn.Position = UDim2.new(1, -32, 0, 10)
    closeBtn.BackgroundColor3 = Config.Colors.Danger
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Config.Colors.Text
    closeBtn.Font = Config.Fonts.Title
    closeBtn.TextSize = 12
    closeBtn.BorderSizePixel = 0
    closeBtn.ZIndex = 903
    Utils.corner(closeBtn, 5)
    closeBtn.MouseButton1Click:Connect(function()
        overlay:Destroy()
    end)
    
    local contentFrame = Instance.new("Frame", modal)
    contentFrame.Size = UDim2.new(1, -28, 1, -90)
    contentFrame.Position = UDim2.new(0, 14, 0, 44)
    contentFrame.BackgroundTransparency = 1
    contentFrame.ZIndex = 902
    
    local cLayout = Instance.new("UIListLayout", contentFrame)
    cLayout.Padding = UDim.new(0, 8)
    cLayout.SortOrder = Enum.SortOrder.LayoutOrder
    
    local function makeInputRow(label, placeholder, default)
        local row = Instance.new("Frame", contentFrame)
        row.Size = UDim2.new(1, 0, 0, 32)
        row.BackgroundColor3 = Config.Colors.Base
        row.BorderSizePixel = 0
        row.ZIndex = 903
        Utils.corner(row, Config.Sizes.RadiusSmall)
        Utils.stroke(row, Config.Colors.Border, 1)
        
        local lbl = Instance.new("TextLabel", row)
        lbl.Size = UDim2.new(0, 90, 1, 0)
        lbl.Position = UDim2.new(0, 8, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.Font = Config.Fonts.Body
        lbl.Text = label
        lbl.TextColor3 = Config.Colors.Muted
        lbl.TextSize = 10
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.ZIndex = 904
        
        local input = Instance.new("TextBox", row)
        input.Size = UDim2.new(1, -106, 1, 0)
        input.Position = UDim2.new(0, 98, 0, 0)
        input.BackgroundTransparency = 1
        input.Font = Config.Fonts.Mono
        input.Text = default or ""
        input.PlaceholderText = placeholder or ""
        input.PlaceholderColor3 = Config.Colors.Muted
        input.TextColor3 = Config.Colors.Text
        input.TextSize = 11
        input.TextXAlignment = Enum.TextXAlignment.Left
        input.ClearTextOnFocus = false
        input.ZIndex = 904
        
        return input
    end
    
    local tierInput = makeInputRow("Tier:", "user / vip / admin", "vip")
    tierInput.LayoutOrder = 1
    
    local usageInput = makeInputRow("Max Usage:", "1 / 5 / 10", "1")
    usageInput.LayoutOrder = 2
    
    local noteInput = makeInputRow("Note:", "opsional", "")
    noteInput.LayoutOrder = 3
    
    local durationLabel = Instance.new("TextLabel", contentFrame)
    durationLabel.Size = UDim2.new(1, 0, 0, 18)
    durationLabel.BackgroundTransparency = 1
    durationLabel.Font = Config.Fonts.Title
    durationLabel.Text = "⏱️ Duration:"
    durationLabel.TextColor3 = Config.Colors.Text
    durationLabel.TextSize = 11
    durationLabel.TextXAlignment = Enum.TextXAlignment.Left
    durationLabel.ZIndex = 903
    durationLabel.LayoutOrder = 4
    
    local durationPicker = modules.DurationPicker.new(contentFrame, {}, Config, Utils, nil)
    durationPicker.LayoutOrder = 5
    
    local btnRow = Instance.new("Frame", modal)
    btnRow.Size = UDim2.new(1, -28, 0, 34)
    btnRow.Position = UDim2.new(0, 14, 1, -44)
    btnRow.BackgroundTransparency = 1
    btnRow.ZIndex = 902
    
    local btnLayout = Instance.new("UIListLayout", btnRow)
    btnLayout.FillDirection = Enum.FillDirection.Horizontal
    btnLayout.Padding = UDim.new(0, 8)
    
    local genBtn = Instance.new("TextButton", btnRow)
    genBtn.Size = UDim2.new(0.5, -4, 1, 0)
    genBtn.BackgroundColor3 = Config.Colors.Accent
    genBtn.Text = "⚡ GENERATE"
    genBtn.TextColor3 = Config.Colors.Text
    genBtn.Font = Config.Fonts.Title
    genBtn.TextSize = 11
    genBtn.BorderSizePixel = 0
    genBtn.ZIndex = 903
    Utils.corner(genBtn, Config.Sizes.RadiusSmall)
    
    local cancelBtn = Instance.new("TextButton", btnRow)
    cancelBtn.Size = UDim2.new(0.5, -4, 1, 0)
    cancelBtn.BackgroundColor3 = Config.Colors.Card
    cancelBtn.Text = "❌ BATAL"
    cancelBtn.TextColor3 = Config.Colors.Text
    cancelBtn.Font = Config.Fonts.Title
    cancelBtn.TextSize = 11
    cancelBtn.BorderSizePixel = 0
    cancelBtn.ZIndex = 903
    Utils.corner(cancelBtn, Config.Sizes.RadiusSmall)
    
    cancelBtn.MouseButton1Click:Connect(function()
        overlay:Destroy()
    end)
    
    genBtn.MouseButton1Click:Connect(function()
        local durData = durationPicker.GetValue()
        local tier = tierInput.Text ~= "" and tierInput.Text or "user"
        local maxUsage = tonumber(usageInput.Text) or 1
        local note = noteInput.Text
        
        local body = {
            tier = tier,
            maxUsage = maxUsage,
            note = note,
            count = 1,
        }
        
        if durData.unit == "lifetime" then
            body.amount = 0
            body.unit = "lifetime"
        else
            body.amount = durData.amount
            body.unit = durData.unit
        end
        
        local opts = {
            Url = "https://igr-backen.vercel.app/api/key/generate",
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json",
                ["X-User-Id"] = tostring(LocalPlayer.UserId),
            },
            Body = HttpService:JSONEncode(body),
        }
        
        local ok, res = pcall(function() return request(opts) end)
        if ok and res then
            local decoded = HttpService:JSONDecode(res.Body)
            if decoded and decoded.ok then
                overlay:Destroy()
                notify("✅ Key Generated", decoded.key or decoded.keys[1], 5)
                pcall(function() setclipboard(decoded.key or decoded.keys[1]) end)
                if refreshCallback then refreshCallback() end
            else
                notify("❌ Gagal", decoded and decoded.error or "Unknown", 3)
            end
        end
    end)
end

function KeyManagerWindow.showEditModalInternal(parentGui, Config, Utils, modules, notify, keyData, refreshCallback)
    local gui = parentGui
    
    local overlay = Instance.new("Frame", gui)
    overlay.Size = UDim2.new(1, 0, 1, 0)
    overlay.BackgroundColor3 = Color3.new(0, 0, 0)
    overlay.BackgroundTransparency = 0.5
    overlay.BorderSizePixel = 0
    overlay.ZIndex = 900
    
    local modal = Instance.new("Frame", overlay)
    modal.Size = UDim2.new(0, 320, 0, 380)
    modal.Position = UDim2.new(0.5, -160, 0.5, -190)
    modal.BackgroundColor3 = Config.Colors.Card
    modal.BorderSizePixel = 0
    modal.ZIndex = 901
    Utils.corner(modal, Config.Sizes.Radius)
    Utils.stroke(modal, Config.Colors.Accent, 1)
    
    local mTitle = Instance.new("TextLabel", modal)
    mTitle.Size = UDim2.new(1, -60, 0, 26)
    mTitle.Position = UDim2.new(0, 14, 0, 10)
    mTitle.BackgroundTransparency = 1
    mTitle.Font = Config.Fonts.Title
    mTitle.Text = "✏️ EDIT KEY"
    mTitle.TextColor3 = Config.Colors.Accent
    mTitle.TextSize = 13
    mTitle.TextXAlignment = Enum.TextXAlignment.Left
    mTitle.ZIndex = 902
    
    local closeBtn = Instance.new("TextButton", modal)
    closeBtn.Size = UDim2.new(0, 24, 0, 24)
    closeBtn.Position = UDim2.new(1, -32, 0, 10)
    closeBtn.BackgroundColor3 = Config.Colors.Danger
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Config.Colors.Text
    closeBtn.Font = Config.Fonts.Title
    closeBtn.TextSize = 12
    closeBtn.BorderSizePixel = 0
    closeBtn.ZIndex = 903
    Utils.corner(closeBtn, 5)
    closeBtn.MouseButton1Click:Connect(function()
        overlay:Destroy()
    end)
    
    local keyLbl = Instance.new("TextLabel", modal)
    keyLbl.Size = UDim2.new(1, -20, 0, 14)
    keyLbl.Position = UDim2.new(0, 14, 0, 36)
    keyLbl.BackgroundTransparency = 1
    keyLbl.Font = Config.Fonts.Mono
    keyLbl.Text = keyData.key
    keyLbl.TextColor3 = Config.Colors.Muted
    keyLbl.TextSize = 10
    keyLbl.TextXAlignment = Enum.TextXAlignment.Left
    keyLbl.ZIndex = 902
    
    local contentFrame = Instance.new("Frame", modal)
    contentFrame.Size = UDim2.new(1, -28, 1, -140)
    contentFrame.Position = UDim2.new(0, 14, 0, 56)
    contentFrame.BackgroundTransparency = 1
    contentFrame.ZIndex = 902
    
    local cLayout = Instance.new("UIListLayout", contentFrame)
    cLayout.Padding = UDim.new(0, 8)
    cLayout.SortOrder = Enum.SortOrder.LayoutOrder
    
    local function makeInputRow(label, default)
        local row = Instance.new("Frame", contentFrame)
        row.Size = UDim2.new(1, 0, 0, 32)
        row.BackgroundColor3 = Config.Colors.Base
        row.BorderSizePixel = 0
        row.ZIndex = 903
        Utils.corner(row, Config.Sizes.RadiusSmall)
        Utils.stroke(row, Config.Colors.Border, 1)
        
        local lbl = Instance.new("TextLabel", row)
        lbl.Size = UDim2.new(0, 90, 1, 0)
        lbl.Position = UDim2.new(0, 8, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.Font = Config.Fonts.Body
        lbl.Text = label
        lbl.TextColor3 = Config.Colors.Muted
        lbl.TextSize = 10
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.ZIndex = 904
        
        local input = Instance.new("TextBox", row)
        input.Size = UDim2.new(1, -106, 1, 0)
        input.Position = UDim2.new(0, 98, 0, 0)
        input.BackgroundTransparency = 1
        input.Font = Config.Fonts.Mono
        input.Text = tostring(default or "")
        input.TextColor3 = Config.Colors.Text
        input.TextSize = 11
        input.TextXAlignment = Enum.TextXAlignment.Left
        input.ClearTextOnFocus = false
        input.ZIndex = 904
        
        return input
    end
    
    local tierInput = makeInputRow("Tier:", keyData.tier)
    tierInput.LayoutOrder = 1
    local usageInput = makeInputRow("Max Usage:", keyData.maxUsage)
    usageInput.LayoutOrder = 2
    local noteInput = makeInputRow("Note:", keyData.note)
    noteInput.LayoutOrder = 3
    
    local durationLabel = Instance.new("TextLabel", contentFrame)
    durationLabel.Size = UDim2.new(1, 0, 0, 18)
    durationLabel.BackgroundTransparency = 1
    durationLabel.Font = Config.Fonts.Title
    durationLabel.Text = "⏱️ Extend Duration:"
    durationLabel.TextColor3 = Config.Colors.Text
    durationLabel.TextSize = 11
    durationLabel.TextXAlignment = Enum.TextXAlignment.Left
    durationLabel.ZIndex = 903
    durationLabel.LayoutOrder = 4
    
    local durationPicker = modules.DurationPicker.new(contentFrame, {}, Config, Utils, nil)
    durationPicker.LayoutOrder = 5
    
    local btnRow = Instance.new("Frame", modal)
    btnRow.Size = UDim2.new(1, -28, 0, 34)
    btnRow.Position = UDim2.new(0, 14, 1, -44)
    btnRow.BackgroundTransparency = 1
    btnRow.ZIndex = 902
    
    local btnLayout = Instance.new("UIListLayout", btnRow)
    btnLayout.FillDirection = Enum.FillDirection.Horizontal
    btnLayout.Padding = UDim.new(0, 8)
    
    local saveBtn = Instance.new("TextButton", btnRow)
    saveBtn.Size = UDim2.new(0.5, -4, 1, 0)
    saveBtn.BackgroundColor3 = Config.Colors.Accent
    saveBtn.Text = "💾 SIMPAN"
    saveBtn.TextColor3 = Config.Colors.Text
    saveBtn.Font = Config.Fonts.Title
    saveBtn.TextSize = 11
    saveBtn.BorderSizePixel = 0
    saveBtn.ZIndex = 903
    Utils.corner(saveBtn, Config.Sizes.RadiusSmall)
    
    local cancelBtn = Instance.new("TextButton", btnRow)
    cancelBtn.Size = UDim2.new(0.5, -4, 1, 0)
    cancelBtn.BackgroundColor3 = Config.Colors.Card
    cancelBtn.Text = "❌ BATAL"
    cancelBtn.TextColor3 = Config.Colors.Text
    cancelBtn.Font = Config.Fonts.Title
    cancelBtn.TextSize = 11
    cancelBtn.BorderSizePixel = 0
    cancelBtn.ZIndex = 903
    Utils.corner(cancelBtn, Config.Sizes.RadiusSmall)
    
    cancelBtn.MouseButton1Click:Connect(function()
        overlay:Destroy()
    end)
    
    saveBtn.MouseButton1Click:Connect(function()
        local durData = durationPicker.GetValue()
        
        local body = {
            key = keyData.key,
            tier = tierInput.Text,
            maxUsage = tonumber(usageInput.Text) or keyData.maxUsage,
            note = noteInput.Text,
        }
        
        if durData.unit == "lifetime" then
            body.amount = 0
            body.unit = "lifetime"
        else
            body.amount = durData.amount
            body.unit = durData.unit
        end
        
        local opts = {
            Url = "https://igr-backen.vercel.app/api/key/edit",
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json",
                ["X-User-Id"] = tostring(LocalPlayer.UserId),
            },
            Body = HttpService:JSONEncode(body),
        }
        
        local ok, res = pcall(function() return request(opts) end)
        if ok and res then
            local decoded = HttpService:JSONDecode(res.Body)
            if decoded and decoded.ok then
                overlay:Destroy()
                notify("✅ Updated", keyData.key, 3)
                if refreshCallback then refreshCallback() end
            end
        end
    end)
end

function KeyManagerWindow.showRevokeConfirmInternal(parentGui, Config, Utils, modules, notify, keyData, refreshCallback)
    local gui = parentGui
    
    local overlay = Instance.new("Frame", gui)
    overlay.Size = UDim2.new(1, 0, 1, 0)
    overlay.BackgroundColor3 = Color3.new(0, 0, 0)
    overlay.BackgroundTransparency = 0.5
    overlay.BorderSizePixel = 0
    overlay.ZIndex = 900
    
    local modal = Instance.new("Frame", overlay)
    modal.Size = UDim2.new(0, 300, 0, 180)
    modal.Position = UDim2.new(0.5, -150, 0.5, -90)
    modal.BackgroundColor3 = Config.Colors.Card
    modal.BorderSizePixel = 0
    modal.ZIndex = 901
    Utils.corner(modal, Config.Sizes.Radius)
    Utils.stroke(modal, Config.Colors.Danger, 1)
    
    local closeBtn = Instance.new("TextButton", modal)
    closeBtn.Size = UDim2.new(0, 24, 0, 24)
    closeBtn.Position = UDim2.new(1, -32, 0, 10)
    closeBtn.BackgroundColor3 = Config.Colors.Danger
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Config.Colors.Text
    closeBtn.Font = Config.Fonts.Title
    closeBtn.TextSize = 12
    closeBtn.BorderSizePixel = 0
    closeBtn.ZIndex = 903
    Utils.corner(closeBtn, 5)
    closeBtn.MouseButton1Click:Connect(function()
        overlay:Destroy()
    end)
    
    local t = Instance.new("TextLabel", modal)
    t.Size = UDim2.new(1, -60, 0, 26)
    t.Position = UDim2.new(0, 10, 0, 10)
    t.BackgroundTransparency = 1
    t.Font = Config.Fonts.Title
    t.Text = "🗑️ REVOKE KEY?"
    t.TextColor3 = Config.Colors.Danger
    t.TextSize = 13
    t.TextXAlignment = Enum.TextXAlignment.Left
    t.ZIndex = 902
    
    local m = Instance.new("TextLabel", modal)
    m.Size = UDim2.new(1, -20, 0, 60)
    m.Position = UDim2.new(0, 10, 0, 42)
    m.BackgroundTransparency = 1
    m.Font = Config.Fonts.Mono
    m.Text = "Key:\n" .. keyData.key .. "\n\nYakin mau revoke?"
    m.TextColor3 = Config.Colors.Text
    m.TextSize = 10
    m.TextWrapped = true
    m.ZIndex = 902
    
    local btnRow = Instance.new("Frame", modal)
    btnRow.Size = UDim2.new(1, -20, 0, 34)
    btnRow.Position = UDim2.new(0, 10, 1, -44)
    btnRow.BackgroundTransparency = 1
    btnRow.ZIndex = 902
    
    local layout = Instance.new("UIListLayout", btnRow)
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.Padding = UDim.new(0, 8)
    
    local okBtn = Instance.new("TextButton", btnRow)
    okBtn.Size = UDim2.new(0.5, -4, 1, 0)
    okBtn.BackgroundColor3 = Config.Colors.Danger
    okBtn.Text = "🗑️ REVOKE"
    okBtn.TextColor3 = Config.Colors.Text
    okBtn.Font = Config.Fonts.Title
    okBtn.TextSize = 11
    okBtn.BorderSizePixel = 0
    okBtn.ZIndex = 903
    Utils.corner(okBtn, Config.Sizes.RadiusSmall)
    
    local cancelBtn = Instance.new("TextButton", btnRow)
    cancelBtn.Size = UDim2.new(0.5, -4, 1, 0)
    cancelBtn.BackgroundColor3 = Config.Colors.Card
    cancelBtn.Text = "❌ BATAL"
    cancelBtn.TextColor3 = Config.Colors.Text
    cancelBtn.Font = Config.Fonts.Title
    cancelBtn.TextSize = 11
    cancelBtn.BorderSizePixel = 0
    cancelBtn.ZIndex = 903
    Utils.corner(cancelBtn, Config.Sizes.RadiusSmall)
    
    cancelBtn.MouseButton1Click:Connect(function()
        overlay:Destroy()
    end)
    
    okBtn.MouseButton1Click:Connect(function()
        local opts = {
            Url = "https://igr-backen.vercel.app/api/key/revoke",
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json",
                ["X-User-Id"] = tostring(LocalPlayer.UserId),
            },
            Body = HttpService:JSONEncode({
                key = keyData.key,
                deleteUser = false,
            }),
        }
        
        local ok, res = pcall(function() return request(opts) end)
        if ok and res then
            local decoded = HttpService:JSONDecode(res.Body)
            if decoded and decoded.ok then
                overlay:Destroy()
                notify("🗑️ Revoked", keyData.key, 3)
                if refreshCallback then refreshCallback() end
            end
        end
    end)
end

return KeyManagerWindow
