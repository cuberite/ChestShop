

function Initialize(Plugin)
	PLUGIN = Plugin
	PLUGIN:SetName("ChestShop")
	PLUGIN:SetVersion("1")
	
	cPluginManager.AddHook(cPluginManager.HOOK_PLAYER_RIGHT_CLICK,    OnPlayerRightClick)
	cPluginManager.AddHook(cPluginManager.HOOK_PLAYER_BREAKING_BLOCK, OnPlayerBreakingBlock)
	cPluginManager.AddHook(cPluginManager.HOOK_UPDATING_SIGN,         OnUpdatingSign)

	PluginManager = cRoot:Get():GetPluginManager()
	COINY = PluginManager:GetPlugin("Coiny");
	HANDY = PluginManager:GetPlugin("Handy");
	PluginManager:BindCommand("/12", "dniwe", setest, "Opens up a window using plugin API");
	PluginManager:BindCommand("/13", "dniwe", lala,   "Opens up a window using plugin API");
	LOG("Initializing ChestShop v1 Demo")
	return true;
end



function OnPlayerRightClick(Player, BlockX, BlockY, BlockZ, BlockFace, CursorX, CursorY, CursorZ)
	World = Player:GetWorld()
	lox= Player:GetName()
	local Item = cItem();
	local Itemf = cItem();
	-- Player:SendMessage(cChatColor.LightGreen .. 'X=' .. BlockX .. ' y=' .. BlockY .. ' Z=' .. BlockZ .. ' BlockFace=' .. BlockFace .. ' ')
	Read, Line1, Line2, Line3, Line4 = World:GetSignLines(BlockX, BlockY, BlockZ, "", "", "", "")

	local split = StringSplit(Line3, "\:");
	if (#split == 2) then
		buy(Split, Player, BlockX, BlockY, BlockZ)
	end

	return false
end




function OnPlayerBreakingBlock(Player, BlockX, BlockY, BlockZ, BlockFace, BlockType, BlockMeta)
	World = Player:GetWorld()
	local Item = cItem();
	local Itemf = cItem();
	-- Player:SendMessage(cChatColor.LightGreen .. 'X=' .. BlockX .. ' y=' .. BlockY .. ' Z=' .. BlockZ .. ' BlockFace=' .. BlockFace .. ' ')	
	Read, Line1, Line2, Line3, Line4 = World:GetSignLines(BlockX, BlockY, BlockZ, "", "", "", "")

	local split = StringSplit(Line3, "\:");
	if (#split == 2) then
		sell(Split, Player, BlockX, BlockY, BlockZ)
		return true
	end

	return false
end





function OnUpdatingSign(World, BlockX, BlockY, BlockZ, Line1, Line2, Line3, Line4, Player)
	------------------------PROTECT------------------
	local Server = cRoot:Get():GetServer()
	if (not(Player:HasPermission("adminshop.create")) then
		local split = StringSplit(Line3, "\:");
		if (#split == 2) then
			local costfr = tonumber(split[1])
			local costto = tonumber(split[2])
			Line3 = (costfr .. "//" .. costto)
		end
		return false, Line1, Line2, Line3, Line4;
	end
	
	if (Player == nil) then
		return false;
	end
	-----------------------------------PROTECT END----------

	local split = StringSplit(Line3, "\:");
	if (#split == 2) then
		if (Line1 ~= Player:GetName()) then
			Line1 = Player:GetName()
		end
		local costfr = tonumber(split[1])
		local costto = tonumber(split[2])
		Line3 = (costfr .. ":" .. costto)
		local splittwo = StringSplit(Line4, "\:");
		if (#splittwo ~= 2) then
			local idiitemfr = tonumber(splittwo[1])
			Line4 = (idiitemfr .. ":0")
		end
		-- Line4 = ItemTypeToString(Line4)
		Player:SendMessage(cChatColor.LightGreen  .. '[AdminShop] Created!')
	end
	return false, Line1, Line2, Line3, Line4;
end










function buy(Split, Player, BlockX, BlockY, BlockZ)
	World = Player:GetWorld()
	Read, Line1, Line2, Line3, Line4 = World:GetSignLines(BlockX, BlockY, BlockZ, "", "", "", "")

	local split = StringSplit(Line3, "\:");
	if (#split == 2) then
		local costfr = tonumber(split[1])
		local costto = tonumber(split[2])	
		if (costfr <= 0) then
			Player:SendMessage(cChatColor.LightGreen  .. '[AdminShop] ' .. cChatColor.Red .. 'You can not buy or sell it here!')
			return true
		end
	end

	local Inventory = Player:GetInventory()
	local emptyslots = -4
	for i = 0, cInventory.invNumSlots - 1 do
		if (Inventory:GetSlot(i).m_ItemType == -1) then
			emptyslots = emptyslots + 1
		end
	end

	if (emptyslots < 1) then
		Player:SendMessage(cChatColor.LightGreen  .. '[AdminShop] ' .. cChatColor.Red .. 'You do not have space in inventory!')
		return true
	end
	local Item = cItem();
	local FoundItem = StringToItem(Line4, Item);
	Item.m_ItemCount = Line2;
	CRR = COINY:Call("TransferMoney", Player:GetName(), Line1, split[1])
	if (CRR == -1) then
		Player:SendMessage(cChatColor.LightGreen  .. '[AdminShop] ' .. cChatColor.Red .. 'You do not have enough money!')
	else
		Player:GetInventory():AddItem(cItem(Item))
		Player:SendMessage(cChatColor.LightGreen  .. '[AdminShop] ' .. cChatColor.White .. 'You paid "' .. CRR .. '" coins to ' ..Line1..' for '.. Line2..' items')
		MA = COINY:Call("GetMoney", Player:GetName())
		Player:SendMessage(cChatColor.LightGreen  .. '[AdminShop] ' .. cChatColor.White .. 'Now you have "' .. MA .. '" coins')
	end;
	return true;
end







function sell(Split, Player, BlockX, BlockY, BlockZ)
	World = Player:GetWorld()
	lox = Player:GetName()
	Read, Line1, Line2, Line3, Line4 = World:GetSignLines(BlockX, BlockY, BlockZ, "", "", "", "")

	local split = StringSplit(Line3, "\:");
	if (#split == 2) then
		local costfr = tonumber(split[1])
		local costto = tonumber(split[2])	
		
		if (costto <= 0) then
			Player:SendMessage(cChatColor.LightGreen  .. '[AdminShop] ' .. cChatColor.Red .. 'You can not buy or sell it here!')
			return true
		end
	end

	local Inventory = Player:GetInventory();
	----------------------------------
	local Itemf = cItem();
	local FoundItem = StringToItem(Line4, Itemf);

	iditem = ItemToString(cItem(Itemf))
	--------------------------------------------

	-- iditem = tonumber(Line4)
	itemcont = tonumber(Line2)
	opapa = Inventory:HowManyItems(cItem(Itemf))

	if (opapa < itemcont) then
		Player:SendMessage(cChatColor.LightGreen  .. '[AdminShop] ' .. cChatColor.Red .. 'You do not have neede items!')
		return true
	end

	CRR = COINY:Call("TransferMoney", Line1, Player:GetName(), split[2])
	if (CRR == -1) then
		Player:SendMessage(cChatColor.LightGreen  .. '[AdminShop] ' .. cChatColor.Red .. 'You do not have enough money!')
	else
		-- iditem = tonumber(Line4)
		local Inventory = Player:GetInventory();
		opapa = Inventory:HowManyItems(cItem(Itemf))
		if (opapa <= 0) then
			return true
		end

		local HasRemoved = false;
		for idx = 0, cInventory.invNumSlots - 1 do
			if (not(HasRemoved) and (Inventory:GetSlot(idx).m_ItemType == Itemf.m_ItemType)) then
				local DiamondsLeft = Inventory:GetSlot(idx);
				if DiamondsLeft.m_ItemCount >= itemcont then
					DiamondsLeft.m_ItemCount = DiamondsLeft.m_ItemCount - Line2;
				else
					Player:SendMessage(cChatColor.LightGreen  .. '[AdminShop] ' .. cChatColor.Red .. 'You do not have neede items! Please, stack you items!')
					return true
				end
				if (DiamondsLeft.m_ItemCount <= 0) then
					Inventory:SetSlot(idx, cItem());
					HasRemoved = true;
				else
					Inventory:SetSlot(idx, DiamondsLeft);
					HasRemoved = true;
				end
			end
		end

		Player:SendMessage(cChatColor.LightGreen  .. '[AdminShop] ' .. cChatColor.White .. 'You sold a player "' ..Line1.. '" items with ID#' ..Line4..' for '..CRR..' coins')
		MA = COINY:Call("GetMoney", Player:GetName())
		Player:SendMessage(cChatColor.LightGreen  .. '[AdminShop] ' .. cChatColor.White .. 'Now you have "' .. MA .. '" coins')
	end;
	return true;
end








function setest(Split,Player)
	opa = Player:GetInventory()
	opapa=opa:HowManyItems(cItem(2))

	Player:SendMessage(cChatColor.Red .. "bilo " .. opapa)

	local Inventory = Player:GetInventory();
		if (opapa <= 0) then
		return true
	end

	local HasRemoved = false;
	for idx = 0, cInventory.invNumSlots - 1 do
		if (not(HasRemoved) and (Inventory:GetSlot(idx).m_ItemType == 2)) then
			local DiamondsLeft = Inventory:GetSlot(idx);
			DiamondsLeft.m_ItemCount = DiamondsLeft.m_ItemCount - 1;
			if DiamondsLeft.m_ItemCount <= 0 then
				Inventory:SetSlot(idx, cItem());
				HasRemoved = true;
			else
				Inventory:SetSlot(idx, DiamondsLeft);
				HasRemoved = true;
			end
		end
	end
	opapa = opa:HowManyItems(cItem(E_ITEM_DIAMOND))
	Player:SendMessage(cChatColor.Red .. "stalo " .. opapa)
	return true
end





function lala(Split,Player)
	local Item = cItem();
	local FoundItem = StringToItem(Split[2], Item);

	-- lala = ItemToString(cItem(Item))
	lala = ItemToFullString(cItem(Item))

	-- opapa = opa:HowManyCanFit(cItem(E_ITEM_GRASS), emptyslottopapa = tonumber(opapa)
	Player:SendMessage(cChatColor.Red .. "LLLLLLLL " .. lala)
	return true
end





function lala22(Split,Player)
	local Wool = cItem(Split[2], 1, Split[3]);
	Player:GetInventory():SetArmorSlot(0, Wool);
	Player:GetInventory():SetArmorSlot(1, Wool);
	Player:GetInventory():SetArmorSlot(2, Wool);
	Player:GetInventory():SetArmorSlot(3, Wool);
	Player:SendMessage("You have been bluewooled :)");
	return true;
end





function lala2(Split,Player)
	Inventory = Player:GetInventory()
	local emptyslots=-4
	for i = 0, cInventory.invNumSlots - 1 do
		if (Inventory:GetSlot(i).m_ItemType == -1) then
			emptyslots = emptyslots + 1
		end
	end
	Player:SendMessage(cChatColor.Red .. "PUSTO " .. emptyslots)
	return true
end




