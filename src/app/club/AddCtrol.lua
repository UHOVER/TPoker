local AddCtrol = {}
local ClubCtrol = require("club.ClubCtrol")

AddCtrol.CLUB = "club"
AddCtrol.UNION_CLUB = "union_club"
AddCtrol.UNION = "union"


local ADD_TARGET = nil

function AddCtrol.setAddTarget( target )
	ADD_TARGET = target
end

function AddCtrol.getHolderText(  )
	local holderText = nil 	-- 提示文字
	if ADD_TARGET == AddCtrol.CLUB then
		-- str = "搜索俱乐部"
		holderText = "俱乐部名称/名片ID"
	elseif ADD_TARGET == AddCtrol.UNION then
		-- str = "搜索联盟"
		holderText = "联盟名称/名片ID"
	elseif ADD_TARGET == AddCtrol.UNION_CLUB or ADD_TARGET == "new" then
		-- str = "邀请加入联盟"
		holderText = "俱乐部名称/名片ID"
	end
	return holderText
end

function AddCtrol.searchStrFunc( searchStr, parent )
	if searchStr == nil or searchStr == "" then
		return
	else
		if not cc.LuaHelp:IsGameName(searchStr) or string.len(searchStr) > LEN_NAME then
			ViewCtrol.showTip({content = "俱乐部名称不能超过"..(LEN_NAME/3).."个汉字或"..LEN_NAME.."个字母、数字！"})
			return
		end
	end
	if ADD_TARGET == AddCtrol.CLUB or ADD_TARGET == AddCtrol.UNION_CLUB then
		AddCtrol.searchArea( "key", searchStr, parent)
	elseif ADD_TARGET == AddCtrol.UNION then
		AddCtrol.searchUnion( "key", searchStr, parent )
	end
end

function AddCtrol.searchCityFunc( searchId, parent )
	if ADD_TARGET == AddCtrol.CLUB or ADD_TARGET == AddCtrol.UNION_CLUB then
		AddCtrol.searchArea( "city", searchId, parent)
	elseif ADD_TARGET == AddCtrol.UNION then
		AddCtrol.searchUnion( "city", searchId, parent )
	end
end

-- 搜索俱乐部
function AddCtrol.searchArea( searchType, searchValue, parent )

	local function response( data )
		if data.code == 0 then
			if data.msg == "ok" then
				local searchList = require('club.SearchList')
				local layer = searchList:create()
				parent:addChild(layer)
				layer:createLayer(data.data, ADD_TARGET)
			elseif data.msg == "failed" then
				local contentStr = nil
				if ADD_TARGET == AddCtrol.CLUB or ADD_TARGET == AddCtrol.UNION_CLUB then
					contentStr = "俱乐部"
				elseif ADD_TARGET == AddCtrol.UNION then
					contentStr = "联盟"
				end
				ViewCtrol.showTip({title = contentStr.."不存在", content = "没有找到相关"..contentStr.."，请更换搜索条件再试。"})
			end
		end
	end
	local tabData = {}
	tabData["category"] = searchType
	tabData["user_id"] = Single:playerModel():getId()
	tabData["search_key"] = searchValue
	XMLHttp.requestHttp( PHP_CLUB_FIND, tabData, response, PHP_POST )
end

-- 搜索联盟
function AddCtrol.searchUnion( searchType, searchValue, parent )
	print("搜索联盟")
	local function response( data )
		dump(data)
		if data.code == 0 then
			if data.msg == "success" then
				local searchList = require('club.SearchList')
				local layer = searchList:create()
				parent:addChild(layer)
				layer:createLayer(data.data, AddCtrol.UNION)
			elseif data.msg == "failed" then
				ViewCtrol.showTip({title = "联盟不存在", content = "没有找到相关联盟，请更换搜索条件再试。"})
			end
		end
	end
	local tabData = {}
	tabData["category"] = searchType
	tabData["club_id"] = ClubCtrol.getClubInfo().id
	tabData["search_key"] = searchValue
	XMLHttp.requestHttp("search_union", tabData, response, PHP_POST)
end

return AddCtrol