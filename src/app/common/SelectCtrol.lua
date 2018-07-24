local SelectCtrol = {}
local UnionCtrol = require("union.UnionCtrol")

local unionMem = {}
local clubList = {}

function SelectCtrol.dataStatUnionMember( funback )
	local function response( data )
		dump(data.data)
		if data.data then
			SelectCtrol.buildUnionMem(data.data)
			funback()
		end
	end
	local tabData = {}
	tabData["union_id"] = UnionCtrol.getUnionInfo()["union_id"]
	XMLHttp.requestHttp("union_club_list", tabData, response, PHP_POST)
end

function SelectCtrol.buildUnionMem( data )
	unionMem = {}
	local selectTab = SelectCtrol.getSelectClub()
	dump(selectTab)
	for k,v in pairs(data) do
		local tmp = {}
		tmp = v
		tmp["showType"] = 0
		tmp["check"] = 0
		if next(selectTab) ~= nil then
			for i,val in ipairs(selectTab) do
				if tonumber(v.club_id) == tonumber(val) then
					tmp["check"] = 1
				end
			end
		end
		unionMem[#unionMem+1] = tmp
	end
end

function SelectCtrol.getUnionMem(  )
	return unionMem
end

function SelectCtrol.setSelectClub( data )
	clubList = {}
	clubList = data
end

function SelectCtrol.getSelectClub(  )
	return clubList
end

return SelectCtrol