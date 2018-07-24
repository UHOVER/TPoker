local DZSchedule = {}


function DZSchedule.runSchedule(funcBack, time, sprite)
    local unscheduler = nil
    local scheduler = cc.Director:getInstance():getScheduler()

    local function handleDestory(event)
        if event == 'exit' then
            scheduler:unscheduleScriptEntry(unscheduler)
            unscheduler = nil
        elseif event == 'enter' then
            unscheduler = scheduler:scheduleScriptFunc(funcBack, time, false)
        end
    end

    local node = cc.Node:create()
    node:registerScriptHandler(handleDestory)

    if sprite == nil then
        sprite = cc.Director:getInstance():getRunningScene()
    end
    sprite:addChild(node)

    return node
end



--调用一次
--
function DZSchedule.schedulerOnce(ctime, scheduleBack)
    local tscheduler = cc.Director:getInstance():getScheduler()
    local scheduleId = nil

    local function callBack()
        if scheduleId then
            tscheduler:unscheduleScriptEntry(scheduleId)
            scheduleId = nil
            scheduleBack()
        end
    end

    scheduleId = tscheduler:scheduleScriptFunc(callBack, ctime, false)
end



--全局时间
--
function DZSchedule.scheduleGlobal(ctime, scheduleBack)
   local tscheduler = cc.Director:getInstance():getScheduler()
    local scheduleId = nil

    local function callBack()
        scheduleBack()
    end

    scheduleId = tscheduler:scheduleScriptFunc(callBack, ctime, false) 
    return scheduleId
end


return DZSchedule