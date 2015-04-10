application =
{

	content =
	{
		width = 384,
		height = 512, 
		yAlign = "top",
		scale = "letterBox",
		fps = 60,
		
		--[[
		imageSuffix =
		{
			    ["@2x"] = 2,
		},
		--]]
	},

	--[[
	-- Push notifications
	notification =
	{
		iphone =
		{
			types =
			{
				"badge", "sound", "alert", "newsstand"
			}
		}
	},
	--]]    
}
