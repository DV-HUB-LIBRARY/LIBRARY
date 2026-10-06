local KeyManagerWindow = {}

local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = game.Players.LocalPlayer

local function makeDraggable(handle, target)
    local dragging = false
    local dragStart = nil
    local startPos = nil
    
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = target.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            target.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

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
    
    local header = Instance.new("Frame", modal)
    header.Size = UDim2.new(1, 0, 0, 32)
    header.BackgroundColor3 = Config.Colors.Topbar
    header.BorderSizePixel = 0
    header.ZIndex = 902
    Utils.corner(header, Config.Sizes.Radius)
    
    local headerPatch = Instance.new("Frame", header)
    headerPatch.Size = UDim2.new(0, 12, 0, 12)
    headerPatch.Position = UDim2.new(0, 0, 1, -12)
    headerPatch.BackgroundColor3 = Config.Colors.Topbar
    headerPatch.BorderSizePixel = 0
    headerPatch.ZIndex = 903
    
    local mTitle = Instance.new("TextLabel", header)
    mTitle.Size = UDim2.new(1, -60, 1, 0)
    mTitle.Position = UDim2.new(0, 12, 0, 0)
    mTitle.BackgroundTransparency = 1
    mTitle.Font = Config.Fonts.Title
    mTitle.Text = "➕ GENERATE KEY"
    mTitle.TextColor3 = Config.Colors.Accent
    mTitle.TextSize = 12
    mTitle.TextXAlignment = Enum.TextXAlignment.Left
    mTitle.ZIndex = 903
    
    local closeBtn = Instance.new("TextButton", header)
    closeBtn.Size = UDim2.new(0, 22, 0, 22)
    closeBtn.Position = UDim2.new(1, -28, 0.5, -11)
    closeBtn.BackgroundColor3 = Config.Colors.Danger
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Config.Colors.Text
    closeBtn.Font = Config.Fonts.Title
    closeBtn.TextSize = 11
    closeBtn.BorderSizePixel = 0
    closeBtn.ZIndex = 904
    Utils.corner(closeBtn, 5)
    closeBtn.MouseButton1Click:Connect(function()
        overlay:Destroy()
    end)
    
    makeDraggable(header, modal)
    makeDraggable(mTitle, modal)
    
    local contentFrame = Instance.new("Frame", modal)
    contentFrame.Size = UDim2.new(1, -24, 1, -80)
    contentFrame.Position = UDim2.new(0, 12, 0, 40)
    contentFrame.BackgroundTransparency = 1
    contentFrame.ZIndex = 902
    
    local cLayout = Instance.new("UIListLayout", contentFrame)
    cLayout.Padding = UDim.new(0, 6)
    cLayout.SortOrder = Enum.SortOrder.LayoutOrder
    
    local function makeInputRow(label, placeholder, default)
        local row = Instance.new("Frame", contentFrame)
        row.Size = UDim2.new(1, 0, 0, 30)
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
    durationLabel.Size = UDim2.new(1, 0, 0, 16)
    durationLabel.BackgroundTransparency = 1
    durationLabel.Font = Config.Fonts.Title
    durationLabel.Text = "⏱️ Duration:"
    durationLabel.TextColor3 = Config.Colors.Text
    durationLabel.TextSize = 10
    durationLabel.TextXAlignment = Enum.TextXAlignment.Left
    durationLabel.ZIndex = 903
    durationLabel.LayoutOrder = 4
    
    local durationPicker = modules.DurationPicker.new(contentFrame, {}, Config, Utils, nil)
    durationPicker.LayoutOrder = 5
    
    local btnRow = Instance.new("Frame", modal)
    btnRow.Size = UDim2.new(1, -24, 0, 32)
    btnRow.Position = UDim2.new(0, 12, 1, -40)
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
    genBtn.TextSize = 10
    genBtn.BorderSizePixel = 0
    genBtn.ZIndex = 903
    Utils.corner(genBtn, Config.Sizes.RadiusSmall)
    
    local cancelBtn = Instance.new("TextButton", btnRow)
    cancelBtn.Size = UDim2.new(0.5, -4, 1, 0)
    cancelBtn.BackgroundColor3 = Config.Colors.Card
    cancelBtn.Text = "❌ BATAL"
    cancelBtn.TextColor3 = Config.Colors.Text
    cancelBtn.Font = Config.Fonts.Title
    cancelBtn.TextSize = 10
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
