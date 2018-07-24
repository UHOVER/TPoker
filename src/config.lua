UPDATE_VERSION = "V11"

-- 0 - disable debug info, 1 - less debug info, 2 - verbose debug info
DEBUG = 2

-- use framework, will disable all deprecated API, false - use legacy API
CC_USE_FRAMEWORK = true

-- show FPS on screen
CC_SHOW_FPS = false

-- disable create unexpected global variable
CC_DISABLE_GLOBAL = true

-- for module display
-- 640 960  0.666、640 1136  0.563、750 1334  0.562、1080 1920  0.5625
CC_DESIGN_RESOLUTION = {
    width = 750,
    height = 1334,
    autoscale = "SHOW_ALL",
    callback = function(framesize)
        local ratio = framesize.width / framesize.height
        -- if ratio <= 1.34 then
        --     -- iPad 768*1024(1536*2048) is 4:3 screen
        --     return {autoscale = "SHOW_ALL"}
        -- end

        if ratio <= 320 / 480 then
            return {autoscale = "FIXED_WIDTH"}
        else
            return {autoscale = "SHOW_ALL"}
        end
    end
}