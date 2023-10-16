-- Madonox
-- 2023

--[[

Tip module
This module aims to provide developers with a simple and easy way to add in interactive visuals to their game

]]

local RunService = game:GetService("RunService")
assert(RunService:IsClient(),"The Tip module can only be used on the client!")

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Player = game:GetService("Players").LocalPlayer

local Tip = {
	Notice = {};
	Hint = {};
}

-- Initialize basic constants and variables

local Character = Player.Character or workspace:WaitForChild(Player.Name)
local RootPart = Character:WaitForChild("HumanoidRootPart")

local function Create(name,values)
	local i = Instance.new(name)
	for k,v in values do
		i[k] = v
	end
	return i
end

local function ReturnInsert(tab,v)
	local point = #tab + 1
	tab[point] = v
	return point
end

local CleanupFunctions;
local function RecursiveClean(data)
	for _,v in data do
		local cleaner = CleanupFunctions[typeof(v)]
		if cleaner then
			cleaner(v)
		end
	end
end
CleanupFunctions = {
	["RBXScriptConnection"] = function(v)
		v:Disconnect()
	end,
	["table"] = function(v)
		RecursiveClean(v)
		table.clear(v)
	end,
}

local BEAM_TEMPLATE = Create("Beam",{
	LightEmission = 1;
	LightInfluence = 0;
	Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0,0),NumberSequenceKeypoint.new(1,1)});
	Width0 = .1;
	Width1 = .1;
})

local NOTICE_TEMPLATE = Create("Part",{
	Size = Vector3.new(.001,.001,.001);
	Transparency = 1;
	Anchored = true;
	CanCollide = false;
	CastShadow = false;
	Massless = true;
	CanQuery = false;
	CanTouch = false;
})
Create("BillboardGui",{
	Size = UDim2.new(1,0,1,0);
	LightInfluence = 0;
	Parent = NOTICE_TEMPLATE;
})

local HINT_UI = Create("ScreenGui",{
	Name = "HintUI";
	ResetOnSpawn = false;
})
local HINT_CONTAINER = Create("Frame",{
	BackgroundTransparency = 1;
	AnchorPoint = Vector2.new(.5,1);
	Size = UDim2.new(.3,0,.4,0);
	Position = UDim2.new(.5,0,.875,0);
	Parent = HINT_UI;
})
Create("UIListLayout",{
	HorizontalAlignment = Enum.HorizontalAlignment.Center;
	VerticalAlignment = Enum.VerticalAlignment.Bottom;
	Parent = HINT_CONTAINER;
})
local HINT_TEMPLATE = Create("TextLabel",{
	Size = UDim2.new(1,0,.15,0);
	BackgroundTransparency = 1;
	TextColor3 = Color3.new(1,1,1);
	TextScaled = true;
	TextTransparency = 1;
})
HINT_UI.Parent = Player:WaitForChild("PlayerGui")

-- Static connections / steps

local RenderSubscriptions = {}

local function SubscribeRender(call)
	local point = ReturnInsert(RenderSubscriptions,call)
	return function()
		table.remove(RenderSubscriptions,point)
	end
end

Player.CharacterAdded:Connect(function()
	Character = Player.Character or workspace:WaitForChild(Player.Name)
	RootPart = Character:WaitForChild("HumanoidRootPart")
end)
RunService.RenderStepped:Connect(function()
	if RootPart then
		for _,subscription in RenderSubscriptions do
			subscription()
		end
	end
end)

-- Code for Hint

local function ShowHint(message,info)
	for _,hint in HINT_CONTAINER:GetChildren() do
		if hint:IsA("TextLabel") then
			hint.LayoutOrder += 1
		end
	end
	local newHint = HINT_TEMPLATE:Clone()
	newHint.Text = message
	local fadeTween = TweenService:Create(newHint,info,{
		TextTransparency = 0;
	})
	fadeTween.Completed:Once(function()
		fadeTween:Destroy()
	end)
	fadeTween:Play()
	newHint.Parent = HINT_CONTAINER
	return newHint
end
local function HideHint(object,info)
	local fadeTween = TweenService:Create(object,info,{
		TextTransparency = 1;
	})
	fadeTween.Completed:Once(function()
		fadeTween:Destroy()
		object:Destroy()
	end)
	fadeTween:Play()
end

Tip.Hint.__index = Tip.Hint
function Tip.Hint.new()
	local self = setmetatable({
		Position = Vector3.new();
		Message = "";
		Radius = 0;
		FadeInfo = TweenInfo.new(1);
		Inputs = {};
	},Tip.Hint)
	self.InputConnection = UserInputService.InputBegan:Connect(function(input,process)
		if not process and self.HintObject then
			for _,call in self.Inputs do
				call(input)
			end
		end
	end)
	return self
end

function Tip.Hint:SetPosition(position)
	self.Position = position
end
function Tip.Hint:SetRadius(radius)
	self.Radius = radius
end
function Tip.Hint:SetMessage(message)
	self.Message = message
end
function Tip.Hint:SetFadeTime(fadeTime)
	self.FadeInfo.Time = fadeTime
end
function Tip.Hint:InputBegan(callback)
	table.insert(self.Inputs,callback)
end

function Tip.Hint:Start()
	if not self.FrameListener then
		local point = self.Position
		local distance = self.Radius
		local message = self.Message
		local info = self.FadeInfo
		self.FrameListener = SubscribeRender(function()
			if (RootPart.Position-point).Magnitude <= distance then
				if self.HintObject == nil then
					self.HintObject = ShowHint(message,info)
				end
				return
			end
			
			local object = self.HintObject
			if object then
				HideHint(object,info)
				self.HintObject = nil
			end
		end)
	end
end

function Tip.Hint:Stop()
	if self.FrameListener then
		self.FrameListener()
		self.FrameListener = nil
	end
	
	if self.HideObject then
		HideHint(self.HintObject,self.FadeInfo)
		self.HintObject = nil
	end
end

function Tip.Hint:Destroy()
	self:Stop()
	RecursiveClean(self)
	table.clear(self)
	setmetatable(self,nil)
end

-- Code for Notice
Tip.Notice.__index = Tip.Notice

function Tip.Notice.new()
	local origin = Create("Part",{
		Size = Vector3.new(.001,.001,.001);
		Transparency = 1;
		Anchored = true;
		CanCollide = false;
		CastShadow = false;
		Massless = true;
		CanQuery = false;
		CanTouch = false;
	})
	local self = setmetatable({
		Origin = origin;
		Indicator = NOTICE_TEMPLATE:Clone()
	},Tip.Notice)
	local attachment = Create("Attachment",{
		Parent = origin
	})
	local beam = BEAM_TEMPLATE:Clone()
	beam.Attachment0 = attachment
	beam.Parent = origin
	return self
end
function Tip.Notice:ChangeUI(new)
	local indicator = self.Indicator
	indicator:FindFirstChildOfClass("BillboardGui"):Destroy()
	new.Parent = indicator
end

return Tip
