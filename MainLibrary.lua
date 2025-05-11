local Library = {}

-- ScreenGui to hold all UI elements
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CustomGUILibrary"
ScreenGui.ResetOnSpawn = false -- Keep UI persistent on respawn
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling -- Or Global, depending on desired layering

-- Function to create the main draggable window
function Library:CreateWindow(title)
    local MainWindow = Instance.new("Frame")
    MainWindow.Name = "MainWindow"
    MainWindow.Size = UDim2.new(0, 400, 0, 300) -- Default size
    MainWindow.Position = UDim2.new(0.5, -200, 0.5, -150) -- Centered
    MainWindow.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    MainWindow.BorderColor3 = Color3.fromRGB(50, 50, 50)
    MainWindow.BorderSizePixel = 2
    MainWindow.Active = true -- Allows dragging
    MainWindow.Draggable = true
    MainWindow.Selectable = true
    MainWindow.ClipsDescendants = true
    MainWindow.Parent = ScreenGui

    local TitleBar = Instance.new("Frame")
    TitleBar.Name = "TitleBar"
    TitleBar.Size = UDim2.new(1, 0, 0, 30)
    TitleBar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    TitleBar.BorderColor3 = Color3.fromRGB(60, 60, 60)
    TitleBar.BorderSizePixel = 1
    TitleBar.Parent = MainWindow

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Name = "TitleLabel"
    TitleLabel.Size = UDim2.new(1, -30, 1, 0) -- Leave space for a close button
    TitleLabel.Text = title or "Custom UI"
    TitleLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
    TitleLabel.Font = Enum.Font.SourceSansBold
    TitleLabel.TextSize = 18
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Position = UDim2.new(0, 10, 0, 0)
    TitleLabel.Parent = TitleBar
    
    -- Placeholder for a close button
    local CloseButton = Instance.new("TextButton")
    CloseButton.Name = "CloseButton"
    CloseButton.Size = UDim2.new(0, 25, 0, 25)
    CloseButton.Position = UDim2.new(1, -28, 0.5, -12.5) -- Anchor to top right
    CloseButton.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
    CloseButton.BorderColor3 = Color3.fromRGB(150, 40, 40)
    CloseButton.Text = "X"
    CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseButton.Font = Enum.Font.SourceSansBold
    CloseButton.TextSize = 16
    CloseButton.Parent = TitleBar
    
    CloseButton.MouseButton1Click:Connect(function()
        MainWindow:Destroy() -- Or ScreenGui:Destroy() if this is the only window
    end)

    local TabContainer = Instance.new("Frame")
    TabContainer.Name = "TabContainer"
    TabContainer.Size = UDim2.new(1, 0, 0, 30)
    TabContainer.Position = UDim2.new(0, 0, 0, 30) -- Below title bar
    TabContainer.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    TabContainer.Parent = MainWindow

    local ContentContainer = Instance.new("Frame")
    ContentContainer.Name = "ContentContainer"
    ContentContainer.Size = UDim2.new(1, 0, 1, -60) -- Below tab container
    ContentContainer.Position = UDim2.new(0, 0, 0, 60)
    ContentContainer.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    ContentContainer.ClipsDescendants = true
    ContentContainer.Parent = MainWindow

    local windowApi = {}
    windowApi.Tabs = {}
    windowApi.UI = MainWindow -- Expose the main frame if needed

    function windowApi:AddTab(tabName)
        local TabButton = Instance.new("TextButton")
        -- ... (Styling and positioning for TabButton)
        TabButton.Name = tabName
        TabButton.Text = tabName
        TabButton.Size = UDim2.new(0, 100, 1, 0) -- Example size
        TabButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        TabButton.TextColor3 = Color3.fromRGB(200, 200, 200)
        TabButton.Parent = TabContainer
        -- TODO: Add layout for multiple tabs (e.g., UIListLayout)

        local TabContent = Instance.new("Frame")
        TabContent.Name = tabName .. "Content"
        TabContent.Size = UDim2.new(1, 0, 1, 0)
        TabContent.BackgroundTransparency = 1
        TabContent.Visible = false -- Only one tab content visible at a time
        TabContent.Parent = ContentContainer

        local tabApi = {}
        tabApi.UI = TabContent

        function tabApi:AddButton(buttonText)
            local Button = Instance.new("TextButton")
            Button.Name = buttonText .. "Button"
            Button.Text = buttonText
            Button.Size = UDim2.new(0, 150, 0, 30) -- Example size
            Button.Position = UDim2.new(0, 10, 0, 10 + (#self.UI:GetChildren() * 35)) -- Basic layout
            Button.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
            Button.TextColor3 = Color3.fromRGB(230, 230, 230)
            Button.Parent = TabContent
            -- TODO: Add more styling and click event handling
            return Button -- Return the button instance for further customization
        end
        
        -- Placeholder for other elements like AddLabel, AddTextbox, etc.

        TabButton.MouseButton1Click:Connect(function()
            -- Hide all other tab contents
            for _, child in ipairs(ContentContainer:GetChildren()) do
                if child:IsA("Frame") then
                    child.Visible = false
                end
            end
            -- Show this tab's content
            TabContent.Visible = true
            -- TODO: Update tab button appearance (active state)
        end)
        
        -- Activate the first tab by default
        if #windowApi.Tabs == 0 then
            TabContent.Visible = true
            -- TODO: Set first tab button to active state
        end

        table.insert(windowApi.Tabs, tabApi)
        return tabApi
    end
    
    -- Make the ScreenGui parented to CoreGui if this script runs in a context where that's appropriate
    -- For now, let's assume it will be parented by the calling script or environment.
    -- game:GetService("CoreGui"):FindFirstChild(ScreenGui.Name) and game:GetService("CoreGui"):FindFirstChild(ScreenGui.Name):Destroy()
    -- ScreenGui.Parent = game:GetService("CoreGui") 

    return windowApi
end

-- Function to make the ScreenGui visible and set its parent
-- This should be called by the script that loads this library
function Library:Initialize(parentGui)
    if parentGui then
        ScreenGui.Parent = parentGui
    else
        -- Attempt to parent to CoreGui, common for standalone libraries
        -- Ensure no duplicates if script is run multiple times
        local existingGui = game:GetService("CoreGui"):FindFirstChild(ScreenGui.Name)
        if existingGui then
            existingGui:Destroy()
        end
        ScreenGui.Parent = game:GetService("CoreGui")
    end
end


-- Example Usage (comment out or remove when used as a library)
--[[
local MyGUI = Library:CreateWindow("My Awesome UI")
local Tab1 = MyGUI:AddTab("Main")
local Button1 = Tab1:AddButton("Click Me!")
Button1.MouseButton1Click:Connect(function()
    print("Button1 Clicked!")
end)

local Tab2 = MyGUI:AddTab("Settings")
local Button2 = Tab2:AddButton("Option 1")

Library:Initialize() -- Call this to show the GUI
]]

return Library
