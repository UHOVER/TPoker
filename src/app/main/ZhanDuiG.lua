local ZhanDuiG = {}

--aos 1,增加 2,删除
--gData 全局数据 team_id, club_id
function ZhanDuiG.showZhanDui(aos, gData)
	print("hhhaaooss")
	if(aos == 1) then
		local function response(tData)
	        print("addddd")
	        -- dump(tData)

	        if(tData == nil) then
	        	ViewCtrol.popHint({popType = 1, bgSize = cc.size(display.width-100, 300), content = "没有可以添加的战队成员",
    			sureFunBack = function()
        		
    			end})
	            
	            return
	        end
	        
	        local mDataArr = {}
	        --处理data
	        local idx = 1
	        for k, v in pairs(tData) do  
	            print("kk="..k)
	            local cellDataG = {}
	            cellDataG.idx = idx
	            cellDataG.type = "g"
	            cellDataG.name = string.upper(k)
	            cellDataG.first = 1
	            cellDataG.key = string.upper(k)
	            cellDataG.key_byte = string.byte(string.upper(k))
	            mDataArr[idx] = cellDataG

	            idx = idx + 1

	            for i = 1, #v do 
	                print("----")
	                -- dump(v)
	                local cellDataC = {}
	                cellDataC.first = 2
	                cellDataC.key = string.upper(k)
	                cellDataC.key_byte = string.byte(string.upper(k))
	                cellDataC.idx = idx--cell索引
	                cellDataC.type = "c"--显示模式
	                cellDataC.name = v[i].user_name
	                cellDataC.head_img = v[i].headimg
	                cellDataC.id = v[i].uid--用户玩家id
	                cellDataC.no = v[i].u_no--用户玩家编号
	                cellDataC.isS = 0--是否被选中0没选中 1选中
	            	cellDataC.exist_team = v[i].exist_team
	                mDataArr[idx] = cellDataC
	                idx = idx + 1
	            end 
	        end 

	        
	        print("wccccccc---")
	        mDataArr = ZhanDuiG.sortTab(mDataArr)
	        for i,v in ipairs(mDataArr) do
	        	mDataArr[i].idx = i
	        end
	        -- dump(mDataArr)

	        print("增加战队成员")
	        local testly = require('main.ZhanDuiAS'):create(mDataArr, 1, gData)
	        cc.Director:getInstance():getRunningScene():addChild(testly, StringUtils.getMaxZOrder(runScene))
	    end

	    local tab = {}
	    tab['team_id'] = gData.team_id
	    tab['club_id'] = gData.club_id
	    MainCtrol.filterNet("clubUserteamList", tab, response, PHP_POST)
	elseif(aos == 2) then

		local function response(tData)
	        print("assssss")
	        -- dump(tData)
	        if(tData == nil) then
	            return
	        end
	        
	        local mDataArr = {}
	        --处理data
	        local idx = 1
	        for k, v in pairs(tData) do  
	            print("kk="..k)
	            local cellDataG = {}
	            cellDataG.idx = idx
	            cellDataG.type = "g"
	            cellDataG.name = string.upper(k)
	            cellDataG.first = 1
	            cellDataG.key = string.upper(k)
	            cellDataG.key_byte = string.byte(string.upper(k))
	            mDataArr[idx] = cellDataG

	            idx = idx + 1

	            for i = 1, #v do
	                print("----")
	                -- dump(v)
	                local cellDataC = {}
	                cellDataC.first = 2
	                cellDataC.key = string.upper(k)
	                cellDataC.key_byte = string.byte(string.upper(k))

	                cellDataC.idx = idx--cell索引
	                cellDataC.type = "c"--显示模式
	                cellDataC.name = v[i].user_name
	                cellDataC.head_img = v[i].headimg
	                cellDataC.id = v[i].uid--用户玩家id
	                cellDataC.no = v[i].u_no--用户玩家编号
	                cellDataC.team_leader = v[i].team_leader--是否是队长
	                cellDataC.isS = 0--是否被选中0没选中 1选中
	            
	                mDataArr[idx] = cellDataC
	                idx = idx + 1
	            end 
	        end
	        
	        print("wccccccc---")
	        mDataArr = ZhanDuiG.sortTab(mDataArr)
	        for i,v in ipairs(mDataArr) do
	        	mDataArr[i].idx = i
	        end
	        -- dump(mDataArr)

	        print("减少战队成员")
	        local testly = require('main.ZhanDuiAS'):create(mDataArr, 2, gData)
	        cc.Director:getInstance():getRunningScene():addChild(testly, StringUtils.getMaxZOrder(runScene))
	    end

	    local tab = {}
	    tab['team_id'] = gData.team_id
	    MainCtrol.filterNet("clubteamList", tab, response, PHP_POST)
	end
end

function ZhanDuiG.sortTab( data )
	local tab = {}
	local tmpTab1 = {}
	local tmpTab2 = {}

	table.sort(data, function ( a, b )
		if a.key_byte == b.key_byte then
			return a.first < b.first
		else
			return a.key_byte < b.key_byte
		end
	end)
	for k,v in pairs(data) do
		if v.key == "#" then
			tmpTab1[#tmpTab1+1] = v
		else
			tmpTab2[#tmpTab2+1] = v
		end
		if k == #data then
			if #tmpTab1 == 0 then
				tab = tmpTab2
			else
				for k1,v1 in pairs(tmpTab1) do
					tmpTab2[#tmpTab2+1] = v1
					if k1 == #tmpTab1 then
						tab = tmpTab2
					end
				end
			end
		end
	end

	return tab
end

return ZhanDuiG